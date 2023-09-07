;;; tabulated-list-search.el --- Seach in tabulated-list mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2019-2023  Shen, Jen-Chieh
;; Created date 2019-07-15 20:00:02

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Seach in tabulated-list mode.
;; Keyword: filtering interface list searching tabulated
;; Version: 0.1.2
;; Package-Requires: ((emacs "25.1"))
;; URL: https://github.com/jcs-legacy/tabulated-list-search

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Seach in tabulated-list mode.
;;

;;; Code:

(require 'tabulated-list)

(defgroup tabulated-list-search nil
  "Seach in tabulated-list mode."
  :prefix "tabulated-list-search-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/jcs-legacy/tabulated-list-search"))

(defcustom tabulated-list-search-mode-enabled-hook nil
  "Hooks run after `tabulated-list-search-mode' is enabled."
  :type 'hook
  :group 'tabulated-list-search)

(defcustom tabulated-list-search-mode-disabled-hook nil
  "Hooks run after `tabulated-list-search-mode' is disabled."
  :type 'hook
  :group 'tabulated-list-search)

(defcustom tabulated-list-search-delay 0.1
  "Input delay to refresh buffer."
  :type 'float
  :group 'tabulated-list-search)

(defcustom tabulated-list-search-title-prefix "Search: "
  "Header put infront of the search string."
  :type 'string
  :group 'tabulated-list-search)

(defconst tabulated-list-search--key-list
  '("a" "b" "c" "d" "e" "f" "g" "h" "i" "j" "k" "l" "m"
    "n" "o" "p" "q" "r" "s" "t" "u" "v" "w" "x" "y" "z"
    "A" "B" "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M"
    "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z"
    "1" "2" "3" "4" "5" "6" "7" "8" "9" "0" "-" "=" "`"
    "!" "@" "#" "$" "%" "^" "&" "*" "(" ")" "_" "\\" "~"
    "{" "}" "[" "]" ";" ":" "'" "\"" "," "." "<" ">" "/"
    "?" "|" " ")
  "List of key to bind.")

(defvar-local tabulated-list-search--done-filtering 1
  "Flag to check if done filtering.")

(defvar-local tabulated-list-search--filter-timer nil
  "Store filter timer function.")

(defvar-local tabulated-list-search--seach-column 3
  "Target column to do the search.")

(defvar-local tabulated-list-search--prev-mode-map nil
  "Record previous tabulated-list mode map.")

(defvar-local tabulated-list-search--return-delay nil
  "Record if hit return when display not ready; once it is ready we redo the action.")

(defvar-local tabulated-list-search--return-key-func nil
  "Record down the return key function name")

(defvar-local tabulated-list-search--backspace-key-func nil
  "Record down the backspace key function name")

(defun tabulated-list-search-return ()
  "Implemenetation for in `tabulated-list-mode' return key."
  (interactive)
  (if (or tabulated-list-search--done-filtering
          (string= tabulated-list--header-string tabulated-list-search-title-prefix))
      (if (ignore-errors (funcall-interactively tabulated-list-search--return-key-func))
          (message nil)  ; Use to clear `[Display not ready]'.
        (user-error "No entry on this line"))
    (setq tabulated-list-search--return-delay t)
    (message "[Display not ready]")))

(defun tabulated-list-search--filter-list ()
  "Do filtering the list."
  (setq tabulated-list-search--done-filtering nil)
  (while (< (line-number-at-pos) (line-number-at-pos (point-max)))
    (let* ((item-name (elt (tabulated-list-get-entry) tabulated-list-search--seach-column))
           (search-str (substring tabulated-list--header-string
                                  (length tabulated-list-search-title-prefix)
                                  (length tabulated-list--header-string))))
      (when (listp item-name) (setq item-name (nth 0 item-name)))
      (if (and (stringp item-name)
               (string-match-p search-str (substring-no-properties item-name)))
          (forward-line 1)
        (tabulated-list-delete-entry))))
  (progn  ; Goto line 2.
    (goto-char (point-min))
    (forward-line (1- 2)))
  (setq tabulated-list-search--done-filtering t)
  ;; Once it is done filtering, we redo return action if needed.
  (when tabulated-list-search--return-delay
    (tabulated-list-search-return)))

(defun tabulated-list-search--input (key-input &optional add-del-num)
  "Insert key KEY-INPUT for fake header for search bar.
ADD-DEL-NUM : Addition or deletion number."
  (unless add-del-num (setq add-del-num (length key-input)))
  (if (< 0 add-del-num)
      (setq tabulated-list--header-string
            (concat tabulated-list--header-string key-input))
    (setq tabulated-list--header-string
          (substring tabulated-list--header-string 0 (1- (length tabulated-list--header-string)))))
  ;; NOTE: Ensure title exists.
  (when (> (length tabulated-list-search-title-prefix) (length tabulated-list--header-string))
    (setq tabulated-list--header-string tabulated-list-search-title-prefix))
  (tabulated-list-revert)
  (tabulated-list-print-fake-header)
  (when (timerp tabulated-list-search--filter-timer)
    (cancel-timer tabulated-list-search--filter-timer))
  (setq tabulated-list-search--filter-timer
        (run-with-idle-timer tabulated-list-search-delay
                             nil
                             'tabulated-list-search--filter-list)))

(defun tabulated-list-search--enable ()
  "Enable `tabulated-list-search' in current buffer."
  (setq tabulated-list-search--prev-mode-map tabulated-list-mode-map)
  (dolist (key-str tabulated-list-search--key-list)
    (define-key tabulated-list-mode-map key-str
      (lambda () (interactive) (tabulated-list-search--input key-str))))
  (progn  ; Bind return
    (setq tabulated-list-search--return-key-func (key-binding (kbd "<return>")))
    (unless  tabulated-list-search--return-key-func
      (setq tabulated-list-search--return-key-func (key-binding (kbd "RET"))))
    (define-key tabulated-list-mode-map (kbd "<return>") #'tabulated-list-search-return))
  (progn  ; Bind backspace
    (setq tabulated-list-search--backspace-key-func (key-binding (kbd "<backspace>")))
    (define-key tabulated-list-mode-map (kbd "<backspace>")
      (lambda () (interactive) (tabulated-list-search--input "" -1))))
  (run-hooks 'tabulated-list-search-mode-enabled-hook))

(defun tabulated-list-search--disable ()
  "Disable `tabulated-list-search' in current buffer."
  (setq-local tabulated-list-mode-map tabulated-list-search--prev-mode-map)
  (progn  ; Unbind return
    (define-key tabulated-list-mode-map (kbd "<return>") tabulated-list-search--return-key-func)
    (setq tabulated-list-search--return-key-func nil))
  (progn  ; Unbind backspace
    (define-key tabulated-list-mode-map (kbd "<backspace>") tabulated-list-search--backspace-key-func)
    (setq tabulated-list-search--backspace-key-func nil))
  (run-hooks 'tabulated-list-search-mode-disabled-hook))

;;;###autoload
(define-minor-mode tabulated-list-search-mode
  "Minor mode 'tabulated-list-search-mode'."
  :lighter " TLS"
  :group tabulated-list-search
  (if tabulated-list-search-mode (tabulated-list-search--enable) (tabulated-list-search--disable)))

(defun tabulated-list-search-turn-on-tabulated-list-search-mode ()
  "Turn on the 'tabulated-list-search-mode'."
  (tabulated-list-search-mode 1))

;;;###autoload
(define-globalized-minor-mode global-tabulated-list-search-mode
  tabulated-list-search-mode tabulated-list-search-turn-on-tabulated-list-search-mode
  :require 'tabulated-list-search)

(provide 'tabulated-list-search)
;;; tabulated-list-search.el ends here
