;; [[file:hh.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

(define-page hh "/hh"
  (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
         (sorted-vacs (sort vacs #'(lambda (a b) (> (salary a) (salary b)))))
         (breadcrumb (breadcrumb "Вакансии" ("/hh" . "HeadHunter")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (base-page (:breadcrumb breadcrumb)
      (content-box ()
        (heading ("Модуль HeadHunter") "Меню модуля"))
      (content-box ()
        ((:section :class "dnd-area")
         ((:ul :class "connected handles list" :id "not")
          ((:li)
           ((:a :href "/hh/vacs") "Отобранные вакансии") "")
          ((:li)
           ((:a :href "/hh/rules") "Правила обработки") ""))))
      (ps-html ((:span :class "clear")))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn nil)))
(in-package #:moto)

(define-page vacs "/hh/vacs"
  (labels ((mrg (param)
             (if (null param)
                 ""
                 (reduce #'(lambda (x y)
                             (concatenate 'string x (string #\NewLine) y))
                         (mapcar #'(lambda (x)
                                     (ps-html ((:li :id (src-id x)
                                                    :class (string-downcase (subseq (state x) 1))
                                                    :title (notes x))
                                               ((:span :class (if (empty (notes x)) "emptynotes" "notes"))
                                                (cond ((equal "USD" (currency x)) "$")
                                                      ((equal "EUR" (currency x)) "€")
                                                      ((equal "RUR" (currency x)) ""))
                                                (salary-max x))
                                               ((:a :href (format nil "/hh/vac/~A" (src-id x)))
                                                (name x)))))
                                 param)))))
    (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
           (sorted-vacs (sort vacs #'(lambda (a b) (> (salary-max a) (salary-max b)))))
           (breadcrumb (breadcrumb "Вакансии" ("/hh" . "HeadHunter")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (base-page (:breadcrumb breadcrumb)
        ((:script)
         (ps
           (defun get-child-ids (selector)
             ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
           (defun save ()
             ((@ $ post) "#" (create :act "SAVE" :not ((@ (get-child-ids "#not") join)) :yep ((@ (get-child-ids "#yep") join)))
              (lambda (data status)
                (if (not (equal status "success"))
                    (alert (concatenate 'string "err-ajax-fail: " status))
                    (eval data))))
             false)))
        (content-box ()
          (heading ("Модуль HeadHunter")
            "В правой колонке - интересные вакансии, в левой - неинтересные. "
            ((:span :class "unsort") "&nbsp;Желтым&nbsp;")
            " выделены вакансии, которые появились в момент последнего сбора данных. "
            "По умолчанию они помещаются в правый столбик - к интересующим вакансиям. "
            "После сортировки следует сохранить состояния вакансий и тогда выделение исчезнет. "
            ((:span :class "responded") "&nbsp;Зеленым&nbsp;") " выделены вакансии, на которые отправлен отзыв. "
            "Вакансии, к которым есть заметки, выделяются зарплатой на "
            ((:span :class "notes") "&nbsp;красном&nbsp;") " фоне. "
            "При наведении на такую вакансию можно увидеть текст заметки."))
        (content-box ()
          %SAVE%
          ((:section :class "dnd-area")
           ((:ul :class "connected handles list" :id "not")
            (mrg (remove-if-not #'(lambda (x)
                                    (equal ":UNINTERESTING" (state x)))
                                sorted-vacs)))
           ((:ul :class "connected handles list no2" :id "yep")
            (mrg (remove-if #'(lambda (x)
                                (equal ":UNINTERESTING" (state x)))
                            sorted-vacs)))))
        (ps-html ((:span :class "clear"))))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn
           (setf *tmp1* (split-sequence:split-sequence #\, (getf p :not)))
           (setf *tmp2* (split-sequence:split-sequence #\, (getf p :yep)))
           (mapcar #'(lambda (x)
                       (takt (car (find-vacancy :src-id (parse-integer x))) :uninteresting))
                   (split-sequence:split-sequence #\, (getf p :not)))
           (mapcar #'(lambda (x)
                       (let ((vac (car (find-vacancy :src-id (parse-integer x)))))
                         (unless (equal (state vac) ":RESPONDED")
                           (takt vac :interesting))))
                   (split-sequence:split-sequence #\, (getf p :yep)))
           (error 'ajax :output "window.location.href='/hh/vacs'"))))
(in-package #:moto)

(define-page vacancy "/hh/vac/:src-id"
  (let* ((vac (car (find-vacancy :src-id src-id)))
         (breadcrumb (if (null vac)
                         (breadcrumb "Не найдено" ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/vacs" . "Вакансии"))
                         (breadcrumb (name vac) ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/vacs" . "Вакансии"))))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*))))
         (text (parenscript::process-html-forms-lhtml (read-from-string (descr vac)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ((format nil "~A ~A" (name vac) (ps-html ((:span :style "color:red") (salary-text vac)))))
          ((:table :border 0 :style "font-size: small;")
           ((:tr)
            ((:td) "id:")         ((:td) (id vac))                                      ((:td) "&nbsp;&nbsp;&nbsp;")
            ((:td) "src-id:")     ((:td) ((:a :href (format nil "http://hh.ru/vacancy/~A" (src-id vac))) (src-id vac))  ((:td) "&nbsp;&nbsp;&nbsp;")
                                   ((:td) "archive:")    ((:td) (archive vac))                                 ((:td) "&nbsp;&nbsp;&nbsp;"))
            ((:tr)
             ((:td) "emp-id:")     ((:td) (emp-id vac))                                  ((:td) "&nbsp;&nbsp;&nbsp;")
             ((:td) "emp-name:")   ((:td) ((:span :style "color:red") (emp-name vac)))   ((:td) "&nbsp;&nbsp;&nbsp;"))
            ((:tr)
             ((:td) "city:")       ((:td) (city vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;")
             ((:td) "metro:")      ((:td) (metro vac))                                   ((:td) "&nbsp;&nbsp;&nbsp;"))
            ((:tr)
             ((:td) "experience:") ((:td) (experience vac))                              ((:td) "&nbsp;&nbsp;&nbsp;")
             ((:td) "date:")       ((:td) (date vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;"))
            ))))
      (content-box ()
        ((:div :class "vacancy-descr") (format nil "~{~A~}" text)))
      (content-box ()
        (form ("vacform" nil :class "form-section-container")
          ((:div :class "form-section")
           (fieldset "Заметки"
             (textarea ("notes" "Заметки") (notes vac))
             (textarea ("response" "Сопроводительное письмо") (response vac))
             (ps-html ((:span :class "clear")))))
          %RESPOND% %SAVE%))
      (ps-html ((:span :class "clear")))))
  (:SAVE (ps-html ((:div :class "form-send-container")
                   (submit "Сохранить вакансию" :name "act" :value "SAVE")))
         (progn
           (id (upd-vacancy (car (find-vacancy :src-id src-id))
                            (list :notes (getf p :notes) :response (getf p :response))))
           (redirect (format nil "/hh/vac/~A" src-id))))
  (:respond (ps-html
             ((:div :class "form-send-container")
              (submit "Отправить отклик" :name "act" :value "RESPOND")))
            (progn
              (id (upd-vacancy (car (find-vacancy :src-id src-id))
                               (list :notes (getf p :notes) :response (getf p :response))))
              (dbg (send-respond src-id 7628220 (getf p :response)))
              (dbg (takt (car (find-vacancy :src-id "12644276")) :responded)))))

;; (takt (car (find-vacancy :src-id "12611079")) :responded)

;; (response (car (find-vacancy :src-id "12644276")))
(in-package #:moto)

(define-page rules "/hh/rules"
  (labels ((mrg (param)
             (if (null param)
                 ""
                 (reduce #'(lambda (x y)
                             (concatenate 'string x (string #\NewLine) y))
                         (mapcar #'(lambda (x)
                                     (ps-html ((:li ;; :id (src-id x)
                                                    ;; :class (string-downcase (subseq (state x) 1))
                                                    ;; :title (notes x)
                                                    )
                                               ;; ((:span :class (if (empty (notes x)) "emptynotes" "notes"))
                                               ;;  (cond ((equal "USD" (currency x)) "$")
                                               ;;        ((equal "EUR" (currency x)) "€")
                                               ;;        ((equal "RUR" (currency x)) ""))
                                               ;;  (salary-max x))
                                               ((:a :href (format nil "/hh/rule/~A" ;; (src-id x)
                                                                  0
                                                                  ))
                                                (symbol-name x)))))
                                 param)))))
    (let* ((breadcrumb (breadcrumb "Правила" ("/hh" . "HeadHunter")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (base-page (:breadcrumb breadcrumb)
        ((:script)
         (ps
           (defun get-child-ids (selector)
             ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
           (defun save ()
             ((@ $ post) "#" (create :act "SAVE" :not ((@ (get-child-ids "#not") join)) :yep ((@ (get-child-ids "#yep") join)))
              (lambda (data status)
                (if (not (equal status "success"))
                    (alert (concatenate 'string "err-ajax-fail: " status))
                    (eval data))))
             false)))
        (content-box ()
          (heading ("Правила обработки")
            "В правой колонке - Правила для тизеров, в левой - для вакансий. "))
        (content-box ()
          %SAVE%
          ((:section :class "dnd-area")
           ((:ul :class "connected handles list" :id "not")
            (mrg (rules-for-teaser)))
           ((:ul :class "connected handles list no2" :id "yep")
            (mrg (rules-for-vacancy)))))
        (ps-html ((:span :class "clear"))))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn
           (setf *tmp1* (split-sequence:split-sequence #\, (getf p :not)))
           (setf *tmp2* (split-sequence:split-sequence #\, (getf p :yep)))
           (mapcar #'(lambda (x)
                       (takt (car (find-vacancy :src-id (parse-integer x))) :uninteresting))
                   (split-sequence:split-sequence #\, (getf p :not)))
           (mapcar #'(lambda (x)
                       (let ((vac (car (find-vacancy :src-id (parse-integer x)))))
                         (unless (equal (state vac) ":RESPONDED")
                           (takt vac :interesting))))
                   (split-sequence:split-sequence #\, (getf p :yep)))
           (error 'ajax :output "window.location.href='/hh/rules'"))))
(in-package #:moto)

(define-page search-vacancy "/hh/search"
  (let* ((breadcrumb (breadcrumb "Поиск" ("/hh" . "HeadHunter")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (base-page (:breadcrumb breadcrumb)
      (content-box ()
        (heading ("Поиск по вакансиям в состоянии :RESPOND") ""))
      (content-box ()
        (let ((q (get-parameter "q")))
          (if (null q)
              "empty searchstring"
              (ps-html
               ((:ul)
                (format nil "~{~A~}"
                        (mapcar #'(lambda (x)
                                    (ps-html
                                     ((:li :style "padding: 3px")
                                      ((:a :href (format nil "/hh/vac/~A" (src-id (car x))))
                                       (name (car x))
                                       "&nbsp&nbsp:&nbsp&nbsp"
                                       (emp-name (car x))))))
                                (sort (remove-if #'(lambda (x)
                                                     (equal (cdr x) 0))
                                                 (mapcar #'(lambda (x)
                                                             (let ((rel 0))
                                                               (when (contains (string-downcase (name x)) (string-downcase q))
                                                                 (incf rel 3))
                                                               (when (contains (string-downcase (emp-name x)) (string-downcase q))
                                                                 (incf rel 5))
                                                               (when (contains (string-downcase (descr x)) (string-downcase q))
                                                                 (incf rel))
                                                               (cons x rel)))
                                                         (find-vacancy :state ":RESPONDED")))
                                      #'(lambda (a b)
                                          (> (cdr a) (cdr b)))))))))))
      (ps-html ((:span :class "clear"))))))
(defparameter *slideshows* (make-hash-table :test 'equalp))

(defun add-slideshow (slideshow-name image-folder)
  (setf (gethash slideshow-name *slideshows*)
        (mapcar (lambda (pathname)
                  (url-encode (format nil "~a.~a"
                                      (pathname-name pathname)
                                      (pathname-type pathname))))
                (list-directory image-folder))))

(add-slideshow "img" "/home/rigidus/repo/moto/img/")
(add-slideshow "pic" "/home/rigidus/repo/moto/pic/")

(alexandria:hash-table-plist *slideshows*)

(defmacro/ps slideshow-image-uri (slideshow-name image-file)
  `(concatenate 'string ,slideshow-name "/" ,image-file))

(restas:define-route y ("y")
  (ps
    (define-symbol-macro fragment-identifier (@ window location hash))
    (defun show-image-number (image-index)
      (let ((image-name (aref *images* (setf *current-image-index* image-index))))
        (setf (chain document (get-element-by-id "slideshow-img-object") src)
              (slideshow-image-uri *slideshow-name* image-name)
              fragment-identifier
              image-name)))
    (defun previous-image ()
      (when (> *current-image-index* 0)
        (show-image-number (1- *current-image-index*))))
    (defun next-image ()
      (when (< *current-image-index* (1- (getprop *images* 'length)))
        (show-image-number (1+ *current-image-index*))))
    ;; this gives bookmarkability using fragment identifiers
    (setf (getprop window 'onload)
          (lambda ()
            (when fragment-identifier
              (let ((image-name (chain fragment-identifier (slice 1))))
                (dotimes (i (length *images*))
                  (when (string= image-name (aref *images* i))
                    (show-image-number i)))))))))

(defun slideshow-handler (slideshow-name)
  (let* ((images (gethash slideshow-name *slideshows*))
         (current-image-index (or (position (get-parameter "image") images :test #'equalp)
                                  0))
         (previous-image-index (max 0 (1- current-image-index)))
         (next-image-index (min (1- (length images)) (1+ current-image-index))))
    (with-html-output-to-string (s)
      (:html
       (:head
        (:title "Parenscript slideshow")
        (:script :type "text/javascript"
                 (str (ps* `(progn
                              (var *slideshow-name* ,slideshow-name)
                              (var *images* (array ,@images))
                              (var *current-image-index* ,current-image-index)))))
        (:script :type "text/javascript" :src "/y")
        )
       (:body
        (:div :id "slideshow-container"
              :style "width:100%;text-align:center"
              (:img :id "slideshow-img-object"
                    :src (slideshow-image-uri slideshow-name
                                              (elt images current-image-index)))
              :br
              (:a :href (format nil "?image=~a" (elt images previous-image-index))
                  :onclick (ps (previous-image) (return false))
                  "Previous")
              " "
              (:a :href (format nil "?image=~a" (elt images next-image-index))
                  :onclick (ps (next-image) (return false))
                  "Next")
              ))))))

(restas:define-route x ("/x")
  (slideshow-handler "pic"))

(restas:define-route z ("/z")
  (slideshow-handler "img"))
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

;; (defun vacancy-table (raw)
;;   (let ((vacs (sort (remove-if #'(lambda (x)
;;                                    (equal 0 (salary x)))
;;                                raw)
;;                     #'(lambda (a b)
;;                         (> (salary a) (salary b))))))
;;     (format nil "<h2>Вакансий: ~A</h2>~%~A" (length vacs)
;;             (tbl
;;              (with-collection (vac vacs)
;;                (tr
;;                 (td
;;                  (state vac))
;;                 (td
;;                  (format nil "<div style=\"background-color:green\">~A</div>"
;;                          (input "radio" :name (format nil "R~A" (id vac)) :value "y"
;;                                 :other (if (string= ":INTERESTING" (state vac)) "checked=\"checked\"" ""))))
;;                 (td
;;                  (format nil "<div style=\"background-color:red\">~A</div>"
;;                          (input "radio" :name (format nil "R~A" (id vac)) :value "n"
;;                                 :other (if (string= ":UNINTERESTING" (state vac)) "checked=\"checked\"" ""))))
;;                 (td (format nil "<a href=\"/vacancy/~A\">~A</a>" (id vac) (name vac)))
;;                 (td (salary-text vac))
;;                 (td (currency vac))))
;;              :border 1))))

;; (define-page profile "/profile/:userid"
;;   (let* ((i (parse-integer userid))
;;          (page-id (parse-integer userid))
;;          (u (get-profile i))
;;          (vacs (sort (remove-if #'(lambda (x)
;;                                     (equal 0 (salary x)))
;;                                 (find-vacancy :profile-id page-id))
;;                      #'(lambda (a b)
;;                          (> (salary a) (salary b))))))
;;     (if (null u)
;;         "Нет такого профиля"
;;         (format nil "~{~A~}"
;;                 (list
;;                  "<script>
;;                          function test (param) {
;;                             $.post(
;;                                \"/profile/1\",
;;                                {act: param},
;;                                function(data) {
;;                                   $(\"#dvtest\").html(data);
;;                                }
;;                            );
;;                          };
;;                   </script>"
;;                  (format nil "<h1>Страница поискового профиля ~A</h1>" (id u))
;;                  (format nil "<h2>Данные поискового профиля ~A</h2>" (name u))
;;                  (frm
;;                   (tbl
;;                    (with-element (u u)
;;                      (row "Имя профиля" (fld "name" (name u)))
;;                      (row "Запрос" (fld "search" (search-query u)))
;;                      (row (hid "profile_id" (id u)) %change%))
;;                    :border 1))
;;                  (tbl
;;                   (tr
;;                    (td %show-all%)
;;                    (td %show-interests%)
;;                    (td %show-not-interests%)
;;                    (td %show-other%)))
;;                  (frm %proceess-interests%)
;;                  (frm
;;                   (list
;;                    "<br /><br />"
;;                    %clarify%
;;                    "<div id=\"dvtest\">dvtest</div>"))))))
;;   (:change  (act-btn "CHANGE" "" "Изменить")
;;             (id (upd-profile (get-profile (parse-integer userid))
;;                              (list :name (getf p :name) :search-query (getf p :query)))))
;;   (:clarify (act-btn "CLARIFY" "" "Уточнить")
;;             (loop :for key :in (cddddr p) :by #'cddr :collect
;;                (let* ((val (getf p key))
;;                       (id  (parse-integer (subseq (symbol-name key) 1)))
;;                       (vac (get-vacancy id)))
;;                  (list id
;;                        (cond ((string= "y" val)
;;                               (unless (string= ":INTERESTING" (state vac))
;;                                 (takt vac :interesting)))
;;                              ((string= "n" val)
;;                               (unless (string= ":UNINTERESTING" (state vac))
;;                                 (takt vac :uninteresting)))
;;                              (t "err param"))))))
;;   (:show-all (format nil "<input type=\"button\" onclick=\"test('SHOW-ALL');\" value=\"все\">")
;;              (error 'ajax :output (vacancy-table (find-vacancy :profile-id 1))))
;;   (:show-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-INTERESTS');\" value=\"интересные\">")
;;                    (error 'ajax :output (vacancy-table (find-vacancy :state ":INTERESTING" :profile-id 1))))
;;   (:show-not-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-NOT-INTERESTS');\" value=\"неинтересные\">")
;;                        (error 'ajax :output (vacancy-table (find-vacancy :state ":UNINTERESTING" :profile-id 1))))
;;   (:show-other (format nil "<input type=\"button\" onclick=\"test('SHOW-OTHER');\" value=\"остальные\">")
;;                (error 'ajax :output (vacancy-table (remove-if #'(lambda (x)
;;                                                                   (or (string= ":UNINTERESTING" (state x) )
;;                                                                       (string= ":INTERESTING" (state x))))
;;                                                               (find-vacancy :profile-id 1)))))
;;   (:proceess-interests (act-btn "PROCEESS-INTERESTS" "" "Собрать данные интересных вакансий")
;;                        "TODO"))

;; (profile-id (car (all-vacancy)))

;; (mapcar #'(lambda (x)
;;             (salary x))
;;         (find-vacancy :profile-id 1))

;; (car
;;  (remove-if #'(lambda (x)
;;                 (null (getf x :salary)))
;;             *teasers*))

;; (currency
;;  (car
;;   (remove-if #'(lambda (x)
;;                  (equal (salary x) 0))
;;              (all-vacancy))))
;; iface ends here
