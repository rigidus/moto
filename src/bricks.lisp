;; [[file:bricks.org][iface]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3

;;;; bricks.lisp

(in-package #:moto)

(defmacro input ((name title &rest rest &key container-class class required type value &allow-other-keys) &body nobody)
  (let ((result-container-class "input-container")
        (label `(:label :for ,name)))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (when required
      (setf label (append label `(:required "required"))))
    (let ((result-class "form-element input-text"))
      (when required
        (setf result-class (concatenate 'string result-class " required")))
      (when class
        (setf result-class (concatenate 'string result-class " " class)))
      (unless type
        (setf type "text"))
      (unless value
        (setf value ""))
      (remf rest :container-class)
      (remf rest :class)
      (remf rest :required)
      (remf rest :type)
      (remf rest :value)
      (let ((input `(:input :type ,type :name ,name :id ,name :class ,result-class :value ,value)))
        (unless (null rest)
          (setf input (append input rest)))
        (let ((input-container `((:div :class ,result-container-class)
                                 (,label ,title)
                                 ((:div :class "input-bg")
                                  (,input)))))
          `(ps-html ,input-container))))))

;; (macroexpand-1 '(input ("mobile" "Мобильный телефон" :maxlength "15" :container-class "input-container--1-2 even")))

;; (macroexpand-1 '(input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50")))

;; (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ))
(in-package #:moto)

(defmacro select ((name title &rest rest &key container-class class required default &allow-other-keys) &body options)
  (let ((result-container-class "input-container")
        (label `(:label :for ,name)))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (when required
      (setf label (append label `(:required "required"))))
    (let ((result-class "form-element"))
      (when required
        (setf result-class (concatenate 'string result-class " required")))
      (remf rest :container-class)
      (remf rest :class)
      (remf rest :required)
      (when default
        (setf default (eval default)))
      (remf rest :default)
      (let ((select `(:select :name ,name :id ,name :class ,result-class)))
        (unless (null rest)
          (setf select (append select rest)))
        (let ((select-container `((:div :class ,result-container-class)
                                  (,label ,title)
                                  (,select ,@(loop :for (value . label) :in (car options) :collect
                                                (if (equal default value)
                                                    `((:option :value ,value :selected "selected") ,label)
                                                    `((:option :value ,value) ,label)))))))
          `(ps-html ,select-container))))))

;; (macroexpand-1 '(select ("sex" "Пол" :default (test "sex"))
;;                  (("" . "Выбрать пол")
;;                   ("male" . "Мужской")
;;                   ("female" . "Женский"))))
;; (select ("sex" "Пол" :default (test "sex"))
;;   (("" . "Выбрать пол")
;;    ("male" . "Мужской")
;;    ("female" . "Женский")))
(in-package #:moto)

(defmacro fieldset (legend &body body)
  `(ps-html ((:fieldset)
             ((:legend) ,legend)
             (format nil "~{~A~}"
                     (list ,@body)))))

;; (fieldset "Обязательные поля"
;;   (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
(in-package #:moto)

(defmacro submit (title &rest rest &key class container-class &allow-other-keys)
  (let ((result-container-class "button")
        (result-class ""))
    (when container-class (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (remf rest :container-class)
    (when class (setf result-class (concatenate 'string result-class " " class)))
    (remf rest :class)
    (let ((button `(:button :type "submit" :class ,result-container-class)))
      (setf button (append button rest))
      `(ps-html ((:div :class ,result-class)
                 (,button ,title))))))

;; (macroexpand-1 '(submit "Зарегистрироваться" :onclick "alert(1);"))
(in-package #:moto)

(defmacro form ((name title &rest rest &key action method class &allow-other-keys) &body body)
  (let ((result-class ""))
    (unless action (setf action "#"))
    (unless method (setf method "POST"))
    (when class (setf result-class (concatenate 'string result-class " " class)))
    ;; (remf rest :title)
    (remf rest :action)
    (remf rest :method)
    (remf rest :class)
    (let ((form `(:form :action ,action :method ,method  :id ,name :name ,name :class ,result-class)))
      (setf form (append form rest))
      (setf form (append `(,form)
                         `(((:input :type "hidden" :name ,(format nil "CSRF-~A" name) :value "todo")))))
      (when title
        (setf form (append form
                           `(((:h2 :class "form-headline heading__headline--h2") ,title)))))
      (setf form (append form `(,@body)))
      `(ps-html ,form))))

;; (defmacro form ((name title &rest rest &key action method class &allow-other-keys) &body body)
;;   (let ((result-class "form-section-container")) ;;  js__formValidation
;;     (unless action (setf action "#"))
;;     (unless method (setf method "POST"))
;;     (when class (setf result-class (concatenate 'string result-class " " class)))
;;     (remf rest :action)
;;     (remf rest :method)
;;     (remf rest :class)
;;     (let ((form `(:form :action ,action :method ,method  :id ,name :name ,name :class ,result-class)))
;;       (setf form (append form rest))
;;       `(ps-html (,form
;;                     ((:input :type "hidden" :name ,(format nil "CSRF-~A" name) :value "d34d75644abf8f1f0b9ee7bbaeb8c178-61d7aa05b65801c3185523a93438a225"))
;;                   ((:h2 :class "form-headline heading__headline--h2") ,title)
;;                   (format nil "~{~A~}"
;;                           (list ,@body)))))))



;; (print
;; (macroexpand-1 '(form ("regform" "Регистрационные данные")
;;                  (fieldset "Обязательные поля"
;;                    (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;                  (fieldset "Необязательные поля"
;;                    (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;                  )))

;; (PS-HTML
;;  ((:FORM :ACTION "#" :METHOD "POST" :ID "regform" :NAME "regform" :CLASS
;;          "form-section-container")
;;   ((:INPUT :TYPE "hidden" :NAME "CSRF-regform" :VALUE "todo"))
;;   ((:H2 :CLASS "form-headline heading__headline--h2") "Регистрационные данные")
;;   (FIELDSET "Обязательные поля"
;;     (INPUT ("email" "Email" :REQUIRED T :CLASS "my-super-class" :TYPE "email"
;;                     :MAXLENGTH "50")
;;       "Please enter a valid email address."))))

;; (PS-HTML
;;  ((:FORM :ACTION "#" :METHOD "POST" :ID "regform" :NAME "regform" :CLASS
;;          "form-section-container")
;;   ((:INPUT :TYPE "hidden" :NAME "CSRF-regform" :VALUE  "d34d75644abf8f1f0b9ee7bbaeb8c178-61d7aa05b65801c3185523a93438a225"))
;;   ((:H2 :CLASS "form-headline heading__headline--h2") "Регистрационные данные")
;;   ;; (FORMAT NIL "~{~A~}"
;;   ;;         (LIST
;;            (FIELDSET "Обязательные поля"
;;              (INPUT ("email" "Email" :REQUIRED T :CLASS "my-super-class" :TYPE
;;                              "email" :MAXLENGTH "50")
;;                "Please enter a valid email address."))
;;            (FIELDSET "Необязательные поля"
;;              (INPUT ("email" "Email" :REQUIRED T :CLASS "my-super-class" :TYPE
;;                              "email" :MAXLENGTH "50")
;;                "Please enter a valid email address."))))
;; ))

;; (form ("regform" "Регистрационные данные")
;;   (fieldset "Обязательные поля"
;;     (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address."))
;;   (fieldset "Необязательные поля"
;;     (input ("email" "Email" :required t :class "my-super-class" :type "email" :maxlength "50" ) "Please enter a valid email address.")))
(in-package #:moto)

(defmacro teaser ((&rest rest &key class header &allow-other-keys) &body contents)
  (let ((result-class "teaser-box")
        (inner '((:div :class "inner"))))
    (when class
      (setf result-class (concatenate 'string result-class " " class)))
    (when header
      (setf inner (append inner `(((:div :class "center") ,header)))))
    (setf inner (append inner `(((:p) ,@contents))))
    (remf rest :class)
    (remf rest :header)
    (let ((teaser-box `(:div :class ,result-class)))
      (setf teaser-box (append teaser-box rest))
      `(ps-html
        (,teaser-box ,inner)))))

(macroexpand-1 '(teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
                 "Адрес электронной почты, телефон и другие
                 данные нигде не показываеются на сайте -
                 мы используем их только для восстановления
                 доступа к аккаунту."
                 ))

;; (macroexpand-1 '(teaser (:header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip") "Безопасность данных"))
;;                  "Пароль к аккаунту храниться в
;;                  зашифрованной форме - даже оператор сайта не
;;                  может прочитать его"
;;                  ))

;; (macroexpand-1 '(teaser (:class "add" :zzz "zzz")
;;                  "Пароль к аккаунту храниться в
;;                  зашифрованной форме - даже оператор сайта не
;;                  может прочитать его"
;;                  ))

  ;; <div class="content-box size-1-5">
  ;;     <div class="teaser-box">
  ;;         <div class="inner">
  ;;             <div class="center">
  ;;                 <h2 class="teaser-box--title">Безопасность данных</h2>
  ;;             </div>
  ;;             <p>
  ;;                 Адрес электронной почты, телефон и другие
  ;;                 данные нигде не показываеются на сайте -
  ;;                 мы используем их только для восстановления
  ;;                 доступа к аккаунту.
  ;;             </p>
  ;;         </div>
  ;;     </div>
  ;;     <div class="teaser-box text-container">
  ;;         <div class="inner">
  ;;             <div class="center">
  ;;                 <img src="https://www.louis.de/content/application/language/de_DE/images/tipp.png" alt="Tip" />
  ;;             </div>
  ;;             <p>Пароль к аккаунту храниться в
  ;;                 зашифрованной форме - даже оператор сайта не
  ;;                 может прочитать его</p>
  ;;         </div>
  ;;     </div>

;; (ps-html
;;  ((:div :class "content-box size-1-5")
;;   (teaser (:header ((:h2 :class "teaser-box--title") "Безопасность данных"))
;;     "Адрес электронной почты, телефон и другие данные нигде не показываеются на сайте - мы используем их только для восстановления доступа к аккаунту."
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Пароль к аккаунту храниться в зашифрованной форме - даже оператор сайта не может прочитать его"
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Все данные шифруются с использованием <a href=\"#dataprivacy-overlay\" class=\"js__openOverlay\">SSL</a>."
;;     )
;;   (teaser (:class "text-container" :header ((:img :src "https://www.louis.de/content/application/language/de_DE/images/tipp.png" :alt "Tip")))
;;     "Безопасный пароль должен состоять не менее чем из 8 символов и включать в себя цифры или другие специальные символы"
;;     )))

(in-package #:moto)

(defmacro overlay ((header &rest rest &key container-class class &allow-other-keys) &body contents)
  (let ((result-container-class "overlay")
        (result-class "text-container"))
    (when container-class
      (setf result-container-class (concatenate 'string result-container-class " " container-class)))
    (remf rest :container-class)
    (remf rest :class)
    (let ((container `(:div :class ,result-container-class)))
      (setf container (append container rest))
      `(ps-html
        (,container
          ((:a :class "action-icon action-icon--close" :href "#") "Close")
          ,header
          ((:div :class "text-container") ,@contents)
          )))))

;; (macroexpand-1 '(overlay (((:h3 :class "overlay__title") "Information on SSL") :container-class "dataprivacy-overlay" :zzz "zzz")
;;                  ((:h4) "How are my order details protected from prying eyes and manipulation by third parties during transmission?")
;;                  ((:p) "Your order data are transmitted to us using 128-bit SSL (Secure Socket Layer) encryption.")))
(in-package #:moto)

(defmacro heading ((title &rest rest &key class &allow-other-keys) &body body)
  (let ((result-box-class "heading"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      (setf box (append `(,box) `(((:div :class "heading__inner")
                                   ((:div :class "heading__headline")
                                    ((:h1 :class "heading__headline--h1") ,title))))))
      (unless (null body)
        (setf box (append box `(((:div :class "heading__text") ,@body)))))
      `(ps-html ,box))))

;; (macroexpand-1 '(heading ("title") "text"))
(in-package #:moto)

(defmacro breadcrumb (last &rest prevs)
  (let ((acc nil))
    (loop :for (url . title) :in prevs :do
       (setf acc (append acc `(((:span :itemscope "" :itemtype "http://data-vocabulary.org/Breadcrumb")
                                ((:a :href ,url :itemprop "url")
                                 ((:span :itemprop "title") ,title)))
                               "&nbsp;/&nbsp;"))))
    (setf acc (append acc `(((:span) ,last))))
    `(ps-html ,`((:p :class "breadcrumb")
                 ((:span :class "breadcrumb__title") "Вы тут:")
                 ((:span :class "breadcrumb__content") ,@acc
                  )))))

;; (macroexpand-1 '(breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))

;; (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная"))
(in-package #:moto)

(defun menu ()
  (if (null *current-user*)
      (ps-html
       ((:li :class "active")
        ((:a :title "Регистрация" :href "/reg") "Регистрация"))
       ((:li)
        ((:a :title "Логин" :href "/login") "Логин")))
      (ps-html
       ((:li)
        ((:a :title "Пользователи" :href "/users") "Пользователи"))
       ((:li)
        ((:a :title "Группы" :href "/groups") "Группы"))
       ((:li)
        ((:a :title "Профиль" :href (format nil "/user/~A" *current-user*)) "Профиль"))
       ((:li)
        ((:a :title "Сообщения" :href "/im") "Сообщения"))
       ((:li)
        ((:a :title "Выход" :href "/logout") "Выход")))))
    ;; "<a href=\"/load\">Загрузка данных</a>")
    ;; "<a href=\"/\">TODO: Расширенный поиск по ЖК</a>"
    ;; "<a href=\"/cmpxs\">Жилые комплексы</a>"
    ;; "<a href=\"/find\">Простой поиск</a>"
(in-package #:moto)

(defmacro content-box ((&rest rest &key class &allow-other-keys) &body body)
  (let ((result-box-class "content-box"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      `(ps-html (,box ,@body)))))
