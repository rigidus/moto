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
                (with-collection (i (funcall #'all-cmpx))
                  (tr
                   (td
                    (format nil "<a href=\"/~a/~a\">~a</a>" "cmpx"
                            (id i) (id i)))
                   (td (name i)) (td (addr i)) (td (frm %del%))))
                :border 1))
  (:del (act-btn "DEL" (id i) "Удалить")
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
                    (row "Адрес" (addr cmpx)))
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
                    (row "Идентификатор района" (district-id plex))
                    (row "Идентификатор метро" (metro-id plex))
                    (row "Расстояние до метро" (distance plex))
                    (row "Субсидия" (subsidy plex))
                    (row "Отделка" (finishing plex))
                    (row "Ипотека" (ipoteka plex))
                    (row "Рассрочка" (installment plex)))
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
             (row "Район" (rooms flat))
             (row "Метро" (area-living flat))
             (row "Название жк" (area-kitchen flat))
             (row "Кол-во комнат" (format nil "~:d"(price flat)))
             (row "Срок сдачи (не позднее)" (balcon flat))
             (row "Стоимость квартиры" (sanuzel flat))
             (row "" %find%))
            :border 1)))
  (:find (act-btn "FIND" "FIND" "Искать")
           (progn 1)))
;; iface ends here
