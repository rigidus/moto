
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
         (let ((msgs (get-msg-for-user-id *current-user*)))
           (mapcar #'msg
                   msgs))))))

;; (create-msg 1 4 "wefewf")

;; ;; Контроллер страницы регистрации
;; (restas:define-route reg-ctrl ("/reg" :method :post)
;;   (with-wrapper
;;     (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
;;       (setf (hunchentoot:session-value 'current-user)
;;             (create-user (getf p :name)
;;                          (getf p :password)
;;                          (getf p :email))))))

;; Событие отправки сообщения
(defun create-msg (snd-id rcv-id msg)
  (let ((msg-id (id (make-msg :snd-id snd-id :rcv-id rcv-id :msg msg))))
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


;; Функция получения всех сообщений для данного пользователя
(defun get-msg-for-user-id (user-id)
  (let ((args (list :snd-id user-id :rcv-id user-id)))
    (with-connection *db-spec*
      (query-dao 'msg
                 (sql-compile
                  (list :select :* :from 'msg
                        :where (make-clause-list ':or ':= args)))))))


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
