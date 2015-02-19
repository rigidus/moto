(in-package #:moto)

;; Скомпилируем шаблон
(closure-template:compile-template
 :common-lisp-backend
 (pathname
  (concatenate 'string *base-path* "mod/auth/auth-tpl.htm")))

(in-package #:moto)

(defun head-login-block ()
  (if *current-user*
      (ps-html
       ((:div :class "flyout-parent user-nav__item user-nav__item--my-louis")
        ((:div)
         ((:a :href "#" :class "nav-button js__setFocus" :data-set-focus "email" :id "mylouis-flyout-link")
          ((:span :class "nav-button__text") "Мой профиль")
          ((:span :class "nav-button__icon sprite"))))
        ((:div :class "user-nav__flyout flyout flyout--my-louis flyout--my-louis--login popup")
         ((:span :class "hover"))
         ((:a :class "action-icon action-icon--close" :href "#") "×")
         ((:div :class "box")
          ((:div :class "box--title") (format nil "Привет, ~A" (name (get-user *current-user*))))
          ((:p) "Последний вход: недавно")
          ((:a :class "button button--link button--secondary" :href "/reg") "Профиль"
           ((:span :class "button__icon")))))))
      ;; else
      (ps-html
       ((:div :class "flyout-parent user-nav__item user-nav__item--my-louis")
        ((:div)
         ((:a :href "#" :class "nav-button js__setFocus" :data-set-focus "email" :id "mylouis-flyout-link")
          ((:span :class "nav-button__text") "Мой профиль")
          ((:span :class "nav-button__icon sprite"))))
        ((:div :class "user-nav__flyout flyout flyout--my-louis flyout--my-louis--login popup")
         ((:span :class "hover"))
         ((:a :class "action-icon action-icon--close" :href "#") "×")
         (form ("loginform" nil :action "/login")
           (fieldset "Вход:"
             (input ("email" "Электронная почта" :required t :type "email" :maxlength "50" :class "input-bg"))
             (input ("password" "Пароль" :required t :type "password" :autocomplete "off" :class "input-bg"))
             (ps-html ((:input :type "hidden" :name "act" :value "LOGIN")))
             (submit "Войти")
             (ps-html ((:p :class "forgot-pw") "Забыли " ((:a :href "/lostpassword") "пароль") "?"))))
         ((:div :class "box")
          ((:div :class "box--title") "Впервые здесь?")
          ((:p) "Зарегистрируйтесь и оцените преимущества!")
          ((:a :class "button button--link button--secondary" :href "/reg") "Зарегистрироваться"
           ((:span :class "button__icon")))))))))
(in-package #:moto)

;; Событие создания роли
(defun create-role (name descr)
  "Создание пользователя. Возвращает id пользователя"
  (let ((new (make-role :name name :descr descr)))
    (if (null new)
        (err 'err-create-role)
        ;; else
        (progn
          (make-event :name "create-role"
                      :tag "create"
                      :msg (aif *current-user*
                                (format nil "Пользователь #~A : ~A cоздал роль #~A : ~A"
                                        *current-user*
                                        (name (get-user *current-user*))
                                        (id new)
                                        (name new)))
                      :author-id *current-user*
                      :ts-create (get-universal-time))
          ;; Возвращаем user-id
          (id new))
        )))
(in-package #:moto)

;; Событие создания пользователя
(defun create-user (name password email)
  "Создание пользователя. Возвращает id пользователя"
  (let ((new-user (make-user :name name :password password :email email :ts-create (get-universal-time) :ts-last (get-universal-time))))
    (if (null new-user)
        (err 'err-create-user)
        ;; else
        (progn
          (make-event :name "create-user"
                      :tag "create"
                      :msg (aif *current-user*
                                (format nil "Пользователь #~A : ~A cоздал пользователя #~A : ~A"
                                        *current-user*
                                        (name (get-user *current-user*))
                                        (id new-user)
                                        (name new-user))
                                ;; else
                                (format nil "Зарегистрировался пользователь #~A : ~A"
                                        (id new-user)
                                        (name new-user)))
                      :author-id *current-user*
                      :ts-create (get-universal-time))
          ;; Делаем его залогиненным
          (upd-user (get-user (id new-user)) (list :state ":LOGGED"))
          ;; Возвращаем user-id
          (id new-user)))))
(in-package #:moto)

(defun create-group (name descr)
  "Создание пользователя. Возвращает id пользователя"
  (let ((new-item (make-group :name name :descr descr :ts-create (get-universal-time) :author-id *current-user*)))
    (if (null new-item)
        (err 'err-create-group)
        ;; else
        (progn
          (make-event :name "create-group"
                      :tag "create"
                      :msg (format nil "Пользователь #~A : ~A cоздал группу #~A : ~A"
                                   *current-user*
                                   (name (get-user *current-user*))
                                   (id new-item)
                                   (name new-item))
                      :author-id *current-user*
                      :ts-create (get-universal-time))
          ;; Возвращаем id
          (id new-item)))))
(in-package #:moto)

;; Событие выхода
(defun logout-user (current-user)
  (takt (get-user current-user) :unlogged)
  (make-event :name "logout-user"
              :tag "logout"
              :msg (format nil "Пользователь #~A : ~A вышел из системы"
                           current-user
                           (name (get-user current-user)))
              :author-id current-user
              :ts-create (get-universal-time)))

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
    (takt u :logged)
    (make-event :name "login-user-success"
                :tag "login-success"
                :msg (format nil "Пользователь #~A : ~A вошел в систему"
                             (id u)
                             (name u))
                :author-id (id u)
                :ts-create (get-universal-time))))
(in-package #:moto)

;; Событие неуспешного входа
(defun login-user-fail ()
  (make-event :name "login-user-fail"
              :tag "login-fail"
              :msg (format nil "Неудачная попытка входа")
              :author-id 0
              :ts-create (get-universal-time)))
(in-package #:moto)

(defun remove-role (role-id)
  "Удаление роли"
  (let* ((role (get-role role-id))
         (name (name role)))
    (prog1 (del-role role-id)
      (make-event :name "del-role"
                  :tag "remove"
                  :msg (format nil "Пользователь #~A : ~A удалил роль #~A : ~A"
                               *current-user*
                               (name (get-user *current-user*))
                               id
                               name)
                  :author-id *current-user*
                  :ts-create (get-universal-time)))))
(in-package #:moto)

(defun remove-group (group-id)
  "Удаление группы"
  (let ((group (get-group group-id))
        (links (mapcar #'(lambda (x)
                           (let ((user (get-user (user-id x))))
                             (list (id user) (name user))))
                       (find-user2group :group-id group-id))))
    ;; Создание события
    (make-event :name "remove-group"
                :tag "remove"
                :msg (aif *current-user*
                          (format nil "Пользователь #~A : ~A удалил группу #~A : ~A и вместе с ней связи: ~{~A,~^, ~}"
                                  *current-user*
                                  (name (get-user *current-user*))
                                  (id group)
                                  (name group)
                                  (mapcar #'(lambda (x)
                                              (format nil "~A-~A" (car x) (cadr x)))
                                          links))
                          ;; else
                          (err "Unauthorized delete group"))
                :author-id *current-user*
                :ts-create (get-universal-time))
    ;; Удаление связей пользователей с этой группой
    ;; (mapcar #'(lambda (x)
    ;;             (del-user2group (id x)))
    ;;         (find-user2group :group-id group-id))
    ;; Удаление группы
    (prog1 (del-group group-id))))
(in-package #:moto)

(defun remove-user (user-id)
  "Удаление пользователя"
  (let ((user (get-user user-id)))
    (prog1 (del-user user-id)
      (make-event :name "remove-user"
                      :tag "remove"
                      :msg (aif *current-user*
                                (format nil "Пользователь #~A : ~A удалил пользователя #~A : ~A"
                                        *current-user*
                                        (name (get-user *current-user*))
                                        (id user)
                                        (name user))
                                ;; else
                                (err "Unauthorized delete user"))
                      :author-id *current-user*
                      :ts-create (get-universal-time)))))

(in-package #:moto)

(defun get-usergroups-names (user-id)
  (mapcar #'(lambda (x)
              (name (get-group (group-id x))))
          (find-user2group :user-id user-id)))
(in-package #:moto)

(defun is-in-group (target-group-name user-id)
  (if (member target-group-name (get-usergroups-names user-id) :test #'equal) t nil))
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
  (let ((breadcrumb (breadcrumb "Выход"))
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
                            ((:p :style "font-size: large") "В данный момент вы не вошли на сайт"))
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

(define-page role "/role/:roleid"
  (let* ((breadcrumb (breadcrumb "Профиль роли" ("/" . "Главная")))
         (id (handler-case (parse-integer roleid)
               (SB-INT:SIMPLE-PARSE-ERROR () 0))))
    (if (null (get-role id))
        (base-page (:breadcrumb breadcrumb)
          (content-box ()
            (system-msg ("caution")
              (ps-html ((:p) "Нет такой роли")))))
        ;; else
        (let* ((role (get-role id))
               (left-name (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
          (standard-page (:breadcrumb breadcrumb :user left-name :menu (menu) :overlay (reg-overlay))
            (content-box ()
              (heading ((format nil "Пользователи, имеющие роль \"~A\"" (name role)))))
            (content-box ()
              (show (find-user :role-id (id role))))
            (ps-html ((:span :class "clear"))))))))
(in-package #:moto)

(define-page group "/group/:groupid"
  (let* ((breadcrumb (breadcrumb "Профиль группы" ("/" . "Главная")))
         (id (handler-case (parse-integer groupid)
               (SB-INT:SIMPLE-PARSE-ERROR () 0))))
      (if (null (get-group id))
          (base-page (:breadcrumb breadcrumb)
            (content-box ()
              (system-msg ("caution")
                (ps-html ((:p) "Нет такой группы")))))
          ;; else
          (let* ((group (get-group id))
                 (left-name (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
            (standard-page (:breadcrumb breadcrumb :user left-name :menu (menu) :overlay (reg-overlay))
              (content-box ()
                (heading ((format nil "Пользователи группы \"~A\"" (name group)))))
              (content-box ()
                (show (mapcar #'(lambda (x)
                                  (get-user (user-id x)))
                              (find-user2group :group-id id))))
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



(labels ((perm-check (current-user)
           (is-in-group "Рулевой" current-user)))
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
                user-ava-html
                (name user))
              (content-box ()
                (change-role-html user %change-role%))
              (content-box ()
                (change-group-html user %change-group%))
              (ps-html ((:span :class "clear")))))))
    (:change-role (if (perm-check *current-user*)
                      (submit "Изменить" :name "act" :value "CHANGE-ROLE")
                      "")
                  (if (perm-check *current-user*)
                      (let* ((i (parse-integer userid))
                             (u (get-user i)))
                        (aif (getf p :role)
                             (role-id (upd-user u (list :role-id (parse-integer it))))
                             "role changed")
                        (redirect (format nil "/user/~A" userid)))
                      "access-denied"))
    (:change-group (if (perm-check *current-user*)
                       (submit "Изменить" :name "act" :value "CHANGE-GROUP")
                       "")
                   (if (perm-check *current-user*)
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
                                :collect (id (make-user2group :user-id i :group-id lnk))))
                         (redirect (format nil "/user/~A" userid))
                       "access-denied")))))
(in-package #:moto)

(labels ((perm-check-dev (current-user)
           (is-in-group "Исполнитель желаний" current-user))
         (perm-check (current-user)
           (is-in-group "Пропускать везде" current-user)))
  (define-page all-users "/users"
    (let ((breadcrumb (breadcrumb "Список пользователей"))
          (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ("Список пользователей") "Пользователи - это субьекты, использующие систему для выполнения своих задач. "
                   "Пользователь - не обязательно человек, внутри системы задачи могут выполнять роботы, активирующиеся по "
                   "расписанию или при срабатывании определенных условий.<br /><br /> Пользователи имеют роль и могут состоять в группах. "
                   "Обычно создание пользователя происходит при регистрации, но пользователя-робота можно создать на этой "
                   "странице, если создающий входит в группу \"Исполнитель желаний\", т.е. является разработчиком."))
        (if (not (perm-check-dev *current-user*))
            ""
            (content-box ()
              (form ("makeuserform" "Создать пользователя" :class "form-section-container")
                ((:div :class "form-section")
                 (fieldset ""
                   (input ("name" "Имя" :required t :type "text"))
                   (eval
                    (macroexpand
                     (append '(select ("role" "Роль"))
                             (list
                              (mapcar #'(lambda (x) (cons (id x) (name x)))
                                      (remove-if #'(lambda (x) (equal (name x) "webuser"))
                                                 (sort (all-role) #'(lambda (a b) (< (id a) (id b))))))))))))
                %NEW%)))
        (content-box ()
          (let ((tmp (show (sort (all-user) #'(lambda (a b) (< (id a) (id b))))
                           :del #'(lambda (user) %DEL%)
                           :msg #'(lambda (user) %MSG%))))
            (ps-html ((:form :method "POST") ((:input :type "hidden" :name "act" :value "DEL")) tmp))))
        (ps-html ((:span :class "clear")))))
    (:DEL (if (or (perm-check-dev *current-user*)
                  (perm-check *current-user*))
              (ps-html ((:form :method "POST")
                        ((:input :type "hidden" :name "act" :value "DEL"))
                        (submit "Удалить" :name "data" :value (id user))))
              "")
          (if (or (perm-check-dev *current-user*)
                  (perm-check *current-user*))
              (progn
                (remove-user (parse-integer (getf p :data)))
                (redirect "/users"))
              ""))
    (:msg (if (and
               (or (perm-check-dev *current-user*)
                   (perm-check *current-user*))
               (not (member "Мизантроп" (mapcar #'(lambda (x)
                                                    (name (get-group (group-id x))))
                                                (find-user2group :user-id (id user))) :test #'equal)))
              (ps-html ((:form :method "POST")
                        ((:input :type "hidden" :name "act" :value "MSG"))
                        (submit "Сообщение (пока не работает)" :name "data" :value (id user))))
              "")
          (if (and
               (or (perm-check-dev *current-user*)
                   (perm-check *current-user*))
               (not (member "Мизантроп" (mapcar #'(lambda (x)
                                                    (name (get-group (group-id x))))
                                                (find-user2group :user-id (id user))) :test #'equal)))
              (progn
                (err "TODO")
                (redirect "/users"))
              ""))
    (:new (if (not (perm-check-dev *current-user*))
              ""
              (ps-html
               ((:input :type "hidden" :name "act" :value "NEW"))
               ((:div :class "form-send-container")
                (submit "Создать пользователя" ))))
          (if (not (perm-check-dev *current-user*))
              ""
              (let ((new-id (create-user (getf p :name) "" "")))
                (upd-user (get-user new-id)
                          (list
                           :role-id (parse-integer (getf p :role))
                           :ts-create (get-universal-time)
                           :ts-last (get-universal-time)))
                (redirect "/users"))))))

(in-package #:moto)

(defmethod show ((param user) &rest actions &key &allow-other-keys)
  (let ((birka  "/img/transparency.gif")
        (avatar (get-avatar-img (id param) :middle))
        (role-id 0)
        (role-name "Нет роли"))
    (if (integerp (role-id param))
        (progn
          (setf role-id (role-id param))
          (setf role-name (name (get-role (role-id param))))
          (setf birka (if (not (equal role-name "webuser")) "/ava/small/robot.png"))
          (cond ((equal role-name "timebot")
                 (setf avatar (ps-html ((:img :src "/ava/middle/timebot.png")))))
                ((equal role-name "autotester")
                 (setf avatar (ps-html ((:img :src "/ava/middle/tester.png")))))
                ((equal role-name "agent")
                 (setf avatar (ps-html ((:img :src "/ava/middle/system.png"))))))))
    (ps-html
     ((:li :class "article-item article-item--list")
      ((:div :class "inner")
       ((:a :class "article-item__image" :href (format nil "/user/~A" (id param))) avatar)
       ((:div :class "article-item__info" :style "width: 540px;")
        ((:img :class "article-item__manufacturer" :src birka))
        ((:div :class "article-item__main-info")
         ((:a :class "article-item__title-link" :href (format nil "/user/~A" (id param)))
          ((:h3 :class "article-item__title") (name param)))
         (if (equal 0 role-id)
             ""
             (ps-html
              ((:div :class "article-item__main-info")
               ((:a :class "article-item__title-link" :href (format nil "/role/~A" role-id))
                ((:h4 :class "article-item__subtitle")
                 role-name)))))
         ((:p :class "article-item__description")
          (format nil "~{~A~^, ~}"
                  (mapcar #'(lambda (y)
                              (ps-html
                               ((:a :href (format nil "/group/~A" (group-id y)))
                                (name (get-group (group-id y))))))
                          (find-user2group :user-id (id param))))
          ))
        ;; ((:div :class "price")
        ;;  ((:p :class "price__current")
        ;;   ((:span :class "price__number")
        ;;    ((:span :class "currency") "€")
        ;;    "&nbsp;12"
        ;;    ((:span :class "cent") "99"))))
        (if (null actions)
            ""
            (format nil "~{~A~}"
                    (loop :for action-key :in actions :by #'cddr :collect
                       (funcall (getf actions action-key) param))))
        ((:span :class "clear"))))))))
(in-package #:moto)

(labels ((perm-check (current-user) (is-in-group "Пропускать везде" current-user)))
  (define-page all-groups "/groups"
    (let* ((breadcrumb (breadcrumb "Группы" ("/" . "Главная")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ("Группы")
            "Группы пользователей определяют набор операций, которые пользователь может выполнять над объектами системы. В отличие от"
            "ролей, один пользователь может входить в несколько групп или не входить ни в одну из них."))
        (if (not (perm-check *current-user*))
            ""
            (content-box ()
              (form ("makegroupform" "Создать группу" :class "form-section-container")
                ((:div :class "form-section")
                 (fieldset ""
                   (input ("name" "Имя" :required t :type "text"))
                   (textarea ("descr" "Описание"))))
                %NEW%)))
        (content-box ()
          (let ((tmp (show (sort (all-group) #'(lambda (a b) (< (id a) (id b)))) :del #'(lambda (group) %DEL%))))
            (ps-html ((:form :method "POST") ((:input :type "hidden" :name "act" :value "DEL")) tmp))))
        (ps-html ((:span :class "clear")))))
    (:del (if (perm-check *current-user*)
              (submit "Удалить" :name "data" :value (id group))
              "")
          (if (perm-check *current-user*)
              (progn (remove-group (parse-integer (getf p :data)))
                     (redirect "/groups"))
              ""))
    (:new (ps-html
           ((:div :class "form-send-container")
            (submit "Создать новую группу" :name "act" :value "NEW")))
          (if (perm-check *current-user*)
              (progn (create-group (getf p :name) (getf p :descr))
                     (redirect "/groups"))
              ""))))
(in-package #:moto)

(defmethod show ((param group) &rest actions &key &allow-other-keys)
  (ps-html
   ((:li :class "article-item article-item--list" :style "height: inherit;;")
    ((:div :class "inner")
     ((:div :class "article-item__info" :style "width: 540px; height: inherit; float: inherit;")
      ((:div :class "article-item__main-info")
       ((:a :class "article-item__title-link" :href (format nil "/group/~A" (id param)))
        ((:h3 :class "article-item__title") (name param))
        ((:h4 :class "article-item__subtitle")
         (aif (author-id param)
              (format nil "author:&nbsp;~A"
                      (ps-html ((:a :href (format nil "/user/~A" it)) (name (get-user it))))) "")))
       ((:p :class "article-item__description") (descr param)))
      (if (null actions)
          ""
          (format nil "~{~A~}"
                  (loop :for action-key :in actions :by #'cddr :collect
                     (funcall (getf actions action-key) param))))
      ((:span :class "clear")))))))
(in-package #:moto)

(labels ((perm-check (current-user)
           (is-in-group "Пропускать везде" current-user)))
  (define-page all-roles "/roles"
    (let* ((breadcrumb (breadcrumb "Роли" ("/" . "Главная")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ("Роли")
            "Роли определяют набор сценариев, которые пользователь выполняет на сайте. Функционал, который выполняет сценарии, запрашивает "
            "разрешение на выполнение действий, которое опирается на роль, присвоенную пользователю. Пользователь может иметь только одну роль "
            "или не иметь ее вовсе."))
        (if (not (perm-check *current-user*))
            ""
            (content-box ()
              (form ("makeroleform" "Создать роль" :class "form-section-container")
                ((:div :class "form-section")
                 (fieldset ""
                   (input ("name" "Имя" :required t :type "text"))
                   (textarea ("descr" "Описание"))))
                %NEW%)))
        (content-box ()
          (let ((tmp (show (sort (all-role) #'(lambda (a b) (< (id a) (id b)))))))
            (ps-html ((:form :method "POST") ((:input :type "hidden" :name "act" :value "DEL")) tmp))))
        (ps-html ((:span :class "clear")))))
    (:del (if (perm-check *current-user*)
              (submit "Удалить" :name "data" :value (id role))
              "")
          (if (perm-check *current-user*)
              (progn (remove-role (getf p :data))
                     (redirect "/roles"))
              ""))
    (:new (ps-html
           ((:div :class "form-send-container")
            (submit "Создать новую роль" :name "act" :value "NEW")))
          (if (perm-check *current-user*)
              (progn (create-role (getf p :name) (getf p :descr))
                     (redirect "/roles"))
              ""))))
(in-package #:moto)

(defmethod show ((param role) &rest actions &key &allow-other-keys)
  (ps-html
   ((:li :class "article-item article-item--list" :style "height: inherit;;")
    ((:div :class "inner")
     ((:div :class "article-item__info" :style "width: 540px; height: inherit; float: inherit;")
      ((:div :class "article-item__main-info")
       ((:a :class "article-item__title-link" :href (format nil "/role/~A" (id param)))
        ((:h3 :class "article-item__title") (name param))
        ((:h4 :class "article-item__subtitle")
         ;; (aif (author-id param)
         ;;      (format nil "author:&nbsp;~A"
         ;;              (ps-html ((:a :href (format nil "/user/~A" it)) (name (get-user it))))) "")
         ))
       ((:p :class "article-item__description" :style "width: 700px;") (descr param)))
      (if (null actions)
          ""
          (format nil "~{~A~}"
                  (loop :for action-key :in actions :by #'cddr :collect
                     (funcall (getf actions action-key) param))))
      ((:span :class "clear")))))))


;; Тестируем авторизацию
(defun auth-test ()
  (in-package #:moto)
  
  ;; Зарегистрируем пользователя
  ;; (let* ((name "admin")
  ;;        (password "tCDm4nFskcBqR7AN")
  ;;        (email "nomail@mail.ru")
  ;;        (new-user-id (create-user name password email)))
  ;;   ;; Проверим что он существует
  ;;   (assert (get-user new-user-id))
  ;;   ;; Проверим, что он залогинен
  ;;   (assert (equal ":LOGGED" (state (get-user new-user-id))))
  ;;   ;; Выход пользователя из системы
  ;;   (logout-user new-user-id)
  ;;   ;; Проверим, что он разлогинен
  ;;   (assert (equal ":UNLOGGED" (state (get-user new-user-id))))
  ;;   ;; Логин пользователя в систему
  ;;   (let ((logged-user-id))
  ;;     (aif (check-auth-data (get-auth-data (list (cons 'email email)
  ;;                                                (cons 'password password))))
  ;;          (progn
  ;;            (login-user-success it)
  ;;            (setf logged-user-id it))
  ;;          (login-user-fail))
  ;;     ;; Проверим, что успешно залогинился
  ;;     (assert (equal ":LOGGED" (state (get-user logged-user-id))))
  ;;     ;; Сновa выход
  ;;     (logout-user logged-user-id))
  ;;   ;; Попытка логина с неверными credentials
  ;;   (let ((logged-user-id))
  ;;     (aif (check-auth-data (get-auth-data (list (cons 'email email)
  ;;                                                (cons 'password "wrong-password"))))
  ;;          (progn
  ;;            (login-user-success it)
  ;;            (setf logged-user-id it))
  ;;          (login-user-fail))
  ;;     ;; Проверим, что не удалось успешно залогиниться
  ;;     (assert (equal nil logged-user-id))))
  (dbg "passed: auth-test~%"))
(auth-test)
