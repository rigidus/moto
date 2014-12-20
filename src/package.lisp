;; [[file:doc.org::*Пакеты][package]]
;;;; Copyright © 2014 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
;;;; package.lisp

(restas:define-module #:moto
  (:use  #:cl #:closer-mop #:postmodern #:anaphora #:hunchentoot #:cl-who #:parenscript #:cl-fad)
  (:shadowing-import-from #:closer-mop
                          #:defclass
                          #:defmethod
                          #:standard-class
                          #:ensure-generic-function
                          #:defgeneric
                          #:standard-generic-function
                          #:class-name))
;; package ends here
