;;; init-evil.el --- configure for evil mode
;;; commentary:
;;; GriffOn evil config, make some move key same in Emacs and Vim mode.
;;; Code:

(require-package 'evil )
(evil-mode 1)
;;(setq evil-default-state 'emacs)
(defun my-move-key (keymap-from keymap-to key)
  "Move KEY binding from KEYMAP-FROM to KEYMAP-TO."
  (define-key keymap-to key (lookup-key keymap-from key))
  (define-key keymap-from key nil))
(my-move-key evil-motion-state-map evil-normal-state-map (kbd "RET"))
;;(my-move-key evil-motion-state-map evil-normal-state-map " ")
(define-key evil-motion-state-map (kbd "SPC") 'evil-scroll-page-down)
(define-key evil-normal-state-map (kbd "DEL") 'evil-scroll-page-up)
(define-key evil-motion-state-map (kbd "C-b") nil)
(define-key evil-motion-state-map (kbd "C-f") nil)
(define-key evil-normal-state-map (kbd "C-n") nil)
(define-key evil-normal-state-map (kbd "C-p") nil)
(define-key evil-motion-state-map "\C-v" nil)
(define-key evil-insert-state-map (kbd "C-v") nil)
(define-key evil-insert-state-map (kbd "A-v") 'evil-scrool-page-up)
(define-key evil-insert-state-map (kbd "C-n") nil)
(define-key evil-insert-state-map (kbd "C-p") nil)
(define-key evil-insert-state-map (kbd "C-r") nil)
(define-key evil-normal-state-map (kbd "C-r") nil)
(define-key evil-motion-state-map (kbd "C-e") nil)
(define-key evil-insert-state-map (kbd "C-a") nil)
(define-key evil-insert-state-map (kbd "C-e") nil)

(provide 'init-evil)
;;; init-evil.el ends here
