
;;;; iface.lisp

(in-package #:moto)

;; Враппер веб-интерфейса
(in-package #:moto)

(defmacro with-wrapper (&body body)
  `(progn
     (hunchentoot:start-session)
     (let* ((*current-user* (hunchentoot:session-value 'current-user))
            (retval)
            (output (with-output-to-string (*standard-output*)
                      (setf retval ,@body))))
       (declare (special *current-user*))
       (tpl:root
        (list
         :title "title"
         :content (format nil "~{~A~}"
                          (list
                           (tpl:dbgblock  (list :dbgout output))
                           (tpl:userblock (list :currentuser
                                                (if (null *current-user*)
                                                    "none"
                                                    *current-user*)))
                           (tpl:retvalblock (list :retval retval)))))))))

;; Хелпер форм
(in-package #:moto)

(defun input (type &key name value)
  (format nil "~%<input type=\"~A\"~A~A/>" type
          (if name  (format nil " name=\"~A\"" name) "")
          (if value (format nil " value=\"~A\"" value) "")))

;; (input "text" :name "zzz" :value 111)
;; (input "submit" :name "submit-btn" :value "send")

(defun fld (name &optional (value ""))
  (input "text" :name name :value value))

(defun btn (name &optional (value ""))
  (input "button" :name name :value value))

(defun hid (name &optional (value ""))
  (input "hidden" :name name :value value))

(defun submit (&optional value)
  (if value
      (input "submit" :value value)
      (input "submit")))

(defmacro row (title &body body)
  `(format nil "~%<tr>~%<td>~A</td>~%<td>~A~%</td>~%</tr>"
           ,title
           ,@body))

;; (row "thetitrle" (submit))

(defun td (dat)
  (format nil "~%<td>~%~A~%</td>" dat))

(defun tr (&rest dat)
  (format nil "~%<tr>~%~{~A~}~%</tr>"
          dat))

;; (tr "wfewf")
;; (tr "wfewf" 1111)

(defun frm (contents &key name (method "POST"))
  (format nil "~%<form method=\"~A\"~A>~{~A~}~%</form>"
          method
          (if name (format nil " name=\"~A\"" name) "")
          (if (consp contents)
              contents
              (list contents))))

;; (frm "form-content" :name "nnnnn")

(defun tbl (contents &key name border)
  (format nil "~%<table~A~A>~{~A~}~%</table>"
          (if name (format nil " name=\"~A\"" name) "")
          (if border (format nil " border=\"~A\"" border) "")
          (if (consp contents)
              contents
              (list contents))))

;; (tbl (list "zzz") :name "table")

;; (frm (tbl (list (row "username" (fld "user")))))

;; Главная страница
(in-package #:moto)

(restas:define-route main ("/")
  (with-wrapper
    "main"))

;; Страница регистрации
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

;; Страница авторизации
(in-package #:moto)

(restas:define-route auth ("/auth")
  (with-wrapper
    (concatenate
     'string
     "<h1>Страница авторизации</h1>"
     (if *current-user*
         "Авторизация невозможна - пользователь залогинен. <a href=\"/logout\">Logout</a>"
         (frm (tbl
               (list
                (row "Имя пользователя" (fld "name"))
                (row "Пароль" (fld "password"))
                (row "" (submit "Войти")))))))))

(restas:define-route auth-ctrl ("/auth" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*)))
           (result (find-user :name (getf p :name) :password (getf p :password))))
      (if (null result)
          "RESULT: Wrong!!"
          (prog1
              (login-user (id (car result)))
            (setf (hunchentoot:session-value 'current-user)
                  (id (car result))))))))

;; Страница логаута
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


;; Список пользователей
(in-package #:moto)

(restas:define-route allusers ("/users")
  (with-wrapper
    (tbl
     (loop :for i :in (all-user) :collect
        (tr
         (td (format nil "<a href=\"/user/~A\">~A</a>" (id i) (id i)))
         (td (name i))
         (td (password i))
         (td (email i))))
     :border 1)))

(restas:define-route allusers-ctrl ("/users" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      "TODO")))

