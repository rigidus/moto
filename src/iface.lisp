;; [[file:doc.org::*Interface][iface]]
Copyright © 2014 Glukhov Mikhail. All rights reserved.

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
    "<a href=\"/\">TODO: Простой поиск по ЖК</a>"
    "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    )))

(in-package #:moto)

(restas:define-route main ("/")
  (with-wrapper
    "<h1>Главная страница</h1>"
    ))

(in-package #:moto)

(define-iface-add-del-entity all-users "/users"
  "пользователи"
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

     (restas:define-route user ("/user/:userid")
       (with-wrapper
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
                        ))))))

     (restas:define-route user-ctrl ("/user/:userid" :method :post)
       (with-wrapper
         (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
           (cond ((getf p :addsum)   )
                 ((getf p :follow)   )
                 ((getf p :neworder) )))))
   #+END_S
* Модули
** Cущности, автоматы и их тесты

   Опишем из чего состоит модуль, это описание станет частью asd-файла:

   #+NAME: mod_entity
   #+BEGIN_SRC lisp
     (:module "entity"
              :serial t
              :pathname "mod"
              :components ((:file "entity")))
;; iface ends here
