(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'no-error 'no-message)

;; Package handling
(defun my-install-all ()
 (package-refresh-contents)
 (unless (package-installed-p 'use-package) (package-install 'use-package))
 (eval-when-compile (require 'use-package))
 (require 'package)
 (dolist (pkg package-selected-packages) (unless (package-installed-p pkg) (package-install pkg))))

(exec-path-from-shell-initialize)
(require 'add-node-modules-path)

(defun my/add-monorepo-node-modules-path ()
  "Search for the project root (git root) and add its node_modules/.bin to exec-path."
  (interactive)
  (let* ((root (locate-dominating-file (buffer-file-name) ".git"))
         (modules (expand-file-name "node_modules/.bin/" root)))
    (when (and root (file-directory-p modules))
      (make-local-variable 'exec-path)
      (add-to-list 'exec-path modules)
      (make-local-variable 'process-environment)
      (setenv "PATH" (concat modules ":" (getenv "PATH"))))))


;;;;; Claude Code
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
;; install required inheritenv dependency:
(use-package inheritenv :vc (:url "https://github.com/purcell/inheritenv" :rev :newest))
;; for eat terminal backend:
(use-package eat :ensure t)
;; for IDE integration (selections, diffs, diagnostics):
(use-package monet
  :vc (:url "https://github.com/stevemolitor/monet" :rev :newest))
;; install claude-code.el
(use-package claude-code :ensure t
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :config
  ;; optional IDE integration with Monet
  (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
  (monet-mode 1)

  (claude-code-mode)
  :bind-keymap ("C-c c" . claude-code-command-map)

  ;; Optionally define a repeat map so that "M" will cycle thru Claude auto-accept/plan/confirm modes after invoking claude-code-cycle-mode / C-c M.
  :bind
  (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode)))
;;;;;; End claude code


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

;; Typscript/tsx setup with tide
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))

;; Check syntax only on save, not on edit
; (setq flycheck-check-syntax-automatically '(save mode-enabled))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

(add-hook 'typescript-ts-base-mode-hook
          (lambda ()
            (my/add-monorepo-node-modules-path)
            (tide-setup)
            (flycheck-mode)
            (eldoc-mode)
            (company-mode)
            (prettier-js-mode)
            (tide-hl-identifier-mode +1)
            ))

;;;; Vue
(require 'eglot)
;;(add-to-list 'eglot-server-programs
;;             '((web-mode) . ("vue-language-server" "--stdio")))
(add-to-list 'eglot-server-programs
             '((web-mode) . ("pnpm" "npx" "vls" "--stdio")))

(add-to-list 'auto-mode-alist '("\\.vue\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal (file-name-extension (buffer-file-name)) "vue")
              (add-node-modules-path)
              (prettier-js-mode)
              (eglot-ensure))))


;;;; Copilot
;; OPTIONAL configuration
(setq gptel-model 'gpt-4o
      gptel-backend (gptel-make-gh-copilot "Copilot"))

