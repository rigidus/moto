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
    "<a href=\"/users\">Пользователи</a>"
    "<a href=\"/roles\">Роли</a>"
    "<a href=\"/groups\">Группы</a>"
    "<a href=\"/cmpxs\">Жилые комплексы</a>"
    "<a href=\"/find\">Простой поиск</a>"
    (when (null *current-user*)
      "<a href=\"/reg\">Регистрация</a>")
    (when (null *current-user*)
      "<a href=\"/login\">Логин</a>")
    (when (null *current-user*)
      "Больше возможностей доступно залогиненным пользоватям")
    (when *current-user*
      (format nil "<a href=\"/user/~A\">Мой профиль</a>" *current-user*))
    (when *current-user*
      "<a href=\"/logout\">Выход</a>")
    (when *current-user*
      "<a href=\"/im\">Сообщения</a>")
    (when *current-user*
      "<a href=\"/load\">Загрузка данных</a>")
    "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    )))

(in-package #:moto)

(restas:define-route main ("/")
  (with-wrapper
      "<h1>Главная страница</h1>"
    ))

(in-package #:moto)

(define-iface-add-del-entity all-users "/users"
  "Пользователи"
  "Новый пользователь"
  ""
  #'all-user "user"
  (name password email state role-id)
  (frm
   (tbl
    (list
     (row "Имя" (fld "name"))
     (row "Email" (fld "email"))
     (row "Пароль" (fld "password"))
     (row "" %new%))))
  (:new (act-btn "NEW" "" "Создать")
        (progn
          (make-user :name (getf p :name)
                     :email (getf p :email)
                     :password (getf p :password)
                     :ts-create (get-universal-time)
                     :ts-last (get-universal-time))
          "Пользователь создан"))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn
          (del-user (getf p :data)))))

(in-package #:moto)

(define-iface-add-del-entity all-roles "/roles"
  "Роли пользователей"
  "Новая роль"
  "Роли определяют набор сценариев, которые пользователь выполняет на
сайте. Функционал, который выполняют сценарии запрашивает
разрешение на выполнение действий, которое опирается на роль,
присвоенную пользователю. Пользователь может иметь только одну роль
или не иметь ее вовсе."
  #'all-role "role"
  (name)
  (frm
   (tbl
    (list
     (row "Название" (fld "name"))
     (row "" %new%))))
  (:new (act-btn "NEW" "" "Создать")
        (progn
          (make-role :name (getf p :name))
          "Роль создана"))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn
          (del-role (getf p :data)))))

(in-package #:moto)

(define-iface-add-del-entity all-groups "/groups"
  "Группы пользователей"
  "Новая группа"
  "Группы пользователей определяют набор операций, которые
пользователь может выполнять над объектами системы. В отличие от
ролей, один пользователь может входить в несколько групп или не
входить ни в одну из них."
  #'all-group "group"
  (name)
  (frm
   (tbl
    (list
     (row "Название" (fld "name"))
     (row "" %new%))))
  (:new (act-btn "NEW" "" "Создать")
        (progn
          (make-group :name (getf p :name))
          "Роль создана"))
  (:del (act-btn "DEL" (id i) "Удалить")
        (progn
          (del-group (getf p :data)))))

(in-package #:moto)

(define-page user "/user/:userid"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}"
                (list
                 (format nil "<h1>Страница пользователя ~A</h1>" (id u))
                 (format nil "<h2>Данные пользователя ~A</h2>" (name u))
                 (tbl
                  (with-element (u u)
                    (row "Имя пользователя" (name u))
                    (row "Пароль" (password u))
                    (row "Email" (email u)))
                  :border 1)
                 (format nil "<h2>Роль пользователя ~A</h2>" (name u))
                 (frm
                  (tbl
                   (list
                    (row "Текущая роль"
                      (select ("role")
                        (list* (list "Выберите роль" "0"
                                     (format nil "disabled~A"
                                             (if (equal :null (role-id u))
                                                 "selected"
                                                 "")))
                               (with-collection (i (all-role))
                                 (list (name i)
                                       (id i)
                                       (if (equal (id i) (role-id u))
                                           "selected"))))))
                    (row "" %change-role%))))
                 (format nil "<h2>Группы пользователя ~A</h2>" (name u))
                 (frm
                  (tbl
                   (list
                    (row "Группы в которые входит пользователь"
                      (select ("groups" "multiple size=\"5\"")
                        (with-collection (i (all-group))
                          (list (name i)
                                (id i)
                                (if (find (id i)
                                          (mapcar #'group-id
                                                  (find-user2group :user-id (parse-integer userid))))
                                    "selected")))))
                    (row "" %change-group%))))))))
  (:change-role (act-btn "CHANGE-ROLE" "" "Изменить")
           (let* ((i (parse-integer userid))
                  (u (get-user i)))
             (aif (getf p :role)
                  (role-id (upd-user u (list :role-id (parse-integer it))))
                  ":null")))
  (:change-group (act-btn "CHANGE-GROUP" "" "Изменить")
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
                          :collect (id (make-user2group :user-id i :group-id lnk)))))))
;; iface ends here
