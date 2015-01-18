(in-package #:moto)

;; special syntax for pattern-matching
(named-readtables:in-readtable :fare-quasiquote)

(in-package #:moto)

(in-package #:moto)

(defmacro define-rule (antecedent &body consequent)
  `(alexandria:named-lambda ,(gensym "RULE-") (vacancy)
     (if ,antecedent
         (let ((result (progn ,@consequent)))
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
   (define-rule (contains (getf vacancy :emp-name) "JetBrains")
     (dbg "drop-vac: Неподходящая компания")
     (setf vacancy nil)
     :stop)
   (define-rule (not (null (find-vacancy :src-id (getf vacancy :id))))
     (let ((exists (car (find-vacancy :src-id (getf vacancy :id)))))
       (dbg "drop-vac: Уже есть в БД: ~A : ~A : ~A" (id exists) (name exists) (emp-name exists)))
     (setf vacancy nil)
     :stop)
   (define-rule t
     (setf (getf vacancy :rank) (getf vacancy :salary)))
   (define-rule (contains (format nil "~A" (bprint (getf vacancy :descr))) "Lisp")
     (dbg "drop-vac: Неподходящая компания")
     (setf (getf vacancy :rank) (+ (getf vacancy :rank) 30000)))
   (define-rule (contains (format nil "~A" (bprint (getf vacancy :descr))) "Erlang")
     (dbg "drop-vac: Неподходящая компания")
     (setf (getf vacancy :rank) (+ (getf vacancy :rank) 15000)))
   (define-rule (contains (format nil "~A" (bprint (getf vacancy :descr))) "Haskell")
     (dbg "drop-vac: Неподходящая компания")
     (setf (getf vacancy :rank) (+ (getf vacancy :rank) 10000)))
   (define-rule t
     (save-vacancy vacancy))
   (define-rule t
     (dbg "~A" (bprint vacancy))
     :stop)
   ))

;; (contains (format nil "~A" (bprint (getf *tmp* :descr))) "JVM2")

;; (defparameter *tmp*
;;   '(:NAME "Senior Software Developer (PyCharm)" :ARCHIVE NIL
;;     :EMP-ID 9281 :EMP-NAME " JetBrains" :CURRENCY "RUR"
;;     :BASE-SALARY "130000" :SALARY-TEXT "от 130 000 руб." :CITY
;;     "Санкт-Петербург" :EXP "3–6 лет" :DESCR
;;     (("Founded in 2000, JetBrains s.r.o. is a world-leading vendor of professional software development tools. At JetBrains, we have a passion for making people more productive through smart software solutions that help them focus more on what they really want to accomplish, and less on mundane, repetitive “computer-busy work.”We are looking for passionate, creative and open-minded people to join our development team."
;;       ("As part of our team, you will provide developers all over the world the best programming environment for Python ecosystem - "
;;        "PyCharm IDE" "."))
;;      ("Responsibilities:"
;;       ("Conceive and implement new features"
;;        "Redesign and optimize existing features"
;;        "Enhance performance of IDE subsystems"
;;        "Interact with users in public issue tracker"))
;;      ("Requirements:"
;;       ("4 years(or more) experience with Java"
;;        "Knowledge of essential algorithms and data structures"
;;        "Experience with multithreaded code"
;;        "Responsibility, discipline, self-motivation"
;;        "Ability to implement ideas into high-quality product features"
;;        "Good teamwork skills"))
;;      ("As a plus would be " "(but not required):")
;;      ("Python knowledge"
;;       "Experience with other JVM based languages"
;;       "Participation in open-source projects")
;;      ("We offer:"
;;       ("Fascinating work in a friendly, young team"
;;        "Developing products for software developers much like ourselves"
;;        "Employment package (compulsory health insurance, 5 weeks paid vacation)"
;;        "High salary: determined individually, but definitely above industry average"
;;        "Full salary during sick leave"
;;        "Voluntary health insurance including dental insurance and voluntary health insurance for your children"
;;        "Bonuses tied to product releases"
;;        "Flexible working schedule"
;;        "Spacious, comfortable office (open 24/7) with hot shower and other amenities"
;;        "Hot meals, coffee, tea, sandwiches, juices and soft drinks free of charge"
;;        "Office library with specialized work-related books and magazines"
;;        "Comfortable, ergonomic workplaces"
;;        "Training including on-the-job English language courses"
;;        "Opportunity to travel to professional conferences in Europe and the US"
;;        "Help in relocating from another region.")))))

(in-package #:moto)

(defparameter *rules-for-teaser*
  (append
   (list
    (define-rule (null (getf vacancy :salary))
      (dbg "drop: Нет зарплаты")
      (setf vacancy nil)
      :stop)
    (define-rule (< (getf vacancy :salary) 80000)
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

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (mtm (`("div" (("class" "search-result") ("data-qa" "vacancy-serp__results")) ,@rest) rest)
       (mtm (`("div" (("data-qa" ,_) ("class" ,(or "search-result-item search-result-item_premium  search-result-item_premium"
                                                   "search-result-item search-result-item_standard "
                                                   "search-result-item search-result-item_standard_plus "))) ,@rest)
              (let ((in (remove-if #'(lambda (x) (or (equal x 'z) (equal x "noindex") (equal x "/noindex"))) rest)))
                (if (not (equal 1 (length in)))
                    (progn (print in)
                           (err "parsing failed, data printed"))
                    (car in))))
            (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label HH-VacancyResponseTrigger-Text g-hidden")
                         ("data-qa" "vacancy-serp__vacancy_responded")) "Вы откликнулись") 'Z)
                 (mtm (`("a" (("title" "Премия HRBrand") ("href" ,_) ("rel" "nofollow")
                              ("class" ,_)
                              ("data-qa" ,_)) " ") 'Z)
                      (mtm (`("div" (("class" "search-result-item__image")) ,_) 'Z)
                           (mtm (`("script" (("data-name" "HH/VacancyResponseTrigger") ("data-params" ""))) 'Z)
                                (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label HH-VacancyResponseTrigger-Text g-hidden")
                                             ("data-qa" "vacancy-serp__vacancy_responded")) "Вы откликнулись") 'Z)
                                     (mtm (`("div" (("class" "search-result-item__star"))) 'Z)
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
                                                                                                    (html5-parser:parse-html5-fragment html)))))))))))))))))))))))

;; (print
;;  ;; (car
;;   (hh-parse-vacancy-teasers
;;    (hh-get-page "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=12")))

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
            (mtm (`" " 'Z)
                 (mtm (`("br" NIL) 'Z)
                      (mtm (`(,(or "ul" "p") NIL ,@rest)
                             (remove-if #'(lambda (x) (and (not (consp x)) (equal x " "))) rest))
                           (mtm (`(,(or "li" "em") NIL ,in) in)
                                (mtm (`("strong" NIL ,in) in) tree-descr))))))
    (labels ((tmp (tree)
               (cond  ((consp tree) (remove-if #'(lambda (x) (equal x 'z))
                                               (cons (tmp (car tree))
                                                     (tmp (cdr tree)))))
                      (t tree))))
      (tmp result))))

(defun hh-parse-vacancy (html &optional intree)
  (let* ((tree (aif intree
                    it
                    (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))))
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
                   (return-from get-vacancy current-vacancy)))))))))

(in-package #:moto)

(defmethod save-vacancy (vacancy)
  (make-vacancy
   :src-id (getf vacancy :id)
   :name (getf vacancy :name)
   :currency (getf vacancy :currency)
   :salary (aif (getf vacancy :salary) it 0)
   :base-salary (aif (getf vacancy :base-salary) it 0)
   :salary-text (getf vacancy :salary-text)
   :emp-id (getf vacancy :emp-id)
   :emp-name (getf vacancy :emp-name)
   :city (getf vacancy :city)
   :metro (getf vacancy :metro)
   :experience (getf vacancy :exp)
   :archive (getf vacancy :archive)
   :date (getf vacancy :date)
   :descr (bprint (getf vacancy :descr)))
  )

(let ((gen (factory 'hh "spb" "Информационные технологии, интернет, телеком"
                    "Программирование, Разработка")))
  (loop :for i :from 1 :to 100 :do
     (dbg "~A" i)
     (let ((vacancy (funcall gen)))
       (when (null vacancy)
         (return)))))
