;; [[file:louis.org::*Interface][iface]]
;;;; 

;;;; iface.lisp

(in-package #:moto)

;; Компилируем шаблоны
(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))

(restas:define-route louis ("/louis")
  (tpl:louis (list :header (tpl:header)
                   :content (tpl:content (list :incontent "rwerewr")
                   :footer (tpl:footer)))))

;; Меню

;; Враппер веб-интерфейса

;; Хелпер форм

;; Страницы
(in-package #:moto)

(defun menu ()
  (remove-if
   #'null
   (list
    (when *current-user*
      "<a href=\"/users\">Пользователи</a>")
    (when *current-user*
      "<a href=\"/roles\">Роли</a>")
    (when *current-user*
      "<a href=\"/groups\">Группы</a>")
    (when (null *current-user*)
      "<a href=\"/reg\">Регистрация</a>")
    (when (null *current-user*)
      "<a href=\"/login\">Логин</a>")
    (when (null *current-user*)
      "Больше возможностей доступно залогиненным пользователям")
    (when *current-user*
      (format nil "<a href=\"/user/~A\">Мой профиль</a>" *current-user*))
    ;; (when *current-user*
    ;;   "<a href=\"/im\">Сообщения</a>")
    (when *current-user*
      "<a href=\"/logout\">Выход</a>")
    ;; (when *current-user*
    ;;   "<a href=\"/load\">Загрузка данных</a>")
    ;; "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    ;; "<a href=\"/cmpxs\">Жилые комплексы</a>"
    ;; "<a href=\"/find\">Простой поиск</a>"
    )))
(in-package #:moto)

;; (print
;;  (macroexpand-1 '
;;   (with-wrapper
;;     "<h1>Главная страница</h1>"
;;     )
;;   ))

(restas:define-route main ("/")
  (with-wrapper
      "<h1>Главная страница</h1>
      <form action=\"/en/login\" method=\"post\" novalidate=\"\" class=\"js__formValidation\">
      <fieldset>
      <legend>
      Log in:</legend>
      <div class=\"input-container hide-label\">
      <label for=\"login-email\">
      Email address</label>
      <div class=\"input-bg\">
      <input name=\"login-email\" id=\"login-email\" class=\"form-element input-text required\" maxlength=\"50\" required=\"required\" value=\"\" type=\"email\">
      <p class=\"validation-explanation validation-explanation--static hidden\">
      Please enter a valid email address.</p>
      </div>
      </div>
      <div class=\"input-container hide-label\">
      <label for=\"login-password\">
      Password</label>
      <div class=\"input-bg\">
      <input name=\"login-password\" id=\"login-password\" class=\"form-element input-text required\" required=\"required\" autocomplete=\"off\" value=\"\" type=\"password\">
      </div>
      </div>
      <button name=\"login-submit\" type=\"submit\" class=\"button\" value=\"Anmelden\">
      Log in</button>
      <p class=\"forgot-pw\">
      Have you forgotten your <a href=\"/en/mylouis/passwort-vergessen\">
      password</a>
      ?</p>
      <input name=\"csrf_login\" id=\"csrf_login\" value=\"94fd26d9fea3f78f0e5908f78e7bb3d4-387a05de406a0986078b9c5f500ae549\" type=\"hidden\">
      <input name=\"return-url\" id=\"return-url\" value=\"098e60cbd72a9211eddba994512c4f11\" type=\"hidden\">
      </fieldset>
      </form>"
    ))

(in-package #:moto)

(define-page all-users "/users"
  (ps-html
   ((:h1) "Пользователи")
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список пользователей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "password")
         (:th "email")
         (:th "ts-create")
         (:th "ts-last")
         (:th "role-id")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) ((:a :href (format nil "/user/~A" (id i))) (id i)))
                     ((:td) (name i))
                     ((:td) (if (equal 1 *current-user*) (password i) ""))
                     ((:td) (email i))
                     ((:td) (ts-create i))
                     ((:td) (ts-last i))
                     ((:td) (role-id i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать нового пользователя")
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
                ((:td) %new%)))))
            ""))))
  (:del (if (and (equal 1 *current-user*)
                 (not (equal 1 (id i))))
              (ps-html
               ((:form :method "POST")
                ((:input :type "hidden" :name "act" :value "DEL"))
                ((:input :type "hidden" :name "data" :value (id i)))
                ((:input :type "submit" :value "Удалить"))))
              "")
        (del-user (getf p :data)))
  (:new (ps-html
         ((:input :type "hidden" :name "act" :value "NEW"))
         ((:input :type "submit" :value "Создать")))
        (progn
          (make-user :name (getf p :name)
                     :email (getf p :email)
                     :password (getf p :password)
                     :ts-create (get-universal-time)
                     :ts-last (get-universal-time))
          "Пользователь создан")))
