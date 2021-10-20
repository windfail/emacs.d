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
(defun wx-c-mode-hook()
  "My C mode hook."
  (setq tab-width 4 ); tab width
  (setq indent-tabs-mode nil)
                                        ;(c-set-style "stroustrup")
                                        ; 自动换行
  (c-toggle-auto-newline 1)
                                        ; 贪心删除
                                        ;  (c-toggle-hungry-state 1)
                                        ; ctrl+`: 代码折叠
                                        ;(define-key c-mode-base-map [(control \`)] 'hs-toggle-hiding)
                                        ; 换行自动递进
                                        ;(define-key c-mode-base-map [(return)] 'newline-and-indent)
                                        ; F7:编译
  ;;  (define-key c-mode-base-map [f7] 'compile)
  ;;缩进风格
  (setq c-basic-offset 4)
  (setq comment-start "// ")
  (setq comment-end ""))
(add-hook 'c-mode-hook 'wx-c-mode-hook)
(add-hook 'c++-mode-hook 'wx-c-mode-hook)

(defun ami-mds-dir-parse ()
  "Parse current dir, if is ami mds workspace, return list (basedir pkgname), otherwise return nil."
  (rx-let ((pack_rx (: (+ (not "/"))
		       (= 4 (+ (any "0-9")) ".")
		       (+ (any "0-9"))
		       (+ (not "/"))))
	   (total_rx (: (group (* nonl))
			"/workspace/source/"
			(group (* (not "/") ))
                        "/data/"
			(* nonl))))
    (setq dir (buffer-file-name))
    (when dir
      (when (string-match (rx total_rx) dir)
        (list (match-string 1 dir) (match-string 2 dir))))))
(defun lnv-compile ()
  "Compile command for lenovo bmc project."
  (interactive )
  (setq bmc-dir (ami-mds-dir-parse))
  (setq prjdir (car bmc-dir))
  (setq pkgname (nth 1 bmc-dir))
  (compile (format "lnv-build.sh %s %s" prjdir pkgname )))

(defun ami-bmc-include ()
  "Add bmc include dir."
  (setq bmc-dir (ami-mds-dir-parse))
  (when bmc-dir
    (setq prjdir (car bmc-dir))
    (setq pkgname (nth 1 bmc-dir))
    (setq makefile (format "%s/workspace/source/%s/data/Makefile" prjdir pkgname))
    (setq include-path
          (cons
           (format "%s/workspace/tools/arm-linux/arm-none-linux-gnueabi/arm-none-linux-gnueabi/sysroot/usr/include" prjdir)
           (process-lines
            "sed" "-n"
            "-e" (format "s|\\$[{(]SPXINC[})]|%s/workspace/Build/include|" prjdir) ;;replace $SPXINC
            "-e" (format "s|\\$[{(]TARGETDIR[})]|%s/workspace/Build/target|" prjdir) ;;replace $TARGETDIR
            "-e" "/^[ \t]*CFLAGS[ \t]*+=[ \t]*-I/s/.*CFLAGS[ \t]*+=[ \t]*-I\\([^# \t]*\\).*$/\\1/p" 
            makefile)))
    ;;    (setq include-path (process-lines "/home/griffon/bin/get-bmc-include.sh" prjdir pkgname))
    (setq ami-defs (list "UN_USED(x)=(void)(x)"))
    (setq flycheck-disabled-checkers '(c/c++-clang)) ;; disable clang for ami code
    (setq flycheck-gcc-include-path include-path)
    (setq flycheck-cppcheck-include-path include-path)
    (setq flycheck-gcc-definitions ami-defs)))

(add-hook 'flycheck-before-syntax-check-hook 'ami-bmc-include)
(provide 'init-griffon)
;;; init-griffon.el ends here
