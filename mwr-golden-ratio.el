;;; mwr-golden-ratio.el --- golden-ratio integration for mwr -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;; Author: Vitor Leal <hello@vitorl.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "24.3") (mwr "0.1.0") (golden-ratio "1.0"))
;; Keywords: convenience, windows
;; URL: https://github.com/nvimtor/mwr.el

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; Integration between mwr and golden-ratio.
;; Inhibits golden-ratio for manually resized windows.

;;; Code:

(require 'mwr)
(require 'golden-ratio)

(defgroup manual-window-resize-golden-ratio nil
  "Golden ratio integration for manual window resize."
  :group 'manual-window-resize
  :prefix "mwr-gr-")

(defvar mwr-gr--resize-mode-active nil
  "Flag indicating if we're currently in resize mode.")

;;; Integration functions

(defun mwr-gr--inhibit-function ()
  "Inhibit function for golden-ratio integration.
Returns non-nil if golden-ratio should be inhibited."
  (or mwr-gr--resize-mode-active
      (mwr-is-window-manually-resized-p)))

(defun mwr-gr-enter-resize-mode ()
  "Enter resize mode - inhibit golden-ratio temporarily."
  (setq mwr-gr--resize-mode-active t))

(defun mwr-gr-exit-resize-mode ()
  "Exit resize mode - allow golden-ratio again."
  (setq mwr-gr--resize-mode-active nil))

(defun mwr-gr-clear-current-window-and-apply ()
  "Clear manual resize status for current window and apply golden-ratio."
  (interactive)
  (mwr-clear-window-manual-resize)
  (when (fboundp 'golden-ratio)
    (golden-ratio)))

(defun mwr-gr--setup-integration ()
  "Set up integration with golden-ratio."
  (when (boundp 'golden-ratio-inhibit-functions)
    (add-to-list 'golden-ratio-inhibit-functions #'mwr-gr--inhibit-function)))

(defun mwr-gr--cleanup-integration ()
  "Clean up integration with golden-ratio."
  (when (boundp 'golden-ratio-inhibit-functions)
    (setq golden-ratio-inhibit-functions
          (remove #'mwr-gr--inhibit-function golden-ratio-inhibit-functions))))

;;;###autoload
(define-minor-mode mwr-golden-ratio-mode
  "Minor mode for golden-ratio integration with manual window resize."
  :global t
  :group 'manual-window-resize-golden-ratio
  :lighter " MWR-GR"
  (if mwr-golden-ratio-mode
      (mwr-gr--setup-integration)
    (mwr-gr--cleanup-integration)))

(provide 'mwr-golden-ratio)

;;; mwr-golden-ratio.el ends here
