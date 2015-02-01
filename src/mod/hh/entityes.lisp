;; [[file:hh.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)
(define-automat vacancy "Автомат вакансии"
  ((id serial)
   (src-id integer)
   (archive boolean)
   (name varchar)
   (currency (or db-null varchar))
   (base-salary (or db-null integer))
   (salary (or db-null integer))
   (salary-text (or db-null varchar))
   (salary-max (or db-null integer))
   (salary-min (or db-null integer))
   (emp-id (or db-null integer))
   (emp-name varchar)
   (city varchar)
   (metro varchar)
   (experience varchar)
   (date varchar)
   (descr varchar)
   (notes (or db-null varchar))
   (response (or db-null varchar)))
  (:responded :interested :not_interested :unsort)
  ((:unsort :not_interested :set-not-interested)
   (:unsort :interested :set-interested)
   (:interested :responded :respond)))
;; entity_and_automates ends here
