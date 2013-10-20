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

(defvar dklrt-LedgerFileSuffix "ldg"
"Suffix of Ledger File (excluding period).")

(defvar dklrt-RecurringConfigFileSuffix "rec"
"Suffix of Recurring Transactions Config File (excluding period).")

(defconst dklrt-PackageDirectory
 (if load-file-name
  (file-name-directory load-file-name)
  nil))

(defun dklrt-AppendRecurring()
"Appends recurring transactions to the current ledger buffer/file."
 (interactive)
 (dklrt-AppendRecurringOk t)

 (message "Appending recurring transactions...")
 (let*
  ((Lfn (buffer-file-name))
   (Cfn (dklrt-RecurringConfigFileName Lfn))
   (Pfn (expand-file-name "Recurring.py" dklrt-PackageDirectory))
   (Td (dkmisc-TimeApplyShift (dkmisc-DateToText) dklrt-RecurringDateShift))
   (Sc (format "python %s %s %s %s" Pfn Lfn Td Cfn))
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

(defun dklrt-AppendRecurringOk(&optional Throw)
"Return non nil if ok to append recurring transactions.
The current buffer must be unmodified, in ledger-mode, and a
Recurring Transactions Config File must exist for the current
file."
 (and
  (dklrt-IsLedgerMode Throw)
  (dklrt-Unmodified Throw)
  (dklrt-LedgerFileExists Throw)
  (dklrt-RecurringConfigFileExists Throw)))

(defun dklrt-IsLedgerMode(&optional Throw)
 "True if current buffer is a ledger buffer."
 (let*
  ((Rv (equal mode-name "Ledger")))
 (and (not Rv) Throw
  (error "Current buffer is not in ledger mode!"))
  Rv))

(defun dklrt-Unmodified(&optional Throw)
 "True if current buffer is unmodified."
 (let*
  ((Rv (not (buffer-modified-p))))
  (and (not Rv) Throw
   (error "Current buffer has changed! Please save it first!"))
  Rv))

(defun dklrt-LedgerFileExists(&optional Throw)
"Return t if the ledger file exists otherwise nil."
 (let*
  ((Lfn (buffer-file-name))
   (Rv (and Lfn (file-exists-p Lfn))))
  (and (not Rv) Throw
   (error "No such Ledger File: \"%s\"!" Lfn))
  Rv))

(defun dklrt-RecurringConfigFileExists(&optional Throw)
"Return t if the Recurring Config File exists, otherwise nil."
 (let*
  ((Lfn (buffer-file-name))
   (Cfn (dklrt-RecurringConfigFileName Lfn))
   (Rv (and Cfn (file-exists-p Cfn))))
  (and (not Rv) Throw
   (error "No such Recurring Config File: \"%s\"!" Cfn))
  Rv))

(defun dklrt-RecurringConfigFileName(LedgerFileName)
"Returns the corresponding recurring configuration file name.
 Removes the suffix (if any) and then appends the recurring
 suffix as per 'dklrt-RecurringConfigFileSuffix'."
 (concat (file-name-sans-extension LedgerFileName) "."
  dklrt-RecurringConfigFileSuffix))

(provide 'dklrt)
