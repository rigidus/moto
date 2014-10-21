
;;;; moto.lisp

(in-package #:moto)

;; Подключим глобальные определения
;;;; entity.lisp

(in-package #:moto)

;; Подключение к базе данных
(defvar *db-name* "ylg_new")
(defvar *db-user* "ylg")
(defvar *db-pass* "6mEfBjyLrSzlE")
(defvar *db-serv* "localhost")

(defvar *db-spec* (list "ylg_new" "ylg" "6mEfBjyLrSzlE" "localhost"))

;; clear db
(let ((tables '("user" "role" "group" "user2group" "msg" "flat")))
  (flet ((rmtbl (tblname)
           (when (with-connection *db-spec*
                   (query (:select 'table_name :from 'information_schema.tables :where
                                   (:and (:= 'table_schema "public")
                                         (:= 'table_name tblname)))))
             (with-connection *db-spec*
               (query (:drop-table (intern (string-upcase tblname))))))))
    (loop :for tblname :in tables :collect
       (rmtbl tblname))))

;; Описания автоматов и сущностей
;; Сущность роли
(define-entity role "Сущность роли"
  ((id serial)
   (name varchar)))

(make-role-table)

(make-role :name "admin")
(make-role :name "manager")
(make-role :name "moderator")
(make-role :name "robot")

;; Сущность группы
(define-entity group "Сущность группы"
  ((id serial)
   (name varchar)))

(make-group-table)

(make-group :name "oldman")
(make-group :name "newboy")
(make-group :name "veteran")
(make-group :name "traveler")
(make-group :name "dirtyman")

;; Сущность группы
(define-entity user2group "Сущность группы"
  ((id serial)
   (user-id integer)
   (group-id integer)))

(make-user2group-table)

(make-user2group-table)

;; Автомат пользователя
(define-automat user "Автомат пользователя"
  ((id serial)
   (name varchar)
   (password varchar)
   (email varchar)
   (ts-create bigint)
   (role-id (or db-null integer)))
  (:sended :unlogged :logged :unregistred)
  ((:unregistred :logged :registration)
   (:logged :unregistred :unregistration)
   (:unlogged :logged :enter)
   (:logged :unlogged :leave)
   (:unlogged :sended :forgot)
   (:sended :logged :remember)))

 (defun registration ()
   "unregistred -> logged"
   )
 
 (defun unregistration ()
   "logged -> unregistred"
   )
 
 (defun enter ()
   "unlogged -> logged"
   )
 
 (defun leave ()
   "logged -> unlogged"
   )
 
 (defun forgot ()
   "unlogged -> sended"
   )
 
 (defun remember ()
   "sended -> logged"
   )

 

;; Автомат сообщения
(define-automat msg "Автомат сообщения"
  ((id serial)
   (snd-id integer)
   (rcv-id integer)
   (msg varchar)
   (ts-create bigint)
   (ts-delivery bigint))
  (:delivered :undelivered)
  ((:undelivered :delivered :delivery))
  )

 (defun delivery ()
   "undelivered -> delivered"
   )


;; Веб-интерфейс

;; start
(restas:start '#:moto :port 9997)
(restas:debug-mode-on)
;; (restas:debug-mode-off)
(setf hunchentoot:*catch-errors-p* t)
