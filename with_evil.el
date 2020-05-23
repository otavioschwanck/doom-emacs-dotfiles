 ;;; ~/.doom.d/with_evil.el -*- lexical-binding: t; -*-

;; C-p when company is active
(map! :after company
      :map company-active-map
      "C-p" nil)

(map! :map ruby-mode-map
      "C-k" #'ruby-beginning-of-block
      "C-j" #'ruby-end-of-block)

(map! :nomv "C-e" 'end-of-line)

(map! :n "C-<SPC>" #'er/expand-region)

(map! :i "<C-return>" #'+company/dabbrev)

(defun save-all-buffers ()
  (interactive)
  (save-some-buffers 0))

(map! :n "ç" #'save-all-buffers)

(map! :nv "<tab>" #'evil-ex-search-forward)
(map! :nv "<C-tab>" #'evil-ex-search-backward)

(map! :n "C-," #'previous-buffer)
(map! :n "C-;" #'next-buffer)

(map! :after company
      :map company-active-map
      "<tab>" #'yas-expand)

(after! company
  (defadvice! +company--abort-previous-a (&rest _)
    :before #'company-begin-backend
    (company-abort))

  (setq company-dabbrev-downcase 0)
  (setq company-idle-delay 0.15))

(defun yas-next-and-close-company ()
  (interactive)
  (company-abort)
  (yas-next-field))

(map! :after yasnippet
      :map yas-keymap
      "<tab>" 'yas-next-and-close-company)

(after! ruby-mode
  (defun msc/revert-buffer-noconfirm ()
    "Call `revert-buffer' with the NOCONFIRM argument set."
    (interactive)
    (revert-buffer nil t))

  (defun rubocop-on-current-file ()
    "RUBOCOP ON CURRENT_FILE."
    (interactive)
    (save-buffer)
    (message "%s" (shell-command-to-string
                   (concat "bundle exec rubocop -a "
                           (shell-quote-argument (buffer-file-name)))))
    (msc/revert-buffer-noconfirm))
  (map! :mode ruby-mode-map :leader "=" #'rubocop-on-current-file))

(map! :leader "-" #'indent-whole-buffer)
(global-set-key (kbd "C-j") (kbd "C-M-n"))
(global-set-key (kbd "C-k") (kbd "C-M-p"))

(map! :v "K" #'drag-stuff-up)
(map! :v "J" #'drag-stuff-down)
(map! :nv "0" #'doom/backward-to-bol-or-indent)
(map! :nv "-" #'end-of-line)

(map! :map ruby-mode-map :localleader "S" #'rails-better-robe-start)

(map! :leader "k" #'kill-current-buffer)
(map! :nv "]g" #'git-gutter:next-hunk)
(map! :nv "[g" #'git-gutter:previous-hunk)
(map! :nv "C-s" #'evil-avy-goto-char-2)

(map! :ieg "C-q" #'evil-paste-after)

(defun noob ()
  (interactive)
  (message "Eu to te vendo o demonio! Use CAPS para sair e movimentar.  Treine para sair e entrar rapidamente do insert mode com a, i, A, I c ci C"))

(map! :map (ruby-mode-map rspec-mode-map yaml-mode-map)
      [left]  #'noob
      [right] #'noob
      [up]    #'noob
      [down]  #'noob)

(map! :map (ruby-mode-map rspec-mode-map yaml-mode-map)
      :n [left]  #'noob
      :n [right] #'noob
      :n [up]    #'noob
      :n [down]  #'noob)

(map! :mode shell-mode-map :leader "l" 'comint-clear-buffer)
