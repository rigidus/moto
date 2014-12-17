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

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (let* ((cut (ppcre:scan-to-strings
               (format nil "~A(.*)~A"
                       "<table class=\"l-table entry-content\" data-qa=\"vacancy-serp__results\">"
                       "<div class=\"g-hidden b-select-icon-popup HH-VacancyToFavorite-LimitPopup\">")
               html))
         (cut-without-tail (subseq cut 0 (- (length cut) 74)))
         (parsed (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment cut-without-tail)))
         (rows   (cddr (nth 2 (car parsed)))))
    (remove-if
     #'null
     (loop :for row :in rows :collect
        (when (or (ppcre:scan-to-strings "vacancy-serp__vacancy_premium" (car (cdaadr row)))
                  (string= "b-vacancy-list-standard" (car (cdaadr row)))
                  (string= "b-vacancy-list-standard_plus" (car (cdaadr row))))
          (let* ((data (nth 3 row))
                 (hh-vacancy-a (cdr (caddr (caddr (caddr (caddr data))))))
                 (hh-vacancy-name (car (last hh-vacancy-a)))
                 (hh-vacancy-id (parse-integer (car (last (split-sequence:split-sequence #\/ (car (cdaddr (car hh-vacancy-a)))))) :junk-allowed t))
                 (hh-vacancy-date (caddr (cadddr (caddr data))))
                 (hh-vacancy-placetime (nth 4 (nth 4 (caddr data))))
                 (hh-salary-div (nth 5 (caddr data)))
                 (result (list :vacancy-name hh-vacancy-name
                               :vacancy-id hh-vacancy-id
                               :vacancy-date hh-vacancy-date
                               )))
            (when hh-vacancy-placetime
              (let ((hh-employer-name (car (last hh-vacancy-placetime)))
                    (hh-employer-id (parse-integer (car (last (split-sequence:split-sequence #\/ (car (cdaadr hh-vacancy-placetime))))) :junk-allowed t)))
                (setf result (append result (list :employer-name hh-employer-name
                                                  :employer-id hh-employer-id)))))
            (when (and hh-salary-div
                       (string= "b-vacancy-list-salary"  (car (cdaadr hh-salary-div))))
              (let ((hh-salary-currency (cadr (cadadr (caddr hh-salary-div))))
                    (hh-salary-base (parse-integer (cadr (cadadr (cadddr hh-salary-div))) :junk-allowed t))
                    (hh-salary-text (car (last hh-salary-div))))
                (setf result (append result (list :salary-currency hh-salary-currency
                                                  :salary-base hh-salary-base
                                                  :salary-text hh-salary-text)))))
            result))))))
(in-package #:moto)

(defun tree-match (tree predict &key (if-match :return-first-match))
  (let ((collect))
    (flet ((match-tree (tree f-predict f-in &key
                             (if-match :return-first-match))
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
                                  (funcall f-in (car tree) f-predict f-in :if-match if-match)
                                  (funcall f-in (cdr tree) f-predict f-in :if-match if-match))))
                              ((equal 'function (type-of if-match))
                               (funcall if-match tree))
                              (t (error 'strategy-not-implemented)))
                        (cons
                         (funcall f-in (car tree) f-predict f-in :if-match if-match)
                         (funcall f-in (cdr tree) f-predict f-in :if-match if-match)))))))
      (match-tree tree predict #'match-tree :if-match if-match)
      collect
      )))
(in-package #:moto)

(defmacro with-predict (pattern &body body)
  `#'(lambda (lambda-param)
       (handler-case
           (destructuring-bind ,pattern
               lambda-param
             ,@body)
         (sb-kernel::arg-count-error nil)
         (sb-kernel::defmacro-bogus-sublist-error nil))))

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
         (h1 (tree-match header (with-predict-if (a ((b c)) title &rest archive-block)
                                  (string= c "title b-vacancy-title"))))
         (-name- **title**)
         (-archive- (if (car (last (car **archive-block**))) t nil))
         (employerblock (tree-match header (with-predict-if (a ((b c) (d lnk)) emp)
                                             (string= c "hiringOrganization"))))
         (-employer-name- **emp**)
         (-employer-id- (parse-integer
                         (car (last (split-sequence:split-sequence #\/ **lnk**)))
                         :junk-allowed t))
         (salaryblock (tree-match summary (with-predict-if
                                              (div ((class l-paddings))
                                                   (meta-1 ((itemprop-1 salaryCurrency) (content-1 CURRENCY)))
                                                   (meta-2 ((itemprop-2 baseSalary) (content-2 VALUE)))
                                                   SALARY-TEXT)
                                            (and
                                             (string= div "div")
                                             (string= class "class")
                                             (string= l-paddings "l-paddings")
                                             (string= salaryCurrency "salaryCurrency")
                                             (string= baseSalary "baseSalary")
                                             ))))
         (-salary-currency- **currency**)
         (-salary- **value**)
         (-salary-text- **salary-text**)
         (cityblock (tree-match summary (with-predict-if (a ((b c)) (d ((e f)) city))
                                          (string= c "l-content-colum-2 b-v-info-content"))))
         (-city- **city**)
         (expblock (tree-match summary (with-predict-if (a ((b c) (d e)) exp)
                                         (string= e "experienceRequirements"))))
         (-exp- **exp**)
         (-description-
          (transform-description
           (tree-match tree (with-predict-if (a ((b c) (d e)) &rest f)
                              (string= c "b-vacancy-desc-wrapper"))))))
    -description-
    ))

(print
 (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12325429")))

(print
 (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12321429")))
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

(defparameter *teasers* (run-collect *programmin-and-development-profile*))

(length *teasers*)

(defun save-collect (all-teasers)
  (loop :for tea :in *teasers* :do
     (print tea)
     (make-vacancy :profile-id (id *programmin-and-development-profile*)
                   :name (getf tea :vacancy-name)
                   :rem-id (getf tea :vacancy-id)
                   :rem-date (getf tea :vacancy-date)
                   :rem-employer-name (getf tea :employer-name)
                   :rem-employer-id (aif (getf tea :employer-id)
                                         it
                                         0)
                   :currency (getf tea :salary-currency)
                   :salary (aif (getf tea :salary-base)
                                it
                                0)
                   :salary-text (getf tea :salary-text)
                   :state ":TEASER"
                   )))

(save-collect *teasers*)


;; Тестируем hh
(defun hh-test ()
  
  
  (dbg "passed: hh-test~%"))
(hh-test)
