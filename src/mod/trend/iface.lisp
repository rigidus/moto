;; [[file:trend.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

;; Страница загрузки данных
(restas:define-route load-data ("/load")
  (with-wrapper
    (concatenate
     'string
     "<h1>Загрузка данных из файлов</h1>"
     (if (null *current-user*)
         "Error: Незалогиненные пользователи не имеют права загружать данные"
         (frm (tbl
               (list
                (row "" (let ((cmpx-s))
                          (loop-dir cmpx ()
                               (push cmpx cmpx-s))
                          (format nil "~{~A<br/>~}<br />" cmpx-s)))
                (row "" (hid "load"))
                (row "" (submit "Загрузить")))))))))

;; Контроллер страницы регистрации
(restas:define-route load-ctrl ("/load" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (if (equal (getf p :load) "")
          "Данные загружены"
          "err"))))

(in-package #:moto)

(define-page all-cmpx-s "/cmpxs"
  (concatenate 'string "<h1>" "Жилые комплексы" "</h1>" ""
               "<br /><br />"
               (tbl
                (with-collection (cmpx (funcall #'all-cmpx))
                  (tr
                   (td
                    (format nil "<a href=\"/~a/~a\">~a</a>" "cmpx"
                    (id cmpx) (id cmpx)))
                   (td (name cmpx))
                   (td (addr cmpx))
                   (td (aif (district-id cmpx)
                            (name (get-district it))))
                   (td (aif (metro-id cmpx)
                            (name (get-metro it))))
                   (td (frm %del%))))
                :border 1))
  (:del (act-btn "DEL" (id cmpx) "Удалить")
        (progn (del-cmpx (getf p :data)))))

(in-package #:moto)

(define-page cmpx "/cmpx/:cmpx-id"
  (let* ((i (parse-integer cmpx-id))
         (cmpx (get-cmpx i)))
    (if (null cmpx)
        "Нет такого жилого комплекса"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница жилого комплекса ~A</h1>" (id cmpx))
                 (format nil "<h2>Данные комплекса ~A</h2>" (name cmpx))
                 (tbl
                  (with-element (cmpx cmpx)
                    (row "Название" (name cmpx))
                    (row "Адрес" (addr cmpx))
                    (row "Район" (aif (district-id cmpx)
                                      (name (get-district it))))
                    (row "Метро" (aif (metro-id cmpx)
                                      (name (get-metro it)))))
                  :border 1)
                 (format nil "<h2>Очереди комплекса ~A</h2>~%~A"
                         (name cmpx)
                         (tbl
                          (with-collection (i (find-plex :cmpx-id i))
                            (tr
                             (td
                              (format nil "<a href=\"/~a/~a\">~a</a>" "plex"
                                      (id i) (id i)))
                             (td (name i)) (td (deadline i)) (td (frm %del%))))
                          :border 1))))))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn (del-plex (getf p :data)))))

(in-package #:moto)

(define-page plex "/plex/:plex-id"
  (let* ((i (parse-integer plex-id))
         (plex (get-plex i)))
    (if (null plex)
        "Нет такой очереди у этого жилого комплекса"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница очереди жилого комплекса</h1>")
                 (format nil "<h2>Данные очереди комплекса</h2>")
                 (tbl
                  (with-element (plex plex)
                    (row "Название" (name plex))
                    (row "Срок сдачи" (deadline plex))
                    (row "Субсидия" (subsidy plex))
                    (row "Отделка" (finishing plex))
                    (row "Ипотека" (ipoteka plex))
                    (row "Рассрочка" (installment plex))
                    (row "Расстояние до метро" (distance plex)))
                  :border 1)
                  (format nil "<h2>Корпуса очереди жилого комплекса</h2>~%~A"
                         (tbl
                          (with-collection (i (find-crps :plex-id i))
                            (tr
                             (td
                              (format nil "<a href=\"/~a/~a\">~a</a>" "crps"
                                      (id i) (id i)))
                             (td (name i)) (td (frm %del%))))
                          :border 1))))))
  (:del (act-btn "del" (id i) "Удалить")
        (progn (del-plex (getf p :data)))))

