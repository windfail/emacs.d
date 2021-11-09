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
  (setq indent-tabs-mode nil)
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

(defun ami-parse-makefile (builddir makefile)
  "This function parse  MAKEFILE, find includ dirs in CFLAGS -I lines, replace SPXINC/TARGDIR with correct dir using  BUILDDIR ."
  (let ((dirlist (list (list "SPXINC"  (format "%s/include" builddir))
                       (list "TARGETDIR"  (format "%s/target" builddir))
                       (list nil  "")))
        (inclist nil))
    (when (file-exists-p makefile)
      (with-temp-buffer
        (insert-file-contents makefile)
        (rx-let ((var_rx (: "$" (any "{(")
                            (group-n 1 (+ (not (any "${()}"))))
                            (any ")}")))
                 (cflag_rx (: line-start (* (any " \t")) "CFLAGS" (+ (any " \t+=")) "-I"
                              (opt var_rx)
                              (group-n 2 (+ (not (any " \t#\n${}")))))))
          (while (re-search-forward (rx cflag_rx) nil t )
            (let ((idir (format "%s%s"
                                (car (cdr (assoc (match-string 1) dirlist)))
                                (match-string 2))))
              (setq inclist (cons idir inclist)))
            ))))
    (nreverse inclist)))
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
    (nreverse ami-defs)))
(defun ami-bmc-include ()
  "Add bmc include dir."
  (let ((bmc-dir (ami-mds-dir-parse (buffer-file-name))))
    (when bmc-dir
      (let* ((workdir (format "%s/workspace" (car bmc-dir)))
             (pkgname (nth 1 bmc-dir))
             (makefile (format "%s/source/%s/data/Makefile" workdir pkgname))
             (builddir (format "%s/Build" workdir))
             (prjheader (format "%s/include/projdef.h" builddir))
             (sysinc (format "%s/tools/arm-linux/arm-none-linux-gnueabi/arm-none-linux-gnueabi/sysroot/usr/include" workdir))
             (include-path (cons sysinc
                                 (ami-parse-makefile builddir makefile)))
             (ami-defs (cons "UN_USED(x)=(void)(x)"
                             (ami-parse-prjdef prjheader)) )
             )
        (setq flycheck-disabled-checkers '(c/c++-clang c/c++-cppcheck)) ;; disable clang for ami code
        (setq flycheck-gcc-include-path include-path)
        (setq flycheck-cppcheck-include-path include-path)
        (setq flycheck-gcc-definitions ami-defs))
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
                    (font-spec :family "Noto Sans Mono CJK SC")))
;; set default font for emacsclient.
(add-to-list 'default-frame-alist '(font . "fontset-mono"))
(add-to-list 'default-frame-alist '(fullscreen . maximized))

(provide 'init-griffon)
;;; init-griffon.el ends here
