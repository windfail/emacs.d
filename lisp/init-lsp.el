;;;  lsp-mode setups
;;; Commentary:
;;; Code:

(require-package 'use-package )
(require-package 'lsp-mode )
(require-package 'lsp-ui )
(require-package 'company )
;; (require-package 'ggtags )
(use-package lsp-mode
  :ensure t
  :hook ((c-mode c++-mode python-mode javascript-mode) . lsp-deferred) ; 为 C/C++ 模式启用 lsp，但延迟启动
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l") ; 设置 lsp 命令前缀，避免快捷键冲突
  (setq lsp-auto-configure nil)
  :config
  ;; (lsp-register-client
  ;;  (make-lsp-client :new-connection (lsp-stdio-connection "clangd")
  ;;                   :major-modes '(c-mode c++-mode) ; 指定支持的语言
  ;;                   :priority 10 ; 高优先级，精确功能由clangd处理
  ;;                   :server-id 'clangd))
  ;; (lsp-register-client
  ;;  (make-lsp-client :new-connection (lsp-stdio-connection "opencode") ; 假设 opencode 命令在 PATH 中
  ;;                   :major-modes '(python-mode javascript-mode c-mode c++-mode) ; 指定支持的语言
  ;;                   :priority 1 ; 低优先级，AI辅助
  ;;                   :server-id 'opencode))
  (setq lsp-auto-guess-root t
        lsp-completion-provider :capf
        ;; 允许多个LSP服务器同时工作
        lsp-enable-file-watchers nil
        lsp-headerline-breadcrumb-enable nil)
  (when-let ((clangd-path (executable-find "clangd")))
    (lsp-register-client
     (make-lsp-client :new-connection (lsp-stdio-connection clangd-path) ; 使用绝对路径更可靠
                      :major-modes '(c-mode c++-mode)
                      :priority 10 ; 高优先级，处理精确导航
                      :server-id 'clangd)))

  ;; 修正点2：同样处理opencode
  (when-let ((opencode-path (executable-find "opencode")))
    (lsp-register-client
     (make-lsp-client :new-connection (lsp-stdio-connection opencode-path)
                      :major-modes '(python-mode javascript-mode c-mode c++-mode)
                      :priority 1 ; 低优先级，提供AI辅助
                      :server-id 'opencode)))
  )
;; 增强 UI 体验
(use-package lsp-ui
  :ensure t
  :after lsp-mode
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-position 'top
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover t))

;; 智能补全前端
(use-package company
  :ensure t
  :config
  (global-company-mode t)
  (setq company-minimum-prefix-length 1
        company-idle-delay 0.1))


;; 配置 ggtags 以使用 GNU Global
;; (use-package ggtags
;;   :ensure t
;;   :hook ((c-mode c++-mode) . ggtags-mode) ; 为 C/C++ 模式启用 ggtags
;;   :config
;;   (setq ggtags-update-on-save t)) ; 保存文件时自动更新 GTAGS
(provide 'init-lsp)
;;; init-lsp.el ends here
