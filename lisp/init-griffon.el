;;; griffon --- my emacs setups
;;; Commentary:
;;; Code:

(require-package 'smart-tabs-mode )
(smart-tabs-insinuate 'c 'c++)
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
(add-to-list 'default-frame-alist
             '(font . "fontset-mono"))
(add-to-list 'default-frame-alist
             '(fullscreen . maximized))
(provide 'init-griffon)
;;; init-griffon.el ends here
