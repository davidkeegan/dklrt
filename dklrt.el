;;; dklrt.el --- Ledger Recurring Transactions.

;; Copyright: (c) David Keegan 2011-2013.
;; Licence: FSF GPLv3.
;; Author: David Keegan <dksw@eircom.net>
;; Version: 0.1
;; Package-Requires: ((ldg-mode "20130908.1357") (emacs "24.1"))
;; Keywords: ledger ledger-cli recurring periodic automatic
;; URL: https://github.com/davidkeegan/dklrt

;;; Commentary:

;; An add-on to ledger-mode which inserts recurring transactions to
;; the current file.

;;; Code:

(defvar dklrt-RecurringDateShift "1w"
 "Recurring transactions posted up to today plus specified period.
  In do list format: <integer>y|m|d|w|h.")

(defconst dklrt-PackageDirectory
 (if load-file-name
  (file-name-directory load-file-name)
  nil))

(defun dklrt-AppendRecurring()
"Appends recurring transactions to the current ledger buffer/file."
 (interactive)
 (dklrt-BufferIs "ldg" t)
 (if (buffer-modified-p)
  (error "Buffer has changed! Please save it first!"))

 (message "Appending recurring transactions...")
 (let*
  ((Lfn (buffer-file-name))
   (Lfd (file-name-directory Lfn))
   (Pfn (expand-file-name "Recurring.py" dklrt-PackageDirectory))
   (Td (dkmisc-TimeApplyShift (dkmisc-DateToText) dklrt-RecurringDateShift))
   (Sc (format "python %s %s %s" Pfn Lfn Td))
   (So (shell-command-to-string Sc)))

  ; Check for error.
  (and (> (length So) 0) (error So))

  ; Sync buffer with (possibly) altered file.
  ; NB: Suppress mode reinitialisation to avoid infinite loop.
  (revert-buffer t t t)

  ; Ensure transactons are in date order.
  (ledger-sort-buffer)
  (save-buffer)
  (end-of-buffer)))

(defun dklrt-BufferIs(Filetype &optional Throw)
 "True if current buffer is a ledger buffer."
 (let*
  ((Rv
    (and (string-match (concat "\\" Filetype "$") (buffer-file-name))
     (equal mode-name "Ledger"))))
  (and (not Rv) Throw
   (error "Not a \".%s\" file in ledger mode!" Filetype))
  Rv))

(provide 'dklrt)
