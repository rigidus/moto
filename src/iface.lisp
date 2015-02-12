;; [[file:louis.org][iface]]
;;;; 

;;;; iface.lisp

(in-package #:moto)

;; Компилируем шаблоны
(closure-template:compile-template
 :common-lisp-backend (pathname (concatenate 'string *base-path* "templates.htm")))

;; Страницы
(in-package #:moto)

;; (print
;;  (macroexpand-1 '
;;   (with-wrapper
;;     "<h1>Главная страница</h1>"
;;     )
;;   ))

(restas:define-route main ("/")
  (with-wrapper
      "<h1>Главная страница</h1>"
    ))
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
  (let* ((breadcrumb (breadcrumb "Группы" ("/" . "Главная")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("Группы")
          "Группы пользователей определяют набор операций, которые
пользователь может выполнять над объектами системы. В отличие от
ролей, один пользователь может входить в несколько групп или не
входить ни в одну из них."))
      (content-box ()
        (let ((elts (mapcar #'(lambda (x)
                                (list-element x))
                            (all-group))))
          (ps-html
           ((:div :class "article-list-container article-list-container--list")
            ((:ul :class "article-list article-list--list")
             (format nil "~{~A~}" elts)
             )))))
      ;;        (if (equal 1 *current-user*)
      ;;            (ps-html
      ;;             ((:h2) "Зарегистрировать новую группу")
      ;;             ((:form :method "POST")
      ;;              ((:table :border 0)
      ;;               ((:tr)
      ;;                ((:td) "Имя шруппы: ")
      ;;                ((:td) ((:input :type "text" :name "name" :value ""))))
      ;;               ((:tr)
      ;;                ((:td) "")
      ;;                ((:td) %new%)))))
      ;;            "")))
      (ps-html ((:span :class "clear")))))
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

(defmethod list-element ((group group))
  (ps-html
   ((:li :class "article-item article-item--list" :style "height: inherit;;")
    ((:div :class "inner")
     ((:div :class "article-item__info" :style "width: 540px; height: inherit; float: inherit;")
      ((:div :class "article-item__main-info")
       ((:a :class "article-item__title-link" :href (format nil "/group/~A" (id group)))
        ((:h3 :class "article-item__title") (name group))
        ;; ((:h4 :class "article-item__subtitle") (role-id user))
        )
       ((:p :class "article-item__description") (descr group)))
      ;; ((:a :class "button button--link" :href "#") "Сообщение"
      ;;  ((:span :class "button__icon")))
      ((:span :class "clear")))))))
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
    ;; ((:tr)
    ;;  ((:td) "password")
    ;;  ((:td) (password u)))
    ;; ((:tr)
    ;;  ((:td) "email")
    ;;  ((:td) (email u)))
    ;; ((:tr)
    ;;  ((:td) "ts-create")
    ;;  ((:td) (ts-create u)))
    ;; ((:tr)
    ;;  ((:td) "ts-last")
    ;;  ((:td) (ts-last u)))
    ;; ((:tr)
    ;;  ((:td) "role-id")
    ;;  ((:td) (role-id u)))
    )))

(in-package #:moto)

(defun change-role-html (u change-role-btn)
  (ps-html
   ((:form :method "POST")
    ((:table :border 0)
     ((:tr)
      ((:td) "Текущая роль:")
      ((:td) ((:select :name "role" :class "form-element")
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
      ((:td :valign "top") ((:select :name "groups" :multiple "multiple" :size "7" :class "form-element" :style "height: 100px")
                            (format nil "~{~A~}"
                                    (with-collection (i (sort (all-group) #'(lambda (a b) (< (id a) (id b)))))
                                      (if (find (id i) (mapcar #'group-id (find-user2group :user-id (id u))))
                                          (ps-html
                                           ((:option :value (id i) :selected "selected") (name i)))
                                          (ps-html
                                           ((:option :value (id i)) (name i))))))))
      ((:td :valign "top") change-group-btn))))))



(define-page user "/user/:userid"
  (let* ((breadcrumb (breadcrumb "Профиль пользователя" ("/" . "Главная")))
         (id (handler-case (parse-integer userid)
               (SB-INT:SIMPLE-PARSE-ERROR () 0))))
      (if (null (get-user id))
          (base-page (:breadcrumb breadcrumb)
            (content-box ()
              (system-msg ("caution")
                (ps-html ((:p) "Нет такого пользователя")))))
          ;; else
          (let* ((user (get-user id))
                 (left-name (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*))))
                 (user-ava-html (get-avatar-img id :middle)))
            (standard-page (:breadcrumb breadcrumb :user left-name :menu (menu) :overlay (reg-overlay))
              (content-box ()
                (heading ((format nil "Страница пользователя ~A" (name user)))))
              (content-box ()
                ((:table)
                 ((:tr)
                  ((:td) user-ava-html)
                  ((:td) (user-data-html user)))))
              (content-box ()
                (change-role-html user %change-role%))
              (content-box ()
                (change-group-html user %change-group%))
              (ps-html ((:span :class "clear")))))))
  (:change-role (if (equal 1 *current-user*)
                    (submit "Изменить" :name "act" :value "CHANGE-ROLE")
                    "")
                (if (equal 1 *current-user*)
                    (let* ((i (parse-integer userid))
                           (u (get-user i)))
                      (aif (getf p :role)
                           (role-id (upd-user u (list :role-id (parse-integer it))))
                           "role changed"))
                    "access-denied"))
  (:change-group (if (equal 1 *current-user*)
                     (submit "Изменить" :name "act" :value "CHANGE-GROUP")
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

(defun reg-teasers ()
  (format nil "~{~A~}"
          (list
           (teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
             "Адрес электронной почты, телефон и другие данные не показываются на сайте - мы используем их только для восстановления доступа к аккаунту.")
           (teaser (:class "text-container" :header ((:img :src "/img/tipp.png" :alt "Tip")))
             "Пароль к аккаунту хранится в зашифрованной форме - даже оператор сайта не может прочитать его")
           (teaser (:class "text-container" :header ((:img :src "/img/tipp.png" :alt "Tip")))
             "Все данные шифруются с использованием <a href=\"#dataprivacy-overlay\" class=\"js__openOverlay\">SSL</a>.")
           (teaser (:class "text-container" :header ((:img :src "/img/tipp.png" :alt "Tip")))
             "Безопасный пароль должен состоять не менее чем из 8 символов и включать в себя цифры или другие специальные символы"))))

(defun reg-overlay ()
  (overlay (((:h3 :class "overlay__title") "Information on SSL") :container-class "dataprivacy-overlay" :zzz "zzz")
    ((:h4) "How are my order details protected from prying eyes and manipulation by third parties during transmission?")
    ((:p) "Your order data are transmitted to us using 128-bit SSL (Secure Socket Layer) encryption.")))

(defun js-reg ()
  (ps-html
   ((:script :type "text/javascript")
    (ps
      (defun get-val (selector)
        ((@ ($ (concatenate 'string "#" selector)) val)))
      (defun empty (string)
        (if (equal "" string) t false))
      (defun contains (string pattern)
        (if (+ 1 ((@ string index-of) pattern)) t false))
      (defun add_explanation (selector content)
        ((@ ((@ ($ (concatenate 'string "#" selector)) parent)) append)
         (lambda (index value)
           (concatenate 'string "<p class='validation-explanation validation-explanation--static'>" content "</p>"))))
      (defun reg-js-valid ()
        ((@ ($ ".validation-explanation") remove))
        (let ((err-cnt 0))
          (when (not (contains (get-val "regemail")  "@"))
            (add_explanation "regemail" "Пожалуйста, введите корректный емайл")
            (incf err-cnt))
          (when (empty (get-val "regpassword"))
            (add_explanation "regpassword" "Пожалуйста, введите непустой пароль")
            (incf err-cnt))
          (when (not (equal (get-val "regpassword") (get-val "regpasswordconfirm")))
            (add_explanation "regpasswordconfirm" "Пожалуйста, введите подтверждение пароля совпадающее с паролем")
            (incf err-cnt))
          (when (empty (get-val "regnickname"))
            (add_explanation "regnickname" "Никнейм не может быть пустым")
            (incf err-cnt))
          (if (equal err-cnt 0)
            t
            false)))
      ))))

(define-page reg "/reg"
  (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("Зарегистрируйтесь как пользователь") "После регистрации вы сможете общаться с другими пользователями, искать товары и делать заказы, создавать и отслеживать свои задачи."))
      (content-box (:class "size-3-5 switch-content-container")
        ;; (if *current-user* (format nil "Кол-во недоставленных сообщений: ~A" (get-undelivered-msg-cnt *current-user*)) "")
        (js-reg)
        (form ("regform" "Регистрационные данные" :action "/reg" :class "form-section-container")
          ((:div :class "form-section")
           (fieldset "Обязательные поля"
             (input ("regemail" "Электронная почта" :required t :type "email" :maxlength "50" :value (aif (get-parameter "regemail") it "")))
             (input ("regpassword" "Пароль" :required t :type "password" :autocomplete "off"))
             (input ("regpasswordconfirm" "Повторите пароль" :required t :type "password" :autocomplete "off"))
             (input ("regnickname" "Никнейм" :required t :maxlength "50":value (aif (get-parameter "regnickname") it "")))))
          ((:div :class "form-section")
           (fieldset "Необязательные поля"
             (input ("firstname" "Имя" :maxlength "25" :value (aif (get-parameter "firstname") it "")))
             (input ("lastname" "Фамилия" :maxlength "25" :value (aif (get-parameter "lastname") it "")))
             (input ("phone" "Телефон" :maxlength "15" :container-class "input-container--1-2 odd" :value (aif (get-parameter "phone") it "")))
             (input ("mobilephone" "Мобильный телефон" :maxlength "15" :container-class "input-container--1-2 even" :value (aif (get-parameter "mobilephone") it "")))
             (ps-html ((:span :class "clear")))
             (if (equal "female" (get-parameter "sex"))
                 (select ("sex" "Пол" :default "female")
                   (("male" . "Мужской")
                    ("female" . "Женский")))
                 (select ("sex" "Пол" :default "male")
                   (("male" . "Мужской")
                    ("female" . "Женский"))))
             (ps-html
              ((:div :class "date-container")
               ((:label :for "date-of-birth") "День рождения")
               ((:div :class "date-container__inputs fieldset-validation")
                (input ("birth-day" "" :maxlength "2" :container-class "hide-label input-container--1st" :value (aif (get-parameter "birth-day") it "")))
                (input ("birth-month" "" :maxlength "2" :container-class "hide-label input-container--2nd input-container--middle"
                                      :value (aif (get-parameter "birth-month") it "")))
                (input ("birth-year" "" :maxlength "4" :container-class "hide-label input-container input-container--3rd"
                                     :value (aif (get-parameter "birth-year") it ""))))))))
          %REGISTER%))
      (content-box (:class "size-1-5") (reg-teasers))
      (ps-html ((:span :class "clear")))))
  (:register (ps-html
              ((:input :type "hidden" :name "act" :value "REGISTER"))
              ((:div :class "form-send-container")
               (submit "Зарегистрироваться" :onclick (ps (return (reg-js-valid))))))
             (macrolet ((get-val (selector)
                          `(getf p ,(intern (string-upcase selector) :keyword))))
               (defun reg-ctrl-valid (p)
                 (let ((errors))
                 (when (not (contains (get-val "regemail")  "@"))
                   (push "Пожалуйста, введите корректный емайл" errors))
                 (when (empty (get-val "regpassword"))
                   (push "Пожалуйста, введите непустой пароль" errors))
                 (when (not (equal (get-val "regpassword") (get-val "regpasswordconfirm")))
                   (push "Пожалуйста, введите подтверждение пароля совпадающее с паролем" errors))
                 (when (empty (get-val "regnickname"))
                   (push "Никнейм не может быть пустым" errors))
                   errors))
               (aif (reg-ctrl-valid p)
                    ;; Возвращены ошибки
                    (dbg "~A" (bprint it))
                    ;; Ошибок нет, создаем пользователя
                    (handler-case
                        (let* ((user-id (create-user (getf p :regnickname) (getf p :regpassword) (getf p :regemail)))
                               (user (get-user user-id)))
                          ;; (dbg "~A :|<BR/>|: ~A" (bprint p) user-id)
                          ;; И сохраняем его id в сесии и thread-local переменной *current-user*
                          (setf (hunchentoot:session-value 'current-user) user-id)
                          (setf *current-user* user-id)
                          ;; Заполняем поля пользователя
                          (upd-user user (list :firstname   (getf p :firstname)     :lastname    (getf p :lastname)       :phone       (getf p :phone)
                                               :mobilephone (getf p :mobilephone)   :sex         (getf p :sex)            :birth-day   (getf p :birth-day)
                                               :birth-month (getf p :birth-month)   :birth-year  (getf p :birth-year)))
                          ;; Выводим страничку о успешной регистрации
                          (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
                                (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
                            (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                              (content-box ()
                                (heading ("Успешная регистрация")))
                              (content-box ()
                                (system-msg ("success")
                                  (let ((tmp (format nil "Подтверждение регистрации будет выслано на <b>~A</b> в течение пары дней. ~A"
                                                     (getf p :regemail)
                                                     "Вы можете использовать свой email и пароль для входа в профиль в любое время")))
                                    (ps-html ((:p) "Ваши регистрационные данные успешно сохранены")
                                             ((:p) tmp)))))
                              (ps-html ((:span :class "clear"))))))
                      (CL-POSTGRES-ERROR:UNIQUE-VIOLATION (e)
                        ;; Выводим страничку о НЕуспешной регистрации
                        (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
                              (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
                          (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                            (content-box ()
                              (heading ("Успешная регистрация")))
                            (content-box ()
                              (system-msg ("caution")
                                (let ((tmp (format nil "К сожалению, кто-то уже занял никнейм <b>~A</b>. Но вы можете выбрать другой!" (getf p :regnickname))))
                                  (ps-html ((:p) tmp)
                                           ((:p) "Не беспокойтесь, вам не придется заполнять форму снова. Просто поменяйте никнейм и вновь введите пароль!")
                                           (submit "Попробовать снова"
                                                   :onclick (progn
                                                              (remf p :csrf-regform)
                                                              (remf p :act)
                                                              (format nil "window.location.href='/reg?~A'; return false;"
                                                                      (format nil "~{~A~^&~}"
                                                                              (loop :for key :in p :by #'cddr :collect
                                                                                 (format nil "~A=~A" (string-downcase key) (getf p key))))))
                                                   )))))
                            (ps-html ((:span :class "clear"))))))
                            )))))
(in-package #:moto)

(flet ((form-section (default-email btn)
         (content-box (:class "size-3-5 switch-content-container")
           (form ("loginform" "Вход" :action "/login" :class "form-section-container")
             ((:div :class "form-section")
              (fieldset "Обязательные поля"
                (input ("email" "Электронная почта" :required t :type "email" :maxlength "50" :value default-email))
                (input ("password" "Пароль" :required t :type "password" :autocomplete "off"))))
             btn))))
  (define-page login "/login"
    (let ((breadcrumb (breadcrumb "Логин"))
          (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ("Страница входа на сайт") "Вы не зашли на сайт. После входа вы сможете общаться с другими пользователями, искать товары и делать заказы, создавать и отслеживать свои задачи."))
        (form-section (aif (post-parameter "email") it "") %LOGIN%)
        (ps-html ((:span :class "clear")))))
    (:LOGIN (ps-html
             ((:input :type "hidden" :name "act" :value "LOGIN"))
             ((:div :class "form-send-container")
              (submit "Войти" )))
            (let ((u (car (find-user :email (getf p :email) :password (getf p :password)))))
              (if u
                  (progn
                    (setf (hunchentoot:session-value 'current-user) (id u))
                    (setf *current-user* (id u))
                    (login-user-success (id u))
                    (let ((breadcrumb (breadcrumb "Логин"))
                          (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
                      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                        (content-box ()
                          (heading ("Успешно")))
                        (content-box ()
                          (system-msg ("success")
                            (ps-html ((:p) "Вы зашли на сайт. Теперь вы можете использовать все его возможности"))))
                        (ps-html ((:span :class "clear"))))))
                  ;; user not found
                  (progn
                    (login-user-fail)
                    (let ((breadcrumb (breadcrumb "Логин"))
                          (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
                      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                        (content-box ()
                          (heading ("Неудачный логин")))
                        (content-box ()
                          (system-msg ("caution")
                            (ps-html ((:p) "К сожалению, мы не смогли вас опознать. Попробуйте снова!"))))
                        (form-section (aif (post-parameter "email") it "") %LOGIN%)
                        (ps-html ((:span :class "clear")))))))))))
(in-package #:moto)

(define-page logout "/logout"
  (let ((breadcrumb (breadcrumb "Логаут"))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (if *current-user*
          (concatenate 'string
                       (content-box ()
                         (heading ("Страница выхода из системы") "В целях безопасности вы можете выйти из своего аккаунта"))
                       (content-box (:class "size-3-5 switch-content-container")
                         (form ("logoutform" nil :class "form-section-container")
                           ((:div :class "form-section")
                            ((:p :class "font-size: big") "Вы действительно хотите выйти?"))
                           %LOGOUT%)))
          ;; else - not logged
          (concatenate 'string
                       (content-box ()
                         (heading ("Страница выхода из системы")))
                       (content-box ()
                         (system-msg ("caution")
                           (ps-html
                            ((:p :style "font-size: large") "В данный момент вы не залогины на сайте"))
                           ((:a :class "button button--link" :href "/login") "Перейти к логину"
                            ((:span :class "button__icon")))
                           ((:br))
                           ((:br))
                           (ps-html
                            ((:div :class "box")
                             ((:div :class "box--title") "У вас нет аккаунта?")
                             ((:p) "Зарегистрируйтесь и оцените преимущества!")
                             ((:a :class "button button--link button--secondary" :href "/reg") "Зарегистрироваться"
                              ((:span :class "button__icon")))))))))
      (ps-html ((:span :class "clear")))))
  (:LOGOUT (form ("logoutform" nil :action "/logout" :class "form-section-container")
             ((:input :type "hidden" :name "act" :value "LOGOUT"))
             ((:div :class "form-send-container")
              (submit "Выйти" )))
           (progn
             (when *current-user*
               (logout-user *current-user*)
               (setf (hunchentoot:session-value 'current-user) nil))
             (let ((breadcrumb (breadcrumb "Логаут"))
                   (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
               (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
                 (content-box ()
                   (heading ("Страница выхода из системы")))
                 (content-box ()
                   (system-msg ("success")
                     (ps-html
                      ((:p :style "font-size: large") "Вы успешно вышли из системы"))
                     ((:a :class "button button--link" :href "/login") "Перейти к логину"
                      ((:span :class "button__icon")))))
                 (ps-html ((:span :class "clear"))))))))
(in-package #:moto)

(define-page all-users "/users"
  (let ((breadcrumb (breadcrumb "Список пользователей"))
        (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
      (content-box ()
        (heading ("Список пользователей") ""))
      (content-box ()
        (let ((elts (mapcar #'(lambda (x)
                                (list-element x))
                            (all-user))))
          (ps-html
           ((:div :class "article-list-container article-list-container--list")
            ((:ul :class "article-list article-list--list")
             (format nil "~{~A~}" elts)
             )))))
        ;; (let ((collection (format nil "~{~A~}"
        ;;                           (with-collection (i (sort (all-user) #'(lambda (a b) (< (id a) (id b)))))
        ;;                             (ps-html
        ;;                              ((:tr)
        ;;                               ((:td) ((:a :href (format nil "/user/~A" (id i))) (id i)))
        ;;                               ((:td) (name i))
        ;;                               ((:td) (ts-create i))
        ;;                               ((:td) (ts-last i))
        ;;                               ((:td) (role-id i))
        ;;                               ((:td) %del%
        ;;                                )))))))
        ;; (ps-html
        ;;  ((:table :border 0)
        ;;   (:th "id")
        ;;   (:th "name")
        ;;   (:th "ts-create")
        ;;   (:th "ts-last")
        ;;   (:th "role-id")
        ;;   (:th "")
        ;;   collection))))
      ;; (content-box ()
      ;;   (let ((zzz (format nil "~A" (list-element (get-user 1)))))
      ;;     (ps-html
      ;;      ((:div :class "article-list-container article-list-container--list")
      ;;       ((:ul :class "article-list article-list--list")
      ;;        zzz)))))
      (ps-html ((:span :class "clear")))))
  (:DEL (if (and (equal 1 *current-user*)
                 (not (equal 1 (id i))))
            (ps-html
             ((:form :method "POST")
              ((:input :type "hidden" :name "act" :value "DEL"))
              ((:input :type "hidden" :name "data" :value (id i)))
              ((:div :class "form-send-container")
               (submit "Удалить" ))))
            "")
        (progn
          (del-user (getf p :data))
          (redirect "/users")))
  (:new (ps-html
         ((:input :type "hidden" :name "act" :value "NEW"))
         ((:div :class "form-send-container")
          (submit "Создать" )))
        (progn
          (make-user :name (getf p :name)
                     :email (getf p :email)
                     :password (getf p :password)
                     :ts-create (get-universal-time)
                     :ts-last (get-universal-time))
          (redirect "/users"))))
(in-package #:moto)

(defmethod list-element ((user user))
  (ps-html
   ((:li :class "article-item article-item--list")
    ((:div :class "inner")
     ((:a :class "article-item__image" :href "#")
      (get-avatar-img (id user) :middle))
     ((:div :class "article-item__info" :style "width: 540px;")
      ;; ((:img :class "article-item__manufacturer" :src "43.gif"))
      ((:div :class "article-item__main-info")
       ((:a :class "article-item__title-link" :href (format nil "/user/~A" (id user)))
        ((:h3 :class "article-item__title") (name user))
        ((:h4 :class "article-item__subtitle") (role-id user))
        )
       ((:p :class "article-item__description")
        (format nil "~{~A~^, ~}"
                (mapcar #'(lambda (x)
                            (ps-html
                             ((:a :href (format nil "/group/~A" (id x)))
                              (name (get-group (group-id x))))))
                        (find-user2group :user-id (id user))))))
      ;; ((:div :class "price")
      ;;  ((:p :class "price__current")
      ;;   ((:span :class "price__number")
      ;;    ((:span :class "currency") "€")
      ;;    "&nbsp;12"
      ;;    ((:span :class "cent") "99"))))
      ((:a :class "button button--link" :href "#") "Сообщение"
       ((:span :class "button__icon")))
      ((:span :class "clear")))))))
;; iface ends here
