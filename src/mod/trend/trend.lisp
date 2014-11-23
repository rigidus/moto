(in-package #:moto)



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
                :border 1)
               "<h2>" "Новый комплекс" "</h2>"
               (frm
                (tbl
                 (list
                  (row "Имя"
                    (fld "name"))
                  (row "Адрес"
                    (fld "name"))))))
  (:del (act-btn "del" (id i) "Удалить")
        (progn (del-cmpx (getf p :data)))))
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
