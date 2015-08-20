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
  (let ((breadcrumb (breadcrumb "Последние измениния"))
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
(in-package #:moto)

;; Событие создания задачи
(defun create-task (name blockdata)
  "Создание задачи. Возвращает id"
  (let ((new (make-task :name name
                        :blockdata blockdata
                        :owner-id *current-user*
                        :exec-id *current-user* ;; идентификатор исполнителя
                        :ts-create (get-universal-time))))
    (if (null new)
        (err 'err-create-task)
        ;; else
        (progn
          (make-event :name "create-task"
                      :tag "create"
                      :msg (aif *current-user*
                                (format nil "Пользователь #~A : ~A cоздал задачу #~A : ~A"
                                        *current-user*
                                        (name (get-user *current-user*))
                                        (id new)
                                        (name new)))
                      :author-id *current-user*
                      :ts-create (get-universal-time))
          ;; Возвращаем user-id
          (id new))
        )))

(defmethod show ((param task) &rest actions &key &allow-other-keys)
  (ps-html
   ((:li :class "article-item article-item--list")
    ((:div :class "inner")
     ;; ((:a :class "article-item__image" :href (format nil "/user/~A" (id param))) avatar)
     ((:div :class "article-item__info" :style "width: 540px;")
      ;; ((:img :class "article-item__manufacturer" :src birka))
      ((:div :class "article-item__main-info")
       ((:a :class "article-item__title-link" :href (format nil "/user/~A" (id param)))
        ((:h3 :class "article-item__title") (name param)))
       ((:p :class "article-item__description")
        (blockdata param)))
      ;; (if (null actions)
      ;;     ""
      ;;     (format nil "~{~A~}"
      ;;             (loop :for action-key :in actions :by #'cddr :collect
      ;;                (funcall (getf actions action-key) param))))
      ((:span :class "clear")))))))

(labels ((perm-check (current-user)
           (is-in-group "Постановщик задач" current-user)))
  (define-page all-tasks "/tasks"
    (let ((breadcrumb (breadcrumb "Список задач"))
          (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ("Список задач")
            "Задачи - это обьекты, созданные пользователями для роботов (или для других пользователей), "
            "которые из исполняют и предоставляют результат. "
            "Задачи можно создавать, удалять, запускать на выполнение немедленно, "
            "запускать на выполнение по расписанию и приостанавливать."))
        (if (not (perm-check *current-user*))
            ""
            (content-box ()
              (form ("maketaskform" "Создать задачу" :class "form-section-container")
                ((:div :class "form-section")
                 (fieldset ""
                   (input ("name" "Имя" :required t :type "text"))
                   (textarea ("blockdata" "Суть задачи"))
                   ))
                %NEW%)))
        (content-box ()
          (let ((tmp (show (sort (all-task) #'(lambda (a b) (< (id a) (id b))))
                           :del #'(lambda (user) %DEL%))))
            (ps-html ((:form :method "POST") ((:input :type "hidden" :name "act" :value "DEL")) tmp))))
        (ps-html ((:span :class "clear")))))
    (:DEL (if (perm-check *current-user*)
              (ps-html ((:form :method "POST")
                        ((:input :type "hidden" :name "act" :value "DEL"))
                        (submit "Удалить" :name "data" :value (id task))))
              "")
          (if (perm-check *current-user*)
              (progn
                (remove-task (parse-integer (getf p :data)))
                (redirect "/tasks"))
              ""))
    (:new (if (not (perm-check *current-user*))
              ""
              (ps-html
               ((:input :type "hidden" :name "act" :value "NEW"))
               ((:div :class "form-send-container")
                (submit "Создать задачу" ))))
          (if (not (perm-check *current-user*))
              ""
              (let ((new-id (create-task
                             (getf p :name)
                             (getf p :blockdata))))
                ;; (upd-task (get-task new-id)
                ;;           (list
                ;;            :role-id (parse-integer (getf p :role))
                ;;            :ts-create (get-universal-time)
                ;;            :ts-last (get-universal-time)))
                (redirect "/tasks"))))))

(in-package #:moto)

;; (restas:define-route frp ("/frp")
;;   "<script type=\"text/javascript\" src=\"/js/frp.js\"></script>")


(define-page frp "/frp"
  (let ((breadcrumb (breadcrumb "FRP"))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("FRP")
          "Тестируем FRP")
        (ps-html ((:div :id "frp")))
      (ps-html ((:span :class "clear")))))
  ))
;; iface ends here
