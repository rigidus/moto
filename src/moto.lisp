;; [[file:doc.org::*Точка входа][enter_point]]
;;;; moto.lisp

(in-package #:moto)

;; start
(restas:start '#:moto :port 9997)
(restas:debug-mode-on)
;; (restas:debugg-mode-off)
(setf hunchentoot:*catch-errors-p* t)
;; enter_point ends here
