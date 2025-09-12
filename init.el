(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(exec-path-from-shell-initialize)
(require 'add-node-modules-path)
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'no-error 'no-message)

;; Treesitter configuration (keep this)
(require 'treesit)
(setq treesit-language-source-alist
   '((bash "https://github.com/tree-sitter/tree-sitter-bash")
     (cmake "https://github.com/uyha/tree-sitter-cmake")
     (css "https://github.com/tree-sitter/tree-sitter-css")
     (elisp "https://github.com/Wilfred/tree-sitter-elisp")
     (go "https://github.com/tree-sitter/tree-sitter-go")
     (html "https://github.com/tree-sitter/tree-sitter-html")
     (javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
     (json "https://github.com/tree-sitter/tree-sitter-json")
     (make "https://github.com/alemuller/tree-sitter-make")
     (markdown "https://github.com/ikatyang/tree-sitter-markdown")
     (python "https://github.com/tree-sitter/tree-sitter-python")
     (kotlin "https://github.com/fwcd/tree-sitter-kotlin")
     (toml "https://github.com/tree-sitter/tree-sitter-toml")
     (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
     (typescript "https://github.com/tree-sitter/tree-sitter-typescript" "master" "typescript/src")
     (yaml "https://github.com/ikatyang/tree-sitter-yaml")))

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

;; Package handling
;; (package-refresh-contents)
;; (unless (package-installed-p 'use-package) (package-install 'use-package))
;; (eval-when-compile (require 'use-package))
;; (require 'package)
;; (dolist (pkg package-selected-packages) (unless (package-installed-p pkg) (package-install pkg)))

;;;; New setup for typescript, eglot etc
(require 'eglot)

(defun my-format-on-save ()
  (when (eglot-managed-p)
    (let ((file-ext (file-name-extension (buffer-file-name))))
      (cond ((string= file-ext "tsx")
             (prettier-prettify))
            ((string= file-ext "ts")
             (eglot-format))))))
(add-hook 'before-save-hook 'my-format-on-save)

(add-to-list 'eglot-server-programs
             '(typescript-ts-base-mode . ("npx" "typescript-language-server" "--stdio")))

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

(add-hook 'typescript-ts-base-mode-hook
          (lambda ()
            (add-node-modules-path)
            (eglot-ensure)
            (company-mode)
            (flymake-eslint-enable)))

;;;; Vue
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


;;;; Copilot
;; OPTIONAL configuration
(setq gptel-model 'gpt-4o
      gptel-backend (gptel-make-gh-copilot "Copilot"))