(in-package #:moto)

(define-page all-roles "/roles"
  (ps-html
   ((:h1) "Роли")
   "Роли определяют набор сценариев, которые пользователь выполняет на
сайте. Функционал, который выполняют сценарии запрашивает
разрешение на выполнение действий, которое опирается на роль,
присвоенную пользователю. Пользователь может иметь только одну роль
или не иметь ее вовсе."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список ролей"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую роль")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя роли: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-role (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-role :name (getf p :name))
              "Роль создана")
            "")))
(in-package #:moto)

(define-page all-groups "/groups"
  (ps-html
   ((:h1) "Группы")
   "Группы пользователей определяют набор операций, которые
пользователь может выполнять над объектами системы. В отличие от
ролей, один пользователь может входить в несколько групп или не
входить ни в одну из них."
   (if (null *current-user*)
       "Только авторизованный пользователи могут просматривать список групп"
       (ps-html
        ((:table :border 0)
         (:th "id")
         (:th "name")
         (:th "")
         (format nil "~{~A~}"
                 (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                   (ps-html
                    ((:tr)
                     ((:td) (id i))
                     ((:td) (name i))
                     ((:td) %del%))))))
        (if (equal 1 *current-user*)
            (ps-html
             ((:h2) "Зарегистрировать новую группу")
             ((:form :method "POST")
              ((:table :border 0)
               ((:tr)
                ((:td) "Имя шруппы: ")
                ((:td) ((:input :type "text" :name "name" :value ""))))
               ((:tr)
                ((:td) "")
                ((:td) %new%)))))
            ""))))
  (:del (if (equal 1 *current-user*)
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:input :type "submit" :value "Удалить"))))
            "")
        (if (equal 1 *current-user*)
            (del-group (getf p :data))))
  (:new (if (equal 1 *current-user*)
            (ps-html
             ((:input :type "hidden" :name "act" :value "NEW"))
             ((:input :type "submit" :value "Создать")))
            "")
        (if (equal 1 *current-user*)
            (progn
              (make-group :name (getf p :name))
              "Группа создана")
            "")))
(in-package #:moto)

(in-package #:moto)

(defun user-data-html (u)
  (ps-html
   ((:table :border 0)
    ((:tr)
     ((:td) "id")
     ((:td) (id u)))
    ((:tr)
     ((:td) "name")
     ((:td) (name u)))
    ((:tr)
     ((:td) "password")
     ((:td) (password u)))
    ((:tr)
     ((:td) "email")
     ((:td) (email u)))
    ((:tr)
     ((:td) "ts-create")
     ((:td) (ts-create u)))
    ((:tr)
     ((:td) "ts-last")
     ((:td) (ts-last u)))
    ((:tr)
     ((:td) "role-id")
     ((:td) (role-id u))))))

(in-package #:moto)

(defun change-role-html (u change-role-btn)
  (ps-html
   ((:form :method "POST")
    ((:table :border 0)
     ((:tr)
      ((:td) "Текущая роль:")
      ((:td) ((:select :name "role")
              ((:option :value "0") "Выберите роль")
              (format nil "~{~A~}"
                      (with-collection (i (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))
                        (if (equal (id i) (role-id u))
                            (ps-html
                             ((:option :value (id i) :selected "selected") (name i)))
                            (ps-html
                             ((:option :value (id i)) (name i))))))))
      ((:td) change-role-btn))))))

(in-package #:moto)

(defun change-group-html (u change-group-btn)
  (ps-html
   ((:form :method "POST")
    ((:table :border 0)
     ((:tr)
      ((:td :valign "top") "Группы пользователя:")
      ((:td :valign "top") ((:select :name "groups" :multiple "multiple" :size "7")
                            (format nil "~{~A~}"
                                    (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                                      (if (find (id i) (mapcar #'group-id (find-user2group :user-id (id u))))
                                          (ps-html
                                           ((:option :value (id i) :selected "selected") (name i)))
                                          (ps-html
                                           ((:option :value (id i)) (name i))))))))
      ((:td :valign "top") change-group-btn))))))

(in-package #:moto)

(defun user-msg-html (u)
  (ps-html
   ((:h2) "Сообщения пользователя:")
   ((:a :href (format nil "/user/~A/im/new" (id u))) "Новое сообщение")
   ((:br))
   ((:br))
   (let ((msgs (get-last-msg-dialogs-for-user-id (id u))))
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
                                    :userid (id u)
                                    )))
                            ((equal :snd (car (last item)))
                             (msgtpl:dlgsnd
                              (list :id (car item)
                                    :to (cadr item)
                                    :time (caddr item)
                                    :msg (cadddr item)
                                    :state (nth 4 item)
                                    :userid (id u)
                                    )))
                            (t (err "unknown dialog type")))))))))))

