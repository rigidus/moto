
(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/msg/msg-tpl.htm")))

(in-package #:moto)

;; Страница сообщений
(restas:define-route im ("/im")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница сообщений</h1>"
     (if (not *current-user*)
         "Невозможно посмотреть сообщения - пользователь не залогинен. <a href=\"/login\">Login</a>"
         (let ((msgs (get-last-msg-dialog-ids-for-user-id *current-user*)))
           (if (equal 0 (length msgs))
               "Нет сообщений"
               (format nil "~{~A~}"
                       (mapcar #'show-msg-id msgs))))))))

;; Событие отправки сообщения
(defun create-msg (snd-id rcv-id msg)
  (let ((msg-id (id (make-msg :snd-id snd-id :rcv-id rcv-id :msg msg :ts-create (get-universal-time) :ts-delivery 0))))
    (dbg "Создано сообщение: ~A" msg-id)
    ;; Делаем его недоставленным
    (upd-msg (get-msg msg-id) (list :state ":UNDELIVERED"))
    ;; Возвращаем msg-id
    msg-id))

;; Функция получения кол-ва непрочитанных сообщений
(defun get-undelivered-msg-cnt (rcv-id)
  (length (find-msg :rcv-id rcv-id :state ":UNDELIVERED")))

;; Функция получения идентификторов непрочитанных сообщений
(defun get-undelivered-msg-ids (snd-id rcv-id)
  (mapcar #'id (find-msg :snd-id snd-id :rcv-id rcv-id :state ":UNDELIVERED")))

;; Функция получения идентификторов непрочитанных сообщений
(defun delivery-msg (msg-id)
  (let ((msg (get-msg msg-id)))
    (if (equal ":UNDELIVERED" (state msg))
        (takt (get-msg msg-id) :delivered))
    msg))

(in-package #:moto)

;; Функция получения всех идентификаторов сообщений для данного пользователя
(defun get-last-msg-dialog-ids-for-user-id (user-id)
  (with-connection *db-spec*
    (let* ((res-snd)
           (res-rcv)
           ;; Получим идентификторы всех, кто нам писал, по ним получим последнее написанное ими сообщение
           (snd (loop
                   :for sndr
                   :in  (query (:select :snd-id :distinct :from 'msg :where (:= :rcv-id user-id)))
                   :collect (query
                             (:limit
                              (:order-by
                               (:select :id :snd-id :ts-create :msg
                                        :from 'msg
                                        :where (:and (:= :rcv-id user-id)
                                                     (:= :snd-id (car sndr))))
                               (:desc :ts-create))
                              1)
                             )))
           ;; Получим идентификторы всех, кому мы писали, по ним получим последнее написанное нами сообщение
           (rcv (loop
                   :for rcvr
                   :in  (query (:select :rcv-id :distinct :from 'msg :where (:= :snd-id user-id)))
                   :collect (query
                             (:limit
                              (:order-by
                               (:select :id :rcv-id :ts-create :msg
                                        :from 'msg
                                        :where (:and (:= :snd-id user-id)
                                                     (:= :rcv-id (car rcvr))))
                               (:desc :ts-create))
                              1)
                             ))))
      ;; Проходим по тем последним сообщениям, что адресованы нам
      (loop :for item :in snd :do
         ;; Проверяем, есть ли сообщение к этому абоненту в списке последних сообщений которые мы послали
         (aif (find (cadar item) rcv :key #'cadar)
              ;; Если есть, то смотрим, какое сообщение более свежее
              (if (> (caddar item) (caddar it))
                  ;; Если то, что нам прислали, то отправляем его в res-snd
                  (setf res-snd (append res-snd (list item)))
                  ;; Если то, что послали мы, то оправляем его в res-rcv
                  (setf res-rcv (append res-rcv (list it))))
              ;; Если нет, то в результат отправляем то что есть в res-snd
              (setf res-snd (append res-snd (list item)))))
      (values res-snd res-rcv))))
(in-package #:moto)

;; Функция отображения одного сообщения в списке сообщений
(defun show-msg-id (msg-id)
  (format nil "<div>~A</div>"
          (msg (get-msg msg-id))))


;; Тестируем сообщения
(defun msg-test ()
  
  ;; Зарегистрируем двух пользователей
  (let ((user-id-1 (create-user "name-1" "password-1" "email-1"))
        (user-id-2 (create-user "name-2" "password-2" "email-2")))
    ;; Пусть первый пользователь пошлет второму сообщение
    (let ((msg-id (create-msg user-id-1 user-id-2 "message-1")))
      ;; Проверим, что сообщение существует
      (assert (get-msg msg-id))
      ;; Проверим, что оно находится в статусе "недоставлено"
      (assert (equal ":UNDELIVERED" (state (get-msg msg-id))))
      ;; Пусть второй пользователь запросит кол-во непрочитанных сообщений
      (let ((undelivered-msg-cnt (get-undelivered-msg-cnt user-id-2)))
        ;; Проверим, что там одно непрочитанное сообщение
        (assert (equal 1 undelivered-msg-cnt))
        ;; Пусть второй пользователь запросит идентификаторы всех своих непрочитанных сообщений
        (let ((undelivered-msg-ids (get-undelivered-msg-ids user-id-1 user-id-2)))
          ;; Проверим, что в списке идентификторов непрочитанных сообщений один элемент
          (assert (equal 1 (length undelivered-msg-ids)))
          ;; Получим это сообщение
          (let* ((read-msg-id (car undelivered-msg-ids))
                 (read-msg (delivery-msg read-msg-id)))
            ;; Проверим, что это именно то сообщение, которое послал первый пользователь
            (assert (equal "message-1" (msg read-msg)))
            ;; Проверим, что сообщение теперь доставлено
            (assert (equal ":DELIVERED" (state (get-msg read-msg-id))))
            )))))
  (dbg "passed: msg-test~%"))
(msg-test)
