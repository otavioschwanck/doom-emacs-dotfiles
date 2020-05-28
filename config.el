;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Otávio Schwanck dos Santos"
      user-mail-address "otavio.schwanck@grafeno.digital")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
(setq doom-font (font-spec :family "Source Code Pro" :size 15))
;; (setq doom-font (font-spec :family "Source Code Pro" :size 15 :weight 'bold))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-molokai)
;; (setq doom-theme 'doom-one-light)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Dropbox/org")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.

(setq display-line-numbers-type t)

;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c g k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c g d') to jump to their definition and see how
;; they are implemented.

;; Indent 2 spaces
(after! web-mode
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-markup-indent-offset 2))

(after! js2-mode
  (setq js-indent-level 2)
  (setq indent-tabs-mode nil))

;; Spotify
(use-package! helm-spotify-plus
  :config
  (map! :leader
        :map global-map
        :prefix "5"
        "p" #'helm-spotify-plus-previous
        "n" #'helm-spotify-plus-next
        "x" #'helm-spotify-plus-pause
        "q" #'helm-spotify-plus-queue-stop
        "s" #'helm-spotify-plus
        "w" #'helm-spotify-plus-play
        ))

;; Magit fetch when select a project
(after! projectile
  (defun projectile-git-fetch (_project)
    (magit-status)
    (if (fboundp 'magit-fetch-from-upstream)
        (call-interactively #'magit-fetch-from-upstream)
      (call-interactively #'magit-fetch-current)))

  (setq +workspaces-switch-project-function #'projectile-git-fetch)
  )

;; jj to escape evil, when you ever typed jj ?
(setq-default evil-escape-key-sequence "jj")
(setq-default evil-escape-delay 0.5)

;; Projectile globally with SPC r
(require 'projectile-rails)
(map! :leader "r" #'projectile-rails-command-map)

;; Fix projectile texts
(after! which-key
  (push '((nil . "projectile-rails-\\(.+\\)") . (nil . "\\1"))
        which-key-replacement-alist))

(after! ruby-mode
  ;; SPC m C to copy class name, super useful to test things on console.
  (defun endless/-ruby-symbol-at-point ()
    (let ((l (point)))
      (save-excursion
        (forward-sexp 1)
        (buffer-substring l (point)))))

  (defun endless/ruby-copy-class-name ()
    (interactive)
    (save-excursion
      (let ((name nil)
            (case-fold-search nil))
        (skip-chars-backward (rx (syntax symbol)))
        (when (looking-at-p "\\_<[A-Z]")
          (setq name (endless/-ruby-symbol-at-point)))
        (while (ignore-errors (backward-up-list) t)
          (when (looking-at-p "class\\|module")
            (save-excursion
              (forward-word 1)
              (skip-chars-forward "\r\n[:blank:]")
              (setq name (if name
                             (concat (endless/-ruby-symbol-at-point) "::" name)
                           (endless/-ruby-symbol-at-point))))))
        (kill-new name)
        (message "Copied %s" name))))

  ;; binding it to SPC m C
  (map! :map ruby-mode-map :localleader "C" #'endless/ruby-copy-class-name)
  )

(use-package! nyan-mode
  :config
  (setq nyan-animate-nyancat t)
  (nyan-mode))

(remove-hook 'text-mode-hook #'visual-line-mode)

(defun indent-whole-buffer ()
  "INDENT WHOLE BUFFER."
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max))
  )

(defvar robe-time-to-start 30
  "Set the time to start robe after starting inf-ruby-console-auto")

(defvar robe-auto-start-on-ruby-files t
  "If t, auto-start robe")

(defun rails-better-robe-start ()
  "Opens robe start silently"
  (interactive)
  (when robe-auto-start-on-ruby-files
    (save-window-excursion (inf-ruby-console-auto))
    (run-at-time robe-time-to-start nil #'robe-start)))

(add-hook 'ruby-mode-hook 'rails-better-robe-start)

(defun file-path-to-test (filename)
  (if (string-match-p "/spec/" filename)
      (if (string-match-p "/admin/" filename)
          (concat
           (replace-regexp-in-string "/spec/controllers/" "/app/" (file-name-directory filename))
           (singularize-string (replace-regexp-in-string "_controller_spec" "" (file-name-base filename)))
           "."
           (file-name-extension filename))
        (concat
         (replace-regexp-in-string "/spec/" "/app/" (file-name-directory filename))
         (replace-regexp-in-string "_spec" "" (file-name-base filename))
         "."
         (file-name-extension filename)))
    (if (string-match-p "/admin/" filename)
        (concat
         (replace-regexp-in-string "/app/" "/spec/controllers/" (file-name-directory filename))
         (pluralize-string (file-name-base filename))
         "_controller_spec."
         (file-name-extension filename))
      (concat
       (replace-regexp-in-string "/app/" "/spec/" (file-name-directory filename))
       (file-name-base filename)
       "_spec."
       (file-name-extension filename)))))

(defun goto-test-and-vsplit ()
  (interactive)
  (if (string-match-p "/spec/" buffer-file-name) (find-file (file-path-to-test buffer-file-name)))
  (delete-other-windows)
  (evil-window-vsplit)
  (evil-window-right 1)
  (if (string-match-p "/app/" buffer-file-name) (find-file (file-path-to-test buffer-file-name))))

(defun goto-test ()
  (interactive)
  (find-file (file-path-to-test buffer-file-name)))

(map! :mode ruby-mode-map :leader "a" 'goto-test)
(map! :mode ruby-mode-map :leader "A" 'goto-test-and-vsplit)

(setq read-process-output-max (* 1024 1024))
(map! :mode shell-mode-map :leader "l" 'comint-clear-buffer)

;; (load "~/.doom.d/no_evil.el")
(load "~/.doom.d/with_evil.el")