(define-page user "/user/:userid"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}" (with-element (u u)
                               (ps-html
                                ((:h1) (format nil "Страница пользователя #~A - ~A" (id u) (name u)))
                                ((:table :border 0 :cellspacing 10 :cellpadding 10)
                                 ((:tr)
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (user-data-html u))
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (change-role-html u %change-role%))
                                  ((:td :valign "top" :bgcolor "#F8F8F8") (change-group-html u %change-group%)))
                                 ((:tr)
                                  ((:td :valign "top" :bgcolor "#F8F8F8" :colspan 3) (user-msg-html u)))))))))
  (:change-role (if (equal 1 *current-user*)
                    (ps-html
                     ((:input :type "hidden" :name "act" :value "CHANGE-ROLE"))
                     ((:input :type "submit" :value "Изменить")))
                    "")
                (if (equal 1 *current-user*)
                    (let* ((i (parse-integer userid))
                           (u (get-user i)))
                      (aif (getf p :role)
                           (role-id (upd-user u (list :role-id (parse-integer it))))
                           "role changed"))
                    "access-denied"))
  (:change-group (if (equal 1 *current-user*)
                     (ps-html
                      ((:input :type "hidden" :name "act" :value "CHANGE-GROUP"))
                      ((:input :type "submit" :value "Изменить")))
                     "")
                 (if (equal 1 *current-user*)
                     (let* ((i (parse-integer userid))
                            (u (get-user i)))
                       (if (null (getf p :groups))
                           "-not change-"
                           (loop
                              :initially (mapcar #'(lambda (x) (del-user2group (id x)))
                                                 (find-user2group :user-id (parse-integer userid)))
                              :for lnk
                              :in (loop
                                     :for key  :in p    :by #'cddr
                                     :for n    :from 1  :to 10 :by (+ 2)
                                     :when    (equal key :groups)
                                     :collect (parse-integer (nth n p)))
                              :collect (id (make-user2group :user-id i :group-id lnk)))))
                     "access-denied")))
(in-package #:moto)

(define-page userim "/user/:userid/im/:imid"
  (let* ((user-id (parse-integer userid))
         (im-id (parse-integer imid))
         (u (get-user user-id))
         (j (get-user im-id)))
    (if (or (null u) (null j))
        "Нет такого пользователя"
        (let ((msgs (get-msg-dialogs-for-two-user-ids user-id im-id)))
          (if (equal 0 (length msgs))
              "Нет сообщений!"
              (ps-html
               ((:h1) (format nil "Страница диалогов пользователя #~A - ~A с пользователем #~A - ~A"
                              (id u) (name u)
                              (id j) (name j)))
               (msgtpl:dialogs
                (list
                 :content
                 (format nil "~{~A~}"
                         (loop :for item :in msgs :collect
                            (cond ((equal user-id (cadr item))
                                   (msgtpl:dlgrcv
                                    (list :id (car item)
                                          :from (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          :userid userid
                                          )))
                                  ((equal im-id (cadr item))
                                   (msgtpl:dlgsnd
                                    (list :id (car item)
                                          :to (cadr item)
                                          :time (caddr item)
                                          :msg (cadddr item)
                                          :state (nth 4 item)
                                          :userid userid
                                          )))
                                  (t (err "err 3536262346")))
                            ))))))))))
(in-package #:moto)

(defmacro label ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("color" . "#45688E")
                                                 ("line-height" . "1.27em")
                                                 ("margin" . "0px")
                                                 ("padding" . "26px 0px 9px")
                                                 ("font-size" . "1.09em")
                                                 ("font-weight" . "bold"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:div :style ,style) ,@body))
        `(ps-html ((:div :style ,style ,@rest) ,@body)))))

(defmacro textarea ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("background" . "#FFFFFF")
                                                 ("color" . "black")
                                                 ("border" . "1px solid #C0CAD5")
                                                 ("width" . "490px")
                                                 ("min-height" . "120px")
                                                 ("padding" . "5px 25px 5px 5px")
                                                 ("vertical-align" . "top")
                                                 ("margin" . "0")
                                                 ("overflow" . "auto")
                                                 ("outline" . "0")
                                                 ("line-height" . "150%")
                                                 ("word-wrap" . "break-word")
                                                 ("cursor" . "text"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:textarea :style ,style) ,@body))
        `(ps-html ((:textarea :style ,style ,@rest) ,@body)))))

