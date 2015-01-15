(in-package #:moto)

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
  (format nil "http://~A.hh.ru/search/vacancy?clusters=true&specialization=~A&area=~A&page=~~A"
          city
          (make-specialization-hh-url-string prof-area specs)
          2))

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

(defmacro with-predict (pattern &body body)
  (let ((lambda-param (gensym)))
    `#'(lambda (,lambda-param)
         (handler-case
             (destructuring-bind ,pattern
                 ,lambda-param
               ,@body)
           (sb-kernel::arg-count-error nil)
           (sb-kernel::defmacro-bogus-sublist-error nil)))))

;; (macroexpand-1 '
;;  (with-predict (a ((b c)) d &rest e)
;;    (aif (and (string= a "div")
;;              (string= c "title b-vacancy-title"))
;;         (prog1 it
;;           (setf **a** a)
;;           (setf **b** b)))))

;; => #'(LAMBDA (LAMBDA-PARAM)
;;        (HANDLER-CASE
;;            (DESTRUCTURING-BIND
;;                  (A ((B C)) D &REST E)
;;                LAMBDA-PARAM
;;              (AIF (AND (STRING= A "div") (STRING= C "title b-vacancy-title"))
;;                   (PROG1 IT (SETF **A** A) (SETF **B** B))))
;;          (SB-KERNEL::ARG-COUNT-ERROR NIL)
;;          (SB-KERNEL::DEFMACRO-BOGUS-SUBLIST-ERROR NIL))), T

(in-package #:moto)

(defmacro with-predict-if (pattern &body condition)
  `(with-predict ,pattern
     (aif ,@condition
          (prog1 it
            ,@(mapcar #'(lambda (x)
                          `(setf ,(intern (format nil "**~A**" (symbol-name x))) ,x))
                      (remove-if #'(lambda (x)
                                     (or (equal x '&rest)
                                         (equal x '&optional)
                                         (equal x '&body)
                                         (equal x '&key)
                                         (equal x '&allow-other-keys)
                                         (equal x '&environment)
                                         (equal x '&aux)
                                         (equal x '&whole)
                                         (equal x '&allow-other-keys)))
                                 (alexandria:flatten pattern)))))))

;; (macroexpand-1 '
;;  (with-predict-if (a b &rest c)
;;    (and (stringp a)
;;         (string= a "class"))))

;; => (WITH-PREDICT (A B &REST C)
;;      (AIF (AND (STRINGP A) (STRING= A "class"))
;;           (PROG1 IT
;;             (SETF **A** A)
;;             (SETF **B** B)
;;             (SETF **C** C))))

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (let* ((tree (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))
         (searchblock (tree-match tree (with-predict-if (a ((b c) (d e)) &rest f)
                                         (string= c "search-result")))))
    (with-predict-maptree (a ((b class) (c d)) &rest z)
      (and (equal class "search-result"))
      #'(lambda (x) (values **z** #'mapcar))
      (with-predict-maptree
          (a ((b c) (d class)) &rest z)
        (and (or (equal class "search-result-item search-result-item_standard ")
                 (equal class "search-result-item search-result-item_standard_plus ")
                 (equal class "search-result-item search-result-item_premium search-result-item_premium")
                 (equal class "search-result-item search-result-item_premium  search-result-item_premium")))
        #'(lambda (x) (values
                       (let ((in (remove-if #'(lambda (x) (or (equal x nil) (equal x "noindex") (equal x "/noindex"))) **z**))
                             (rs))
                         (if (not (equal 1 (length in)))
                             (err "parsing failed, data NOT printed") ;; (print in)
                             (mapcar #'(lambda (item)
                                         (when (and (consp item)
                                                    (not (null item))
                                                    (keywordp (car item)))
                                           (setf rs (append rs item))))
                                     (car in)))
                         rs)
                       #'mapcar))
        (with-predict-maptree (a (b c (d e) (f g)) h)
          (and (equal e "search-result-item__label HH-VacancyResponseTrigger-Text g-hidden")
               (equal g "vacancy-serp__vacancy_responded")
               (equal h "Вы откликнулись"))
          #'(lambda (x) (values nil #'mapcar))
          (with-predict-maptree  (a ((b  c ) (d  e) (f  g) (h i) (j k)) l)
            (and (equal c "Премия HRBrand"))
            #'(lambda (x) (values nil #'mapcar))
            (with-predict-maptree (a ((b class)) logo)
              (and (equal class "search-result-item__image"))
              #'(lambda (x) (values nil #'mapcar))
              (with-predict-maptree (a ((b class) (c d)))
                (and (equal class "HH/VacancyResponseTrigger"))
                #'(lambda (x) (values nil #'mapcar))
                (with-predict-maptree (a ((b class) (c d)) z)
                  (and (equal class "search-result-item__label HH-VacancyResponseTrigger-Text g-hidden"))
                  #'(lambda (x) (values nil #'mapcar))
                  (with-predict-maptree (a ((b class)))
                    (and (equal class "search-result-item__star"))
                    #'(lambda (x) (values nil #'mapcar))
                    (with-predict-maptree (a ((b class)) c d e &optional f)
                      (and (equal class "search-result-item__description"))
                      #'(lambda (x) (values (remove-if #'null (list **c** **d** **e** **f**)) #'mapcar))
                      (with-predict-maptree (a ((b class)) (c ((d e) (f g) (h i) (j k)) z))
                        (and (equal class "search-result-item__head")
                             (or  (equal e "search-result-item__name search-result-item__name_standard")
                                  (equal e "search-result-item__name search-result-item__name_standard_plus")
                                  (equal e "search-result-item__name search-result-item__name_premium")))
                        #'(lambda (x) (values (list :id **i** :name **z**) #'mapcar))
                        (with-predict-maptree (a ((b class) (c d)) (e ((f g) (h i))) (j ((k l) (m n))) z)
                          (and (equal class "b-vacancy-list-salary"))
                          #'(lambda (x) (values (list :currency **i** :salary **n** :salary-text **z**) #'mapcar))
                          (with-predict-maptree (a ((b class)) (c ((d e) (f g) (h i)) z))
                            (and (equal class "search-result-item__company"))
                            #'(lambda (x) (values (list :emp-id **e** :emp-name **z**) #'mapcar))
                            (with-predict-maptree (a ((b class)) &rest rest)
                              (and (equal class "search-result-item__info"))
                              #'(lambda (x) (values (let ((rs))
                                                      (loop :for item :in **rest** :do
                                                         (when (and (consp item) (keywordp (car item)))
                                                           (setf rs (append rs item))))
                                                      rs)
                                                    #'mapcar))
                              (with-predict-maptree (c ((d sr-addr) (qa serp-addr)) city &rest rest)
                                (and (equal sr-addr "searchresult__address")
                                     (equal serp-addr "vacancy-serp__vacancy-address"))
                                #'(lambda (x) (values (let ((metro (loop :for item in **rest** :do
                                                                      (when (and (consp item) (equal :metro (car item)))
                                                                        (return (cadr item))))))
                                                        (list :city **city** :metro metro))
                                                      #'mapcar))
                                (with-predict-maptree (a ((b class)) (c ((d metro-point) (i j))) metro)
                                  (and (equal class "metro-station")
                                       (equal metro-point "metro-point"))
                                  #'(lambda (x) (values (list :metro **metro**) #'mapcar))
                                  (with-predict-maptree (a ((b class) (c d)) date)
                                    (and (equal class "b-vacancy-list-date"))
                                    #'(lambda (x) (values (list :date **date**) #'mapcar))
                                    searchblock))))))))))))))))))

;; test

;; (print
;;  (car
;;   (hh-parse-vacancy-teasers
;;    (hh-get-page "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=0"))))
(in-package #:moto)

(in-package #:moto)

(defun transform-description (tree-descr)
  (let ((result)
        (header))
    (mapcar #'(lambda (item)
                (unless (equal " " item)
                  (cond ((and (null header) (consp item) (equal 1 (length item)))
                         (setf header (car item)))
                        ((and (not (null header)) (consp item) (not (equal 1 (length item))))
                         (progn
                           (setf result (append result (list (list header item))))
                           (setf header nil)))
                        (t (setf result (append result (list item)))))))
            (cddr
             (with-predict-maptree (ul nil-1 &rest tail)
                    (and (or (equal ul "ul")
                             (equal ul "p"))
                         (equal nil-1 'nil))
                    #'(lambda (x)
                        (values (remove-if #'(lambda (y)
                                               (and (not (consp y)) (equal y " ")))
                                           **tail**)
                                #'mapcar))
                    (with-predict-maptree (tag nil-1 point)
                      (and (or (equal tag "li")
                               (equal tag "em"))
                           (equal nil-1 'nil))
                      #'(lambda (x)
                          (values **point** #'mapcar))
                      (with-predict-maptree (tag nil-1 point)
                        (and (equal tag "strong")
                             (equal nil-1 'nil))
                        #'(lambda (x)
                            (values **point** #'mapcar))
                        tree-descr)))))
    result))

(defun hh-parse-vacancy (html)
  "Получение вакансии из html"
  (let* ((tree (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))
         (header (tree-match tree (with-predict-if (a ((b c)) &rest d)
                                    (string= c "b-vacancy-custom g-round"))))
         (summary (tree-match tree (with-predict-if (a ((b c)) &rest d)
                                     (string= c "b-important b-vacancy-info"))))
         (infoblock (tree-match tree (with-predict-if (a ((b c)) &rest d)
                                       (string= c "l-content-2colums b-vacancy-container"))))
         (h1 (tree-match header (with-predict-if (a ((b c)) name &rest archive-block)
                                  (string= c "title b-vacancy-title"))))
         (employerblock (tree-match header (with-predict-if (a ((b c) (d emp-lnk)) emp-name)
                                             (string= c "hiringOrganization"))))
         (salaryblock (tree-match summary (with-predict-if (a ((b c))
                                                              (d ((e f) (g currency)))
                                                              (h ((i j) (k base-salary)))
                                                              salary-text)
                                            (string= f "salaryCurrency"))))
         (cityblock (tree-match summary (with-predict-if (a ((b c)) (d ((e f)) city))
                                          (string= c "l-content-colum-2 b-v-info-content"))))
         (expblock (tree-match summary (with-predict-if (a ((b c) (d e)) exp)
                                         (string= e "experienceRequirements")))))
    (list :name **name**
          :archive (if (car (last (car **archive-block**))) t nil)
          :emp-name **emp-name**
          :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ **emp-lnk**))) :junk-allowed t)
          :currency (if (null salaryblock) nil **currency**)
          :base-salary (if (null salaryblock) nil **base-salary**)
          :salary-text (if (null salaryblock) nil **salary-text**)
          :city **city**
          :exp **exp**
          :description (transform-description
                        (tree-match tree (with-predict-if (a ((b c) (d e)) &rest f)
                                           (string= c "b-vacancy-desc-wrapper")))))))

;; (print
;;  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12325429")))

;; (print
;;  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12321429")))



(defmethod process-teaser (current-teaser)
  (hh-parse-vacancy (hh-get-page (getf current-teaser :id))))

(defmethod metagen ((vac-src (eql 'hh)) city prof-area &optional spec)
  (let ((url     (make-hh-url city prof-area spec))
        (page    0)
        (teasers nil))
    (alexandria:named-lambda get-vacancy ()
      (labels ((load-next-teasers-page ()
                 (dbg "~~ LOAD (page=~A)" page)
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
                   (return-from get-vacancy (merge-plists current-teaser current-vacancy))))))))))

(in-package #:moto)

(defmacro define-rule (condition &body body)
  `(alexandria:named-lambda ,(gensym "RULE-") (vacancy)
     (if ,condition
         (let ((result (progn ,@body)))
           (values vacancy result))
         vacancy)))

;; expand
;; (macroexpand-1 '(define-rule (and (> (getf vacancy :salary) 70000)
;;                                   (not (contains "Java" (getf vacancy :name))))
;;                  (setf (getf vacancy :interested) t)
;;                  :stop))

;; => (ALEXANDRIA.0.DEV:NAMED-LAMBDA #:RULE-3676 (VACANCY)
;;      (IF (AND (> (GETF VACANCY :SALARY) 70000)
;;               (NOT (CONTAINS "Java" (GETF VACANCY :NAME))))
;;          (LET ((RESULT (PROGN (SETF (GETF VACANCY :INTERESTED) T) :STOP)))
;;            (VALUES VACANCY RESULT))
;;          VACANCY)), T

;; test

;; (multiple-value-bind (vacancy rule-result)
;;     (funcall
;;      (define-rule (and (> (getf vacancy :salary) 70000)
;;                        (not (contains "Java" (getf vacancy :name))))
;;        (setf (getf vacancy :interested) t)
;;        :stop)
;;      '(:name "Python" :salary 80000))
;;   (dbg "vacancy: ~A ~% rule-result: ~A" (bprint vacancy) (bprint rule-result)))

;; ->  vacancy: (:INTERESTED T :NAME "Python" :SALARY 80000)
;; ->  rule-result: :STOP

(in-package #:moto)

(defun process (vacancy rules)
  (tagbody
   renew
     (loop :for rule :in rules :do
        (multiple-value-bind (vacancy-result rule-result)
            (funcall rule vacancy)
          (setf vacancy vacancy-result)
          (when (equal rule-result :stop)
            (return-from process vacancy))
          (when (equal rule-result :renew)
            (go renew)))))
  vacancy)

;; test

;; (let ((tmp 0))
;;   (process '(:name "Python" :salary 80000)
;;            (list
;;             (define-rule (equal 12 tmp)
;;               (setf (getf vacancy :tmp) tmp)
;;               :stop)
;;             (define-rule (and (> (getf vacancy :salary) 70000)
;;                               (not (contains "Java" (getf vacancy :name))))
;;               (print (incf tmp))
;;               :renew)
;;             )))

(in-package #:moto)

(in-package #:moto)

 (defmacro drop-by-name (text)
   `(define-rule (contains (getf vacancy :name) ,text)
      (dbg "drop: name contains ~A" ,text)
      (setf vacancy nil)
      :stop))

 ;; expand

 ;; (macroexpand-1 '(drop-by-name "IOS"))

 ;; => (DEFINE-RULE (CONTAINS (GETF VACANCY :NAME) "IOS")
 ;;      (DBG "drop: name contains ~A" "IOS")
 ;;      (SETF VACANCY NIL)
 ;;      :STOP), T

 (defmacro drop-names (&rest names)
   `(list ,@(loop :for name :in names :collect
               `(drop-by-name ,name))))

 ;; expand

 (macroexpand-1 '(drop-names "IOS" "1С" "C++"))

 ;; => (LIST (DROP-BY-NAME "IOS") (DROP-BY-NAME "1С") (DROP-BY-NAME "C++")), T


(in-package #:moto)

(defparameter *rules-for-vacancy*
  (list
   ;; (define-rule nil
   ;;   (dbg "empty")
   ;;   ;; (setf vacancy nil)
   ;;   :stop)
   ))

(in-package #:moto)

(defparameter *rules-for-teaser*
  (append
   (list
    (define-rule (null (getf vacancy :salary))
      (dbg "drop: Нет зарплаты")
      (setf vacancy nil)
      :stop)
    (define-rule (< (parse-integer (getf vacancy :salary)) 90000)
      (dbg "drop: Маленькая зарплата")
      (setf vacancy nil)
      :stop))
   (drop-names "IOS" "1С" "C++" "Ruby on Rails" "Frontend" "Go" "Qa" "C#" ".NET" "Unity3D" "Flash" "Java" "Android" "ASP" "Objective-C" "Front End" "Go")
   ))

(defmethod process-teaser :around (current-teaser)
  (aif (process current-teaser *rules-for-teaser*)
       (process (call-next-method it) *rules-for-vacancy*)
       nil))

(in-package #:moto)

(let ((gen (metagen 'hh "spb" "Информационные технологии, интернет, телеком"
                    "Программирование, Разработка")))
  (loop :for i :from 1 :to 100 :do
     (dbg "~A" i)
     (let ((vacancy (funcall gen)))
       (when (null vacancy)
         (return))
       (dbg "~A" (bprint vacancy)))))

(in-package #:moto)

(defun teaser-rejection ()
  "teaser-rejection")

(defun rejection-favorite ()
  "rejection-favorite")

;; (in-package #:moto)

;; (defparameter *programmin-and-development-profile*
;;   (make-profile :name "Программирование и разработка"
;;                 :user-id 1
;;                 :search-query "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=~A"
;;                 :ts-create (get-universal-time)
;;                 :ts-last (get-universal-time)))

;; (defun run-collect (profile)
;;   (let* ((search-str   (search-query profile))
;;          (all-teasers  nil))
;;     (block get-all-hh-teasers
;;       (loop :for num :from 0 :to 100 :do
;;          (print num)
;;          (let* ((url (format nil search-str num))
;;                 (teasers (hh-parse-vacancy-teasers (hh-get-page url))))
;;            (if (equal 0 (length teasers))
;;                (return-from get-all-hh-teasers)
;;                (setf all-teasers (append all-teasers teasers)))))
;;       (print "over-100"))
;;     all-teasers))

;; ;; (print
;; ;;  (hh-parse-vacancy-teasers (hh-get-page "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=28")))

;; (defparameter *teasers* (run-collect *programmin-and-development-profile*))

;; ;; (length *teasers*)

;; (defun save-collect (all-teasers)
;;   (loop :for tea :in all-teasers :do
;;      (print tea)
;;      (make-vacancy :profile-id (id *programmin-and-development-profile*)
;;                    :name (getf tea :vac-name)
;;                    :rem-id (parse-integer
;;                             (car (last (split-sequence:split-sequence
;;                                         #\/ (getf tea :vac-id)))))
;;                    :rem-date (getf tea :vacancy-date)
;;                    :rem-employer-name (getf tea :employer-name)
;;                    :rem-employer-id (aif (getf tea :employer-id)
;;                                          (parse-integer
;;                                           (car (last (split-sequence:split-sequence
;;                                                       #\/ it))))
;;                                          0)
;;                    :currency (getf tea :currency)
;;                    :salary (aif (getf tea :salary)
;;                                 it
;;                                 0)
;;                    :salary-text (getf tea :salary-text)
;;                    :state ":TEASER"
;;                    )))

;; (save-collect *teasers*)

;; ;; (length (all-vacancy))

;; ;; (print
;; ;;  (hh-parse-vacancy (hh-get-page (format nil "http://spb.hh.ru/vacancy/~A" (rem-id (get-vacancy 1))))))

;; ;; (car *teasers*)


;; Тестируем hh
(defun hh-test ()


  (dbg "passed: hh-test~%"))
(hh-test)
