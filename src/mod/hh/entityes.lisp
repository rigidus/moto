;; [[file:hh.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)

(define-entity profile "Сущность поисковые профили"
  ((id serial)
   (user-id integer)
   (query varchar)
   (ts-create bigint)
   (ts-last bigint)))

(make-profile-table)
;; entity_and_automates ends here
