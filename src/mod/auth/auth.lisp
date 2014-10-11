
(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))

;; Контроллер логина
(defun loginform-ctrl (request)
  (aif (check-auth-data (get-auth-data request))
       (progn
         (setf (session-value current-user) it)
         (auth-success))
       (auth-fail)))

;; Контроллер логаута
(defun logout-ctrl (request)
  (delete-session-value current-user)
  (logout))

;; Функция проверки авторизационных данных


;; Обобщенный метод извлечения авторизационных данных


;; Функция проверки, залогинен ли пользователь
;; (defun is-logged (request)
;;   ( (session-value current-user

;; Хук успешной авторизации


;; Хук неуспешной авторизации
