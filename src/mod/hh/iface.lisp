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
           ((:a :href "/hh/rules") "Правила обработки") "")
          ((:li)
           ((:a :href "/hh-doc") "Документация") ""))))
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
            ((:br))((:br))
            ((:span :class "unsort") "&nbsp;Желтым&nbsp;")
            " выделены вакансии, которые появились в момент последнего сбора данных. "
            "По умолчанию они помещаются в правый столбик - к интересующим вакансиям. "
            "После сортировки следует сохранить состояния вакансий и тогда выделение исчезнет. "
            ((:br))
            ((:span :class "responded") "&nbsp;Голубым&nbsp;") " выделены вакансии, на которые отправлен отзыв. "
            ((:br))
            ((:span :class "beenviewed") "&nbsp;Фиолетовым&nbsp;") " выделены вакансии, отзыв на которые был просмотрен. "
            ((:br))
            ((:span :class "reject") "&nbsp;Красным&nbsp;") " - если работодатель отказал. "
            "Можно попробовать откликнуться другим резюме или забить на вакансию и перенести ее в 'неинтересные' "
            ((:br))
            ((:span :class "invite") "&nbsp;Зеленым&nbsp;") " - если работодатель пригласил на собеседование. "
            ((:br))
            ((:span :class "interview") "&nbsp;Серым&nbsp;") " - если собеседование было пройдено. "
            ((:br))((:br))
            "Вакансии, к которым есть заметки, выделяются зарплатой на "
            ((:span :class "notes") "&nbsp;черном&nbsp;") " фоне. "
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
                         (when (or (equal (state vac) ":UNSORT")
                                   (equal (state vac) ":UNINTERESTING"))
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
          (form ("chvacstateform" "")
            ((:table :border 0 :style "font-size: small;")
             ((:tr)
              ((:td) "id:")
              ((:td) (id vac))
              ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "src-id:")
              ((:td) ((:a :href (format nil "http://hh.ru/vacancy/~A" (src-id vac))) (src-id vac)))
              ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "archive:")
              ((:td) (archive vac))
              ((:td) "&nbsp;&nbsp;&nbsp;"))
             ((:tr)
              ((:td) "emp-id:")
              ((:td) (emp-id vac))
              ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "emp-name:")
              ((:td) ((:span :style "color:red") (emp-name vac)))
              ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "state:")
              ((:td) (state vac))
              ((:td) "&nbsp;&nbsp;&nbsp;"))
             ((:tr)
              ((:td) "city:")       ((:td) (city vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "metro:")      ((:td) (metro vac))                                   ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "state:")
              ((:td)
               (fieldset ""
                 (eval
                  (macroexpand
                   (append `(select ("newstate" "" :default ,(subseq (state vac) 1)))
                           (list
                            (mapcar #'(lambda (x)
                                        (cons (symbol-name x) (symbol-name x)))
                                    (possible-trans vac))))))))
              ((:td) "&nbsp;&nbsp;&nbsp;"))
             ((:tr)
              ((:td) "experience:") ((:td) (experience vac))                              ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "date:")       ((:td) (date vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;")
              ((:td) "state:")      ((:td) %CHSTATE%)                                     ((:td) "&nbsp;&nbsp;&nbsp;"))
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
  (:chstate (ps-html ((:div :class "form-send-container")
                      (submit "Изменить" :name "act" :value "CHSTATE")))
            (progn
              ;; (id (upd-vacancy (car (find-vacancy :src-id src-id))
              ;;                  (list :notes (getf p :notes) :response (getf p :response))))
              (takt (car (find-vacancy :src-id src-id))
                    (intern (getf p :newstate) :keyword))
              (redirect (format nil "/hh/vac/~A" src-id))
              ))
  (:save (ps-html ((:div :class "form-send-container")
                   (submit "Сохранить вакансию" :name "act" :value "SAVE")))
         (progn
           (id (upd-vacancy (car (find-vacancy :src-id src-id))
                            (list :notes (getf p :notes) :response (getf p :response))))
           (redirect (format nil "/hh/vac/~A" src-id))))
  (:respond (ps-html
             ((:div :class "form-send-container")
              (eval
               (macroexpand
                (append '(select ("resume" "Выбрать резюме для отправки отклика:"))
                        (list
                         (mapcar #'(lambda (x) (cons (id x) (title x)))
                                 (sort (all-resume) #'(lambda (a b) (< (id a) (id b)))))))))
              (submit "Отправить отклик" :name "act" :value "RESPOND")))
            (progn
              (id (upd-vacancy (car (find-vacancy :src-id src-id))
                               (list :notes (getf p :notes) :response (getf p :response))))
              (dbg (send-respond
                    src-id
                    (res-id (get-resume (parse-integer (getf p :resume))))
                    (getf p :response)))
              (dbg (takt (car (find-vacancy :src-id src-id)) :responded)))))
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
                                                (name x)))))
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

(restas:define-route hh-doc ("/hh-doc")
  (alexandria:read-file-into-string
   (merge-pathnames
    (pathname-parent-directory (pathname *base-path*))
    #P"hh.html")))
(in-package #:moto)

(define-page search-vacancy "/hh/search"
  (let* ((breadcrumb (breadcrumb "Поиск" ("/hh" . "HeadHunter")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (base-page (:breadcrumb breadcrumb)
      (content-box ()
        (heading ("Поиск по вакансиям в состоянии выше :RESPOND") ""))
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
                                                         (remove-if #'(lambda (x)
                                                                        (or (equal ":UNSORT" (state x)))
                                                                        (or (equal ":UNINTERESTING" (state x))))
                                                                    (all-vacancy))))
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
;; iface ends here
