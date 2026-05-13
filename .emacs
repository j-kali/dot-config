(require 'package)
(add-to-list 'package-archives '("melpa-edge" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))
(package-initialize)

(unless package-archive-contents (package-refresh-contents))

;; Install use-package itself
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;;; ── Global defaults ────────────────────────────────────────────────

(setq-default indent-tabs-mode nil)
(setq require-final-newline t
      sh-basic-offset 4
      js-indent-level 4)

(tool-bar-mode -1)
(menu-bar-mode -1)
(set-frame-font "Monospace-9" t t)

(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

;;; ── Whitespace & line numbers ──────────────────────────────────────

(use-package whitespace
  :ensure nil  ; built-in
  :custom
  (whitespace-style '(face spaces tabs trailing newline space-mark tab-mark newline-mark))
  (whitespace-line-column 120)
  :config
  (global-whitespace-mode))

(use-package simple  ; provides display-line-numbers-mode
  :ensure nil
  :config
  (global-display-line-numbers-mode))

;;; ── Theme ──────────────────────────────────────────────────────────

(use-package dracula-theme
  :config
  (load-theme 'dracula t))

;;; ── Company ────────────────────────────────────────────────────────

(use-package company
  :custom
  (company-idle-delay 0)
  (company-minimum-prefix-length 1)
  :hook (after-init . global-company-mode))

(use-package company-go
  :after company)

;;; ── Flyspell ───────────────────────────────────────────────────────

(use-package flyspell
  :ensure nil  ; built-in
  :hook
  (text-mode . flyspell-mode)
  (prog-mode . flyspell-prog-mode))

;;; ── YAML ───────────────────────────────────────────────────────────

(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :bind
  (:map yaml-mode-map
        ("RET" . newline-and-indent)))

;;; ── Terraform ──────────────────────────────────────────────────────

(use-package terraform-mode
  :mode "\\.tf\\'")

;;; ── Markdown ───────────────────────────────────────────────────────

(use-package markdown-mode
  :mode "\\.md\\'")

;;; ── Speedbar ───────────────────────────────────────────────────────

(use-package sr-speedbar
  :bind ("C-c s" . sr-speedbar-toggle)
  :config
  (setq speedbar-use-images nil)

  ;; IMPORTANT: show everything
  (setq speedbar-directory-unshown-regexp "^\\(CVS\\|RCS\\|SCCS\\|\\.\\.*$\\)\\'")
  (setq speedbar-show-unknown-files t)

  ;; stop Speedbar from grouping/hiding things
  (setq speedbar-inhibit-faces t)
  (setq speedbar-smart-directory-expand-list nil)

  ;; optional but often helps visibility
  (setq speedbar-hide-button-brackets nil)
  (setq speedbar-use-imenu-flag nil))

;;; ── LSP GLOBAL CONFIG ──────────────────────────────────────────────

(use-package lsp-mode
  :hook
  (go-mode . lsp-deferred)
  (rust-mode . lsp-deferred)
  (python-mode . lsp-deferred)
  :commands lsp-deferred
  :custom
  (lsp-enable-file-watchers nil))

(with-eval-after-load 'lsp-mode
  (setq lsp-rust-analyzer-cargo-watch-command "check"
        lsp-rust-analyzer-proc-macro-enable t
        lsp-rust-analyzer-cargo-all-targets t
        lsp-pyright-typechecking-mode "basic"
        lsp-pyright-auto-import-completions t
        python-format-on-save t
        lsp-go-use-gofumpt t))

;;; ── Go ─────────────────────────────────────────────────────────────

(defun my-go-mode-setup ()
  ;; Snippets
  (yas-minor-mode 1)

  ;; Ensure hooks are not duplicated
  (remove-hook 'before-save-hook #'lsp-format-buffer t)
  (remove-hook 'before-save-hook #'lsp-organize-imports t)

  ;; Re-add buffer-local save hooks
  (add-hook 'before-save-hook #'lsp-format-buffer nil t)
  (add-hook 'before-save-hook #'lsp-organize-imports nil t))

(use-package go-mode
  :mode "\\.go\\'"
  :hook (go-mode . my-go-mode-setup))

;;; ── Rust ───────────────────────────────────────────────────────────

(defun my-rust-mode-setup ()
  (yas-minor-mode 1)

  ;; format on save (rustfmt via rust-analyzer)
  (remove-hook 'before-save-hook #'lsp-format-buffer t)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t)

  ;; optional (safe in most Cargo projects)
  (remove-hook 'before-save-hook #'lsp-organize-imports t)
  (add-hook 'before-save-hook #'lsp-organize-imports nil t))

(use-package rust-mode
  :mode "\\.rs\\'"
  :hook (rust-mode . my-rust-mode-setup))

;;; ── Python ─────────────────────────────────────────────────────────

(defun my-python-mode-setup ()
  (yas-minor-mode 1)

  ;; LSP formatting (safe hooks, same pattern as Go/Rust)
  (remove-hook 'before-save-hook #'lsp-format-buffer t)
  (add-hook 'before-save-hook #'lsp-format-buffer nil t)

  ;; Optional: organize imports (works depending on backend)
  (remove-hook 'before-save-hook #'lsp-organize-imports t)
  (add-hook 'before-save-hook #'lsp-organize-imports nil t))

(use-package python-mode
  :mode "\\.py\\'"
  :hook (python-mode . my-python-mode-setup))

;;; ── Trailing whitespace cleanup ────────────────────────────────────

(add-hook 'before-save-hook #'delete-trailing-whitespace)

;;; ── Custom file (let Emacs manage this) ────────────────────────────

(custom-set-variables
 '(custom-safe-themes
   '("dcdd1471fde79899ae47152d090e3551b889edf4b46f00df36d653adc2bf550d"
     "d0fe9efeaf9bbb6f42ce08cd55be3f63d4dfcb87601a55e36c3421f2b5dc70f3"
     default)))
(custom-set-faces)