(defmacro button ((&rest rest) &body body)
  (let ((style (format nil "~{~A~^;~}" (mapcar #'(lambda (x) (format nil "~A:~A" (car x) (cdr x)))
                                               '(("padding" . "6px 16px 7px 16px")
                                                 ("*padding" . "6px 17px 7px 17px")
                                                 ("margin" . "0")
                                                 ("font-size" . "11px")
                                                 ("display" . "inline-block")
                                                 ("*display" . "inline")
                                                 ("zoom" . "1")
                                                 ("cursor" . "pointer")
                                                 ("white-space" . "nowrap")
                                                 ("outline" . "none")
                                                 ("font-family" . "tahoma, arial, verdana, sans-serif, Lucida Sans")
                                                 ("vertical-align" . "top")
                                                 ("overflow" . "visible")
                                                 ("line-height" . "13px")
                                                 ("text-decoration" . "none")
                                                 ("background" . "none")
                                                 ("background-color" . "#6383a8")
                                                 ("color" . "#FFF")
                                                 ("border" . "0")
                                                 ("*border" . "0")
                                                 ("-webkit-border-radius" . "2px")
                                                 ("-khtml-border-radius" . "2px")
                                                 ("-moz-border-radius" . "2px")
                                                 ("-ms-border-radius" . "2px")
                                                 ("border-radius" . "2px")
                                                 ("-webkit-transition" . "background-color 100ms ease-in-out")
                                                 ("-khtml-transition" . "background-color 100ms ease-in-out")
                                                 ("-moz-transition" . "background-color 100ms ease-in-out")
                                                 ("-ms-transition" . "background-color 100ms ease-in-out")
                                                 ("-o-transition" . "background-color 100ms ease-in-out")
                                                 ("transition" . "background-color 100ms ease-in-out"))))))
    (when (null body)
      (setf body (list "")))
    (if (null rest)
        `(ps-html ((:button :style ,style) ,@body))
        `(ps-html ((:button :style ,style ,@rest) ,@body)))))


(define-page imnew "/user/:userid/im/new"
  (let* ((i (parse-integer userid))
         (u (get-user i)))
    (if (null u)
        "Нет такого пользователя"
        (format nil "~{~A~}"
                (with-element (u u)
                  (ps-html
                   ((:h1) (format nil "Новое сообщения от пользователя #~A - ~A" (id u) (name u)))
                   ((:form :method "POST")
                    ((:div :style "width: 600px; font-family: tahoma,arial,verdana,sans-serif,Lucida Sans; font-size: 11px; font-weight: normal; line-height: 140%;")
                     ((:div :style "background: none repeat scroll 0% 0% #597BA5; padding: 0 10px 10px 10px; position: relative; overflow: hidden;")
                      ((:div :style "padding: 17px 26px 18px; margin: -10px -10px -11px; color: #C7D7E9; transition: color 100ms linear 0s; float: right; text-decoration: none; cursor: pointer;  ") "Закрыть")
                      ((:div :style "color: #FFF; backgound-color: #D7E7F9; padding: 7px 16px; font-weight: bold; font-size: 1.09em; ") "Новое сообщение")
                      ((:div :style "padding: 26px; background: #F7F7F7;")
                       ((:div :style "display: block; margin: 0px; float: right; color: #000;")
                        ((:a :href "/im?sel=3754275" :style "color: #2B587A; text-decoration: none; cursor: pointer;") "Перейти к диалогу"))
                       ((:div :style "padding-top: 0px; color: #45688E; line-height: 1.27em; margin: 0px; padding: 26px 0px 9px; font-size: 1.09em; font-weight: bold; ") "Получатель")
                       ((:select :name "abonent")
                        ((:option :value "0") "Выберите пользователя")
                        (format nil "~{~A~}"
                                (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
                                  (if (equal (id i) (id u))
                                      ""
                                      (ps-html
                                       ((:option :value (id i)) (name i)))))))
                       ((:div :style "padding-top: 0px; color: #45688E; line-height: 1.27em; margin: 0px; padding: 26px 0px 9px; font-size: 1.09em; font-weight: bold; ") "Сообщение")
                       (textarea (:name "msg"))
                       ((:div :style "padding-top: 16px")
                        %zzz%)
                       )))))))))
  (:zzz (if (or (equal 1 *current-user*)
                (equal *current-user* (parse-integer userid)))
            (ps-html
             ((:input :type "hidden" :name "act" :value "ZZZ"))
             (button () "Отправить"))
            " [access-denied for send message]")

        (if (or (equal 1 *current-user*)
                (equal *current-user* (parse-integer userid)))
            (create-msg (parse-integer userid) (getf p :abonent) (getf p :msg))
            "access-denied")))
;; iface ends here
