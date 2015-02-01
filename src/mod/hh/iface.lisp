;; [[file:hh.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

(defmacro vac-elt (id name salary class)
  `(ps-html ((:li :title ,salary :class ,class)
             ((:span) "&nbsp×&nbsp")
             ((:a :href ,id)
              ,name))))

(labels ((mrg (param)
           (if (null param)
               (vac-elt 0 "Нет вакансий" 0 "highlight")
               (reduce #'(lambda (x y)
                           (concatenate 'string x (string #\NewLine) y))
                       (mapcar #'(lambda (x)
                                   (vac-elt (format nil "/vac/~A" (id x))
                                            (name x)
                                            (salary-max x)
                                            (if (equal ":UNSORT" (state x)) "highlight" "")))
                               param)))))
  (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
         (sorted-vacs (sort vacs #'(lambda (a b) (> (salary a) (salary b))))))
    (define-page hh-main "/hh"
      (let ((breadcrumb (breadcrumb "HeadHunter"))
            (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
        (base-page (:breadcrumb breadcrumb)
          (content-box ()
            (heading ("Модуль HeadHunter") "Так я ищу работу."))
          (content-box (:style "position:relative; x: -600")
            %SAVE%
            ((:section :class "dnd-area")
             ((:ul :class "connected handles list")
              ((:div :class "dnd-head"))
              (mrg (remove-if-not #'(lambda (x)
                                      (equal ":NOT-INTERESTING" (state x)))
                                  sorted-vacs)))
             ((:ul :class "connected handles list no2")
              ((:div :class "dnd-head"))
              (mrg (remove-if #'(lambda (x)
                                  (equal ":NOT-INTERESTING" (state x)))
                              sorted-vacs)))))
          (ps-html ((:span :class "clear")))))
      (:SAVE (ps-html
              ((:input :type "hidden" :name "act" :value "SAVE"))
              (submit "SAVE" :onclick "save_state();return false;"))
             (print "todo:save")))))
(in-package #:moto)

(defmethod to-html ((vac vacancy) &key filter &allow-other-keys)
  (ps-html
   ((:table :border 0 :style "font-size: small;")
    ((:tr)
     ((:td) "id:")         ((:td) (id vac))         ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "src-id:")     ((:td) (src-id vac))     ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "archive:")    ((:td) (archive vac))    ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "emp-id:")     ((:td) (emp-id vac))     ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "emp-name:")   ((:td) (emp-name vac))   ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "city:")       ((:td) (city vac))       ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "metro:")      ((:td) (metro vac))      ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "experience:") ((:td) (experience vac)) ((:td) "&nbsp;&nbsp;&nbsp;")
     ((:td) "date:")       ((:td) (date vac))       ((:td) "&nbsp;&nbsp;&nbsp;")))
   ((:h3) (name vac) "&nbsp;&nbsp;&nbsp;" ((:span :style "color:red") (salary-text vac)))
   ((:pre) (descr vac))
   ((:table :border 0)
    ((:th) "notes")
    ((:th) "response")
    ((:tr)
     ((:td :width 500 :valign "top") ((:textarea :name "notes" :cols 60 :rows 6) (notes vac)))
     ((:td :width 500 :valign "top") ((:textarea :name "response" :cols 60 :rows 6) (response vac)))))))

(define-page vacancy "/vacancy/:id"
  (ps-html
   ((:form :method "POST")
     (format nil "~{~A~}"
          (list
           (to-html (car (find-vacancy :src-id id)))
           %save% %respond%))))
  (:save  "<input type=\"submit\" name=\"act\" value=\"SAVE\" />"
          (id (upd-vacancy (car (find-vacancy :src-id id))
                           (list :notes (getf p :notes) :response (getf p :response)))))
  (:respond "<input type=\"submit\" name=\"act\" value=\"RESPOND\" />"
            (progn
              (id (upd-vacancy (car (find-vacancy :src-id id))
                               (list :response (getf p :response))))
              (respond id 7628220 (getf p :response)))))
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
;;                                 :other (if (string= ":INTERESTED" (state vac)) "checked=\"checked\"" ""))))
;;                 (td
;;                  (format nil "<div style=\"background-color:red\">~A</div>"
;;                          (input "radio" :name (format nil "R~A" (id vac)) :value "n"
;;                                 :other (if (string= ":NOT_INTERESTED" (state vac)) "checked=\"checked\"" ""))))
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
;;                               (unless (string= ":INTERESTED" (state vac))
;;                                 (takt vac :interested)))
;;                              ((string= "n" val)
;;                               (unless (string= ":NOT_INTERESTED" (state vac))
;;                                 (takt vac :not_interested)))
;;                              (t "err param"))))))
;;   (:show-all (format nil "<input type=\"button\" onclick=\"test('SHOW-ALL');\" value=\"все\">")
;;              (error 'ajax :output (vacancy-table (find-vacancy :profile-id 1))))
;;   (:show-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-INTERESTS');\" value=\"интересные\">")
;;                    (error 'ajax :output (vacancy-table (find-vacancy :state ":INTERESTED" :profile-id 1))))
;;   (:show-not-interests (format nil "<input type=\"button\" onclick=\"test('SHOW-NOT-INTERESTS');\" value=\"неинтересные\">")
;;                        (error 'ajax :output (vacancy-table (find-vacancy :state ":NOT_INTERESTED" :profile-id 1))))
;;   (:show-other (format nil "<input type=\"button\" onclick=\"test('SHOW-OTHER');\" value=\"остальные\">")
;;                (error 'ajax :output (vacancy-table (remove-if #'(lambda (x)
;;                                                                   (or (string= ":NOT_INTERESTED" (state x) )
;;                                                                       (string= ":INTERESTED" (state x))))
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
