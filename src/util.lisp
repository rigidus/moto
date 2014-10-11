
;;;; util.lisp

(in-package #:moto)

;; Превращает инициализированные поля объекта в plist
(defun get-obj-data (obj)
  (let ((class (find-class (type-of obj)))
        (result))
    (loop :for slot :in (closer-mop:class-direct-slots class) :collect
       (let ((slot-name (closer-mop:slot-definition-name slot)))
         (when (slot-boundp obj slot-name)
           (setf result
                 (append result (list (intern (symbol-name slot-name) :keyword)
                                      (funcall slot-name obj)))))))
    result))

;; Assembly WHERE clause
(defun make-clause-list (glob-rel rel args)
  (append (list glob-rel)
          (loop
             :for i
             :in args
             :when (and (symbolp i)
                        (getf args i)
                        (not (symbolp (getf args i))))
             :collect (list rel i (getf args i)))))

;; Макросы для корректного вывода ошибок
(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defmacro err (var)
  `(error (format nil "ERR:[~A]" (bprint ,var))))

;; Отладочный вывод
(defparameter *dbg-enable* t)
(defparameter *dbg-indent* 1)

(defun dbgout (out)
  (when *dbg-enable*
    (format t (format nil "~~%~~~AT~~A" *dbg-indent*) out)))

(defmacro dbg (frmt &rest params)
  `(dbgout (format nil ,frmt ,@params)))

;; (macroexpand-1 '(dbg "~A~A~{~A~^,~}" "zzz" "34234" '(1 2 3 4)))

(defun anything-to-keyword (item)
  (intern (string-upcase (format nil "~a" item)) :keyword))

(defun alist-to-plist (alist)
  (if (not (equal (type-of alist) 'cons))
      alist
      ;;else
      (loop
         :for (key . value)
         :in alist
         :nconc (list (anything-to-keyword key) value))))
