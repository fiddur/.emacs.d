;; Standard Emacs package management setup
(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(setq custom-file (expand-file-name "init.el" user-emacs-directory))

;; Treesitter configuration (keep this)
(require 'treesit)
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     ...
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")))

;; General keybindings and preferences
(setq make-backup-files nil)
(defun myprevious-window () (interactive) (other-window -1))
(global-set-key [?\C-\056] 'other-window)
(global-set-key [?\C-\054] 'myprevious-window)
(global-set-key "\M-j" 'goto-line)
(global-set-key "\C-c\C-k" 'string-inflection-kebab-case)
(menu-bar-mode -1)
(tool-bar-mode -1)
(prefer-coding-system 'utf-8)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")

;; Custom variables (you can keep these, but remove the JDEE and eslint-related ones)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(add-node-modules-path-command "pnpm bin")
 '(blink-cursor-mode nil)
 '(custom-enabled-themes '(deeper-blue))
 '(default-frame-alist '((vertical-scroll-bars . right)))
 '(global-font-lock-mode t nil (font-lock))
 '(indent-tabs-mode nil)
 '(js-indent-level 2)
 '(js-switch-indent-offset 2)
 '(package-selected-packages
   '(## company exec-path-from-shell flymake-eslint git-grep json-mode
        kotlin-ts-mode markdown-mode string-inflection svelte-mode
        web-mode yaml yaml-mode))
 '(select-enable-primary t)
 '(sort-fold-case t t)
 '(tab-width 2)
 '(typescript-indent-level 2))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;;; New setup for typescript, eglot etc
(require 'eglot)
;;(add-to-list 'package-selected-packages 'exec-path-from-shell)
(require 'exec-path-from-shell)
(exec-path-from-shell-initialize)
(require 'add-node-modules-path)

(defun my-typescript-setup ()
  (add-node-modules-path)
  (eglot-ensure)
  (flymake-eslint-enable))

(add-to-list 'eglot-server-programs
             '(typescript-mode . ("npx" "typescript-language-server" "--stdio")))

(defun my-format-on-save () (when (eglot-managed-p) (eglot-format)))
(add-hook 'before-save-hook 'my-format-on-save)

(add-hook 'typescript-mode-hook #'my-typescript-setup)
(add-hook 'after-load-hook #'add-node-modules-path)
(add-hook 'typescript-mode-hook #'company-mode)


;;;; Vue
;;(add-to-list 'eglot-server-programs
;;             '((web-mode) . ("vue-language-server" "--stdio")))
;;(add-to-list 'eglot-server-programs
;;             '((web-mode) . ("pnpm" "npx" "vue-language-server" "--stdio")))
(add-to-list 'eglot-server-programs
             '((web-mode) . ("pnpm" "npx" "vls" "--stdio")))

(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal (file-name-extension (buffer-file-name)) "vue")
              (add-node-modules-path)
              (eglot-ensure))))
