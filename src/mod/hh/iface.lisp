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

(defun vacancy-table (raw)
  (let ((vacs (sort (remove-if #'(lambda (x)
                                   (equal 0 (salary x)))
                               raw)
                    #'(lambda (a b)
                        (> (salary a) (salary b))))))
    (format nil "<h2>Вакансий: ~A</h2>~%~A" (length vacs)
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
             :border 1))))

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
                 "<script>
                         function test (param) {
                            $.post(
                               \"/profile/1\",
                               {act: param},
                               function(data) {
                                  $(\"#dvtest\").html(data);
                               }
                           );
                         };
                  </script>"
                 (format nil "<h1>Страница поискового профиля ~A</h1>" (id u))
                 (format nil "<h2>Данные поискового профиля ~A</h2>" (name u))
                 (frm
                  (tbl
                   (with-element (u u)
                     (row "Имя профиля" (fld "name" (name u)))
                     (row "Запрос" (fld "search" (search-query u)))
                     (row (hid "profile_id" (id u)) %change%))
                   :border 1))
                 (tbl
                  (tr
                   (td %show-all%)
                   (td %show-interests%)
                   (td %show-not-interests%)
                   (td %show-other%)))
                 (frm %proceess-interests%)
                 (frm
                  (list
                   "<br /><br />"
                   %clarify%
                   "<div id=\"dvtest\">dvtest</div>"))))))
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
                             (t "err param"))))))
  (:show-all (format nil "<input type=\"button\" onclick=\"test('SHOW-ALL');\" value=\"все\">")
             (error 'ajax :output (vacancy-table (find-vacancy :profile-id 1))))
  (:show-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-INTERESTS');\" value=\"интересные\">")
                   (error 'ajax :output (vacancy-table (find-vacancy :state ":INTERESTED" :profile-id 1))))
  (:show-not-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-NOT-INTERESTS');\" value=\"неинтересные\">")
                       (error 'ajax :output (vacancy-table (find-vacancy :state ":NOT_INTERESTED" :profile-id 1))))
  (:show-other (format nil "<input type=\"button\" onclick=\"test('SHOW-OTHER');\" value=\"остальные\">")
               (error 'ajax :output (vacancy-table (remove-if #'(lambda (x)
                                                                  (or (string= ":NOT_INTERESTED" (state x) )
                                                                      (string= ":INTERESTED" (state x))))
                                                              (find-vacancy :profile-id 1)))))
  (:proceess-interests (act-btn "PROCEESS-INTERESTS" "" "Собрать данные интересных вакансий")
                       "TODO"))
;; iface ends here
