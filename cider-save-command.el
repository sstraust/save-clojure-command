;; -*- lexical-binding: t -*-

(defcustom cider-saved-commands '((1 "(println \"test-cmd2\")"))
     "Foo's doc."
     :type  '(alist :value-type (integer string))
     :group 'convenience)


(defun set-command-in-cider-saved-commands (command-num command-value)
  (customize-save-variable 'cider-saved-commands
			   (cons (list command-num command-value)
				 (cl-remove-if (lambda (x) (= (car x) command-num))
					       cider-saved-commands))))

(defun cider-save-last-sexp (command-num)
  (cider-interactive-eval
   (concat "`" (cider-last-sexp))
   (lambda (value) (when (nrepl-dict-get value "value") (set-command-in-cider-saved-commands command-num (nrepl-dict-get value "value"))))
   nil
   (cider--nrepl-pr-request-map)))



(defun cider-get-saved-command (command-num)
  (car (cdr (car (cl-remove-if-not (lambda (x) (= (car x) command-num)) cider-saved-commands)))))

(defun cider-exec-saved-command (command-num)
  (cider-interactive-eval
   (cider-get-saved-command command-num)
   nil
   nil
   (cider--nrepl-pr-request-map)))
  

(mapcar
 (lambda (x)
   (add-hook 'cider-mode-hook
	     (lambda () (local-set-key (kbd (concat "C-c C-s C-" (number-to-string x)))
				       (lambda () (interactive) (cider-save-last-sexp x))))))
 (number-sequence 1 9))

(mapcar
 (lambda (x)
   (add-hook 'cider-mode-hook
	     (lambda () (local-set-key (kbd (concat "C-c C-" (number-to-string x)))
				       (lambda () (interactive) (cider-exec-saved-command x))))))
 (number-sequence 1 9))

(provide 'cider-save-command)
