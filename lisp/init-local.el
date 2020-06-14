;;-----set by hand ------------
(global-unset-key (kbd "C-SPC"))
(global-set-key (kbd "M-SPC") 'set-mark-command)
(global-set-key [C-tab] 'next-buffer)
;;(global-set-key [f5] 'revert-buffer)
;;(global-set-key [f7] 'compile)
;;(global-set-key [f6] 'speedbar)
(global-set-key [C-S-iso-lefttab] 'previous-buffer)
(setq scheme-program-name "mit-scheme")
;;(fset 'perl-mode 'cperl-mode)
                                        ;滚屏一次一行
(setq scroll-conservatively 1)
                                        ;缩进风格
                                        ;(setq c-basic-offset 8)
(setq c-default-style
      '( (java-mode . "java") (awk-mode . "awk") (python . "python") (other . "linux")))
                                        ;      '( (java-mode . "java") (awk-mode . "awk")  (other . "linux")))
;; (defun griffon-cperl-mode-hook()
;;   (setq cperl-auto-newline t)
;;   (cperl-set-style "PerlStyle")
;;   )
;; (add-hook 'cperl-mode-hook 'griffon-cperl-mode-hook)

;; C/C++语言风格
(defun wx-c-mode-hook()
                                        ;(setq tab-width 4 indent-tabs-mode nil)
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
                                        ;  (define-key c-mode-base-map [f7] 'compile)
  (setq comment-start "// ")
  (setq comment-end "")

  )
(add-hook 'c-mode-hook 'wx-c-mode-hook)
(add-hook 'c++-mode-hook 'wx-c-mode-hook)

;;-------set by emacs -------
;;(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 ;;'(inhibit-startup-screen t)
;; '(scroll-bar-mode (quote right)))
;;(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
;; '(default ((t (:inherit nil :stipple nil :background "black" :foreground "gray85" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 120 :width normal :foundry "unknown" :family "DejaVu Sans Mono")))))

;;(put 'narrow-to-region 'disabled nil)
;;(put 'dired-find-alternate-file 'disabled nil)

(provide 'init-local')