(in-package #:moto)

(define-page crps "/crps/:crps-id"
  (let* ((i (parse-integer crps-id))
         (crps (get-crps i)))
    (if (null crps)
        "Нет такой очереди у этого жилого комплекса"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница корпуса очереди жилого комплекса</h1>")
                 (format nil "<h2>Данные очереди комплекса</h2>")
                 (tbl
                  (with-element (crps crps)
                    (row "Название" (name crps)))
                  :border 1)
                  (format nil "<h2>Планировки корпуса очереди жилого комплекса</h2>~%~A"
                         (tbl
                          (with-collection (i (find-flat :crps-id i))
                            (tr
                             (td
                              (format nil "<a href=\"/~a/~a\">~a</a>" "flat"
                                      (id i) (id i)))
                             (td (format nil "~A к.кв." (rooms i)))
                             (td (format nil "~:d руб." (price i)))
                             (td (frm %del%))))
                          :border 1))))))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn (del-flat (getf p :data)))))
(in-package #:moto)

;; (restas:define-route flat ("/flat/:flatid")
;;   (with-wrapper
;;     (let ((flat (get-flat 1)))
;;       (trendtpl:flatpage
;;        (list
;;         :rooms (let ((r (rooms flat)))
;;                  (cond ((equal 0 r) "Квартира-студия")
;;                        ((equal 1 r) "1-комнатная квартира")
;;                        ((equal 2 r) "2-комнатная квартира")
;;                        ((equal 3 r) "3-комнатная квартира")
;;                        ((equal 4 r) "4-комнатная квартира")
;;                        (t (err "unknown rooms value"))))
;;         :id (id flat)
;;         :price (price flat)
;;         :rooms (rooms flat)
;;         :area_living (area-living flat)
;;         :area_sum (area-sum flat)
;;         :area_kitchen (area-kitchen flat)
;;         :sanuzel (sanuzel flat)
;;         :finishing (finishing flat)
;;         :balcon (balcon flat)
;;         )))))

(in-package #:moto)

(define-page flat "/flat/:flat-id"
  (let* ((i (parse-integer flat-id))
         (flat (get-flat i)))
    (if (null flat)
        "Нет такой квартиры"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница квартиры</h1>")
                 (format nil "<h2>Данные квартиры</h2>")
                 (tbl
                  (with-element (flat flat)
                    (row "Кол-во комнат" (rooms flat))
                    (row "Общая площадь" (area-living flat))
                    (row "Площадь кухни" (area-kitchen flat))
                    (row "цена" (format nil "~:d"(price flat)))
                    (row "балкон/лоджия" (balcon flat))
                    (row "Санузел" (sanuzel flat))
                    (row "" (frm %buy%))
                    )
                  :border 1)))))
  (:buy (act-btn "BUY" "BUY" "Купить")
        (progn 1)))

