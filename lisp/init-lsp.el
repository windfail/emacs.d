;;;  lsp-mode setups
;;; Commentary:
;;; Code:

(require-package 'use-package )
(require-package 'lsp-mode )
;; (require-package 'ggtags )
(use-package lsp-mode
  :ensure t
  :hook ((c-mode c++-mode) . lsp-deferred) ; 为 C/C++ 模式启用 lsp，但延迟启动
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l") ; 设置 lsp 命令前缀，避免快捷键冲突
  :config
  (setq lsp-auto-configure t
        lsp-auto-guess-root t)) ; 自动猜测项目根目录

;; 配置 ggtags 以使用 GNU Global
;; (use-package ggtags
;;   :ensure t
;;   :hook ((c-mode c++-mode) . ggtags-mode) ; 为 C/C++ 模式启用 ggtags
;;   :config
;;   (setq ggtags-update-on-save t)) ; 保存文件时自动更新 GTAGS
(provide 'init-lsp)
;;; init-griffon.el ends here
