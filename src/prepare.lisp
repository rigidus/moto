
;;;; prepare.lisp

(in-package #:moto)

;; Базовый путь, от которого будем все считать
(defparameter *base-path* (format nil "~A~A"
                                  (namestring (user-homedir-pathname))
                                  "repo/moto/src/"))

(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))

(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "flat-templates.htm")))
