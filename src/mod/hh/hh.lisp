(in-package #:moto)

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

;; special syntax for pattern-matching
(named-readtables:in-readtable :fare-quasiquote)

(in-package #:moto)

(in-package #:moto)

(defmacro define-rule ((name antecedent) &body consequent)
  `(list
     (defun ,(intern (concatenate 'string (symbol-name name) "-ANTECEDENT")) (vacancy)
       ,antecedent)
     (defun ,(intern (concatenate 'string (symbol-name name) "-CONSEQUENT")) (vacancy)
       (let ((result (progn ,@consequent)))
         (values vacancy result)))))

;; expand

;; (macroexpand-1 '(define-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                               (not (contains "Java" (getf vacancy :name)))))
;;                  (setf (getf vacancy :interested) t)
;;                  :stop))

;; test

;; (define-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                   (not (contains "Java" (getf vacancy :name)))))
;;   (setf (getf vacancy :interested) t)
;;   :stop)

;; (let ((vacancy '(:name "Python" :salary 80000)))
;;   (multiple-value-bind (vacancy-result rule-result)
;;       (if (hi-salary-java-antecedent vacancy)
;;           (hi-salary-java-consequent vacancy))
;;     (print (format nil "vacancy: ~A ||| rule-result: ~A" (bprint vacancy-result) (bprint rule-result)))))

;; ->"vacancy: (:INTERESTED T :NAME \"Python\" :SALARY 80000) ||| rule-result: :STOP"

(in-package #:moto)

(defun process (vacancy rules)
  (let ((vacancy vacancy))
    (tagbody
     renew
       (loop :for rule :in rules :do
          (let ((antecedent (concatenate 'string (symbol-name rule) "-ANTECEDENT"))
                (consequent (concatenate 'string (symbol-name rule) "-CONSEQUENT")))
            (if (funcall (intern antecedent) vacancy)
                (multiple-value-bind (vacancy-result rule-result)
                    (funcall (intern consequent) vacancy)
                  (setf vacancy vacancy-result)
                  (when (equal rule-result :stop)
                    (return-from process vacancy))
                  (when (equal rule-result :renew)
                    (go renew)))))))
    vacancy))

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-vacancy-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-VACANCY-IF-"(symbol-name name))) ,antecedent)
     (dbg "drop vacancy:")
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

(defmethod show-vacancy (vacancy)
  (format t "~%")
  (format t "~%~A :~A: ~A [~A]"
       (getf vacancy :salary-text)
       (getf vacancy :currency)
       (getf vacancy :name)
       (getf vacancy :id))
  (format t "~%~A" (getf vacancy :emp-name))
  (format t "~A" (show-descr (getf vacancy :descr))))

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

(define-drop-vacancy-rule (already-worked (contains (getf vacancy :emp-name) "Webdom"))
  ;; (dbg "already worked: ~A" (getf vacancy :emp-name))
  )

(define-drop-vacancy-rule (already-exists-in-db (not (null (find-vacancy :src-id (getf vacancy :id)))))
  (let ((exists (car (find-vacancy :src-id (getf vacancy :id)))))
    (dbg "already exists: ~A : ~A : ~A" (id exists) (name exists) (emp-name exists))))

(define-rule (set-rank t)
  (setf (getf vacancy :rank) (getf vacancy :salary)))

(define-rule (set-rank-up-by-lisp (contains (format nil "~A" (bprint (getf vacancy :descr))) "Lisp"))
  ;; (dbg "up rank by Lisp")
  (setf (getf vacancy :rank) (+ (getf vacancy :rank) 30000)))

(define-rule (set-rank-up-by-erlang (contains (format nil "~A" (bprint (getf vacancy :descr))) "Erlang"))
  ;; (dbg "up rank by Erlang")
  (setf (getf vacancy :rank) (+ (getf vacancy :rank) 15000)))

(define-rule (set-rank-up-by-haskell (contains (format nil "~A" (bprint (getf vacancy :descr))) "Haskell"))
  ;; (dbg "up rank by Haskell")
  (setf (getf vacancy :rank) (+ (getf vacancy :rank) 10000)))

(define-rule (z-print t)
  (show-vacancy vacancy))

(define-rule (z-save t)
  (save-vacancy vacancy)
  :stop)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-teaser-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-TEASER-IF-"(symbol-name name))) ,antecedent)
     ;; (dbg "drop teaser:")
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
     ;; (dbg "  - :name contains ~A" ,str)
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

(define-drop-teaser-rule (salary-1-no (null (getf vacancy :salary)))
  ;; (dbg "  - no salary")
  )

(define-drop-teaser-rule (salary-2-low (< (getf vacancy :salary-max) 90000))
  ;; (dbg "  - no salary")
  )


(define-drop-all-teaser-when-name-contains-rule
    "iOS" "Python" "Django" "IOS" "1C" "1С" "C++" "С++" "Ruby" "Ruby on Rails"
    "Frontend" "Front End" "Front-end" "Go" "Q/A" "QA" "C#" ".NET" ".Net"
    "Unity3D" "Flash" "Java" "Android" "ASP" "Objective-C" "Go" "Delphi"
    "Sharepoint" "Flash" "PL/SQL" "Oracle" "designer")

(defun get-all-rules ()
  (let ((result (make-hash-table :test #'equal)))
    (loop :for var :being :the present-symbols :in (find-package "MOTO")
       :when (or
              (and (search "CONSEQUENT" (symbol-name var))
                   (fboundp var))
              (and (search "ANTECEDENT" (symbol-name var))
                   (fboundp var)))
       :collect (let ((key (ppcre:regex-replace "-ANTECEDENT" (symbol-name var) "")))
                  (setf key (ppcre:regex-replace "-CONSEQUENT" key ""))
                  (setf (gethash key result) "")))
    (mapcar #'intern
            (sort
             (alexandria:hash-table-keys result)
             #'(lambda (a b)
                 (string< a b))))))

(defun clear-all-rules ()
  (loop :for var :being :the present-symbols :in (find-package "MOTO")
     :when (or
            (and (search "CONSEQUENT" (symbol-name var))
                 (fboundp var))
            (and (search "ANTECEDENT" (symbol-name var))
                 (fboundp var)))
     :collect (fmakunbound var)))

(defun rules-for-teaser ()
  (remove-if-not #'(lambda (x)
                     (search "DROP-TEASER-IF" (symbol-name x)))
                 (get-all-rules)))

(defun rules-for-vacancy ()
  (remove-if #'(lambda (x)
                 (search "DROP-TEASER-IF" (symbol-name x)))
             (get-all-rules)))

(defmethod process-teaser :around (current-teaser)
  (aif (process current-teaser (rules-for-teaser))
       (process (call-next-method it) (rules-for-vacancy))
       nil))

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(defparameter *prof-areas*
  '(("Все профессиональные области" . (""))
    ("Информационные технологии, интернет, телеком"
     . ("1" (("CRM системы" . "536")
             ("CTO, CIO, Директор по IT" . "3")
             ("Web инженер" . "9")
             ("Web мастер" . "10")
             ("Администратор баз данных" . "420")
             ("Аналитик" . "25")
             ("Арт-директор" . "30")
             ("Банковское ПО" . "395")
             ("Игровое ПО" . "475")
             ("Инженер" . "82")
             ("Интернет" . "89")
             ("Компьютерная безопасность" . "110")
             ("Консалтинг, Аутсорсинг" . "113")
             ("Контент" . "116")
             ("Маркетинг" . "137")
             ("Мультимедиа" . "161")
             ("Начальный уровень, Мало опыта" . "172")
             ("Оптимизация сайта (SEO)" . "400")
             ("Передача данных и доступ в интернет" . "203")
             ("Поддержка, Helpdesk" . "211")
             ("Программирование, Разработка" . "221")
             ("Продажи" . "225")
             ("Продюсер" . "232")
             ("Развитие бизнеса" . "246")
             ("Сетевые технологии" . "270")
             ("Системная интеграция" . "272")
             ("Системный администратор" . "273")
             ("Системы автоматизированного проектирования" . "274")
             ("Системы управления предприятием (ERP)" . "50")
             ("Сотовые, Беспроводные технологии" . "277")
             ("Стартапы" . "474")
             ("Телекоммуникации" . "295")
             ("Тестирование" . "117")
             ("Технический писатель" . "296")
             ("Управление проектами" . "327")
             ("Электронная коммерция" . "359"))))
    ("Бухгалтерия, управленческий учет, финансы предприятия" . ("2"))
    ("Маркетинг, реклама, PR" . ("3"))
    ("Административный персонал" . ("4"))
    ("Банки, инвестиции, лизинг" . ("5"))
    ("Управление персоналом, тренинги" . ("6"))
    ("Автомобильный бизнес" . ("7"))
    ("Безопасность" . ("8"))
    ("Высший менеджмент" . ("9"))
    ("Добыча сырья" . ("10"))
    ("Искусство, развлечения, масс-медиа" . ("11"))
    ("Консультирование" . ("12"))
    ("Медицина, фармацевтика" . ("13"))
    ("Наука, образование" . ("14"))
    ("Государственная служба, некоммерческие организации" . ("16"))
    ("Продажи" . ("17"))
    ("Производство" . ("18"))
    ("Страхование" . ("19"))
    ("Строительство, недвижимость" . ("20"))
    ("Транспорт, логистика" . ("21"))
    ("Туризм, гостиницы, рестораны" . ("22"))
    ("Юристы" . ("23"))
    ("Спортивные клубы, фитнес, салоны красоты" . ("24"))
    ("Инсталляция и сервис" . ("25"))
    ("Закупки" . ("26"))
    ("Начало карьеры, студенты" . ("15"))
    ("Домашний персонал" . ("27"))
    ("Рабочий персонал" . ("29"))))

(defun make-specialization-hh-url-string (prof-area &optional specs)
  (let ((specialization (assoc prof-area *prof-areas* :test #'equal)))
    (when (null specialization)
      (err 'specialization-not-found))
    (when (stringp specs)
      (setf specs (list specs)))
    (if (null specs)
        (concatenate 'string
                     "&specialization="
                     (cadr specialization))
        (format nil "~{&~A~}"
                (loop :for spec :in specs :collect
                   (let ((spec (cdr (assoc spec (caddr specialization) :test #'equal))))
                     (when (null spec)
                       (err 'spec-not-found))
                     (concatenate 'string "specialization=" (cadr specialization) "." spec)))))))

;; test

;; (make-specialization-hh-url-string "Информационные технологии, интернет, телеком")
;; (make-specialization-hh-url-string "Информационные технологии, интернет, телеком" '("Программирование, Разработка"))
;; (make-specialization-hh-url-string "Информационные технологии, интернет, телеком" "Программирование, Разработка")
;; (make-specialization-hh-url-string "Информационные технологии, интернет, телеком"
;;                                    '("Программирование, Разработка"
;;                                      "Web инженер"
;;                                      "Web мастер"
;;                                      "Стартапы"
;;                                      "Управление проектами"
;;                                      "Электронная коммерция"))

(defun make-hh-url (city prof-area &optional specs)
  "http://spb.hh.ru/search/vacancy?text=&specialization=1.221&area=2&items_on_page=100&no_magic=true&page=~A")

;; test

(make-hh-url "spb" "Информационные технологии, интернет, телеком" "Программирование, Разработка")

(in-package #:moto)

(defun hh-get-page (url)
  "Получение страницы"
  (flexi-streams:octets-to-string
   (drakma:http-request url
                        :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0"
                        :additional-headers `(("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                                              ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
                                              ("Accept-Charset" . "utf-8")
                                              ("Referer" . "http://spb.hh.ru/")
                                              ("Cookie" . "redirect_host=spb.hh.ru; regions=2; __utma=192485224.1206865564.1390484616.1410378170.1417257232.29; __utmz=192485224.1390484616.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _xsrf=85014f262b894a1e9fc57b4b838e48e8; hhtoken=ES030IVQP52ULPbRqN9DQOcMIR!T; hhuid=x_FxSYWUbySJe1LhHIQxDA--; hhrole=anonymous; GMT=3; display=desktop; unique_banner_user=1418008672.846376826735616")
                                              ("Cache-Control" . "max-age=0"))
                        :force-binary t)
   :external-format :utf-8))

(in-package #:moto)

(in-package #:moto)

;; Это аналог maptree-if, но здесь одна функция и ищет и трансформирует узел дерева
(defun maptree (predicate-transformer tree)
  (multiple-value-bind (t-tree control)
      (aif (funcall predicate-transformer tree)
           it
           (values tree #'mapcar))
    (if (and (consp t-tree)
             control)
        (funcall control
                 #'(lambda (x)
                     (maptree predicate-transformer x))
                 t-tree)
        t-tree)))

;; maptree-transformer - синтаксический сахар для maptree
(defmacro mtm (transformer tree)
  (let ((lambda-param (gensym)))
    `(maptree #'(lambda (,lambda-param)
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

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
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
                                                       (mtm (`("div" (("class" "search-result-item__description")) ,@rest)
                                                              (loop :for item :in rest :when (consp item) :append item))
                                                            (mtm (`("div" (("class" "search-result-item__head"))
                                                                          ("a" (("class" ,(or "search-result-item__name search-result-item__name_standard"
                                                                                              "search-result-item__name search-result-item__name_standard_plus"
                                                                                              "search-result-item__name search-result-item__name_premium"))
                                                                                ("data-qa" "vacancy-serp__vacancy-title") ("href" ,id) ("target" "_blank")) ,name))
                                                                   (list :id (parse-integer (car (last (split-sequence:split-sequence #\/ id)))) :name name))
                                                                 (mtm (`("div" (("class" "b-vacancy-list-salary") ("data-qa" "vacancy-serp__vacancy-compensation"))
                                                                               ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
                                                                               ("meta" (("itemprop" "baseSalary") ("content" ,salary))) ,salary-text)
                                                                        (list :currency currency :salary (parse-integer salary) :salary-text salary-text))
                                                                      (mtm (`("div" (("class" "search-result-item__company")) ,emp-name)
                                                                             (list :emp-name emp-name))
                                                                           (mtm (`("div" (("class" "search-result-item__company"))
                                                                                         ("a" (("href" ,emp-id)
                                                                                               ("class" "search-result-item__company-link")
                                                                                               ("data-qa" "vacancy-serp__vacancy-employer"))
                                                                                              ,emp-name))
                                                                                  (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-id))) :junk-allowed t)
                                                                                        :emp-name emp-name))
                                                                                (mtm (`("div" (("class" "search-result-item__info")) ,@rest)
                                                                                       (loop :for item :in rest :when (consp item) :append item))
                                                                                     (mtm (`("span" (("class" "searchresult__address")
                                                                                                     ("data-qa" "vacancy-serp__vacancy-address")) ,city ,@rest)
                                                                                            (let ((metro (loop :for item in rest :do
                                                                                                            (when (and (consp item) (equal :metro (car item)))
                                                                                                              (return (cadr item))))))
                                                                                              (list :city city :metro metro)))
                                                                                          (mtm (`("span" (("class" "metro-station"))
                                                                                                         ("span" (("class" "metro-point") ("style" ,_))) ,metro)
                                                                                                 (list :metro metro))
                                                                                               (mtm (`("span" (("class" "b-vacancy-list-date")
                                                                                                               ("data-qa" "vacancy-serp__vacancy-date")) ,date)
                                                                                                      (list :date date))
                                                                                                    (mtm (`("span"
                                                                                                            (("class" "vacancy-list-platform")
                                                                                                             ("data-qa" "vacancy-serp__vacancy_career"))
                                                                                                            "  •  " ("span" (("class" "vacancy-list-platform__name"))
                                                                                                                            "CAREER.RU"))
                                                                                                           (list :platform 'career.ru))
                                                                                                         (block subtree-extract
                                                                                                           (mtm (`("div"
                                                                                                                   (("class" "search-result")
                                                                                                                    ("data-qa" "vacancy-serp__results"))
                                                                                                                   ,@rest)
                                                                                                                  (return-from subtree-extract rest))
                                                                                                                (html5-parser:node-to-xmls
                                                                                                                 (html5-parser:parse-html5-fragment html)))))))))))))))))))))))))

