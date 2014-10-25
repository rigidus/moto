
;; Do not prompt to confirm evaluation
;; This may be dangerous - make sure you understand the consequences
;; of setting this -- see the docstring for details
(setq org-confirm-babel-evaluate nil)

(defun gen-fields (table)
  (let ((rows (nthcdr 2 table)))
    (princ (format "(%s\n" (butlast (car rows))))
    (mapcar #'(lambda (x)
                (princ (format " %s\n" (butlast x))))
            (butlast (cdr rows)))
    (princ (format " %s)" (butlast (car (last rows)))))))

(defun gen-states (table)
  (let ((rows (nthcdr 2 table))
        (hash (make-hash-table :test #'equal))
        (states))
    (dolist (elt rows nil)
      (puthash (cadr elt) nil hash)
      (puthash (cadr (cdr elt))  nil hash))
    (maphash (lambda (k v)
               (push k states))
             hash)
    (princ "(")
    (dolist (elt (butlast states))
      (princ (format ":%s " elt)))
    (princ (format ":%s)" (car (last states))))))

(defun gen-actions (table)
  (let ((rows (nthcdr 2 table)))
    (let ((x (car rows)))
      (princ (format "((:%s :%s :%s)" (cadr x) (cadr (cdr x)) (car x))))
    (if (equal 1 (length rows))
        (princ ")\n")
        (progn
          (princ "\n")
          (mapcar #'(lambda (x)
                      (princ (format " (:%s :%s :%s)\n" (cadr x) (cadr (cdr x)) (car x))))
                  (cdr (butlast rows)))
          (let ((x (car (last rows))))
            (princ (format " (:%s :%s :%s))" (cadr x) (cadr (cdr x)) (car x))))))))
