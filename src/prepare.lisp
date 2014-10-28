
;;;; prepare.lisp

(in-package #:moto)

(defparameter *repo-folder* "repo")
(defparameter *prj-folder* "moto")

;; Базовый путь, от которого будем все считать
(defparameter *base-path*
  (format nil "~A~A"
          (namestring (user-homedir-pathname))
          (format nil "~A/~A/src/"
                  *repo-folder*
                  *prj-folder*)))

;; Путь к данным
(defparameter *data-path*
  (format nil "~A~A"
          (namestring (user-homedir-pathname))
          (format nil "~A/~A/data/"
                  *repo-folder*
                  *prj-folder*)))

;; Компилируем шаблоны
(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))
