;; [[file:louis.org][iface]]
;;;; 

;;;; iface.lisp

(in-package #:moto)

;; Компилируем шаблоны
(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))

;; Страницы
(in-package #:moto)

(defmethod show ((param (eql nil)) &rest actions &key &allow-other-keys)
  (ps-html
   ((:div :class "article-list-container article-list-container--list")
    ((:ul :class "article-list article-list--list")
     ((:p) "Нет элементов для отображения")))))
(in-package #:moto)

(defmethod show ((param list) &rest actions &key &allow-other-keys)
  (setf (car param)
        (apply #'show (list* (car param) actions)))
  (ps-html
   ((:div :class "article-list-container article-list-container--list")
    ((:ul :class "article-list article-list--list")
     (reduce #'(lambda (acc elt)
                 (concatenate 'string
                              acc
                              (apply #'show (list* elt actions))))
             param)))))
(in-package #:moto)

(define-page main "/"
  (let ((breadcrumb (breadcrumb "Список пользователей"))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("Что происходит?") "Последние события:"))
      (content-box ()
        (show (sort (all-event) #'(lambda (a b) (> (id a) (id b))))))
      (ps-html ((:span :class "clear"))))))

(defmethod show ((param event) &rest actions &key &allow-other-keys)
  (let ((time-record
         (multiple-value-bind (second minute hour date month year day daylight-p zone)
             (decode-universal-time (ts-create param))
           (format nil "~A:~A:~A ~A.~A.~A"
                   hour minute second date month year))))

  (ps-html
   ((:li :class "article-item article-item--list" :style "height: inherit;;")
    ((:div :class "inner")
     ((:div :class "article-item__info" :style "width: 540px; height: inherit; float: inherit;")
      ((:div :class "article-item__main-info")
       ;; ((:a :class "article-item__title-link" :href (format nil "/group/~A" (id param)))
       ;;  ((:h3 :class "article-item__title") (name param))
       ;;  ((:h4 :class "article-item__subtitle")))
       ((:p :class "article-item__description") (msg param)))
      time-record
      ;; (if (null actions)
      ;; ""
      ;;   (format nil "~{~A~}"
      ;;           (loop :for action-key :in actions :by #'cddr :collect
      ;;              (funcall (getf actions action-key) param))))
      ((:span :class "clear"))))))))
;; iface ends here
