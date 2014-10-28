
(in-package #:moto)


(define-entity cmpx "Сущность комплекса"
  ((id serial)
   (name varchar)
   (addr varchar)))

(make-cmpx-table)
