;; [[file:hh.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)

(define-entity profile "Сущность поисковые профили"
  ((id serial)
   (user-id integer)
   (search-query varchar)
   (ts-create bigint)
   (ts-last bigint)))

(make-profile-table)


(in-package #:moto)

(defparameter *profile-all*
  (make-profile :name "Все вакансии программистов"
                :user-id 1
                :search-query "http://spb.hh.ru/search/vacancy?area=2&text=&salary=&currency_code=RUR&specialization=1.221"
                :ts-create (get-universal-time)
                :ts-last (get-universal-time)))

(gen-automat "collection" "сборки" flds states)

(in-package #:moto)

(defparameter *collection-all*
  (make-collection :profile-id (id *profile-all*)
                   :ts-create (get-universal-time)
                   :ts-shedule (get-universal-time)
                   :state :sheduled))
;; entity_and_automates ends here