;; Страничка пользователя
(in-package #:moto)

(restas:define-route user ("/user/:userid")
  (with-wrapper
    (let* ((i (parse-integer userid))
           (u (get-user i)))
      (if (null u)
          "Нет такого пользователя"
          (format nil "~{~A~}"
                  (list
                   (format nil "<h1>Страница пользователя ~A</h1>" (id u))
                   (format nil "<h2>Данные пользователя ~A</h2>" (name u))
                   (tbl (list
                         (row "Имя пользователя" (name u))
                         (row "Пароль" (password u))
                         (row "Email" (email u)))
                        :border 1)
                   "<h2>Аккаунты пользователя</h2>"
                   (format nil "~{~A~}"
                           (loop :for a :in (find-account :user-id (id u)) :collect
                              (show-account i a)))))))))

(defun show-account (i a)
  (format nil "<div style=\"background-color: #CCCCCC; padding: 2px 20px 2px 20px;\">~{~A~}</div><br />"
          (list
           (format nil "<h3>Аккаунт ~A</h3>" (id a))
           (addsum a)
           (follow i a)
           (neworder a)
           ;; ORDERS
           (format nil "<h4>Ордера аккаунта ~A</h4>" (id a))
           (let ((orders (find-order :account_id (id a))))
             (if (null orders)
                 (format nil "нет ордеров~%")
                 (format nil "~{~A ~}"
                         (loop :for o :in orders :collect
                            (tbl
                             (list
                              (tr
                               (td (format nil "<a href=\"/order/~A\">id: ~A</a>" (id o) (id o)))
                               (td (format nil "price_open: ~A</a>" (price_open o)))
                               (td (format nil "state: ~A</a>" (state o)))
                               (td (format nil "stop_loss: ~A</a>" (stop_loss o)))
                               (td (format nil "take_profit: ~A</a>" (take_profit o)))
                               (td (format nil "currency: ~A</a>" (currency o)))))
                             :border 1))))))))

(defun addsum (a)
  (frm
   (list
    (tbl
     (list
      (row "id" (id a))
      (row "type"(account_type a))
      (row "sum" (sum a))
      (row (fld "add") (submit "Добавить денег на аккаунт" )))
     :border 1)
    (hid "account_id" (id a))
    (hid "addsum"))))

(defun follow (i a)
  (frm
   (list
    (if (null *current-user*)
        (tpl:followblock (list :following "Нет залогиненного пользователя, поэтому фолловинг невозможен"))
        (if (equal *current-user* i)
            (tpl:followblock (list :following "Нельзя зафолловить самого себя"))
            (tpl:followblock (list :following "Надо выбрать аккаунт"))
            ))

            ;; "wefwef")))))
            ;; (format nil "OPEN-ORDERS-QUEUE-FOR-ACCOUNT-~A - ~A" 1 2))))))1
            ;; (if ;; (find-in-queue (format nil "OPEN-ORDERS-QUEUE-FOR-ACCOUNT-~A" (id a) (id i)))
            ;;  nil
            ;;     "Фолловинг: этот пользователь уже зафолловен. Расфолловить?"
            ;;     (tbl
            ;;      (list
            ;;       (row "В данный момент не зафоловлен текущим пользователем" (submit "Зафолловить" )))
            ;;      :border 1))))
    (hid "account_id" (id a))
    (hid "follow"))))

(defun neworder (a)
  (format nil "<div style=\"background-color: #FFFFFF; padding: 2px 20px 2px 20px;\">~%Создать новый ордер на аккаунте ~A:~A</div>"
          (id a)
          (frm
           (list
            (hid "neworder")
            (hid "account_id" (id a))
            (tbl
             (list
              (row "symbol_id" (fld "symbol_id" "EURUSD"))
              (row "order_type" (fld "order_type" 1))
              (row "risk-level" (fld "risk_level"))
              (row "leverage" (fld "leverage"))
              (row "lots" (fld "lots"))
              (row "sum" (fld "sum"))
              (row "stop_loss"  (fld "stop_loss"))
              (row "take_profit" (fld "take_profit"))
              (row "" (submit "Создать ордер"))))))))

(restas:define-route user-ctrl ("/user/:userid" :method :post)
  (with-wrapper
    (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
      (cond ((getf p :addsum)   (add-balance (parse-integer (getf p :account_id)) (parse-integer (getf p :add))))
            ((getf p :follow)   (dbg "~A" (bprint p)))
            ((getf p :neworder) (progn
                                  (create-order
                                   (parse-integer (getf p :account_id))
                                   (let ((s (find-symb :symb "EURUSD")))
                                     (if (null s)
                                         (err "unknown symb")
                                         (id (car s))))
                                   t ;; order-type
                                   t  ;; risk-level
                                   (parse-integer (getf p :leverage))
                                   (parse-integer (getf p :lots))
                                   (parse-integer (getf p :sum))
                                   (parse-integer (getf p :stop_loss))
                                   (parse-integer (getf p :take_profit))
                                   )))))))
