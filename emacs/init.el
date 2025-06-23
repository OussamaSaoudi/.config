(setq inhibit-startup-message t)


;; Set the option key to meta when in MacOS (darwin)
(when (eq system-type 'darwin)
  (setq mac-option-modifier 'meta))

;; Only disable GUI elements if they exist
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'tooltip-mode)
  (tooltip-mode -1))
;(when (fboundp 'menu-bar-mode)
					;  (menu-bar-mode -1))
(menu-bar-mode t)

;; Set up the visual bell
(setq visible-bell nil)

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; enable column mode and add line numbers
(column-number-mode)
(global-display-line-numbers-mode t)

;; disable line numbers for some modes
(dolist (mode '(org-mode-hook
		treemacs-mode
		term-mode-hook
		eshell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))



;; Initialize package sources
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/"))
(add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/"))
(package-initialize)

;; If there is no cache of packages on the computer, refresh the cache
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Install the 'use-package package
(require 'use-package)

;; ensure will download a package if it is not present already
;; this command will set it to true so that all packages will
;; automatically be downloaded
(setq use-package-always-ensure t)


;; install completions
(use-package ivy
	     :diminish
	     :bind (("C-s" . swiper)
		    :map ivy-minibuffer-map
		    ("TAB" . ivy-alt-done)
		    ("C-l" . ivy-alt-done)
		    ("C-j" . ivy-next-line)
		    ("C-k" . ivy-previous-line)
		    :map ivy-switch-buffer-map
		    ("C-k" . ivy-previous-line)
		    ("C-l" . ivy-done)
		    ("C-d" . ivy-switch-buffer-kill)
		    :map ivy-reverse-i-search-map
		    ("C-k" . ivy-previous-line)
		    ("C-d" . ivy-reverse-i-search-kill))
	     :config
	     (ivy-mode 1))
;; Adds descriptions in buffers like M-x
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package swiper)

;; Maps bindings to the ivy versions of the actions
(use-package counsel
  :bind (
         ("M-x" . counsel-M-x)
	 ("C-x b" . counsel-ibuffer)
	 ("C-x C-f" . counsel-find-file)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history)))


;; NOTE: the first time you load the configurations on a new machine, you'll
;; need to run the following command interactively so that mode line icons
;; display correctly
;;
;; M-x all-the-icons-install-fonts
(use-package all-the-icons)

;; status line at the bottom
(use-package doom-modeline
	     :ensure t
	     :init (doom-modeline-mode 1)
	     :custom ((doom-modeline-height 15)))
(use-package doom-themes
  :init (load-theme 'doom-gruvbox t))

;; Rainbow delimiters
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))


;; Helpful packages for discoverability
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-funcion] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

;; global-set-key can be used to set global keybinds
;; define-key can be used to set keybinds in a specific mode's keymap
;; example:
;; (define-key emacs-lisp-mode-map (kbd "C-x M-t") 'counsel-do-something)
(use-package general)

(defun rune/evil-hook ()
  (dolist (mode '(custom-mode
		  eshell-mode
		  git-rebase-mode
		  erc-mode
		  circe-server-mode
		  circe-chat-mode
		  circe-query-mode
		  sauron-mode
		  term-mode))
    (add-to-list 'evil-emacs-state-modes mode)))
  
(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  :hook (evil-mode . rune/evil-hook)
  :config
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))
(evil-mode 1)

;; to remove an item from the evil-collection list, look for 'remove' something or another
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

;; Useful for defining small modes for configuring stuff
(use-package hydra
  :after general)

;; Define a hydra for scaling text in/out.
;; NOTE: this only works in the emacs app.
(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

;; Project management 
(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  (when (file-directory-p "~/projects/code")
    (setq projectile-project-search-path '("~/projects/code")))
  (setq projectile-switch-project-action #'projectile-dired))

;; rg and additional functionality on top of projectile
(use-package counsel-projectile
  :config (counsel-projectile-mode))

;; Install nerd-icons
(use-package nerd-icons)


;; Git integration
(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package forge
  :after magit)

;; setup auth source. this contains the github token for forge
(setq auth-sources '("~/.authinfo"))


;; Org Mode Configuration ----------------------------------
(defun efs/org-mode-setup ()
  (org-indent-mode)
  (visual-line-mode 1))

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•")))))))

(use-package org
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")
  (efs/org-font-setup)
  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)
  (setq org-agenda-files
      '("~/projects/code/org-files/tasks.org"
	"~/projects/code/org-files/birthdays.org"))
  (setq org-todo-keywords
	'((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
	  (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))) 

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))

;; Directory tree ------------------------------------------------------------------

(use-package treemacs
  :config
  :bind
    (:map global-map
	    ("M-0"       . treemacs-select-window)
	    ("C-x t 1"   . treemacs-delete-other-windows)
	    ("C-x t t"   . treemacs)
	    ("C-x t d"   . treemacs-select-directory)
	    ("C-x t B"   . treemacs-bookmark)
	    ("C-x t C-t" . treemacs-find-file)
	    ("C-x t M-t" . treemacs-find-tag)))
(use-package treemacs-evil)
(use-package treemacs-projectile
  :after projectile)
(use-package treemacs-icons-dired
  :hook (dired-mode . treemacs-icons-dired-enable-once)
  :ensure t)
(use-package treemacs-magit
  :after (treemacs magit)
  :ensure t)
(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))
;; Language servers -----------------------------------------------------

;; enable breadcrumbs at the top of the buffer
(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")
  :config
  (lsp-enable-which-key-integration t)
  (setq lsp-clangd-binary-path "/opt/homebrew/opt/llvm@16/bin/clangd"))

;; enables automatic completions
(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind
  (:map company-active-map
	("<tab>" . company-complete-selection))
  (:map lsp-mode-map
	("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

;; Adds hints and actions when hovering over text in a buffer
;; Note: this is not compatible with flycheck-inline
(use-package lsp-ui
  :after lsp-mode
  :hook (lsp-mode . lsp-ui-mode))

;; Makes the completion box look better
(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy
  :after lsp)

(use-package dap-mode)

;; Flycheck for syntax checking (works with LSP)
(use-package flycheck
  :hook (prog-mode . flycheck-mode))

(use-package yasnippet)


;; Company backends for better C++ completion
(use-package company-c-headers
  :after company
  :config
  (add-to-list 'company-backends 'company-c-headers))

;; Setup window management keybinds

(global-set-key (kbd "C-c w h") 'windmove-left)
(global-set-key (kbd "C-c w j") 'windmove-down)
(global-set-key (kbd "C-c w k") 'windmove-up)
(global-set-key (kbd "C-c w l") 'windmove-right)

(defvar-keymap windmove-repeat-map
  :repeat t
  "h" #'windmove-left
  "j" #'windmove-down
  "k" #'windmove-up
  "l" #'windmove-right)


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons ccls cmake-mode company-box company-c-headers
		   counsel-projectile dap-mode doom-modeline
		   doom-themes evil-collection flycheck
		   flycheck-inline forge general helpful ivy-rich
		   lsp-ivy lsp-treemacs lsp-ui modern-cpp-font-lock
		   org-bullets rainbow-delimiters
		   treemacs-all-the-icons treemacs-evil
		   treemacs-icons-dired treemacs-magit
		   treemacs-nerd-icons treemacs-projectile use-package
		   which-key yasnippet))
 '(warning-suppress-types '((use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
