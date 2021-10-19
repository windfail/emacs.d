;;; init-evil.el --- configure for evil mode
;;; commentary:
;;; Code:

(require-package 'evil )
(evil-mode 1)
;;(setq evil-default-state 'emacs)
(define-key evil-motion-state-map (kbd "SPC") 'evil-scroll-page-down)
(define-key evil-normal-state-map (kbd "DEL") 'evil-scroll-page-up)

(provide 'init-evil)
;;; init-evil.el ends here
