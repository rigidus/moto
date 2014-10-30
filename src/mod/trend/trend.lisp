(in-package #:moto)

;; Сущность планировки
(define-entity flat "Сущность планировки"
  ((id serial)
   (plex-id (or db-null integer))
   (rooms (or db-null integer))
   (area-sum (or db-null integer))
   (area-living (or db-null integer))
   (area-kitchen (or db-null integer))
   (price (or db-null integer))
   (balcon (or db-null varchar))
   (sanuzel (or db-null boolean))))

(make-flat-table)

(make-flat :rooms 1 :price 2589000)

(in-package #:moto)

(restas:define-route flat ("/flat/:flatid")
  (with-wrapper
    (let ((flat (get-flat 1)))
      (trendtpl:flatpage
       (list
        :rooms (let ((r (rooms flat)))
                 (cond ((equal 0 r) "Квартира-студия")
                       ((equal 1 r) "1-комнатная квартира")
                       ((equal 2 r) "2-комнатная квартира")
                       ((equal 3 r) "3-комнатная квартира")
                       ((equal 4 r) "4-комнатная квартира")
                       (t (err "unknown rooms value"))))
        :id (id flat)
        :price (price flat)
        :rooms (rooms flat)
        :area_living (area-living flat)
        :area_sum (area-sum flat)
        :area_kitchen (area-kitchen flat)
        :sanuzel (sanuzel flat)
        :finishing (finishing flat)
        :balcon (balcon flat)
        )))))


;; Тестируем trend
(defun trend-test ()
  
  
  (dbg "passed: trend-test~%"))
(trend-test)
