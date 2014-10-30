;; [[file:doc.org::*Утилиты][utility_file]]
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

(in-package #:moto)

(defmacro with-wrapper (&body body)
  `(progn
     (hunchentoot:start-session)
     (let* ((*current-user* (hunchentoot:session-value 'current-user))
            (retval)
            (output (with-output-to-string (*standard-output*)
                      (setf retval ,@body))))
       (declare (special *current-user*))
       (tpl:root
        (list
         :title "title"
         :content
         (format
          nil "~{~A~}"
          (list
           (tpl:dbgblock (list :dbgout output))
           (tpl:userblock (list :currentuser (if (null *current-user*)
                                                 "none"
                                                 *current-user*)))
           (if *current-user*
               (tpl:msgblock
                (list :msgcnt (get-undelivered-msg-cnt *current-user*)))
               "")
           (tpl:menublock
            (list
             :menu
             (format
              nil "~{~A<br />~}"
              (remove-if
               #'null
               (list
                "<a href=\"/users\">Список пользователей</a>"
                (when (null *current-user*)
                  "<a href=\"/reg\">Регистрация</a>")
                (when (null *current-user*)
                  "<a href=\"/login\">Логин</a>")
                (when (null *current-user*)
                  "Больше возможностей доступно залогиненным пользоватям")
                (when *current-user*
                  (format nil "<a href=\"/user/~A\">Мой профиль</a>" *current-user*))
                (when *current-user*
                  "<a href=\"/logout\">Выход</a>")
                )))))
           (tpl:retvalblock (list :retval retval)))))))))

(in-package #:moto)

(defun input (type &key name value)
  (format nil "~%<input type=\"~A\"~A~A/>" type
          (if name  (format nil " name=\"~A\"" name) "")
          (if value (format nil " value=\"~A\"" value) "")))

;; (input "text" :name "zzz" :value 111)
;; (input "submit" :name "submit-btn" :value "send")

(defun fld (name &optional (value ""))
  (input "text" :name name :value value))

(defun btn (name &optional (value ""))
  (input "button" :name name :value value))

(defun hid (name &optional (value ""))
  (input "hidden" :name name :value value))

(defun submit (&optional value)
  (if value
      (input "submit" :value value)
      (input "submit")))

(defmacro row (title &body body)
  `(format nil "~%<tr>~%<td>~A</td>~%<td>~A~%</td>~%</tr>"
           ,title
           ,@body))

;; (row "thetitrle" (submit))

(defun td (dat)
  (format nil "~%<td>~%~A~%</td>" dat))

(defun tr (&rest dat)
  (format nil "~%<tr>~%~{~A~}~%</tr>"
          dat))

;; (tr "wfewf")
;; (tr "wfewf" 1111)

(defun frm (contents &key name (method "POST"))
  (format nil "~%<form method=\"~A\"~A>~{~A~}~%</form>"
          method
          (if name (format nil " name=\"~A\"" name) "")
          (if (consp contents)
              contents
              (list contents))))

;; (frm "form-content" :name "nnnnn")

(defun tbl (contents &key name border)
  (format nil "~%<table~A~A>~{~A~}~%</table>"
          (if name (format nil " name=\"~A\"" name) "")
          (if border (format nil " border=\"~A\"" border) "")
          (if (consp contents)
              contents
              (list contents))))

;; (tbl (list "zzz") :name "table")

;; (frm (tbl (list (row "username" (fld "user")))))


(defmacro with-collection ((item collection) &body body)
  `(loop :for ,item :in ,collection :collect
      ,@body))


(defmacro with-element ((item elt) &body body)
  `(let ((,item ,elt))
     (list
      ,@body)))


(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))


(defun explore-dir (path)
  (let ((raw (directory path))
        (dirs)
        (files))
    (mapcar #'(lambda (x)
                (if (cl-fad:directory-pathname-p x)
                    (push x dirs)
                    (push x files)))
            raw)
    (values dirs files raw)))
;; utility_file ends here
