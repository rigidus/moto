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
  (setf hunchentoot:*catch-errors-p* t)
  (make-event :name "restart"
              :tag "restart"
              :msg (format nil "Сервер перезапущен")
              :author-id 0
              :ts-create (get-universal-time)))

(main)
;; enter_point ends here
