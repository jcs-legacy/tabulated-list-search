;;; tabulated-list-filter.el --- Provide filtering/searching tabulated-list interface.  -*- lexical-binding: t; -*-

;; Copyright (C) 2019  Shen, Jen-Chieh
;; Created date 2019-07-15 20:00:02

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Description: Provide filtering/searching tabulated-list interface.
;; Keyword: filtering interface list searching tabulated
;; Version: 0.0.1
;; Package-Requires: ((emacs "24.3"))
;; URL: https://github.com/jcs090218/tabulated-list-filter

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
;; Provide filtering/searching tabulated-list interface.
;;

;;; Code:

(require 'tabulated-list)


(defgroup tabulated-list-filter nil
  "Provide filtering/searching tabulated-list interface."
  :prefix "tabulated-list-filter-"
  :group 'tool
  :link '(url-link :tag "Repository" "https://github.com/jcs090218/tabulated-list-filter"))


(defcustom tabulated-list-filter-filter-delay 0.3
  "Store filter timer function."
  :type 'float
  :group 'tabulated-list-filter)

(defvar-local tabulated-list-filter--filter-timer nil
  "Store filter timer function.")


(provide 'tabulated-list-filter)
;;; tabulated-list-filter.el ends here
