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
  "Когда соискатель пользуется профильным сайтом он использует
   поисковые запросы, на основании которых мы можем формировать,
   гм... назовем это =поисковыми профилями=. Поисковый профиль - это
   запрос пользователя, плюс набор связанных с ним вакансий"
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
         (page-id (parse-integer userid))
         (u (get-profile i))
         (vacs (sort (remove-if #'(lambda (x)
                                    (equal 0 (salary x)))
                                (find-vacancy :profile-id page-id))
                     #'(lambda (a b)
                         (> (salary a) (salary b))))))
    (if (null u)
        "Нет такого профиля"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница поискового профиля ~A</h1>" (id u))
                 (format nil "<h2>Данные поискового профиля ~A</h2>" (name u))
                 (frm
                  (tbl
                   (with-element (u u)
                     (row "Имя профиля" (fld "name" (name u)))
                     (row "Запрос" (fld "search" (search-query u)))
                     (row (hid "profile_id" (id u)) %change%))
                   :border 1))
                 (format nil "<h2>Вакансий: ~A</h2>" (length vacs))
                 (frm
                  (list
                   %clarify%
                   (tbl
                    (with-collection (vac vacs)
                      (tr
                       (td
                        (state vac))
                       (td
                        (format nil "<div style=\"background-color:green\">~A</div>"
                                (input "radio" :name (format nil "R~A" (id vac)) :value "y"
                                       :other (if (string= ":INTERESTED" (state vac)) "checked=\"checked\"" ""))))
                       (td
                        (format nil "<div style=\"background-color:red\">~A</div>"
                                (input "radio" :name (format nil "R~A" (id vac)) :value "n"
                                       :other (if (string= ":NOT_INTERESTED" (state vac)) "checked=\"checked\"" ""))))
                       (td (format nil "<a href=\"/vacancy/~A\">~A</a>" (id vac) (name vac)))
                       (td (salary-text vac))
                       (td (currency vac))))
                    :border 1)
                   ))
                 ))))
  (:change  (act-btn "CHANGE" "" "Изменить")
            (id (upd-profile (get-profile (parse-integer userid))
                             (list :name (getf p :name) :search-query (getf p :query)))))
  (:clarify (act-btn "CLARIFY" "" "Уточнить")
            (loop :for key :in (cddddr p) :by #'cddr :collect
               (let* ((val (getf p key))
                      (id  (parse-integer (subseq (symbol-name key) 1)))
                      (vac (get-vacancy id)))
                 (list id
                       (cond ((string= "y" val)
                              (unless (string= ":INTERESTED" (state vac))
                                (takt vac :interested)))
                             ((string= "n" val)
                              (unless (string= ":NOT_INTERESTED" (state vac))
                                (takt vac :not_interested)))
                             (t "err param")))))))
;; iface ends here
