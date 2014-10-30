;; [[file:doc.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Враппер веб-интерфейса
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
         :content (format nil "~{~A~}"
                          (list
                           (tpl:dbgblock  (list :dbgout output))
                           (tpl:userblock (list :currentuser
                                                (if (null *current-user*)
                                                    "none"
                                                    *current-user*)))
                           (if *current-user*
                               (tpl:msgblock
                                (list :msgcnt (get-undelivered-msg-cnt *current-user*)))
                               "")
                           (tpl:retvalblock (list :retval retval)))))))))

;; Хелпер форм
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

(in-package #:moto)

(restas:define-route main ("/")
  (with-wrapper
    "main"))
(in-package #:moto)

(restas:define-route allusers ("/users")
  (with-wrapper
    (tbl
     (with-collection (i (all-user))
       (tr
        (td (format nil "<a href=\"/user/~A\">~A</a>" (id i) (id i)))
        (td (name i))
        (td (password i))
        (td (email i))))
     :border 1)))

(restas:define-route allusers-ctrl ("/users" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      "TODO")))
(in-package #:moto)

(restas:define-route user ("/user/:userid")
  (with-wrapper
    (let* ((i (parse-integer userid))
           (u (get-user i)))
      (if (null u)
          "Нет такого пользователя"
          (format nil "~{~A~}"
                  (list
                   (format nil "<h1>Страница пользователя ~A</h1>" (id u))
                   (format nil "<h2>Данные пользователя ~A</h2>" (name u))
                   (tbl
                    (with-element (u u)
                      (row "Имя пользователя" (name u))
                      (row "Пароль" (password u))
                      (row "Email" (email u)))
                    :border 1)
                   ))))))

(restas:define-route user-ctrl ("/user/:userid" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (cond ((getf p :addsum)   )
            ((getf p :follow)   )
            ((getf p :neworder) )))))
;; iface ends here
