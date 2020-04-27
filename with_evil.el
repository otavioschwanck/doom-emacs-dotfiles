;;; ~/.doom.d/with_evil.el -*- lexical-binding: t; -*-

;; C-p when company is active
(map! :after company
      :map company-active-map
      "C-p" nil)

(map! :map ruby-mode-map
      "C-M-k" #'ruby-beginning-of-block
      "C-M-j" #'ruby-end-of-block)

(map! :n "C-<SPC>" #'er/expand-region)
