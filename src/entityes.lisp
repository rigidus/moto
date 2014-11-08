;; [[file:doc.org::*Сущности и автоматы][entity_and_automates]]
(in-package #:moto)

(define-automat user "Автомат пользователя"
  ((id serial)
   (name varchar)
   (password varchar)
   (email varchar)
   (ts-create bigint)
   (ts-last bigint)
   (role-id (or db-null integer)))
  (:sended :unlogged :logged :unregistred):abcdefg  )
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
   (name (or db-null varchar))))

(make-role-table)


(make-role :name "admin")
(make-role :name "manager")
(make-role :name "moderator")
(make-role :name "editor")
(make-role :name "robot")


(define-entity group "Сущность группы"
  ((id serial)
   (name varchar)))

(make-group-table)


(make-group :name "oldman")
(make-group :name "newboy")
(make-group :name "veteran")
(make-group :name "traveler")
(make-group :name "troll")

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
  (:delivered :undelivered):abcdefg  )
  ((:undelivered :delivered :delivery)))


(defun delivery ()
  "undelivered -> delivered"
  )


(define-entity que "Сущность очереди"
  ((id serial)
   (name varchar)))

(make-que-table)


;; (make-que :name "admin")
;; (make-que :name "manager")
;; (make-que :name "moderator")
;; (make-que :name "robot")

(define-entity quelt "Сущность элемента очереди"
  ((id serial)
   (que-id integer)
   (text varchar)))

(make-quelt-table)





(define-automat avatar "Автомат аватара"
  ((id serial)
   (user-id integer)
   (name varchar)
   (origin varchar)
   (ts-create bigint))
  (:inactive :active):abcdefg  )
  ((:active :inactive :avatar-off)
   (:inactive :active :avatar-on)))


(defun avatar-off ()
  "active -> inactive"
  )

(defun avatar-on ()
  "inactive -> active"
  )




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
  (:куплен :продан :чинится :угнан :хлам :сломан :продается :используется):abcdefg  )
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
(in-package #:moto)

;; (loop :for item :in (with-connection *db-spec*
;;                        (query
;;                         (:limit
;;                          (:select 'motos
;;                                   :from 'bratan
;;                                   :where (:not (:like "" 'motos)))
;;                                  999999999999))) :do
;;    (format t "~%~A"
;;             (ppcre:split "\\s+" (car item))))




(define-entity color "Сущность цвета"
  ((id serial)
   (name varchar)))

(make-color-table)



(define-entity vendor "Сущность производителя"
  ((id serial)
   (name varchar)))

(make-vendor-table)



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
;; entity_and_automates ends here
