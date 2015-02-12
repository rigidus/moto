;; [[file:doc.org::*Сущности][entity_and_automates]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
(in-package #:moto)
;; entity_and_automates ends here
;; [[file:doc.org::*Пользователи (user)][user_automat]]
(define-automat user "Автомат пользователя"
  ((id serial)
   (name varchar)
   (password varchar)
   (email varchar)
   (firstname (or db-null varchar))
   (lastname (or db-null varchar))
   (phone (or db-null varchar))
   (mobilephone (or db-null varchar))
   (sex (or db-null varchar))
   (birth-day (or db-null varchar))
   (birth-month (or db-null varchar))
   (birth-year (or db-null varchar))
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
  "unregistred -> logged")
(defun unregistration ()
  "logged -> unregistred")
(defun enter ()
  "unlogged -> logged")
(defun leave ()
  "logged -> unlogged")
(defun forgot ()
  "unlogged -> sended")
(defun remember ()
  "sended -> logged")
;; NAME DB CONSTRAINT

(with-connection *db-spec*
  (unless (table-exists-p "user")
    (query (:alter-table "user" :add-constraint "uniq_name" :unique "name"))))
;; user_automat ends here
;; [[file:doc.org::*Роли (role)][role_entity]]
(define-entity role "Сущность роли"
  ((id serial)
   (name varchar)))

(make-role-table)

;; (make-role :name "admin")
;; (make-role :name "manager")
;; (make-role :name "moderator")
;; (make-role :name "system")
;; role_entity ends here
;; [[file:doc.org::*Группы (group, user2group)][group_entity]]
(define-entity group "Сущность группы"
  ((id serial)
   (name varchar)
   (descr (or db-null varchar))
   (author-id (or db-null integer))))

(make-group-table)

(make-role :name "Исполнитель желаний" :descr "Может сделать то что ты хочешь. Обращайся")
(make-role :name "Пропускать везде" :descr "Для этого пользователя нет запретных мест")
(make-role :name "Острый глаз" :descr "Обладает способностью замечать мельчайшие недоработки")
(make-role :name "Основатель" :descr "Стоял у истоков проекта")
;; group_entity ends here
;; [[file:doc.org::*Группы (group, user2group)][user2group_entity]]
(define-entity user2group "Сущность связи пользователя и группы"
  ((id serial)
   (user-id integer)
   (group-id integer)))

(make-user2group-table)
;; user2group_entity ends here
;; [[file:doc.org::*Сообщения (msg)][msg_automat]]
(define-automat msg "Автомат сообщения"
  ((id serial)
   (snd-id integer)
   (rcv-id integer)
   (msg varchar)
   (ts-create bigint)
   (ts-delivery bigint))
  (:delivered :undelivered)
  ((:undelivered :delivered :delivery)))

(defun delivery ()
  "undelivered -> delivered")
;; msg_automat ends here
;; [[file:doc.org::*Очереди (que, quelt)][que_entity]]
(define-entity que "Сущность очереди"
  ((id serial)
   (name varchar)))

(make-que-table)

(define-entity quelt "Сущность элемента очереди"
  ((id serial)
   (que-id integer)
   (text varchar)))

(make-quelt-table)

;; (make-que :name "admin")
;; (make-que :name "manager")
;; (make-que :name "moderator")
;; (make-que :name "robot")
;; que_entity ends here
;; [[file:doc.org::*Аватары (avatar)][avatar_automat]]
(define-automat avatar "Автомат аватара"
  ((id serial)
   (user-id integer)
   (origin varchar)
   (ts-create bigint))
  (:inactive :active)
  ((:active :inactive :avatar-off)
   (:inactive :active :avatar-on)))

(defun avatar-off ()
  "active -> inactive")
(defun avatar-on ()
  "inactive -> active")
;; avatar_automat ends here
;; [[file:doc.org::*Аватары (avatar)][avatar_automat]]
(in-package #:moto)

(defmethod get-avatar-img ((user-id integer) (size (eql :small))) ;; 50x50
  (ps-html ((:img :src (aif (car (find-avatar :user-id user-id :state ":ACTIVE"))
                            (concatenate 'string "/ava/small/" (origin it))
                            "/ava/small/0.png")))))

(defmethod get-avatar-img ((user-id integer) (size (eql :middle))) ;; 170x170
  (ps-html ((:img :src (aif (car (find-avatar :user-id user-id :state ":ACTIVE"))
                            (concatenate 'string "/ava/middle/" (origin it))
                            "/ava/middle/0.png")))))

(defmethod get-avatar-img ((user-id integer) (size (eql :big))) ;; 512x512
  (ps-html ((:img :src (aif (car (find-avatar :user-id user-id :state ":ACTIVE"))
                            (concatenate 'string "/ava/big/" (origin it))
                            "/ava/big/0.png")))))

;; (drop '("group"))
;; avatar_automat ends here
;; [[file:doc.org::*Мотоциклы (moto)][moto_automat]]
(define-automat moto "Автомат мотоцикла"
  ((id serial)
   (vendor-id (or db-null integer))
   (model-id (or db-null integer))
   (color-id (or db-null integer))
   (year (or db-null integer))
   (price (or db-null integer))
   (plate (or db-null varchar))
   (vin (or db-null varchar))
   (frame-num (or db-null varchar))
   (engine-num (or db-null varchar))
   (pts-data (or db-null varchar))
   (desc (or db-null varchar))
   (tuning (or db-null varchar)))
  (:куплен :продан :чинится :угнан :хлам :сломан :продается :используется)
  ((:используется :продается :выставление.на.продажу)
   (:используется :сломан :сломался)
   (:используется :хлам :крэш)
   (:используется :угнан :угон)
   (:угнан :сломан :воры.повредили)
   (:угнан :хлам :воры.разбили)
   (:продается :используется :отмена.выставления.на.продажу)
   (:сломан :чинится :отвоз.в.ремонт)
   (:сломан :хлам :доломал)
   (:чинится :сломан :неосилил.починить)
   (:чинится :используется :починил)
   (:чинится :хлам :здесь.не.починишь)
   (:продается :продан :продажа)
   (:продан :куплен :покупка)
   (:куплен :используется :ввод.в.эксплуатацию)
   (:угнан :используется :возврат.с.угона)))

(defun |выставление.на.продажу| ()
  "используется -> продается")
(defun |сломался| ()
  "используется -> сломан")
(defun |крэш| ()
  "используется -> хлам")
(defun |угон| ()
  "используется -> угнан")
(defun |воры.повредили| ()
  "угнан -> сломан")
(defun |воры.разьебали| ()
  "угнан -> хлам")
(defun |отмена.выставления.на.продажу| ()
  "продается -> используется")
(defun |отвоз.в.ремонт| ()
  "сломан -> чинится")
(defun |доломал| ()
  "сломан -> хлам")
(defun |неосилил.починить| ()
  "чинится -> сломан")
(defun |починил| ()
  "чинится -> используется")
(defun |здесь.не.починишь| ()
  "чинится -> хлам")
(defun |продажа| ()
  "продается -> продан")
(defun |покупка| ()
  "продан -> куплен")
(defun |ввод.в.эксплуатацию| ()
  "куплен -> используется")
(defun |возврат.с.угона| ()
  "угнан -> используется")
;; moto_automat ends here
;; [[file:doc.org::*Цвет (color)][color_entity]]
(define-entity color "Сущность цвета"
  ((id serial)
   (name varchar)))

(make-color-table)
;; color_entity ends here
;; [[file:doc.org::*Производитель (vendor)][vendor_entity]]
(define-entity vendor "Сущность производителя"
  ((id serial)
   (name varchar)))

(make-vendor-table)
;; vendor_entity ends here
;; [[file:doc.org::*Братан (bratan)][bratan_entity]]
(define-entity bratan "Сущность братана"
  ((id serial)
   (bratan-id (or db-null integer))
   (ts-last-upd (or db-null bigint))
   (name varchar)
   (fio (or db-null varchar))
   (last-seen (or db-null varchar))
   (addr (or db-null varchar))
   (ts_reg (or db-null varchar))
   (age (or db-null varchar))
   (birthday (or db-null varchar))
   (blood (or db-null varchar))
   (moto-exp (or db-null varchar))
   (phone (or db-null varchar))
   (activityes (or db-null varchar))
   (interests (or db-null varchar))
   (photos (or db-null varchar))
   (avatar (or db-null varchar))
   (motos (or db-null varchar))))

(make-bratan-table)
;; bratan_entity ends here
