
(in-package #:moto)


(define-automat user "Автомат пользователя"
  ((id serial)
   (name varchar)
   (password varchar)
   (email varchar)
   (ts-create bigint)
   (ts-last bigint)
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

 

(define-entity role "Сущность роли"
  ((id serial)
   (name varchar)))

(make-role-table)

(make-role :name "admin")
(make-role :name "manager")
(make-role :name "moderator")
(make-role :name "robot")

(define-entity group "Сущность группы"
  ((id serial)
   (name varchar)))

(make-group-table)

(make-group :name "oldman")
(make-group :name "newboy")
(make-group :name "veteran")
(make-group :name "traveler")
(make-group :name "dirtyman")

(define-entity user2group "Сущность связи пользователя и группы"
  ((id serial)
   (user-id integer)
   (group-id integer)))

(make-user2group-table)

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

(define-automat avatar "Автомат аватара"
  ((id serial)
   (user-id integer)
   (name varchar)
   (origin varchar)
   (ts-create bigint))
  (:inactive :active)
  ((:active :inactive :avatar-off)
   (:inactive :active :avatar-on)))

 (defun avatar-off ()
   "active -> inactive"
   )
 
 (defun avatar-on ()
   "inactive -> active"
   )

 

(define-entity bratan "Сущность братана"
  ((id serial)
   (bratan-id (or db-null integer))
   (name varchar)
   (last-seen (or db-null varchar))
   (distriсt (or db-null varchar))
   (ts_reg (or db-null varchar))
   (age (or db-null varchar))
   (birthday (or db-null varchar))
   (blood (or db-null varchar))
   (moto-exp (or db-null varchar))
   (phone (or db-null varchar))
   (activityes (or db-null varchar))
   (interests (or db-null varchar))
   (photos (or db-null varchar))
   (avatar (or db-null varchar))))

(make-bratan-table)