(in-package #:moto)

(defmacro system-msg ((msg-type &rest rest &key class &allow-other-keys) &body body)
  "msg-type: sucess | caution | advantage"
  (let ((result-box-class "box system-message"))
    (when class
      (setf result-box-class (concatenate 'string result-box-class " " class)))
    (remf rest :class)
    (let ((box `(:div :class ,result-box-class)))
      (unless (null rest)
        (setf box (append box rest)))
      (let ((result-icon-type (format nil "result-icon result-icon--~A media__item media__item--left" msg-type)))
        `(ps-html (,box ((:span :class ,result-icon-type))
                        ((:div :class "system-message__text-container")
                         ((:div :class "system-message__text") ,@body))
                        ((:span :class "clear"))))))))

;; (macroexpand-1 '(system-msg ("success") "zzz"))
;; (system-msg (success) "zzz")
(in-package #:moto)

(defmacro standard-page ((&rest rest &key breadcrumb user menu overlay &allow-other-keys) &body body)
  (unless overlay
    (setf overlay ""))
  `(ps-html
    ((:section :class "container")
     ,breadcrumb
     ((:div :class "main hasNavigation")
      ((:div :class "category-nav-container")
       ((:p :class "category-nav-container__headline trail") ,user)
       ((:ul :class "category-nav--lvl0 category-nav") ,menu))
      ((:article :class "content") ,@body)
      ((:div :class "overlay-container popup" :id "dataprivacy-overlay" :data-dontcloseviabg "" :data-mustrevalidate "") ,overlay)
      ((:span :class "clear")))
     ((:div :class "main-ending")
      ((:div :class "last-seen")
       ((:h5) "Items viewed recently")
       ((:p) "You do not have any recently viewed items.")))
     ((:div :class "overlay-bg")))))
;; iface ends here
