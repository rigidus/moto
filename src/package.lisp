
;;;; package.lisp

(restas:define-module #:moto
  (:use  #:cl #:closer-mop #:postmodern #:anaphora #:hunchentoot)
  (:shadowing-import-from #:closer-mop
                          #:defclass
                          #:defmethod
                          #:standard-class
                          #:ensure-generic-function
                          #:defgeneric
                          #:standard-generic-function
                          #:class-name))
