(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))

(in-package #:moto)

(define-page reg "/reg"
  (ps-html
   ((:h1) "Страница регистрации")
   (if *current-user*
       "Регистрация невозможна - пользователь залогинен"
       (ps-html
        ((:form :method "POST")
         ((:table :border 0)
          ((:tr)
           ((:td) "Имя пользователя: ")
           ((:td) ((:input :type "text" :name "name" :value ""))))
          ((:tr)
           ((:td) "Пароль: ")
           ((:td) ((:input :type "password" :name "password" :value ""))))
          ((:tr)
           ((:td) "Email: ")
           ((:td) ((:input :type "email" :name "email" :value ""))))
          ((:tr)
           ((:td) "")
           ((:td) %register%)))))))
  (:register (ps-html
              ((:input :type "hidden" :name "act" :value "REGISTER"))
              ((:input :type "submit" :value "Зарегистрироваться")))
             (setf (hunchentoot:session-value 'current-user)
                   (create-user (getf p :name)
                                (getf p :password)
                                (getf p :email)))))
(in-package #:moto)

;; Событие создания пользователя
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (let ((user-id (id (make-user :name name :password password :email email :ts-create (get-universal-time) :ts-last (get-universal-time)))))
    (dbg "Создан пользователь: ~A" user-id)
    ;; Делаем его залогиненным
    (upd-user (get-user user-id) (list :state ":LOGGED"))
    ;; Возвращаем user-id
    user-id))
(in-package #:moto)

(define-page logout "/logout"
  (ps-html
   ((:h1) "Страница выхода из системы")
   (if *current-user*
       (ps-html
        ((:form :method "POST")
         %logout%))
       "Выход невозможен - никто не залогинен"))
  (:logout (ps-html
              ((:input :type "hidden" :name "act" :value "LOGOUT"))
              ((:input :type "submit" :value "Выйти")))
           (prog1 (format nil "~A" (logout-user *current-user*))
             (setf (hunchentoot:session-value 'current-user) nil))))
(in-package #:moto)

;; Событие выхода
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged))
(in-package #:moto)

(define-page login "/login"
  (ps-html
   ((:h1) "Страница авторизации")
   (if *current-user*
       "Авторизация невозможна - пользователь залогинен. <a href=\"/logout\">Logout</a>"
       (ps-html
        ((:form :method "POST")
         ((:table :border 0)
          ((:tr)
           ((:td) "Email: ")
           ((:td) ((:input :type "email" :name "email" :value ""))))
          ((:tr)
           ((:td) "Пароль: ")
           ((:td) ((:input :type "password" :name "password" :value ""))))
          ((:tr)
           ((:td) "")
           ((:td) %login%)))))))
  (:login (ps-html
              ((:input :type "hidden" :name "act" :value "LOGIN"))
              ((:input :type "submit" :value "Войти")))
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
  (let* ((name "admin")
         (password "tCDm4nFskcBqR7AN")
         (email "nomail@mail.ru")
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
