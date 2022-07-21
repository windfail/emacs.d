;;; griffon --- my emacs setups
;;; Commentary:
;;; Code:

;;(require-package 'smart-tabs-mode )
;;(smart-tabs-insinuate 'c 'c++)
(require 'gtags)

(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "M-SPC") 'set-mark-command)
(global-set-key (kbd "M-c") 'execute-extended-command) ;M-x与系统截图冲突
(global-set-key [C-tab] 'next-buffer)
(global-set-key [f5] 'revert-buffer)
;;(global-set-key [f7] 'compile)
;;(global-set-key [f6] 'speedbar)
(global-set-key [C-S-iso-lefttab] 'previous-buffer)
;;(setq scheme-program-name "mit-scheme")
;;(fset 'perl-mode 'cperl-mode)

;;滚屏一次一行
(setq scroll-conservatively 3)
;;(setq inhibit-startup-screen t)
;;(setq scroll-bar-mode "right")

(put 'narrow-to-region 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

(setq c-default-style
      '( (java-mode . "java") (awk-mode . "awk") (python . "python") (other . "linux")))

;; C/C++语言风格
(defun my-c-mode-hook()
  "My C mode hook."
  (setq tab-width 4 ); tab width
  (setq indent-tabs-mode t)
  (c-toggle-auto-newline 1)
  ;;缩进风格
  (setq c-basic-offset 4)
  (setq comment-start "// ")
  (setq comment-end "")
  (c-set-offset 'inline-open 0))
(add-hook 'c-mode-hook 'my-c-mode-hook)
(add-hook 'c++-mode-hook 'my-c-mode-hook)

(defun ami-mds-dir-parse (dir)
  "Parse DIR, if is ami mds workspace, return list (basedir pkgname), otherwise return nil."
  (rx-let ((pack_rx (: (+ (not "/"))
                       (= 4 (+ (any "0-9")) ".")
                       (+ (any "0-9"))
                       (+ (not "/"))))
           (total_rx (: (group (* nonl))
                        "/workspace/source/"
                        (group (* (not "/") ))
                        "/data/"
                        (* nonl))))
    (when (string-match (rx total_rx) dir)
      (list (match-string 1 dir) (match-string 2 dir)))))
(defun lnv-compile ()
  "Compile command for lenovo bmc project."
  (interactive )
  (let ((bmc-dir (ami-mds-dir-parse (buffer-file-name))))
    (when bmc-dir
      (let ((prjdir (car bmc-dir))
            (pkgname (nth 1 bmc-dir)))
        (compile (format "bash -c \"cd %s; sudo project.py -b %s.spx --rebuild\""
                         prjdir pkgname ))))))

(defun ami-parse-makefile (builddir pkgdir)
  "This function parse makefile in PKGDIR, find includ dirs in CFLAGS -I lines, replace SPXINC/TARGDIR with correct dir using  BUILDDIR ."
  (let ((dirlist (list (list "SPXINC"  (format "%s/include" builddir))
                       (list "TARGETDIR"  (format "%s/target" builddir))
                       (list "."  (format "%s/data" pkgdir))
                       (list nil  "")))
        (makefile (format "%s/data/Makefile" pkgdir))
        (deflist nil)
        (wflaglist nil)
        (inclist (list (format "%s/data" pkgdir)) )
        (gccstd nil)
        )
    (when (file-exists-p makefile)
      (with-temp-buffer
        (insert-file-contents makefile)
        (rx-let ((var_rx (: "$" (any "{(")
                            (group-n 1 (+ (not (any "${()}"))))
                            (any ")}")))
                 (cflag_rx (: line-start (* (any " \t")) "CFLAGS" (+ (any " \t+="))
                              (or (: "-I"
                                     (opt var_rx)
                                     (opt (group-n 2 (: ".")))
                                     (opt (group-n 7 (+ (not (any " \t#\r\n${}"))))) )
                                  (: "-D"
                                     (* "'" )
                                     (group-n 3 (+ (not (any "\t#\n\r${}'")))))
                                  (: "-W"
                                     (group-n 4 (+ (not (any " \t#\r\n${}")))))
                                  )))
                 (cxxflag_rx (: line-start (* (any " \t")) "CXXFLAGS" (+ (any " \t+="))
                                (: "-std="
                                   (group-n 5 (+ (not (any " \t#\n\r${}")))))))
                 (inc_rx (: line-start (* (any " \t")) "include" (+ (any " \t+="))
                            (group-n 6 (+ (not (any " \t#\n\r${}"))))
                            (* nonl)
                            "\n"
                            ))
                 (opts (or cflag_rx
                           cxxflag_rx
                           inc_rx
                           ))
                 )
          (while (re-search-forward (rx opts) nil t )
            (let* ((m_var (match-string 1))
                   (m_dot (match-string 2))
                   (m_sub (if m_var m_var m_dot))
                   (m_incdir (match-string 7))
                   (m_def (match-string 3))
                   (m_war (match-string 4))
                   (m_std (match-string 5))
                   (m_incf (match-string 6))
                   )
              (cond ((or m_incdir m_sub)
                     (let ((idir (format "%s%s"
                                         (nth 1 (assoc m_sub dirlist))
                                         (if m_incdir m_incdir "") )))
                       (setq inclist (cons idir inclist))))
                    (m_def
                     (setq deflist (cons m_def deflist)))
                    (m_war
                     (setq wflaglist (cons m_war wflaglist)))
                    (m_std
                     (setq gccstd m_std))
                    (m_incf
                     (insert-file-contents (format "%s/data/%s" pkgdir m_incf))
                     ;;(print (buffer-string))
                     )
                    )
              )
            ))))
    ;;(print inclist)
    ;;(print deflist)
    (list deflist (nreverse inclist) wflaglist gccstd)
    ))
(defun ami-parse-prjdef (prjheader)
  "This function parse PRJHEADER, change the defines into list of gcc definitions for providing to flycheck."
  (let ((ami-defs nil))
    (when (file-exists-p prjheader)
      (with-temp-buffer
        (insert-file-contents prjheader)
        (rx-let ((def_rx (: "define" (+ (any " \t"))
                            (group (+ (not (any " \t"))))
                            (+ (any " \t"))
                            (group (+ nonl)))))
          (while (re-search-forward (rx def_rx) nil t)
            (setq ami-defs
                  (cons (format "%s=%s"
                                (match-string 1)
                                (match-string 2))
                        ami-defs))))))
    ;; (print ami-defs)
    (nreverse ami-defs)))
(defun ami-bmc-include ()
  "Add bmc include dir."
  (let ((bmc-dir (ami-mds-dir-parse (buffer-file-name))))
    (if bmc-dir
        (let* ((workdir (format "%s/workspace" (car bmc-dir)))
               (pkgname (nth 1 bmc-dir))
               (pkgdir (format "%s/source/%s" workdir pkgname))
               (builddir (format "%s/Build" workdir))
               (prjheader (format "%s/include/projdef.h" builddir))
               (pkgvar (ami-parse-makefile builddir pkgdir))
               (gnuabir13 (format "%s/tools/arm-soft-linux-gnueabi" workdir))
               (gnuabir12 (format "%s/tools/arm-linux/arm-none-linux-gnueabi" workdir))
               (prjvar
                ;; prjvar list (gcc-exec, list-of-includepath)
                (cond ((file-exists-p gnuabir12)
                       (list (format "%s/bin/arm-none-linux-gnueabi-gcc" gnuabir12)
                             (list (format "%s/arm-none-linux-gnueabi/sysroot/usr/include" gnuabir12)
                                   (format "%s/arm-none-linux-gnueabi/include/c++/4.9.2" gnuabir12)))
                       )
                      ((file-exists-p gnuabir13)
                       (list (format "%s/bin/arm-soft-linux-gnueabi-gcc" gnuabir13)
                             (list (format "%s/arm-soft-linux-gnueabi/sysroot/usr/include" gnuabir13)
                                   (format "%s/arm-soft-linux-gnueabi/include/c++/8.3.0" gnuabir13))
                             ) )))
               (include-path (append
                              (nth 1 prjvar)
                              (nth 1 pkgvar)))
               (ami-defs (cons "UN_USED(x)=(void)(x)"
                               (append
                                (ami-parse-prjdef prjheader) (car pkgvar))
                               ) )
               )
          ;; (print include-path)
          (setq flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck)) ;; disable clang for ami code
          (setq flycheck-c/c++-gcc-executable (car prjvar))
          ;; (print flycheck-c/c++-gcc-executable)
          (setq flycheck-gcc-include-path include-path)
          (setq flycheck-cppcheck-include-path include-path)
          (setq flycheck-gcc-definitions ami-defs)
          (setq flycheck-gcc-language-standard (nth 3 pkgvar) )
          (setq flycheck-gcc-warnings (cons "sign-compare" ( nth 2 pkgvar))   )
          )
      ;; no ami project found, reset to default
      (setq flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck)) ;; disable clang for ami code
      (setq flycheck-c/c++-gcc-executable nil)
      ;; (print flycheck-c/c++-gcc-executable)
      (setq flycheck-gcc-include-path nil)
      (setq flycheck-cppcheck-include-path nil)
      (setq flycheck-gcc-definitions nil)
      (setq flycheck-gcc-language-standard "c++17" )
      (setq flycheck-gcc-warnings (list "all" "extra" "sign-compare")  )
      )))

(add-hook 'flycheck-before-syntax-check-hook 'ami-bmc-include)

;; (let ((spec '((t (:family "mono" :height 120)))))
;; ;; (let ((spec '((t (:family "DejaVu Sans Mono" :height 120)))))
;;     ;; (let ((spec '((t (:family "DejaVu Sans Mono" :size 18)))))
;;     (mapc (lambda (face)
;;             (face-spec-set face spec)
;;             (put face 'face-defface-spec spec)
;;             ;;          (set-fontset-font (face-font face) 'unicode (font-spec :family "monospace" :height 140))
;;             (dolist (charset '(kana han symbol cjk-misc bopomofo))
;;               ;; (set-fontset-font (frame-parameter nil 'font) charset
;;               (set-fontset-font (face-font face) charset
;;                                 (font-spec :family "Noto Sans Mono CJK SC"))))
;;           '(default menu)))

;; create new fontset-mono
(create-fontset-from-fontset-spec "-*-DejaVu Sans Mono-normal-normal-normal-*-15-*-*-*-*-*-fontset-mono" )
(dolist (charset '(kana han symbol cjk-misc bopomofo))
  (set-fontset-font "fontset-mono" charset
                    (font-spec :family "Noto Sans Mono CJK SC" )))
;; set default font for emacsclient.
(add-to-list 'default-frame-alist '(font . "fontset-mono"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(provide 'init-griffon)
;;; init-griffon.el ends here
