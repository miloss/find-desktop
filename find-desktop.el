;;; find-desktop.el --- Find desktop quickly

;; Copyright (c) 2015 - 2017 Milos Popovic <the.elephant@gmail.com>

;; Author: Milos Popovic <the.elephant@gmail.com>
;; Version: 0.2.0
;; URL: http://github.com/miloss/find-desktop
;; Package-Requires: ((emacs "24.0"))
;; Created: 2016-06-20
;; Keywords: desktop, project, sessions, convenience

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth
;; Floor, Boston, MA 02110-1301, USA.

;;; Comentary:

;; `find-desktop' displays a list of directories to select by auto
;; completing their name. Desktops are stored in a `fd-desktops-file'
;; as simple list of paths separated by newline.

(defvar fd-desktops-file
  "~/.emacs.desktops.list"
  "Location of a file to store all desktops.")

;; If this file is not present, `find' command scans entire $HOME folder
;; for all directories containing `.emacs.desktop' file and results are
;; cached to `fd-desktops-file'.

;; Desktop directory is chosen by auto-completing its name with
;; duplicate directories distinguished by parent directory name. If Ido
;; is present, `ido-completing-read' is used instead of default
;; `completing-read'.

;; When a desktop is selected:
;;  - any previously loaded desktop is saved
;;  - new selected desktop is loaded
;;  - its name is stored to `fd-desktop-name' variable
;;  - message is displayed to the user
;;  - message is displayed to the user

;; If desktop loaded for the first time - a `dired' buffer is opened at
;; the directory.

;;; Installation and usage:

;; To install, drop this file somewhere into Emacs load path and load it:
;;   (require `find-desktop')

;; To use, simply run `M-x find-desktop'. Recommended binding is:
;;   (global-set-key (kbd "C-x C-d") 'find-desktop)

;;; Code:


(defvar fd-desktop-name
  ""
  "Directory name of currently loaded desktop.")


(defun fd-desktop-find ()
  "Return output of GNU 'find' command over a $HOME directory.

Uses cached output from `fd-desktops-file' file, if available."
    (if (file-exists-p fd-desktops-file)
            (shell-command-to-string
             (concat "cat " fd-desktops-file))
        (shell-command-to-string
         (concat "find ~ -name '.emacs.desktop' -print 2>/dev/null"
                 " | xargs dirname"
                 " > " fd-desktops-file
                 "; cat " fd-desktops-file))))

(defun fd-desktops-list ()
  "Return an alist of all desktop directories and their path.

Files with duplicate folder name are suffixed with the name of the
parent directory they are found in so that they are unique."
  (let ((file-alist nil))
    (mapcar (lambda (file)
              (let ((file-cons (cons (file-name-nondirectory file)
                                     (expand-file-name file))))
                (when (assoc (car file-cons) file-alist)
                  (fd-uniqueify (assoc (car file-cons) file-alist))
                  (fd-uniqueify file-cons))
                (add-to-list 'file-alist file-cons)
                file-cons))
            (split-string (fd-desktop-find)))))

(defun fd-uniqueify (file-cons)
  "Set the car of the argument to include the directory name plus the file name."

  (setcar file-cons
          (concat (car file-cons) " "
                  (cadr (reverse (split-string (cdr file-cons) "/"))))))

(defun fd-find-desktop ()
  "Prompt with a completing list of all desktops to find one.

Desktop is defined as topmost directory containing `.emacs.desktop' file."

  (interactive)
  (let* ((desktops-found (fd-desktops-list))
         (file (if (functionp 'ido-completing-read)
                   (ido-completing-read "Find desktop: "
                                        (mapcar 'car desktops-found))
                 (completing-read "Find desktop: "
                                  (mapcar 'car desktops-found)))))
    (cdr (assoc file desktops-found))))

(defun find-desktop ()
  "Find desktop and display message about it"

  (interactive)
  (let* ((dirpath (fd-find-desktop)))
    (if (boundp 'desktop-dirname)
        (session-save))
    (desktop-change-dir dirpath)
    (setq fd-desktop-name (file-name-nondirectory (directory-file-name dirpath)))
    (message (concat "Desktop read from " dirpath))
    (if (not (file-exists-p (concat dirpath "/.emacs.desktop")))
        (dired dirpath))))

(provide 'find-desktop)
;;; find-desktop.el ends here
