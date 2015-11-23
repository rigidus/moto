(in-package #:moto)

;; special syntax for pattern-matching - ON
(named-readtables:in-readtable :fare-quasiquote)

(defun tree-match (tree predict &optional (if-match :return-first-match))
  (let ((collect))
    (labels ((match-tree (tree f-predict &optional (if-match :return-first-match))
             (cond ((null tree) nil)
                   ((atom tree) nil)
                   (t
                    (if (funcall f-predict tree)
                        (cond ((equal if-match :return-first-match)
                               (return-from tree-match tree))
                              ((equal if-match :return-first-level-match)
                               (setf collect
                                     (append collect (list tree))))
                              ((equal if-match :return-all-match)
                               (progn
                                   (setf collect
                                         (append collect (list tree)))
                                   (cons
                                    (funcall #'match-tree (car tree) f-predict if-match)
                                    (funcall #'match-tree (cdr tree) f-predict if-match))))
                              ((equal 'function (type-of if-match))
                               (funcall if-match tree))
                              (t (error 'strategy-not-implemented)))
                        (cons
                         (funcall #'match-tree (car tree) f-predict if-match)
                         (funcall #'match-tree (cdr tree) f-predict if-match)))))))
      (match-tree tree predict if-match)
      collect)))

(in-package #:moto)





(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-vacancy-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-VACANCY-IF-"(symbol-name name))) ,antecedent)
     (dbg "drop vacancy: ~A : ~A" (getf vacancy :name) (getf vacancy :emp-name))
     ,@consequent
     (setf vacancy nil)
     :stop))

;; expand

;; (print
;;  (macroexpand-1
;;   '(define-drop-vacancy-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                              (not (contains "Java" (getf vacancy :name)))))
;;     (print (getf vacancy :name))
;;     (print (getf vacancy :salary)))))

;; (DEFINE-RULE (DROP-VACANCY-IF-HI-SALARY-JAVA
;;               (AND (> (GETF VACANCY :SALARY) 70000)
;;                    (NOT (CONTAINS "Java" (GETF VACANCY :NAME)))))
;;   (PRINT (GETF VACANCY :NAME))
;;   (PRINT (GETF VACANCY :SALARY))
;;   (SETF VACANCY NIL)
;;   :STOP)

(in-package #:moto)

(defun show-descr (tree)
  (let ((output (make-string-output-stream))
        (indent 2)
        (prefix ""))
    (labels ((out (format tree)
               (format output "~A~A" (make-string indent :initial-element #\Space)
                       (format nil format tree)))
             (rec (tree)
               (cond ((consp tree) (cond ((and (equal 2 (length tree))
                                               (equal :L (car tree))
                                               (stringp (cadr tree))) (prog1 nil
                                                                        (format output "~A-> ~A~%" prefix (cadr tree))))
                                         ((equal :U (car tree)) (prog1 nil
                                                                  (setf prefix (concatenate 'string (make-string indent :initial-element #\Space) prefix))
                                                                  (rec (cdr tree))
                                                                  (setf prefix (subseq prefix indent))))
                                         ((and (equal 2 (length tree))
                                               (equal :B (car tree))
                                               (stringp (cadr tree))) (format output "~A[~A]~%" prefix (cadr tree)))
                                         (t (cons (rec (car tree))
                                                  (rec (cdr tree))))))
                     (t (cond ((stringp tree) (format output "~A~A~%" prefix tree)))))))
      (rec tree))
    (get-output-stream-string output)))

(defmethod show-vacancy (vacancy)
  (format t "~%")
  (format t "~%~A :~A: ~A [~A]"
       (getf vacancy :salary-text)
       (getf vacancy :currency)
       (getf vacancy :name)
       (getf vacancy :id))
  (format t "~%~A" (getf vacancy :emp-name))
  (format t "~A" (show-descr (getf vacancy :descr))))

;; (define-drop-vacancy-rule (already-worked (contains (getf vacancy :emp-name) "Webdom"))
;;   (dbg "   - already worked"))

;; (define-drop-vacancy-rule (already-worked (contains (getf vacancy :emp-name) "Пулково-Сервис"))
;;   (dbg "   - already worked"))

;; (define-drop-vacancy-rule (already-worked (contains (getf vacancy :emp-name) "FBS"))
;;   (dbg "   - already worked"))

;; (define-drop-vacancy-rule (already-exists-in-db (not (null (find-vacancy :src-id (getf vacancy :id)))))
;;   (let ((exists (car (find-vacancy :src-id (getf vacancy :id)))))
;;     (dbg "   - already exists")))

;; (define-rule (set-rank t)
;;   (setf (getf vacancy :rank) (getf vacancy :salary)))

;; (define-rule (set-rank-up-by-lisp (contains (format nil "~A" (bprint (getf vacancy :descr))) "Lisp"))
;;   (dbg "up rank by Lisp")
;;   (setf (getf vacancy :rank) (+ (getf vacancy :rank) 30000)))

;; (define-rule (set-rank-up-by-erlang (contains (format nil "~A" (bprint (getf vacancy :descr))) "Erlang"))
;;   (dbg "up rank by Erlang")
;;   (setf (getf vacancy :rank) (+ (getf vacancy :rank) 15000)))

;; (define-rule (set-rank-up-by-haskell (contains (format nil "~A" (bprint (getf vacancy :descr))) "Haskell"))
;;   (dbg "up rank by Haskell")
;;   (setf (getf vacancy :rank) (+ (getf vacancy :rank) 10000)))

;; (define-rule (z-print t)
;;   (show-vacancy vacancy))

;; (define-rule (z-save t)
;;   (save-vacancy vacancy)
;;   :stop)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-teaser-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-TEASER-IF-"(symbol-name name))) ,antecedent)
     (dbg "drop teaser: ~A-~A (~A) ~A" (getf vacancy :salary-min) (getf vacancy :salary-max) (getf vacancy :currency) (getf vacancy :name))
     ;; (dbg "~A" vacancy)
     ,@consequent
     (setf vacancy nil)
     :stop))

;; expand

;; (print
;;  (macroexpand-1
;;   '(define-drop-teaser-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                              (not (contains "Java" (getf vacancy :name)))))
;;     (print (getf vacancy :name))
;;     (print (getf vacancy :salary)))))

;; (DEFINE-RULE (DROP-TEASER-IF-HI-SALARY-JAVA
;;               (AND (> (GETF VACANCY :SALARY) 70000)
;;                    (NOT (CONTAINS "Java" (GETF VACANCY :NAME)))))
;;   (PRINT (GETF VACANCY :NAME))
;;   (PRINT (GETF VACANCY :SALARY))
;;   (SETF VACANCY NIL)
;;   :STOP)
(in-package #:moto)

(defmacro define-drop-teaser-by-name-rule (str &body consequent)
  `(define-drop-teaser-rule (,(intern (concatenate 'string "NAME-CONTAINS-" (string-upcase (ppcre:regex-replace-all "\\s+" str "-"))))
                              (contains (getf vacancy :name) ,str))
     (dbg "  - name contains ~A" ,str)
     ,@consequent))

;; expand

;; (print
;;  (macroexpand-1
;;   '(define-drop-teaser-by-name-rule "Android")))

;; (DEFINE-DROP-TEASER-RULE (IF-NAME-CONTAINS-ANDROID
;;                           (CONTAINS (GETF VACANCY :NAME) "Android"))
;;   (DBG "drop:")
;;   (DBG "  name contains ~A" "Android"))

;; test

;; (define-drop-teaser-by-name-rule "Android")

;; ==> (DROP-TEASER-IF-IF-NAME-CONTAINS-ANDROID-ANTECEDENT
;;      DROP-TEASER-IF-IF-NAME-CONTAINS-ANDROID-CONSEQUENT)

(in-package #:moto)

(defmacro define-drop-all-teaser-when-name-contains-rule (&rest names)
  `(list ,@(loop :for name :in names :collect
              `(define-drop-teaser-by-name-rule ,name))))

;; expand
;; (macroexpand-1 '(define-drop-all-teaser-when-name-contains-rule "IOS" "1С" "C++"))

;; (LIST (DEFINE-DROP-TEASER-BY-NAME-RULE "IOS")
;;       (DEFINE-DROP-TEASER-BY-NAME-RULE "1С")
;;       (DEFINE-DROP-TEASER-BY-NAME-RULE "C++"))

;; test

;; (define-drop-all-teaser-when-name-contains-rule "IOS" "1С" "C++"))

;; =>
;; ((DROP-TEASER-IF-IF-NAME-CONTAINS-IOS-ANTECEDENT
;;   DROP-TEASER-IF-IF-NAME-CONTAINS-IOS-CONSEQUENT)
;;  (DROP-TEASER-IF-IF-NAME-CONTAINS-1С-ANTECEDENT
;;   DROP-TEASER-IF-IF-NAME-CONTAINS-1С-CONSEQUENT)
;;  (DROP-TEASER-IF-IF-NAME-CONTAINS-C++-ANTECEDENT
;;   DROP-TEASER-IF-IF-NAME-CONTAINS-C++-CONSEQUENT))

;; (define-drop-teaser-rule (salary-1-no (null (getf vacancy :salary)))
;;   (dbg "  - no salary"))

;; (define-drop-teaser-rule (salary-2-low (or
;;                                         (and (equal (getf vacancy :currency) "RUR")
;;                                              (< (getf vacancy :salary-max) 90000))
;;                                         (and (equal (getf vacancy :currency) "USD")
;;                                              (< (getf vacancy :salary-max) (floor 90000 67)))
;;                                         (and (equal (getf vacancy :currency) "USD")
;;                                              (< (getf vacancy :salary-max) (floor 90000 77)))
;;                                         ))
;;   (dbg "  - low salary"))

;; (define-drop-all-teaser-when-name-contains-rule
;;     "iOS" "Python" "Django" "IOS" "1C" "1С" "C++" "С++" "Ruby" "Ruby on Rails"
;;     "Frontend" "Front End" "Front-end" "Go" "Q/A" "QA" "C#" ".NET" ".Net"
;;     "Unity3D" "Flash" "Java" "Android" "ASP" "Objective-C" "Go" "Delphi"
;;     "Sharepoint" "Flash" "PL/SQL" "Oracle" "designer")

(defun get-all-rules ()
  (sort
   (mapcar #'(lambda (x)
               (setf (name x)
                     (replace-all (name x) "|" ""))
               x)
           (find-rule :user-id 1))
   #'(lambda (a b)
       (string< (name a) (name b)))))

(defun rules-for-teaser ()
  (remove-if-not #'(lambda (x)
                     (search "DROP-TEASER-IF" (name x)))
                 (get-all-rules)))

(defun rules-for-vacancy ()
  (remove-if #'(lambda (x)
                 (search "DROP-TEASER-IF" (name x)))
             (get-all-rules)))

(defmethod process-teaser :around (current-teaser)
  (aif (process current-teaser (rules-for-teaser))
       (process (call-next-method it) (rules-for-vacancy))
       nil))

(in-package #:moto)

(in-package #:moto)



(defun make-hh-url (city prof-area &optional specs)
  "http://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&items_on_page=100&no_magic=true&page=~A")

;; test
;; (make-hh-url "spb" "Информационные технологии, интернет, телеком" "Программирование, Разработка")

(in-package #:moto)

(in-package #:moto)

(defparameter *user-agent* "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:35.0) Gecko/20100101 Firefox/35.0")

(defparameter *additional-headers* `(("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                                     ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
                                     ("Accept-Charset" . "utf-8")))

(defparameter *cookies* nil)

(defparameter *cookie-jar* (make-instance 'drakma:cookie-jar))

(defparameter *referer* "")

(defparameter *need-start* t)

(defun is-logged (html)
  "Проверяем наличие в html блока 'Войти'"
  (dbg ":: is-logged")
  (not (contains html "data-qa=\"mainmenu_loginForm\">Войти</div>")))

(defun get-cookies-alist (cookie-jar)
  "Получаем alist с печеньками из cookie-jar"
  (loop :for cookie :in (drakma:cookie-jar-cookies cookie-jar) :append
     (list (cons (drakma:cookie-name cookie) (drakma:cookie-value cookie)))))

(defun recovery-login ()
  ;; Сначала заходим на главную как будто первый раз, без печенек
  (setf drakma:*header-stream* nil)
  (let* ((start-uri "http://spb.hh.ru/")
         (cookie-jar (make-instance 'drakma:cookie-jar))
         (additional-headers *additional-headers*)
         (response (drakma:http-request start-uri
                                        :user-agent *user-agent*
                                        :additional-headers additional-headers
                                        :force-binary t
                                        :cookie-jar cookie-jar))
         (tree (html5-parser:node-to-xmls
                (html5-parser:parse-html5-fragment
                 (flexi-streams:octets-to-string response :external-format :utf-8)))))
    ;; Теперь попробуем использовать печеньки для логина
    ;; GMT=3 ;; _xsrf=  ;; hhrole=anonymous ;; hhtoken= ;; hhuid= ;; regions=2 ;; unique_banner_user=
    ;; И заходим с вот-таким гет-запросом:
    ;; username=avenger-f@ya.ru ;; password=jGwPswRAfU6sKEhVXX ;; backurl=http://spb.hh.ru/ ;; remember=yes ;; action="Войти" ;; _xsrf=
    ;; [TODO] - Позже сделаем так, чтобы гет-запрос брался из таблички, связанной с пользователем
    ;; (setf drakma:*header-stream* *standard-output*)
    (let* ((post-parameters `(("username" . "avenger-f@yandex.ru")
                              ("password" . "jGwPswRAfU6sKEhVXX")
                              ("backUrl"  . "http://spb.hh.ru/")
                              ("remember" . "yes")
                              ("action"   . "%D0%92%D0%BE%D0%B9%D1%82%D0%B8")
                              ("_xsrf"    . ,(cdr (assoc "_xsrf" (get-cookies-alist cookie-jar) :test #'equal)))))
           (xsrf (cdr (assoc "_xsrf" (get-cookies-alist cookie-jar) :test #'equal)))
           (cookie-jar-2 (make-instance 'drakma:cookie-jar
                                        :cookies (append (list (make-instance 'drakma:cookie :name "GMT"   :value "3" :domain "spb.hh.ru")
                                                               (make-instance 'drakma:cookie :name "_xsrf" :value xsrf :domain "spb.hh.ru"))
                                                         (remove-if #'(lambda (x)
                                                                        (equal "crypted_id" (drakma:cookie-name x)))
                                                                    (drakma:cookie-jar-cookies cookie-jar)))))
           (response-2 (drakma:http-request "https://spb.hh.ru/account/login"
                                            :user-agent *user-agent*
                                            :method :post
                                            :parameters post-parameters
                                            :additional-headers (append *additional-headers* `(("Referer" . ,start-uri)))
                                            :cookie-jar cookie-jar-2
                                            :force-binary t))
           (html (flexi-streams:octets-to-string response-2 :external-format :utf-8)))
      (when (contains html "Неправильные имя и/или пароль - попробуйте, пожалуйста, снова.")
        (err "login failed"))
      (when (contains html "Что-то пошло не так")
        (err "login error"))
      (when (contains html "Михаил Михайлович Глухов")
        (return-from recovery-login
          (values ;; (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html))
                  html
                  cookie-jar-2)))
      (err "login exception"))))

(defun hh-get-page (url cookie-jar referer)
  "Получение страницы"
  ;; Если ни одного запроса еще не было - сделаем запрос к главной и снимем флаг
  (when *need-start*
    (drakma:http-request "http://spb.hh.ru/" :user-agent *user-agent*
                         :force-binary t     :cookie-jar cookie-jar)
    (setf referer "http://spb.hh.ru/")
    (setf *need-start* nil))
  ;; Делаем основной запрос, по урлу из параметров, сохраняя результат в response
  ;; и обновляя cookie-jar
  (let ((response   "")
        (repeat-cnt 0))
    (tagbody repeat
       (setf response
             (flexi-streams:octets-to-string
              (drakma:http-request
               url :user-agent *user-agent* :force-binary t :cookie-jar cookie-jar
               :additional-headers (append *additional-headers*
                                           `(("Referer" . ,referer))))
              :external-format :utf-8))
       ;; Если мы не залогинены:
       (unless (is-logged response)
         ;; Проверяем, не превышено ли кол-во попыток восстановления
         (when (> repeat-cnt 3)
           ;; Если их больше трех - сигнализируем ошибку
           (err "max hh-login try"))
         ;; Пытаемся восстановить сессию
         (multiple-value-bind (recovery-html recovery-cookie-jar)
             (recovery-login)
           (setf response recovery-html)
           (setf cookie-jar recovery-cookie-jar)
           (setf referer "https://spb.hh.ru/account/login"))
         ;; Увеличиваем счетчик попыток
         (incf repeat-cnt)
         ;; Пробуем загрузить страницу снова
         (go repeat)))
    ;; Возвращаем значения
    (values ;; (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment response))
            response
            cookie-jar
            url)))

;; (hh-get-page "http://spb.hh.ru/applicant/negotiations?wed=1"
;;              (make-instance 'drakma:cookie-jar)
;;              "http://spb.hh.ru/")

(in-package #:moto)

(in-package #:moto)

(defun maptree-transform (predicate-transformer tree)
  (multiple-value-bind (t-tree control)
      (aif (funcall predicate-transformer tree)
           it
           (values tree #'mapcar))
    (if (and (consp t-tree)
             control)
        (funcall control
                 #'(lambda (x)
                     (maptree-transform predicate-transformer x))
                 t-tree)
        t-tree)))

;; mtm - синтаксический сахар для maptree-transform
(defmacro mtm (transformer tree)
  (let ((lambda-param (gensym)))
    `(maptree-transform #'(lambda (,lambda-param)
                            (values (match ,lambda-param ,transformer)
                                    #'mapcar))
                        ,tree)))

(in-package #:moto)

(defun parse-salary (vacancy)
  (let ((currency (getf vacancy :CURRENCY))
        (salary-text (ppcre:regex-replace-all " " (getf vacancy :salary-text) ""))
        (salary-min nil)
        (salary-max nil))
    (cond ((equal currency "RUR")
           (setf salary-text (ppcre:regex-replace-all " руб." salary-text "")))
          ((equal currency "USD")
           (setf salary-text (ppcre:regex-replace-all " USD" salary-text "")))
          ((equal currency "EUR")
           (setf salary-text (ppcre:regex-replace-all " EUR" salary-text "")))
          ((equal currency nil)
           'nil)
          (t (progn
               (print (getf vacancy :currency))
               (err 'unk-currency))))
    (cond ((search "от " salary-text)
           (setf salary-min (parse-integer (ppcre:regex-replace-all "от " salary-text ""))))
          ((search "до " salary-text)
           (setf salary-max (parse-integer (ppcre:regex-replace-all "до " salary-text ""))))
          ((search "–" salary-text)
           (let ((splt (ppcre:split "–" salary-text)))
             (setf salary-min (parse-integer (car splt)))
             (setf salary-max (parse-integer (cadr splt)))))
          ((search "-" salary-text)
           (let ((splt (ppcre:split "-" salary-text)))
             (setf salary-min (parse-integer (car splt)))
             (setf salary-max (parse-integer (cadr splt))))))
    (when (null salary-min)
      (setf salary-min salary-max))
    (when (null salary-max)
      (setf salary-max salary-min))
    (setf (getf vacancy :salary-min) salary-min)
    (setf (getf vacancy :salary-max) salary-max)
    vacancy))

;; (hh-parse-vacancy-teasers
;;  (hh-get-page "http://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true"))

(defun html-to-tree (html)
  (html5-parser:node-to-xmls
   (html5-parser:parse-html5-fragment html)))

(defun extract-search-results (tree)
  (block subtree-extract
    (mtm (`("div"
            (("class" "search-result")
             ("data-qa" "vacancy-serp__results"))
            ,@rest)
           (return-from subtree-extract rest))
         tree)))

(defun detect-platform (tree)
  (mtm (`("span"
          (("class" "vacancy-list-platform")
           ("data-qa" "vacancy-serp__vacancy_career"))
          "  •  " ("span" (("class" "vacancy-list-platform__name"))
                          "CAREER.RU"))
         (list :platform 'career.ru))
       tree))

(defun detect-date (tree)
  (mtm (`("span" (("class" "b-vacancy-list-date")
                  ("data-qa" "vacancy-serp__vacancy-date")) ,date)
         (list :date date))
       tree))

(defun detect-metro (tree)
  (mtm (`("span" (("class" "metro-station"))
                 ("span" (("class" "metro-point") ("style" ,_))) ,metro)
         (list :metro metro))
       tree))

(defun detect-address (tree)
  (mtm (`("span" (("class" "searchresult__address")
                  ("data-qa" "vacancy-serp__vacancy-address")) ,city ,@rest)
         (let ((metro (loop :for item in rest :do
                         (when (and (consp item) (equal :metro (car item)))
                           (return (cadr item))))))
           (list :city city :metro metro)))
       tree))

(defun detect-info (tree)
  (mtm (`("div" (("class" "search-result-item__info")) ,@rest)
         (loop :for item :in rest :when (consp item) :append item))
       tree))

(defun detect-emp (tree)
  (mtm (`("div" (("class" "search-result-item__company"))
                ("a" (("href" ,emp-id)
                      ("class" "search-result-item__company-link")
                      ("data-qa" "vacancy-serp__vacancy-employer"))
                     ,emp-name))
         (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-id)))
                                      :junk-allowed t)
               :emp-name emp-name))
       tree))

(defun detect-company (tree)
  (mtm (`("div" (("class" "search-result-item__company")) ,emp-name)
         (list :emp-name emp-name))
       tree))

(defun detect-salary (tree)
  (mtm (`("div" (("class" "b-vacancy-list-salary") ("data-qa" "vacancy-serp__vacancy-compensation"))
                ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
                ("meta" (("itemprop" "baseSalary") ("content" ,salary))) ,salary-text)
         (list :currency currency :salary (parse-integer salary) :salary-text salary-text))
       tree))

(defun detect-interview (tree)
  (mtm (`("a" (("class" "interview-insider__link                   m-interview-insider__link-searchresult")
               ("href" ,href)
               ("data-qa" "vacancy-serp__vacancy-interview-insider"))
              "Посмотреть интервью о жизни в компании")
         (list :interview href))
       tree))

(defun detect-name (tree)
  (mtm (`("div" (("class" "search-result-item__head"))
                ("a" (("class" ,(or "search-result-item__name search-result-item__name_standard"
                                    "search-result-item__name search-result-item__name_standard_plus"
                                    "search-result-item__name search-result-item__name_premium"))
                      ("data-qa" "vacancy-serp__vacancy-title") ("href" ,id) ("target" "_blank")) ,name))
         (list :id (parse-integer (car (last (split-sequence:split-sequence #\/ id)))) :name name))
       tree))

(defun detect-description (tree)
  (mtm (`("div" (("class" "search-result-item__description")) ,@rest)
         (loop :for item :in rest :when (consp item) :append item))
       tree))

(defun detect-garbage-elts (tree)
  (mtm (`("a" (("class" _) ("href" _) ("data-qa" "vacancy-serp__vacancy-interview-insider"))
              "Посмотреть интервью о жизни в компании") 'Z)
       (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_invited")
                    ("data-qa" "vacancy-serp__vacancy_invited")) "Вы приглашены!") 'Z)
            (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_discard")
                         ("data-qa" "vacancy-serp__vacancy_rejected")) "Вам отказали") 'Z)
                 (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_discard")
                              ("data-qa" "vacancy-serp__vacancy_rejected")) "Вам отказали") 'Z)
                      (mtm (`("a" (("title" "Премия HRBrand") ("href" ,_) ("rel" "nofollow")
                                   ("class" ,_)
                                   ("data-qa" ,_)) " ") 'Z)
                           (mtm (`("div" (("class" "search-result-item__image")) ,_) 'Z)
                                (mtm (`("script" (("data-name" "HH/VacancyResponseTrigger") ("data-params" ""))) 'Z)
                                     (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" ,_)
                                                  ("data-qa" "vacancy-serp__vacancy_responded")) "Вы откликнулись") 'Z)
                                          (mtm (`("div" (("class" "search-result-item__star")) ,@_) 'Z)
                                               tree))))))))))

(defparameter *last-parse-data* nil)

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (dbg "hh-parse-vacancy-teasers")
  (setf *last-parse-data* html)
  (mapcar #'parse-salary
          (mtm (`("div" (("class" "search-result") ("data-qa" "vacancy-serp__results")) ,@rest) rest)
               (mtm (`("div" (("data-qa" ,_) ("class" ,(or "search-result-item search-result-item_premium  search-result-item_premium"
                                                           "search-result-item search-result-item_standard "
                                                           "search-result-item search-result-item_standard_plus "))) ,@rest)
                      (let ((in (remove-if #'(lambda (x) (or (equal x 'z) (equal x "noindex") (equal x "/noindex"))) rest)))
                        (if (not (equal 1 (length in)))
                            (progn (print in)
                                   (err "parsing failed, data printed"))
                            (car in))))
                    (-> (html-to-tree html)
                        (extract-search-results)
                        (detect-platform)
                        (detect-date)
                        (detect-metro)
                        (detect-address)
                        (detect-info)
                        (detect-emp)
                        (detect-company)
                        (detect-salary)
                        (detect-interview)
                        (detect-name)
                        (detect-description)
                        (detect-garbage-elts))))))

;; (run)

;; (print
;;  (let ((html *last-parse-data*))
;;    (-> (html-to-tree html)
;;        (extract-search-results)
;;        (detect-platform)
;;        (detect-date)
;;        (detect-metro)
;;        (detect-address)
;;        (detect-info)
;;        (detect-emp)
;;        (detect-company)
;;        (detect-salary)
;;        (detect-interview)
;;        (detect-name)
;;        (detect-description)
;;        (detect-garbage-elts))))

;; (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (hh-parse-vacancy-teasers
;;    (hh-get-page "http://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true" temp-cookie-jar "http://spb.hh.ru/")))




(let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
  ;; -------
  (defmethod process-teaser (current-teaser)
      (aif (hh-parse-vacancy (hh-get-page (format nil "http://spb.hh.ru/vacancy/~A" (getf current-teaser :id))
                                          temp-cookie-jar
                                          "http://spb.hh.ru"))
           (merge-plists current-teaser it)
           nil))
  ;; -------
  (defmethod factory ((vac-src (eql 'hh)) city prof-area &optional spec)
      (let ((url     (make-hh-url city prof-area spec))
            (page    0)
            (teasers nil))
        (alexandria:named-lambda get-vacancy ()
          (dbg "get-vacancy-named-lambda")
          (labels ((load-next-teasers-page ()
                     (dbg "~~ LOAD (page=~A)" page)
                     (setf teasers (hh-parse-vacancy-teasers (hh-get-page (format nil url page)
                                                                          temp-cookie-jar
                                                                          "http://spb.hh.ru")))
                     (incf page)
                     (when (equal 0 (length teasers))
                       (dbg "~~ FIN")
                       (return-from get-vacancy 'nil)))
                   (get-teaser ()
                     (when (equal 0 (length teasers))
                       (load-next-teasers-page))
                     (let ((current-teaser (car teasers)))
                       (setf teasers (cdr teasers))
                       current-teaser)))
            (tagbody get-new-teaser
               (let ((current-teaser (get-teaser)))
                 (let ((current-vacancy (process-teaser current-teaser)))
                   (if (null current-vacancy)
                       (go get-new-teaser)
                       (return-from get-vacancy current-vacancy)))))))))
  ;; -------
  )

;; (let ((gen (factory 'hh "spb" "Информационные технологии, интернет, телеком"
;;                     "Программирование, Разработка")))
;;   (loop :for i :from 1 :to 100 :do
;;      ;; (dbg "~A" i)
;;      (let ((vacancy (funcall gen)))
;;        (when (null vacancy)
;;          (return))))))

;; (print
;; (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (hh-get-page (format nil (make-hh-url "spb" "Информационные технологии, интернет, телеком" "Программирование, Разработка") 0)
;;                temp-cookie-jar
;;                "http://spb.hh.ru")))





(defun run ()
  (make-event :name "run"
              :tag "parser-run"
              :msg (format nil "Сбор вакансий")
              :author-id 0
              :ts-create (get-universal-time))
  (let ((gen (factory 'hh "spb" "Информационные технологии, интернет, телеком"
                      "Программирование, Разработка")))
    (loop :for i :from 1 :to 100 :do
       (dbg "~A" i)
       (let ((vacancy (funcall gen)))
         (when (null vacancy)
           (return))))))

;; (run)









;; Pattern matching test
(dbg "match_1: ~A" (match 1 (1 2)))
(dbg "match_2: ~A" (match '(1 2 3 4) (`(1 ,x ,@y) (list x y))))

;; special syntax for pattern-matching - OFF
;; (named-readtables:in-readtable :standard)
