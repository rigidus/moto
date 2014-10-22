
(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))


;; Страница регистрации
(restas:define-route reg ("/reg")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница регистрации</h1>"
     (if *current-user*
         "Регистрация невозможна - пользователь залогинен. <a href=\"/logout\">Logout</a>"
         (frm (tbl
               (list
                (row "Имя пользователя" (fld "name"))
                (row "Пароль" (fld "password"))
                (row "Email" (fld "email"))
                (row "" (submit "Зарегистрироваться")))))))))

;; Контроллер страницы регистрации
(restas:define-route reg-ctrl ("/reg" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (setf (hunchentoot:session-value 'current-user)
            (create-user (getf p :name)
                         (getf p :password)
                         (getf p :email))))))

;; Событие создания пользователя
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (let ((user-id (id (make-user :name name :password password :email email :ts-create (get-universal-time) :ts-last (get-universal-time)))))
    (dbg "Создан пользователь: ~A" user-id)
    ;; Делаем его залогиненным
    (upd-user (get-user user-id) (list :state ":LOGGED"))
    ;; Возвращаем user-id
    user-id))

;; Страница выхода из системы
(restas:define-route logout ("/logout")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница выхода из системы</h1>"
     (if *current-user*
         (frm (tbl
               (list
                (row "" (submit "Выйти")))))
         "Выход невозможен - никто не залогинен"
         ))))

;; Контроллер страницы выхода из системы
(restas:define-route logout-ctrl ("/logout" :method :post)
  (with-wrapper
    (prog1
        (format nil "~A" (logout-user *current-user*))
      (setf (hunchentoot:session-value 'current-user) nil))))

;; Событие выхода
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged))

;; Страница логина
(restas:define-route login ("/login")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница авторизации</h1>"
     (if *current-user*
         "Авторизация невозможна - пользователь залогинен. <a href=\"/logout\">Logout</a>"
         (frm (tbl
               (list
                (row "Email" (fld "email"))
                (row "Пароль" (fld "password"))
                (row "" (submit "Войти")))))))))

;; Контроллер страницы логина
(restas:define-route login-ctrl ("/login" :method :post)
  (with-wrapper
    (aif (check-auth-data (get-auth-data (hunchentoot:post-parameters*)))
         (progn
           (setf (hunchentoot:session-value 'current-user) it)
           (login-user-success it))
         (login-user-fail))))

;; Извлечение авторизационных данных
(defmethod get-auth-data ((request list))
  (alist-to-plist request))

;; Проверка авторизационных данных
(defun check-auth-data (auth-data)
  (let ((result (find-user :email (getf auth-data :email) :password (getf auth-data :password))))
    (if (null result)
        nil
        (id (car result)))))

;; Событие успешного входа
(defun login-user-success (id)
  (takt (get-user id) :logged))

;; Событие неуспешного входа
(defun login-user-fail ()
  "Wrong auth"
  )


;; Тестируем авторизацию
(defun auth-test ()
  ;; Зарегистрируем пользователя
  (let* ((name "test-name")
         (password "test-password")
         (email "test-email")
         (new-user-id (create-user name password email)))
    ;; Проверим что он существует
    (assert (get-user new-user-id))
    ;; Проверим, что он залогинен
    (assert (equal ":LOGGED" (state (get-user new-user-id))))
    ;; Выход пользователя из системы
    (logout-user new-user-id)
    ;; Проверим, что он разлогинен
    (assert (equal ":UNLOGGED" (state (get-user new-user-id))))
    ;; Логин пользователя в систему
    (let ((logged-user-id))
      (aif (check-auth-data (get-auth-data (list (cons 'email email)
                                                 (cons 'password password))))
           (progn
             (login-user-success it)
             (setf logged-user-id it))
           (login-user-fail))
      ;; Проверим, что успешно залогинился
      (assert (equal ":LOGGED" (state (get-user logged-user-id))))
      ;; Сновa выход
      (logout-user logged-user-id))
    ;; Попытка логина с неверными credentials
    (let ((logged-user-id))
      (aif (check-auth-data (get-auth-data (list (cons 'email email)
                                                 (cons 'password "wrong-password"))))
           (progn
             (login-user-success it)
             (setf logged-user-id it))
           (login-user-fail))
      ;; Проверим, что не удалось успешно залогиниться
      (assert (equal nil logged-user-id))))
  (dbg "passed: auth-test~%"))
(auth-test)
