;; [[file:doc.org::*Точка входа][enter_point]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
;;;; moto.lisp

(in-package #:moto)

(defun main ()
  ;; start
  (restas:start '#:moto :port 9997)
  (restas:debug-mode-on)
  ;; (restas:debugg-mode-off)
  (setf hunchentoot:*catch-errors-p* t))

(main)
;; enter_point ends here
