;;; mwr.el --- Core manual window resizing functionality -*- lexical-binding: t; -*-

;; Copyright (C) 2025
;; Author: Vitor Leal <hello@vitorl.com>
;; Version: 0.1.0
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
;; Core functionality for manual window resizing.

;;; Code:

(defgroup manual-window-resize nil
  "Manual window resize core functionality."
  :group 'convenience
  :prefix "mwr-")

(defcustom mwr-resize-step 50
  "Number of columns/rows to resize by in each step."
  :type 'integer
  :group 'manual-window-resize)

(add-to-list 'window-persistent-parameters '(manually-resized . writable))

;;; Helpers
(defun mwr--get-window-size (window)
  "Get the size of WINDOW as a cons cell (width . height)."
  (cons (window-width window) (window-height window)))

;;; Hooks
(defun mwr--preserve-window-sizes-hook ()
  "Preserve sizes for manually resized windows after window changes in current frame."
  (dolist (window (window-list (selected-frame)))
    (when-let ((stored-size (window-parameter window 'manually-resized)))
      (window-preserve-size window t t))))

;;; Core tracking functions
(defun mwr-mark-window-manually-resized (&optional window)
  "Mark WINDOW (or current window) as manually resized."
  (let ((win (or window (selected-window))))
    (window-preserve-size win t t)
    (set-window-parameter win 'manually-resized (mwr--get-window-size win))))

(defun mwr-is-window-manually-resized-p (&optional window)
  "Check if WINDOW (or current window) is marked as manually resized."
  (let ((win (or window (selected-window))))
    (window-parameter win 'manually-resized)))

(defun mwr-clear-window-manual-resize (&optional window)
  "Clear manual resize status for WINDOW (or current window)."
  (let ((win (or window (selected-window))))
    (window-preserve-size win t nil)
    (set-window-parameter win 'manually-resized nil)))

(defun mwr-clear-all-windows ()
  "Clear manual resize status for all windows."
  (interactive)
  (dolist (window (window-list))
    (mwr-clear-window-manual-resize window)))

(defun mwr-list-manually-resized-windows ()
  "List all manually resized windows."
  (interactive)
  (let ((resized-windows '()))
    (dolist (window (window-list))
      (when (window-parameter window 'manually-resized)
        (push (buffer-name (window-buffer window)) resized-windows)))
    (if resized-windows
        (message "Manually resized windows: %s" (string-join resized-windows ", "))
      (message "No manually resized windows"))))

;;; Window position detection
(defun mwr--win-position-vertical ()
  "Return window's vertical position: 'top, 'bottom, or 'middle."
  (let* ((win-edges (window-edges))
         (this-window-y-min (nth 1 win-edges))
         (this-window-y-max (nth 3 win-edges))
         (fr-height (frame-height)))
    (cond
     ((eq 0 this-window-y-min) 'top)
     ((eq (- fr-height 1) this-window-y-max) 'bottom)
     (t 'middle))))

(defun mwr--win-position-horizontal ()
  "Return window's horizontal position: 'left, 'right, or 'middle."
  (let* ((win-edges (window-edges))
         (this-window-x-min (nth 0 win-edges))
         (this-window-x-max (nth 2 win-edges))
         (fr-width (frame-width)))
    (cond
     ((eq 0 this-window-x-min) 'left)
     ((< (- fr-width this-window-x-max) 5) 'right)
     (t 'middle))))

;;; Core resize functions
(defun mwr-decrease-width ()
  "Decrease current window width and mark as manually resized."
  (interactive)
  (let ((resize-amount (pcase (mwr--win-position-horizontal)
                         ('right mwr-resize-step)
                         ('left (- mwr-resize-step))
                         (_ (- mwr-resize-step)))))
    (when (window-resizable nil resize-amount t nil t)
      (window-resize nil resize-amount t nil t)
      (mwr-mark-window-manually-resized))))

(defun mwr-increase-width ()
  "Increase current window width and mark as manually resized."
  (interactive)
  (let ((resize-amount (pcase (mwr--win-position-horizontal)
                         ('right (- mwr-resize-step))
                         ('left mwr-resize-step)
                         (_ mwr-resize-step))))
    (when (window-resizable nil resize-amount t nil t)
      (window-resize nil resize-amount t nil t)
      (mwr-mark-window-manually-resized))))

(defun mwr-decrease-height ()
  "Decrease current window height and mark as manually resized."
  (interactive)
  (let ((resize-amount (pcase (mwr--win-position-vertical)
                         ('top mwr-resize-step)
                         ('bottom (- mwr-resize-step))
                         (_ mwr-resize-step))))
    (when (window-resizable nil resize-amount nil nil t)
      (window-resize nil resize-amount nil nil t)
      (mwr-mark-window-manually-resized))))

(defun mwr-increase-height ()
  "Increase current window height and mark as manually resized."
  (interactive)
  (let ((resize-amount (pcase (mwr--win-position-vertical)
                         ('top (- mwr-resize-step))
                         ('bottom mwr-resize-step)
                         (_ (- mwr-resize-step)))))
    (when (window-resizable nil resize-amount nil nil t)
      (window-resize nil resize-amount nil nil t)
      (mwr-mark-window-manually-resized))))

;;; Minor mode definition
;;;###autoload
(define-minor-mode mwr-mode
  "Toggle manual window resize management.

When enabled, this global mode adds a hook to
=window-configuration-change-hook' to preserve the size of
windows that have been manually resized using =mwr-' commands, and adds a `manually-resized' persistent window parameter to track them."
  :init-value nil
  :lighter " MWR"
  :global t
  (if mwr-mode
      (progn
        (add-to-list 'window-persistent-parameters '(manually-resized . writable))
        (add-hook 'window-configuration-change-hook #'mwr--preserve-window-sizes-hook))
    (progn
      (setq window-persistent-parameters
            (delete '(manually-resized . writable) window-persistent-parameters))
      (remove-hook 'window-configuration-change-hook #'mwr--preserve-window-sizes-hook))))


(provide 'mwr)

;;; mwr.el ends here
