
;;;; prepare.lisp

(in-package #:moto)

;; Базовый путь, от которого будем все считать
(defparameter *base-path* "/home/rigidus/repo/moto/src/")

(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))
