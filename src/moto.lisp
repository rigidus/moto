
;;;; moto.lisp

(in-package #:moto)

;; start
(restas:start '#:moto :port 9997)
(restas:debug-mode-on)
;; (restas:debug-mode-off)
(setf hunchentoot:*catch-errors-p* t)
