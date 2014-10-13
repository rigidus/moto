
(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/msg-tpl.htm")))


;; Страница сообщений
(restas:define-route msgs ("/user/:id/msgs")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница сообщений</h1>"
     (if *current-user*
         "Регистрация невозможна - пользователь залогинен. <a href=\"/logout\">Logout</a>"
         (frm (tbl
               (list
                (row "Имя пользователя" (fld "name"))
                (row "Пароль" (fld "password"))
                (row "Email" (fld "email"))
                (row "" (submit "Зарегистрироваться")))))))))

;; Контроллер страницы регистрации
(restas:define-route msgs-ctrl ("/user/:id/msgs" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (setf (hunchentoot:session-value 'current-user)
            (create-user (getf p :name)
                         (getf p :password)
                         (getf p :email))))))


;; Тестируем сообщения
(defun msg-test ()
  ;; Зарегистрируем двух пользователей
  (let ((user-id-1 (create-user "name-1" "password-1" "email-1"))
        (user-id-2 (create-user "name-2" "password-2" "email-2")))
    ;; Пусть первый пользователь пошлет второму сообщение
    (let ((msg-id (snd user-id-1 user-id-2 "message-1")))
      ;; Проверим, что сообщение существует
      (assert (get-msg msg-id))
      ;; Проверим, что оно находится в статусе "недоставлено"
      (assert (equal ":UNDELIVERED" (state (get-msg msg-id))))
      ;; Пусть второй пользователь запросит кол-во непрочитанных сообщений
      (let ((unread-msg-cnt (get-unread-msg-cnt user-id-2)))
        ;; Проверим, что там одно непрочитанное сообщение
        (assert (equal 1 unread-msg-cnt))
        ;; Пусть второй пользователь запросит идентификаторы всех своих непрочитанных сообщений
        (let ((unread-msg-ids (get-unread-msg-ids user-id)))
          ;; Проверим, что в списке идентификторов непрочитанных сообщений один элемент
          (assert (equal 1 (length unread-msgs)))
          ;; Получим это сообщение
          (let ((read-msg (car unread-msg-ids)))
            ;; Проверим, что это именно то сообщение, которое послал первый пользователь
            (assert (equal "message-1" (msg red-msg))))))))
  (dbg "passed: msg-test~%"))
(msg-test)
