(in-package #:moto)

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
(in-package #:moto)

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (let* ((tree (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))
         (searchblock (tree-match tree (with-predict-if (a ((b c) (d e)) &rest f)
                                         (string= c "search-result")))))
    (with-predict-maptree (a ((b class) (c d)) &rest z)
      (and (equal class "search-result"))
      #'(lambda (x) (values **z** #'mapcar))
      (with-predict-maptree (a ((b class) (c d)) &rest z)
        (and (or (equal class "search-result-item search-result-item_standard")
                 (equal class "search-result-item search-result-item_standard_plus")
                 (equal class "search-result-item search-result-item_premium search-result-item_premium")))
        #'(lambda (x) (values
                       (let ((in (remove-if #'(lambda (x) (or (equal x nil) (equal x "noindex") (equal x "/noindex"))) **z**))
                             (rs))
                         (if (not (equal 1 (length in)))
                             (err "parsing failed, data NOT printed")
                             (mapcar #'(lambda (item)
                                         (when (and (consp item)
                                                    (not (null item))
                                                    (keywordp (car item)))
                                           (setf rs (append rs item))))
                                     (car in)))
                         rs)
                       #'mapcar))
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
                      #'(lambda (x) (values (list :vac-id **i** :vac-name **z**) #'mapcar))
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
                                  searchblock)))))))))))))))))

(print
 (hh-parse-vacancy-teasers
  (hh-get-page "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=29")))

;; ("div" (("class" "search-result-item__description"))
;;        (:VAC-ID "http://spb.hh.ru/vacancy/12215964" :VAC-NAME "C# Developer / Программист C#")
;;        (:CURRENCY "RUR" :SALARY "40000" :SALARY-TEXT "от 40 000 руб.")
;;        ("a"
;;         (("class"
;;           "interview-insider__link                   m-interview-insider__link-searchresult")
;;          ("href" "/article/8628")
;;          ("data-qa" "vacancy-serp__vacancy-interview-insider"))
;;         "Посмотреть интервью с представителем компании")
;;        (:EMP-ID "/employer/15092" :EMP-NAME "Veeam Software")
;;        (:CITY "Санкт-Петербург" :METRO NIL :DATE "11 декабря"))
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
(in-package #:moto)

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
          :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ **emp-lnk**))))
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
(in-package #:moto)

(defun teaser-rejection ()
  "teaser-rejection")

(defun rejection-favorite ()
  "rejection-favorite")

(in-package #:moto)

(defparameter *programmin-and-development-profile*
  (make-profile :name "Программирование и разработка"
                :user-id 1
                :search-query "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=~A"
                :ts-create (get-universal-time)
                :ts-last (get-universal-time)))

(defun run-collect (profile)
  (let* ((search-str   (search-query profile))
         (all-teasers  nil))
    (block get-all-hh-teasers
      (loop :for num :from 0 :to 100 :do
         (print num)
         (let* ((url (format nil search-str num))
                (teasers (hh-parse-vacancy-teasers (hh-get-page url))))
           (if (equal 0 (length teasers))
               (return-from get-all-hh-teasers)
               (setf all-teasers (append all-teasers teasers)))))
      (print "over-100"))
    all-teasers))

;; (print
;;  (hh-parse-vacancy-teasers (hh-get-page "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=28")))

(defparameter *teasers* (run-collect *programmin-and-development-profile*))

(length *teasers*)

(defun save-collect (all-teasers)
  (loop :for tea :in all-teasers :do
     (print tea)
     (make-vacancy :profile-id (id *programmin-and-development-profile*)
                   :name (getf tea :vac-name)
                   :rem-id (parse-integer
                            (car (last (split-sequence:split-sequence
                                        #\/ (getf tea :vac-id)))))
                   :rem-date (getf tea :vacancy-date)
                   :rem-employer-name (getf tea :employer-name)
                   :rem-employer-id (aif (getf tea :employer-id)
                                         (parse-integer
                                          (car (last (split-sequence:split-sequence
                                                      #\/ it))))
                                         0)
                   :currency (getf tea :salary-currency)
                   :salary (aif (getf tea :salary-base)
                                it
                                0)
                   :salary-text (getf tea :salary-text)
                   :state ":TEASER"
                   )))

(save-collect *teasers*)

(length (all-vacancy))


(print
 (hh-parse-vacancy (hh-get-page (format nil "http://spb.hh.ru/vacancy/~A" (rem-id (get-vacancy 1))))))




;; Тестируем hh
(defun hh-test ()
  
  
  (dbg "passed: hh-test~%"))
(hh-test)
