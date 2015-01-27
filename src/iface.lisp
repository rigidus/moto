;; [[file:doc.org::*Interface][iface]]
;;;; Copyright © 2014 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3

;;;; iface.lisp

(in-package #:moto)

;; Меню

;; Враппер веб-интерфейса

;; Хелпер форм

;; Страницы

(in-package #:moto)

(defun menu ()
  (remove-if
   #'null
   (list
    (when *current-user*
      "<a href=\"/users\">Пользователи</a>")
    (when *current-user*
      "<a href=\"/roles\">Роли</a>")
    (when *current-user*
      "<a href=\"/groups\">Группы</a>")
    ;; "<a href=\"/cmpxs\">Жилые комплексы</a>"
    ;; "<a href=\"/find\">Простой поиск</a>"
    (when (null *current-user*)
      "<a href=\"/reg\">Регистрация</a>")
    (when (null *current-user*)
      "<a href=\"/login\">Логин</a>")
    (when (null *current-user*)
      "Больше возможностей доступно залогиненным пользователям")
    (when *current-user*
      (format nil "<a href=\"/user/~A\">Мой профиль</a>" *current-user*))
    (when *current-user*
      "<a href=\"/logout\">Выход</a>")
    (when *current-user*
      "<a href=\"/im\">Сообщения</a>")
    (when *current-user*
      "<a href=\"/load\">Загрузка данных</a>")
    ;; "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    )))

(in-package #:moto)

(restas:define-route main ("/")
  (with-wrapper
      "<h1>Главная страница</h1>"
    ))
(in-package #:moto)

(define-page all-users "/users"
  (ps-html
   ((:h1) "Пользователи")
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список пользователей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "password")
         (:th "email")
         (:th "ts-create")
         (:th "ts-last")
         (:th "role-id")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) ((:a :href (format nil "/user/~A" (id i))) (id i)))
                     ((:td) (name i))
                     ((:td) (if (equal 1 *current-user*) (password i) ""))
                     ((:td) (email i))
                     ((:td) (ts-create i))
                     ((:td) (ts-last i))
                     ((:td) (role-id i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать нового пользователя")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя пользователя: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "Пароль: ")
                ((:td) ((:input :type "password" :name "password" :value ""))))
               ((:tr)
                ((:td) "Email: ")
                ((:td) ((:input :type "email" :name "email" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (and (equal 1 *current-user*)
                 (not (equal 1 (id i))))
              (ps-html
               ((:form :method "POST")
                ((:input :type "hidden" :name "act" :value "DEL"))
                ((:input :type "hidden" :name "data" :value (id i)))
                ((:input :type "submit" :value "Удалить"))))
              "")
        (del-user (getf p :data)))
  (:new (ps-html
         ((:input :type "hidden" :name "act" :value "NEW"))
         ((:input :type "submit" :value "Создать")))
        (progn
          (make-user :name (getf p :name)
                     :email (getf p :email)
                     :password (getf p :password)
                     :ts-create (get-universal-time)
                     :ts-last (get-universal-time))
          "Пользователь создан")))
(in-package #:moto)

(define-page all-roles "/roles"
  (ps-html
   ((:h1) "Роли")
   "Роли определяют набор сценариев, которые пользователь выполняет на
сайте. Функционал, который выполняют сценарии запрашивает
разрешение на выполнение действий, которое опирается на роль,
присвоенную пользователю. Пользователь может иметь только одну роль
или не иметь ее вовсе."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список ролей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую роль")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя роли: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-role (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-role :name (getf p :name))
              "Роль создана")
            "")))
(in-package #:moto)

(define-page all-groups "/groups"
  (ps-html
   ((:h1) "Группы")
   "Группы пользователей определяют набор операций, которые
пользователь может выполнять над объектами системы. В отличие от
ролей, один пользователь может входить в несколько групп или не
входить ни в одну из них."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список групп"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую группу")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя шруппы: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-group (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-group :name (getf p :name))
              "Группа создана")
            "")))

(in-package #:moto)

(define-page user "/user/:userid"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}"
                (list
                 (format nil "~{~A~}"
                         (with-element (u u)
                           (ps-html
                            ((:h1) (format nil "Страница пользователя #~A - ~A" (id u) (name u)))
                            ((:table :border 0)
                             ((:tr)
                              ((:td) "id")
                              ((:td) (id u)))
                             ((:tr)
                              ((:td) "name")
                              ((:td) (name u)))
                             ((:tr)
                              ((:td) "password")
                              ((:td) (password u)))
                             ((:tr)
                              ((:td) "email")
                              ((:td) (email u)))
                             ((:tr)
                              ((:td) "ts-create")
                              ((:td) (ts-create u)))
                             ((:tr)
                              ((:td) "ts-last")
                              ((:td) (ts-last u)))
                             ((:tr)
                              ((:td) "role-id")
                              ((:td) (role-id u))))
                            ((:form :method "POST")
                             ((:table :border 0)
                              ((:tr)
                               ((:td) "Текущая роль:")
                               ((:td) ((:select :name "role")
                                       ((:option :value "0") "Выберите роль")
                                       (format nil "~{~A~}"
                                               (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                                                 (if (equal (id i) (role-id u))
                                                     (ps-html
                                                      ((:option :value (id i) :selected "selected") (name i)))
                                                     (ps-html
                                                      ((:option :value (id i)) (name i))))))))
                               ((:td) %change-role%))))
                            ((:form :method "POST")
                             ((:table :border 0)
                              ((:tr)
                               ((:td :valign "top") "Группы пользователя:")
                               ((:td :valign "top") ((:select :name "groups" :multiple "multiple" :size "7")
                                       (format nil "~{~A~}"
                                               (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                                                 (if (find (id i) (mapcar #'group-id (find-user2group :user-id (parse-integer userid))))
                                                     (ps-html
                                                      ((:option :value (id i) :selected "selected") (name i)))
                                                     (ps-html
                                                      ((:option :value (id i)) (name i))))))))
                               ((:td :valign "top") %change-group%)))))))))))
  (:change-role (if (equal 1 *current-user*)
                    (ps-html
                     ((:input :type "hidden" :name "act" :value "CHANGE-ROLE"))
                     ((:input :type "submit" :value "Изменить")))
                    "")
                (if (equal 1 *current-user*)
                    (let* ((i (parse-integer userid))
                           (u (get-user i)))
                      (aif (getf p :role)
                           (role-id (upd-user u (list :role-id (parse-integer it))))
                           "role changed"))
                    "access-denied"))
  (:change-group (if (equal 1 *current-user*)
                     (ps-html
                      ((:input :type "hidden" :name "act" :value "CHANGE-GROUP"))
                      ((:input :type "submit" :value "Изменить")))
                     "")
                 (if (equal 1 *current-user*)
                     (let* ((i (parse-integer userid))
                            (u (get-user i)))
                       (if (null (getf p :groups))
                           "-not change-"
                           (loop
                              :initially (mapcar #'(lambda (x)
                                                     (del-user2group (id x)))
                                                 (find-user2group :user-id (parse-integer userid)))
                              :for lnk
                              :in (loop
                                     :for key  :in p    :by #'cddr
                                     :for n    :from 1  :to 10 :by (+ 2)
                                     :when    (equal key :groups)
                                     :collect (parse-integer (nth n p)))
                              :collect (id (make-user2group :user-id i :group-id lnk)))))
                     "access-denied")))
;; iface ends here
