;; [[file:trend.org::*Определения сущностей][entity_and_automates]]
(in-package #:moto)


(define-entity cmpx "Сущность комплекса"
  ((addr (or db-null varchar))
   (addr (or db-null varchar))))

(make-cmpx-table)

(define-entity plex "Сущность очереди жилого комплекса"
  ((name (or db-null varchar))
   (addr (or db-null varchar))
   (deadline (or db-null varchar))
   (district-id (or db-null integer))
   (metro-id (or db-null integer))
   (distance (or db-null varchar))
   (subsidy (or db-null boolean))
   (finishing (or db-null boolean))
   (ipoteka (or db-null boolean))
   (installment (or db-null boolean))))

(make-plex-table)
;; entity_and_automates ends here
