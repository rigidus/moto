;; [[file:hh.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы

(in-package #:moto)

(restas:define-route hh-main ("/hh")
  (with-wrapper
      "<h1>Главная страница</h1>"
    ))

(in-package #:moto)

(define-iface-add-del-entity all-profiles "/profiles"
  "Поисковые профили"
  "Новый профиль"
  "Когда
   соискатель пользуется профильным сайтом он использует поисковые запросы, на основании
   которых мы можем формировать, гм... назовем это =поисковыми профилями=. Поисковый
   профиль - это запрос пользователя, плюс несколько наборов связанных с ним данных -
   назовем их =сборками=."
  #'all-profile "profile"
  (name)
  (frm
   (tbl
    (list
     (row "Название" (fld "name"))
     (row "Запрос" (fld "search"))
     (row "" %new%))))
  (:new (act-btn "NEW" "" "Создать")
        (progn
          (make-profile :name (getf p :name)
                        :user-id 1
                        :search-query (getf p :search)
                        :ts-create (get-universal-time)
                        :ts-last (get-universal-time))
          "Профиль создан"))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn
          (del-profile (getf p :data)))))

(in-package #:moto)

(define-page profile "/profile/:userid"
  (let* ((i (parse-integer userid))
         (u (get-profile i)))
    (if (null u)
        "Нет такого профиля"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница поискового профиля ~A</h1>" (id u))
                 (format nil "<h2>Данные поискового профиля ~A</h2>" (name u))
                 (tbl
                  (with-element (u u)
                    (row "Имя профиля" (fld "name" (name u)))
                    (row "Запрос" (fld "search" (search-query u)))
                    (row "" %change%))
                  :border 1)
                 (format nil "<h2>Сборки данных</h2>")
                 (frm
                  (tbl
                   (with-collection (i (all-vacancy))
                     (tr
                      (td (input "checkbox" :name (format nil "~A" i) :value "on"))
                      (td (format nil "<a href=\"/vacancy/~A\">~A</a>" (id i) (name i)))
                      (td (salary-text i))))
                   :border 1))
                 ))))
  (:change (act-btn "CHANGE" "" "Изменить")
           (let* ((i (parse-integer userid))
                  (u (get-user i)))
             (aif (getf p :role)
                  (role-id (upd-user u (list :role-id (parse-integer it))))
                  ":null"))))
;; iface ends here