(in-package #:moto)

(define-page findpage "/find"
  (format nil "~{~A~}"
          (list
           (format nil "<h1>Страница поиска</h1>")
           (format nil "<h2>Простой поиск</h2>")
           (frm
            (tbl
             (list
              (row "Район"
                (select ("district")
                  (list* (list "Не важен" "0")
                         (with-collection (i (all-district))
                           (list (name i)
                                 (id i))))))
              (row "Метро"
                (select ("metro")
                  (list* (list "Любое" "0")
                         (with-collection (i (all-metro))
                           (list (name i)
                                 (id i))))))
              (row "Название ЖК"
                (select ("cmpx")
                  (list* (list "Любой ЖК" "0")
                         (with-collection (i (all-cmpx))
                           (list (name i)
                                 (id i))))))
              (row "Кол-во комнат"
                (tbl
                 (list
                  (row "" "Выберите не менее одного варианта")
                  (row (input "checkbox" :name "studio" :value t) "Студия")
                  (row (input "checkbox" :name "one" :value t) "Однокомнатная")
                  (row (input "checkbox" :name "two" :value t) "Двухкомнатная")
                  (row (input "checkbox" :name "three" :value t) "Трехкомнатная"))))
              (row "Срок сдачи (не позднее)"
                (select ("deadline")
                  (list* (list "Не важен" "0")
                         (with-collection (i (all-deadline))
                           (list (name i)
                                 (id i))))))
              (row "Стоимость квартиры"
                (tbl
                 (list
                  (row "" "Обязательные поля")
                  (row "от" (fld "price-from"))
                  (row "до" (fld "price-to")))))
              (row "" %find%))
             :border 1)
            :action "/results")))
  (:find (act-btn "FIND" "FIND" "Искать")
         "Err: redirect to /results!"))
(in-package #:moto)

(defmacro find-query (price-from price-to &optional &key district metro deadline cmpx studio one two three)
  `(with-connection *db-spec*
     (query
      (:limit
       (:select (:as 'district.name 'district)  (:as 'cmpx.name 'cmpx)
                (:as 'metro.name    'metro)     'distance
                (:as 'deadline.name 'deadline)  'finishing
                'ipoteka  'installment  'rooms  'area-sum  'price
                :from 'flat
                :inner-join 'crps :on (:= 'flat.crps_id 'crps.id)
                :inner-join 'plex :on (:= 'crps.plex_id 'plex.id)
                :inner-join 'cmpx :on (:= 'plex.cmpx_id 'cmpx.id)
                :inner-join 'district :on (:= 'cmpx.district_id 'district.id)
                :inner-join 'metro :on (:= 'cmpx.metro_id 'metro.id)
                :inner-join 'deadline :on (:= 'plex.deadline_id 'deadline.id)
                :where (:and ,(remove-if #'null
                                         `(:or ,(when studio `(:= 'rooms 0))
                                               ,(when one    `(:= 'rooms 1))
                                               ,(when two    `(:= 'rooms 2))
                                               ,(when three  `(:= 'rooms 3))))
                             (:and (:> 'price ,price-from)
                                   (:< 'price ,price-to))
                             ,(if district
                                  `(:= 'district_id ,district)
                                  t)
                             ,(if metro
                                  `(:= 'metro_id ,metro)
                                  t)
                             ,(if deadline
                                  `(:<= 'deadline_id ,deadline)
                                  t)
                             ,(if cmpx
                                  `(:= 'cmpx_id ,cmpx)
                                  t)))
       2000))))

(define-page results "/results"
  (format nil "~{~A~}"
          (list
           (format nil "<h1>Страница поиска</h1>")
           (format nil "<h2>Простой поиск</h2>")
           "Пустой поисковый запрос"))
  (:find (act-btn "FIND" "FIND" "Искать")
         (format nil "~{~A~}"
                 (list
                  (format nil "~%<h1>Страница поиска</h1>")
                  (format nil "~%<h2>Выборка</h2>")
                  (format nil "~%<br /><br />Параметры поиска: ~A" (bprint p))
                  (format nil "~%<br /><br />~A"
                          (let* ((form `(find-query
                                         ,(parse-integer (getf p :price-from))
                                         ,(parse-integer (getf p :price-to))
                                         )))
                            (unless (equal "0" (getf p :district))
                              (setf form (append form (list :district (parse-integer (getf p :district))))))
                            (unless (equal "0" (getf p :metro))
                              (setf form (append form (list :metro (parse-integer (getf p :metro))))))
                            (unless (equal "0" (getf p :deadline))
                              (setf form (append form (list :deadline (parse-integer (getf p :deadline))))))
                            (unless (equal "0" (getf p :cmpx))
                              (setf form (append form (list :cmpx (parse-integer (getf p :cmpx))))))
                            (when (getf p :studio)
                              (setf form (append form (list :studio t))))
                            (when (getf p :one)
                              (setf form (append form (list :one t))))
                            (when (getf p :two)
                              (setf form (append form (list :two t))))
                            (when (getf p :three)
                              (setf form (append form (list :three t))))
                            (format nil "~%<br /><br />Запрос: ~A~%<br /><br />Результат: <br/><br />~A"
                                    (bprint form)
                                    (format nil "<table border=1><tr>~{~A~}</tr>~{~A~}</table>"
                                            (loop :for item :in '("Район" "Комплекс" "Метро" "Расстояние" "Срок сдачи"
                                                                  "Отделка" "Ипотека" "Рассрочка" "Кол-во комнат" "Общая площадь" "Цена") :collect
                                               (format nil "~%<th>~A</th>" item))
                                            (loop :for item :in (eval form) :collect
                                               (format nil "~%<tr>~{~A~}</tr>"
                                                       (loop :for item :in item :collect
                                                          (format nil "~%<td>&nbsp;~A&nbsp;</td>" item))))))))))))
;; iface ends here
