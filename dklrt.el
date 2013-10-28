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

(defvar dklrt-SortAfterAppend nil
"If t, sort buffer after append to ensure recurring transactions are
positioned by date.")

(defvar dklrt-PythonProgram "python"
"Python interpreter to be run.")

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

;DkTbd:
(or dklrt-PackageDirectory 
 (setq dklrt-PackageDirectory "/opt/dk/emacs/dklrt-20131028.821/"))

(defun dklrt-SetCcKeys()
"Bind \C-cr to dklrt-AppendRecurring.
To invoke, add this function to ledger-mode-hook."
 (define-key (current-local-map) "\C-cr" 'dklrt-AppendRecurring))

(defun dklrt-AppendRecurringMaybe()
"Call dklrt_AppendRecurring(), but only if appropriate."
 (interactive)
 (if (dklrt-AppendRecurringOk) (dklrt-AppendRecurring)))

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
   (Sc (format "%s %s %s %s %s" dklrt-PythonProgram Pfn Lfn Td Cfn)))

   (message "Invoking: \"%s\"..." Sc)
   (let*
    ((Fl (point-max))
     (So (shell-command-to-string Sc)))

    ; Check for error.
    (and (> (length So) 0) (error So))

    ; Sync buffer with (possibly) altered file.
    ; NB: Suppress mode reinitialisation to avoid infinite loop.
    (revert-buffer t t t)
    
    ; Transactions were appended?
    (if (> (point-max) Fl)
     (progn
      (if dklrt-SortAfterAppend
       (progn
        (message "Sorting buffer transactions by date...")
        (ledger-sort-buffer)))

      (message "Saving ledger buffer...") 
      (save-buffer))))))

(defun dklrt-AppendRecurringOk(&optional Throw)
"Return non nil if ok to append recurring transactions.
The current buffer must be unmodified, in ledger-mode, and a
Recurring Transactions Config File must exist for the current
file."
 (and
  (dklrt-IsLedgerMode Throw)
  (dklrt-NotRecurringConfigFile Throw)
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

(defun dklrt-NotRecurringConfigFile(&optional Throw)
 "True if current buffer is not a Recurring Config File."
 (let*
  ((Fne (file-name-extension (buffer-file-name)))
   (Rv (not (string= Fne dklrt-RecurringConfigFileSuffix))))

  (and (not Rv) Throw
   (error "Cannot append recurring transactions to Config File!"))
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
