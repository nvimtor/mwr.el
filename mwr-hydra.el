;;; mwr-hydra.el --- Hydra integration for mwr.el -*- lexical-binding: t; -*-

;; Copyright (C) 2025

;; Author: Vitor Leal <hello@vitorl.com>
;; Version: 0.1.0
;; Package-Requires: ((mwr) (hydra))
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

;; Hydra integration for manual-window-resize.
;; Provides a convenient hydra interface for resizing windows.

;;; Code:

(require 'mwr)
(require 'hydra)

(defgroup manual-window-resize-hydra nil
  "Hydra integration for manual window resize."
  :group 'manual-window-resize
  :prefix "mwr-hydra-")

;;; Hydra definition

;;;###autoload
(defhydra mwr-hydra-window-resize (:color pink :hint nil
                                   :pre (when (fboundp 'mwr-gr-enter-resize-mode)
                                          (mwr-gr-enter-resize-mode))
                                   :post (when (fboundp 'mwr-gr-exit-resize-mode)
                                           (mwr-gr-exit-resize-mode)))
  "
⚙️ mwr.el
┌─────────────────────────────────────────────────────┐
│  Arrow Keys: Resize   │  Commands:                  │
│  ← → : Width          │  c: Clear current window    │
│  ↑ ↓ : Height         │  C: Clear all windows       │
└─────────────────────────────────────────────────────┘
"
  ("<left>"   mwr-decrease-width "← shrink width")
  ("<right>"  mwr-increase-width "→ grow width")
  ("<up>"     mwr-increase-height "↑ grow height")
  ("<down>"   mwr-decrease-height "↓ shrink height")
  ("h"        mwr-decrease-width "← shrink width")
  ("l"        mwr-increase-width "→ grow width")
  ("k"        mwr-increase-height "↑ grow height")
  ("j"        mwr-decrease-height "↓ shrink height")
  ("c"        (progn (mwr-clear-window-manual-resize)
                     (message "Current window cleared")) "clear current" :color blue)
  ("C"        (progn (mwr-clear-all-windows)
                     (message "All windows cleared")) "clear all" :color blue)
  ("<escape>" nil "cancel" :color blue)
  ("q"        nil "quit" :color blue))

;;; Convenience functions

;;;###autoload
(defun mwr-hydra-start-resize ()
  "Start the manual window resize hydra."
  (interactive)
  (mwr-hydra-window-resize/body))

(provide 'mwr-hydra)

;;; mwr-hydra.el ends here