;; (hh-parse-vacancy-teasers
;;  (hh-get-page "http://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true"))

(in-package #:moto)

(in-package #:moto)

(defun transform-description (tree-descr)
  (labels ((rem-z (tree)
             (cond ((consp tree)
                    (cons (if (equal (car tree) 'z)
                              (rem-z (cdr tree))
                              (rem-z (car tree)))
                          (rem-z (remove-if #'(lambda (x) (equal x 'z))
                                            (cdr tree)))))
                   (t tree)))
           (rem-nil (tree)
             (cond ((consp tree) (cons (rem-nil (car tree))
                                       (rem-nil (remove-if #'(lambda (x) (or (equal x " ")
                                                                             (equal x NIL)))
                                                           (cdr tree)))))
                   (t tree))))
    (rem-z
     (mtm (`("p" ,@in) in)
          (mtm (`("li" ,@in) `(:l ,in))
               (mtm (`("ul" ,@in) `(:u ,in))
                    (mtm (`("li" ,in) `(:l ,in))
                         (mtm (`("p" ,in) in)
                              (mtm (`("strong" ,in) `(:b ,in))
                                   (mtm (`("em" ,in) `(:b ,in))
                                        (mtm (`("br") 'Z)
                                             (rem-nil tree-descr))))))))))))

;; (print
;;  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12586420")))

(defun hh-parse-vacancy (html)
  (let* ((tree (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html))))
    (append (block header-extract
              (mtm (`("div" (("class" "b-vacancy-custom g-round")) ("meta" (("itemprop" "title") ("content" ,_)))
                            ("h1" (("class" "title b-vacancy-title")) ,name ,@archive) ,@rest)
                     (return-from header-extract
                       (append (list :name name :archive (if archive t nil))
                               (block emp-block (mtm (`("div" (("class" "companyname")) ("a" (("itemprop" "hiringOrganization") ("href" ,emp-lnk)) ,emp-name))
                                                       (return-from emp-block
                                                         (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-lnk))) :junk-allowed t)
                                                               :emp-name emp-name))) rest)))))
                   tree))
            (let ((salary-result (block salary-extract
                                   (mtm (`("div" (("class" "l-paddings"))
                                                 ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
                                                 ("meta" (("itemprop" "baseSalary") ("content" ,base-salary)))
                                                 ,salary-text)
                                          (return-from salary-extract (list :currency currency :base-salary (parse-integer base-salary) :salary-text salary-text)))
                                        tree))))
              (if (equal 6 (length salary-result))
                  salary-result
                  (list :currency nil :base-salary nil :salary-text nil)))
            (let ((city-result (block city-extract (mtm (`("td" (("class" "l-content-colum-2 b-v-info-content")) ("div" (("class" "l-paddings")) ,city))
                                                          (return-from city-extract (list :city city))) tree))))
              (if (equal 2 (length city-result)) city-result (list :city nil)))
            (let ((exp-result (block exp-extract (mtm (`("td" (("class" "l-content-colum-3 b-v-info-content"))
                                                              ("div" (("class" "l-paddings") ("itemprop" "experienceRequirements")) ,exp))
                                                        (return-from exp-extract (list :exp exp))) tree))))
              (if (equal 2 (length exp-result)) exp-result (list :exp nil)))
            (block descr-extract
              (mtm (`("div" (("class" "b-vacancy-desc-wrapper") ("itemprop" "description")) ,@descr)
                     (return-from descr-extract (list :descr (transform-description descr)))) tree)))))

;; (print
;;  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12561525")))

;; (print
;;  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12581768")))

(defmethod process-teaser (current-teaser)
  (aif (hh-parse-vacancy (hh-get-page (format nil "http://spb.hh.ru/vacancy/~A" (getf current-teaser :id))))
       (merge-plists current-teaser it)
       nil))

(defmethod factory ((vac-src (eql 'hh)) city prof-area &optional spec)
  (let ((url     (make-hh-url city prof-area spec))
        (page    0)
        (teasers nil))
    (alexandria:named-lambda get-vacancy ()
      (labels ((load-next-teasers-page ()
                 ;; (dbg "~~ LOAD (page=~A)" page)
                 (setf teasers (hh-parse-vacancy-teasers (hh-get-page (format nil url page))))
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

(in-package #:moto)

(defparameter *saved-vacancy* nil)

(defmethod save-vacancy (vacancy)
  (setf *saved-vacancy*
        (append *saved-vacancy*
                (list (make-vacancy
                       :src-id (getf vacancy :id)
                       :name (getf vacancy :name)
                       :currency (getf vacancy :currency)
                       :salary (aif (getf vacancy :salary) it 0)
                       :base-salary (aif (getf vacancy :base-salary) it 0)
                       :salary-text (getf vacancy :salary-text)
                       :salary-max (getf vacancy :salary-max)
                       :salary-min (getf vacancy :salary-min)
                       :emp-id (getf vacancy :emp-id)
                       :emp-name (getf vacancy :emp-name)
                       :city (getf vacancy :city)
                       :metro (getf vacancy :metro)
                       :experience (getf vacancy :exp)
                       :archive (getf vacancy :archive)
                       :date (getf vacancy :date)
                       :state ":UNSORT"
                       :descr (bprint (show-descr (getf vacancy :descr)))
                       :notes ""
                       :response "Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90")))))

(in-package #:moto)

(defun make-additional-headers (referer cookies)
    `(("Accept"           . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
      ("Accept-Language"  . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
      ("Accept-Charset"   . "utf-8")
      ("Referer"          . ,referer)
      ("Cache-Control"    . "no-cache")
      ("Cookie"           . ,(format nil "~{~{~A=~A~}~^; ~}" cookies))))

(defun respond (vacancy-id resume-id letter)
  (let* ((hhtoken     "ES030IVQP52ULPbRqN9DQOcMIR!T")
         (hhuid       "x_FxSYWUbySJe1LhHIQxDA--")
         (xsrf        "ed689ea1ff02a3074c848b69225e3c78")
         (hhrole      "applicant")
         (crypted-id  "2B9E046016B13C9E701CAC5A276D51C8A5471C6F722104504734B32F0D03E9F8")
         (cookie-jar (make-instance 'drakma:cookie-jar))
         (html (flexi-streams:octets-to-string
                (drakma:http-request
                 (format nil "http://spb.hh.ru/vacancy/~A" vacancy-id)
                 :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0"
                 :additional-headers (make-additional-headers "http://spb.hh.ru/"
                                                              `(("redirect_host"       "spb.hh.ru")  ("regions"             "2")        ("_xsrf"               ,xsrf)
                                                                ("hhtoken"             ,hhtoken)     ("hhuid"               ,hhuid)     ("hhrole"              ,hhrole)
                                                                ("GMT"                 "3")          ("display"             "desktop")))
                 :cookie-jar cookie-jar :force-binary t)
                :external-format :utf-8))
         (cookie-data (loop :for cookie :in (drakma:cookie-jar-cookies cookie-jar) :append
                         (list (intern (string-upcase (drakma:cookie-name cookie)) :keyword) (drakma:cookie-value cookie))))
         (unique-banner-user (getf cookie-data :unique_banner_user)))
    (assert (equal crypted-id (getf cookie-data :crypted_id)))
    (assert (equal "applicant" (getf cookie-data :hhrole)))
    (assert (equal xsrf (getf cookie-data :_xsrf)))
    (let* ((tree (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))
           (name (block namer (mtm (`("div" (("class" "navi-item__switcher HH-Navi-MenuItems-Switcher") ("data-qa" "mainmenu_normalUserName"))
                                            ,name ("span" (("class" "navi-item__post"))))
                                     (return-from namer name))
                                   tree))))
      (assert (equal "Михаил Михайлович Глухов" name))
      (sleep 1)
      (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
        (flexi-streams:octets-to-string
         (drakma:http-request
          "http://spb.hh.ru/applicant/vacancy_response/popup"
          :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0"
          :method :post
          :content (format nil "~{~A~^&~}"
                           (mapcar #'(lambda (x)
                                       (format nil "~A=~A" (car x) (cdr x)))
                                   `(("vacancy_id" . ,(format nil "~A" vacancy-id))
                                     ("resume_id" . ,(format nil "~A" resume-id))
                                     ("letter" . ,(drakma:url-encode letter :utf-8))
                                     ("_xsrf" . ,xsrf)
                                     ("ignore_postponed" . "true"))))
          :content-type "application/x-www-form-urlencoded; charset=UTF-8"
          :additional-headers `(("Accept"           . "*/*")
                                ("Accept-Language"  . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
                                ("Accept-Encoding"  . "gzip, deflate")
                                ("X-Xsrftoken"      . ,xsrf)
                                ("X-Requested-With" . "XMLHttpRequest")
                                ("Referer"          . ,(format nil "http://spb.hh.ru/vacancy/~A" vacancy-id))
                                ("Cookie"           . ,(format nil "~{~A~^;~}"
                                                               (mapcar #'(lambda (x)
                                                                           (format nil "~A=~A" (car x) (cdr x)))
                                                                       `(("redirect_host" . "vladivostok.hh.ru")
                                                                         ("regions" . "2")
                                                                         ("__utma" . "192485224.1206865564.1390484616.1421799450.1421859024.49")
                                                                         ("__utmz" . "192485224.1390484616.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)")
                                                                         ("hipsterShown" . "true")
                                                                         ("hhref" . "")
                                                                         ("vishnu1.userid" . "2B9E046016B13C9E701CAC5A276D51C8A5471C6F722104504734B32F0D03E9F8")
                                                                         ("lt-vc" . "11")
                                                                         ("hhtoken" . ,hhtoken)
                                                                         ("hhuid" . ,hhuid)
                                                                         ("hhrole" . ,hhrole)
                                                                         ("GMT" . "3")
                                                                         ("display" . "desktop")
                                                                         ("_xsrf" . ,xsrf)
                                                                         ("JSESSIONID" . "1i5cpqbtgjgh7ztfwncgixv8c")
                                                                         ("lrp" . "\"http://spb.hh.ru/\"")
                                                                         ("lrr" . "true")
                                                                         ("crypted_id" . ,crypted-id)
                                                                         ("lt-tl" . "8xmy,rn2r,21i1,6gix")
                                                                         ("lt-on-site-time" . "1421859023")
                                                                         ("_xsrf" . "ed689ea1ff02a3074c848b69225e3c78")
                                                                         ("crypted_id" . ,crypted-id)
                                                                         ("unique_banner_user" . ,unique-banner-user)
                                                                         ("__utmb" . "192485224.39.10.1421859024")
                                                                         ("__utmc" . "192485224")
                                                                         ("lt-8xmy" . "46005334")
                                                                         ("lt-rn2r" . "46005334")
                                                                         ("lt-21i1" . "46005334")
                                                                         ("__utmt_vishnu1" . "1")
                                                                         ("lt-6gix" . "46005334")))))
                                ("Cache-Control" . "no-cache"))
          :cookie-jar cookie-jar
          :force-binary t)
         :external-format :utf-8)))))

;; (let ((respond (respond 12646549 7628220 "тест")))
;;   (print respond))

;; (setf drakma:*header-stream* *standard-output*)

(defun run ()
  (let ((gen (factory 'hh "spb" "Информационные технологии, интернет, телеком"
                      "Программирование, Разработка")))
    (loop :for i :from 1 :to 100 :do
       ;; (dbg "~A" i)
       (let ((vacancy (funcall gen)))
         (when (null vacancy)
           (return))))))

(run)
