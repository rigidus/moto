
;;;; events.lisp

(in-package #:moto)

;; Создание пользователя
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (let ((user-id (id (make-user :name name :password password :email email))))
    (dbg "Создан пользователь: ~A" user-id)
    ;; Делаем его залогиненным
    (upd-user (get-user user-id) (list :state ":logged"))
    ;; Возвращаем user-id
    user-id))

;; Логин пользователя
(in-package #:moto)

(defun login-user (id)
  (takt (get-user id) :logged))

;; Логаут пользователя
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged))
