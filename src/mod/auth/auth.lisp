
(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))

;; Страница регистрации и ее контроллер
(in-package #:moto)

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

(restas:define-route reg-ctrl ("/reg" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (setf (hunchentoot:session-value 'current-user)
            (create-user (getf p :name)
                         (getf p :password)
                         (getf p :email))))))

;; Событие создания пользователя, которые вызывает контроллер регистрации
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (let ((user-id (id (make-user :name name :password password :email email))))
    (dbg "Создан пользователь: ~A" user-id)
    ;; Делаем его залогиненным
    (upd-user (get-user user-id) (list :state ":logged"))
    ;; Возвращаем user-id
    user-id))

;; Страница выхода из системы и ее контроллер
(in-package #:moto)

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

(restas:define-route logout-ctrl ("/logout" :method :post)
  (with-wrapper
    (prog1
        (format nil "~A" (logout-user *current-user*))
      (setf (hunchentoot:session-value 'current-user) nil))))

;; Событие выхода пользователя из системы
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged))

;; Страница логина и ее контроллер
(in-package #:moto)

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

(restas:define-route login-ctrl ("/login" :method :post)
  (with-wrapper
    (aif (check-auth-data (get-auth-data (hunchentoot:post-parameters*)))
         (progn
           (setf (hunchentoot:session-value 'current-user) it)
           (login-user-success it))
         (login-user-fail))))

;; Обобщенный метод извлечения авторизационных данных
(defmethod get-auth-data ((request list))
  (alist-to-plist request))

;; (get-auth-data (list (cons 'a 'b) (cons 'c 'd)))

;; Функция проверки авторизационных данных
(defun check-auth-data (auth-data)
  (let ((result (find-user :email (getf auth-data :email) :password (getf auth-data :password))))
    (if (null result)
        nil
        (id (car result)))))


;; Событие успешного входа пользователя в систему
(in-package #:moto)

(defun login-user-success (id)
  (takt (get-user id) :logged))

;; Событие неуспешного входа пользователя в систему
(in-package #:moto)

(defun login-user-fail ()
  "Wrong auth"
  )
