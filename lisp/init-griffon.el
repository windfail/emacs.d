;;; griffon --- my emacs setups
;;; Commentary:
;;; Code:

;;(require-package 'smart-tabs-mode )
;;(smart-tabs-insinuate 'c 'c++)
(require-package 'evil )
(evil-mode 1)
;;(setq evil-default-state 'emacs)
(define-key evil-motion-state-map (kbd "SPC") 'evil-scroll-page-down)
(define-key evil-normal-state-map (kbd "DEL") 'evil-scroll-page-up)
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
(setq scroll-conservatively 1)
(tool-bar-mode 0)
(setq inhibit-startup-screen t)
(setq scroll-bar-mode "right")

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
  (setq comment-end "")

  )
(add-hook 'c-mode-hook 'wx-c-mode-hook)
(add-hook 'c++-mode-hook 'wx-c-mode-hook)


(defun lnv-package ()
  "Get project base dir and package name."
  (rx-let ((pack_rx (: (+ (not "/"))
		       (= 4 (+ (any "0-9")) ".")
		       (+ (any "0-9"))
		       (+ (not "/"))))
	   (total_rx (: (group (* nonl))
			"/workspace/source/"
			(group pack_rx)
			(* nonl))) )
    (setq dir (buffer-file-name))
    (string-match (rx total_rx) dir)
    (list (match-string 1 dir) (match-string 2 dir))
    ))

(defun lnv-compile ()
  "Compile command for lenovo bmc project."
  (interactive )
  (setq bmc-dir (lnv-package))
  (setq prjdir (car bmc-dir))
  (setq pkgname (nth 1 bmc-dir))
  (compile (format "lnv-build.sh %s %s" prjdir pkgname ) )
  )
;;-------set by emacs -------
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:inherit nil :stipple nil :background "black" :foreground "gray85" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(flycheck-color-mode-line-error-face ((t (:inherit flycheck-fringe-error :background "dim gray"))))
 '(flycheck-color-mode-line-info-face ((t (:inherit flycheck-fringe-info :background "dim gray")))))

(provide 'init-griffon)
;;; init-griffon.el ends here
