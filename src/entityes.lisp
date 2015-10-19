;; [[file:doc.org::*Сущности][entity_and_automates]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
(in-package #:moto)
;; entity_and_automates ends here
;; [[file:doc.org::*События][event_entity]]
(define-entity event "Сущность события"
  ((id serial)
   (name (or db-null varchar))
   (tag (or db-null varchar))
   (msg (or db-null varchar))
   (author-id (or db-null varchar))
   (ts-create bigint)))

(make-event-table)
;; event_entity ends here
;; [[file:doc.org::*Роли (role)][role_entity]]
(in-package #:moto)
(define-entity role "Сущность роли"
  ((id serial)
   (name varchar)
   (descr (or db-null varchar))))

(make-role-table)

;; (make-role :name "webuser")
;; (make-role :name "timebot")
;; (make-role :name "autotester")
;; (make-role :name "system")

;; (upd-role (get-role 1) (list :descr "Пользователи сайта. Они могут выполнять все пользовательские сценарии, (начиная с \"регистрации\" и \"логина\") и использовать все функциональные элементы на страницах сайта. Некоторые из пользователей, имеющих эту роль имеют дополнительные права, например на редактирование групп"))

;; (upd-role (get-role 2) (list :descr "Роботы, выполняющие задачи по расписанию. Могут подключаться к таймерам и использовать низкоуровневое API сайта для сбора и обработки данных. Они представляют собой код, который работает прямо внутри системы"))

;; (upd-role (get-role 3) (list :descr "Роботы, выполняющие тестирование внешних API сайта. Могу подключаться к таймерам и использовать внешнее REST-API сайта по протоколам взаимодейтствия, определенным для внешних агентов. Они представляют собой код, который работает как сторонняя программа, возможно даже на другой машине"))

;; (upd-role (get-role 4) (list :name "agent" :descr "Сторонние программы и агенты (такие, как мобильные приложения), которые могут только использовать только внешнее REST-API системы"))
;; role_entity ends here
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

(with-connection *db-spec*
  (unless (table-exists-p "user")
    (query (:alter-table "user" :add-constraint "uniq_email" :unique "email"))
    (query (:alter-table "user" :add-constraint "uniq_name" :unique "name"))))
(with-connection *db-spec*
  (unless (table-exists-p "user")
    (query (:alter-table "user" :add-constraint "foreign_role" :foreign-key ("role_id") ("role" "id")))))
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
;; user_automat ends here
;; [[file:doc.org::*Группы (group, user2group)][group_entity]]
(define-entity group "Сущность группы"
  ((id serial)
   (name varchar)
   (descr (or db-null varchar))
   (ts-create bigint)
   (author-id (or db-null integer))))

(make-group-table)

;; (make-group
;;  :name "Исполнитель желаний"
;;  :descr "Создатель штук, которых еще нет. Исправлятель штук, которые неправильно работают."
;;  :ts-create (get-universal-time)
;;  :author-id 1)
;; (make-group
;;  :name "Пропускать везде"
;;  :descr "Для этого пользователя нет запретных мест"
;;  :ts-create (get-universal-time)
;;  :author-id 1)
;; (make-group
;;  :name "Острый глаз"
;;  :descr "Обладает способностью замечать недоработки"
;;  :ts-create (get-universal-time)
;;  :author-id 1)
;; (make-group
;;  :name "Основатель"
;;  :descr "Был с нами еще до того как это стало мейнстримом"
;;  :ts-create (get-universal-time)
;;  :author-id 1)
;; (make-group
;;  :name "Рулевой"
;;  :descr "Управляет пользователями и назначает права доступа"
;;  :ts-create (get-universal-time)
;;  :author-id 1)
;; group_entity ends here
;; [[file:doc.org::*Группы (group, user2group)][user2group_entity]]
(define-entity user2group "Сущность связи пользователя и группы"
  ((id serial)
   (user-id integer)
   (group-id integer)))

(make-user2group-table)

(with-connection *db-spec*
  (unless (table-exists-p "user2group")
    (query (:alter-table "user2group" :add-constraint "on_del_user"  :foreign-key ("user_id") ("user" "id") :cascade))
    (query (:alter-table "user2group" :add-constraint "on_del_group" :foreign-key ("group_id") ("group" "id") :cascade))))
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
;; [[file:doc.org::*Задачи (task)][task_automat]]
(define-automat task "Автомат задачи"
  ((id serial)
   (name varchar)
   (blockdata varchar)
   (owner-id (or db-null integer))
   (exec-id (or db-null integer))
   (ts-create bigint))
  (:terminated :cancelled :standby :inaction :new)
  ((:new :inaction :starttask)
   (:inaction :standby :stoptask)
   (:standby :inaction :restarttask)
   (:new :cancelled :cancelnewtask)
   (:inaction :cancelled :cancelactiontask)
   (:standby :cancelled :cancelstandbytask)
   (:inaction :terminated :terminateactiontask)
   (:standby :terminated :terminatestandbytask)))

(with-connection *db-spec*
  (unless (table-exists-p "task")
    (query (:alter-table "task" :add-constraint "task_name" :unique "name"))))
(in-package #:moto)

(with-connection *db-spec*
  (unless (table-exists-p "task")
    (query (:alter-table "task" :add-constraint "on_del_user" :foreign-key ("owner_id") ("user" "id") :cascade))))
(defun starttask ()
  "new -> inaction")
(defun stoptask ()
  "inaction -> standby")
(defun restarttask ()
  "standby -> inaction")
(defun cancelnewtask ()
  "new -> cancelled")
(defun cancelactiontask ()
  "inaction -> cancelled")
(defun cancelstandbytask ()
  "standby -> cancelled")
(defun terminateactiontask ()
  "inaction -> action")
(defun terminatestandbytask ()
  "standby -> terminated")
;; task_automat ends here
;; [[file:doc.org::*Застройщики (developer)][developer_entity]]
(define-entity developer "Сущность застройщика"
  ((id serial)
   (guid varchar)
   (name varchar)
   (address varchar)
   (url varchar)
   (phone varchar)
   (note text)))

(make-developer-table)
;; developer_entity ends here
;; [[file:doc.org::*Жилые комплексы (cmpx)][cmpx_entity]]
(define-entity cmpx "Сущность комплекса"
  ((id serial)
   (guid varchar)
   (nb_sourceId integer)
   (statusId integer)
   (developerId varchar)
   (date_insert (or db-null timestamp))
   (regionId integer)
   (districtId integer)
   (district_name varchar)
   (city_name varchar)
   (street_name varchar)
   (subway1Id (or db-null integer))
   (subway2Id (or db-null integer))
   (subway3Id (or db-null integer))
   (name varchar)
   (note text)
   (longitude varchar)
   (latitude varchar)
   (dateUpdate (or db-null timestamp))
   (isPrivate integer)
   (bknId varchar)))

(make-cmpx-table)
;; cmpx_entity ends here
;; [[file:doc.org::*Корпуса жилых комплексов (blk)][blk_entity]]
(define-entity blk "Сущность корпуса"
  ((id serial)
   (guid varchar)
   (nb_sourceId integer)
   (nb_cmpxId varchar)
   (statusId integer)
   (street (or db-null varchar))
   (house (or db-null varchar))
   (corpus (or db-null varchar))
   (litera (or db-null varchar))
   (floors (or db-null varchar))
   (quarter_end (or db-null integer))
   (year_end (or db-null integer))
   (house_typeId (or db-null integer))
   (bknId (or db-null varchar))
   (dateUpdate (or db-null timestamp))))

(make-blk-table)
;; blk_entity ends here
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
