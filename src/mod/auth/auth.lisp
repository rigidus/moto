(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))

(in-package #:moto)

;; Событие создания пользователя
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (aif (make-user :name name :password password :email email :ts-create (get-universal-time) :ts-last (get-universal-time))
       (progn
         ;; (dbg "Создан пользователь: ~A" (id it))
         ;; Делаем его залогиненным
         (upd-user (get-user (id it)) (list :state ":LOGGED"))
         ;; Возвращаем user-id
         (id it))
       (err 'err-create-user)))
;; (in-package #:moto)

;; (define-page logout "/logout"
;;   (ps-html
;;    ((:h1) "Страница выхода из системы")
;;    (if *current-user*
;;        (ps-html
;;         ((:form :method "POST")
;;          %logout%))
;;        "Выход невозможен - никто не залогинен"))
;;   (:logout (ps-html
;;               ((:input :type "hidden" :name "act" :value "LOGOUT"))
;;               ((:input :type "submit" :value "Выйти")))
;;            (prog1 (format nil "~A" (logout-user *current-user*))
;;              (setf (hunchentoot:session-value 'current-user) nil))))
(in-package #:moto)

;; Событие выхода
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged))

;; Извлечение авторизационных данных
(defmethod get-auth-data ((request list))
  (alist-to-plist request))

;; Проверка авторизационных данных
(defun check-auth-data (auth-data)
  (let ((result (find-user :email (getf auth-data :email) :password (getf auth-data :password))))
    (if (null result)
        nil
        (id (car result)))))
(in-package #:moto)

;; Событие успешного входа
(defun login-user-success (id)
  (let ((u (get-user id)))
    (when (equal ":LOGGED" (state u))
      (upd-user u (list :state ":UNLOGGED")))
    (takt u :logged)))

;; Событие неуспешного входа
(defun login-user-fail ()
  "Wrong auth"
  )


;; Тестируем авторизацию
(defun auth-test ()
  (in-package #:moto)
  
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
