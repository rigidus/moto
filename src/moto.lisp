
;;;; moto.lisp

(in-package #:moto)

(closure-template:compile-template :common-lisp-backend #P"/home/rigidus/repo/moto/src/templates.htm")

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
(let ((tables '("account" "order" "quot" "symb" "user")))
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
(define-automat user "Автомат пользователя"
  ((id serial)
   (name varchar)
   (password varchar)
   (email varchar))
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

 

;; Веб-интерфейс

;; start
(restas:start '#:moto :port 9997)
(restas:debug-mode-on)
;; (restas:debug-mode-off)
(setf hunchentoot:*catch-errors-p* t)
