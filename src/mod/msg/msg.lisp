
(in-package #:moto)

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
               (msgtpl:dialogs
                (list
                 :content
                 (format nil "~{~A~}"
                         (loop :for item :in msgs :collect
                            (cond ((equal :rcv (car (last item)))
                                   (msgtpl:dlgrcv
                                    (list :id (car item)
                                          :from (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          )))
                                  ((equal :snd (car (last item)))
                                   (msgtpl:dlgsnd
                                    (list :id (car item)
                                          :to (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          )))
                                   (t (err "unknown dialog type")))
                                   ))))))))))


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
                               (:select :id :snd-id :ts-create :msg :state
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
                               (:select :id :rcv-id :ts-create :msg :state
                                        :from 'msg
                                        :where (:and (:= :snd-id user-id)
                                                     (:= :rcv-id (car rcvr))))
                               (:desc :ts-create))
                              1)
                             ))))
      ;; Проходим по тем последним сообщениям, что присланы нам
      (loop :for item :in snd :do
         ;; (dbg "~%:~A" item)
         ;; Проверяем, есть ли сообщение к этому абоненту в списке последних сообщений которые мы послали
         (aif (find (cadar item) rcv :key #'cadar)
              ;; Если есть, то...
              (progn
                ;; (dbg "~%:Y: ~A - ~A" (caddar item) (caddar it))
                ;; Смотрим, какое сообщение свежее
                (if (> (caddar item) (caddar it))
                    ;; Если более позднее то, что нам прислали, то
                    ;; отправляем его в res-snd
                    (progn
                      (setf res-snd (append res-snd (list item)))
                      ;; (dbg "~%|YY|res-snd: ~A" res-snd)
                      )
                    ;; Если то, что послали мы, то оправляем его в res-rcv и удаляем из rcv - останутся только неспаренные
                    (progn
                      (setf res-rcv (append res-rcv (list it)))
                      ;; (dbg "~%|NN|res-rcv: ~A" res-rcv)
                      (setf rcv (remove it rcv)))))
              ;; Если нет, то
              (progn
                ;; Результат отправляем то что есть в res-snd
                (setf res-snd (append res-snd (list item)))
                ;; (dbg "~%|N|res-snd: ~A" res-snd)
                )))
      ;; Добавляем к res-rcv неспаренные остатки из rcv
      (setf res-rcv (append res-rcv rcv))
      ;; Добавим направление
      (setf res-rcv (mapcar #'(lambda (x)
                                (append (car x) (list :rcv)))
                            res-rcv))
      (setf res-snd (mapcar #'(lambda (x)
                                (append (car x) (list :snd)))
                            res-snd))
      ;; Объединим res-rcv и res-snd и отсортируем
      (sort
       (append res-snd res-rcv)
       #'(lambda (a b)
           (> (caddr a) (caddr b)))))))
(in-package #:moto)

;; Функция отображения одного сообщения в списке сообщений
(defun show-msg-id (msg-id)
  (format nil "<div>~A</div>"
          (msg (get-msg msg-id))))


;; Тестируем сообщения
(defun msg-test ()
  
  ;; Зарегистрируем четырех пользователей
  (let ((alice (create-user "alice" "aXJAVtBT" "alice@mail.com"))
        (bob   (create-user "bob"   "pDa84LAh" "bob@mail.com"))
        (carol (create-user "carol" "zDgjGus7" "carol@mail.com"))
        (dave  (create-user "dave"  "6zt5GmvE" "dave@mail.com")))
    ;; Пусть Алиса пошлет Бобу сообщение
    (let* ((test-msg "Привет, Боб, это Алиса!")
           (msg-id (create-msg alice bob test-msg)))
      ;; Проверим, что сообщение существует
      (assert (get-msg msg-id))
      ;; Проверим, что оно находится в статусе "недоставлено"
      (assert (equal ":UNDELIVERED" (state (get-msg msg-id))))
      ;; Пусть второй пользователь запросит кол-во непрочитанных сообщений
      (let ((undelivered-msg-cnt (get-undelivered-msg-cnt bob)))
        ;; Проверим, что там одно непрочитанное сообщение
        (assert (equal 1 undelivered-msg-cnt))
        ;; Пусть второй пользователь запросит идентификаторы всех своих непрочитанных сообщений
        (let ((undelivered-msg-ids (get-undelivered-msg-ids alice bob)))
          ;; Проверим, что в списке идентификторов непрочитанных сообщений один элемент
          (assert (equal 1 (length undelivered-msg-ids)))
          ;; Получим это сообщение
          (let* ((read-msg-id (car undelivered-msg-ids))
                 (read-msg (delivery-msg read-msg-id)))
            ;; Проверим, что это именно то сообщение, которое послал первый пользователь
            (assert (equal test-msg (msg read-msg)))
            ;; Проверим, что сообщение теперь доставлено
            (assert (equal ":DELIVERED" (state (get-msg read-msg-id))))))))
    ;; Пусть Боб ответит Алисе и напишет Кэрол
    (sleep 1)
    (let* ((reply-bob-to-alice "Здравствуй, Алиса, я получил твое письмо. Я напишу Кэрол что ты нашла меня")
           (reply-bob-to-alice-id (create-msg bob alice reply-bob-to-alice)))
      (sleep 1)
      (let* ((msg-bob-to-carol "Кэрол, передаю привет от Алисы. Боб.")
             (msg-bob-to-carol-id (create-msg bob carol msg-bob-to-carol)))
        (sleep 1)
        ;; Пусть Дэйв напишет Бобу
        (let* ((msg-dave-to-bob "Привет, Боб, я хочу добавить тебя в друзья")
               (msg-dave-to-bob-id (create-msg dave bob msg-dave-to-bob)))
          ;; Получим последние диалоги Боба
          (let ((last-dialogs (get-last-msg-dialog-ids-for-user-id bob)))
            ;; (dbg "~%~A" (bprint last-dialogs))
            ;; Проверим, что в имеем три диалога
            (assert (equal 3 (length last-dialogs)))
            ;; Проверим, что сообщения правильно упорядочены
            (assert (equal (list msg-dave-to-bob-id
                                 msg-bob-to-carol-id
                                 reply-bob-to-alice-id)
                           (mapcar #'car last-dialogs)))))))
    (logout-user dave)
    (logout-user carol)
    (logout-user bob)
    (logout-user alice))
  (dbg "passed: msg-test~%"))
(msg-test)
