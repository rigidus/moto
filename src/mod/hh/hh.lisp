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

(defun tree-match (tree predict &key (if-match :return-first-match) (if-atom #'identity))
  (let ((collect))
    (flet ((match-tree (tree f-predict f-in &key
                             (if-atom #'identity)
                             (if-match :return-first-match))
             (cond ((null tree) nil)
                   ((atom tree)
                    (funcall if-atom tree))
                   (t
                    (if (funcall f-predict tree)
                        (cond ((equal if-match :return-first-match)
                               (return-from tree-match
                                 (if (equal if-atom #'identity)
                                     tree
                                     (funcall f-in
                                              tree
                                              #'(lambda (x)
                                                  (declare (ignore x))
                                                  nil)
                                              f-in
                                              :if-match if-match :if-atom if-atom))))
                              ((equal if-match :return-first-level-match)
                               (setf collect
                                     (append collect
                                             (if (equal if-atom #'identity)
                                                 tree
                                                 (funcall f-in
                                                          tree
                                                          #'(lambda (x)
                                                              (declare (ignore x))
                                                              nil)
                                                          f-in
                                                          :if-match if-match :if-atom if-atom)))))
                              ((equal if-match :return-all-match)
                               (progn
                                 (setf collect
                                       (append collect
                                               (if (equal if-atom #'identity)
                                                   tree
                                                   (funcall f-in
                                                            tree
                                                            #'(lambda (x)
                                                                (declare (ignore x))
                                                                nil)
                                                            f-in
                                                            :if-match if-match :if-atom if-atom))))
                                 (cons
                                  (funcall f-in (car tree) f-predict f-in :if-match if-match :if-atom if-atom)
                                  (funcall f-in (cdr tree) f-predict f-in :if-match if-match :if-atom if-atom))))
                              ((equal 'function (type-of if-match))
                               (funcall if-match tree))
                              (t (error 'strategy-not-implemented)))
                        (cons
                         (funcall f-in (car tree) f-predict f-in :if-match if-match :if-atom if-atom)
                         (funcall f-in (cdr tree) f-predict f-in :if-match if-match :if-atom if-atom)))))))
      (let ((result (match-tree tree predict #'match-tree :if-match if-match :if-atom if-atom)))
        (if (or (equal if-match :return-first-level-match)
                (equal if-match :return-all-match))
            collect
            result))
      )))

(tree-match '("div"
              (("class" "b-vacancy-custom g-round"
                ("meta" (("itemprop" "title") ("content" "Ведущий android-разработчик")))
                ("h1" (("class" "title b-vacancy-title")) "Ведущий android-разработчик")
                ("table" (("class" "l"))
                         ("tbody" NIL
                                  ("tr" NIL
                                        ("td" (("colspan" "2") ("class" "l-cell"))
                                              ("div" (("class" "employer-marks g-clearfix"))
                                                     ("div" (("class" "companyname"))
                                                            ("a" (("itemprop" "hiringOrganization") ("href" "/employer/1529644"))
                                                                 "ООО Нимбл"))))
                                        ("td" (("class" "l-cell"))))))))
              (("class" "g-round plus"))
              ("meta" (("itemprop" "title") ("content" "Ведущий android-разработчик"))))
            #'(lambda (x)
                (handler-case
                    (destructuring-bind ((a b &rest c))
                        x
                      (aif (and (stringp a)
                                (string= a "class"))
                           it))
                  (sb-kernel::arg-count-error nil)
                  (sb-kernel::defmacro-bogus-sublist-error nil)))
            :if-match :return-first-level-match
            :if-atom #'(lambda (atom)
                         (if (stringp atom)
                             (intern (string-upcase atom))
                             atom)))

(tree-match (html5-parser:node-to-xmls
              (html5-parser:parse-html5-fragment
               (hh-get-page "http://spb.hh.ru/vacancy/12325429")))
             #'(lambda (x)
                 (handler-case
                     (destructuring-bind (a ((b c)) &rest d)
                         x
                       (aif (and (string= a "div")
                                 (string= c "b-vacancy-custom g-round"))
                            it))
                   (sb-kernel::arg-count-error nil)
                   (sb-kernel::defmacro-bogus-sublist-error nil)))
             :if-match :return-first-match
             :if-atom #'(lambda (atom)
                          (if (stringp atom)
                              (intern (string-upcase atom))
                              atom)))

(tree-match '("div" (("class" "b-vacancy-custom g-round"))
               ("meta" (("itemprop" "title") ("content" "Ведущий android-разработчик")))
               ("h1" (("class" "title b-vacancy-title")) "Ведущий android-разработчик")
               ("table" (("class" "l"))
                ("tbody" NIL
                 ("tr" NIL
                       ("td" (("colspan" "2") ("class" "l-cell"))
                             ("div" (("class" "employer-marks g-clearfix"))
                                    ("div" (("class" "companyname"))
                                           ("a" (("itemprop" "hiringOrganization") ("href" "/employer/1529644"))
                                                "ООО Нимбл"))))
                       ("td" (("class" "l-cell")))))))
             #'(lambda (x)
                 (handler-case
                     (destructuring-bind (a ((b c)) &rest d)
                         x
                       (aif (and (string= a "table"))
                            it))
                   (sb-kernel::arg-count-error nil)
                   (sb-kernel::defmacro-bogus-sublist-error nil)))
             :if-match :return-transform
             :if-atom #'(lambda (atom)
                          (if (stringp atom)
                              (intern (string-upcase atom))
                              atom)))

(in-package #:moto)

(defmacro binder (varlist)
  `(progn
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
                          (alexandria:flatten varlist)))))

;; (macroexpand-1
;;  '(binder (a ((b c)) d &rest e)))

(defmacro compile-pattern ((pattern) &body constraints)
  `#'(lambda (x)
       (handler-case
           (destructuring-bind ,pattern
               x
             (aif (and ,@constraints)
                  (progn
                    (binder ,pattern)
                    it)))
         (sb-kernel::arg-count-error nil)
         (sb-kernel::defmacro-bogus-sublist-error nil))))

;; (macroexpand-1 '(compile-pattern ((a ((b c)) d &rest e))
;;                  (string= a "div")
;;                  (string= c "title b-vacancy-title")))
(in-package #:moto)


(defun hh-parse-vacancy (html)
  "Получение вакансии из html"
  (let* ((parsed (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html)))
         (header (parse-match parsed (compile-pattern ((a ((b c)) &rest d))
                                       (string= c "b-vacancy-custom g-round"))))
         (summary (parse-match parsed (compile-pattern ((a ((b c)) &rest d))
                                        (string= c "b-important b-vacancy-info"))))
         (infoblock (parse-match parsed (compile-pattern ((a ((b c)) &rest d))
                                          (string= c "l-content-2colums b-vacancy-container"))))
         (h1 (parse-match header (compile-pattern ((a ((b c)) title &rest archive-block))
                                   (string= c "title b-vacancy-title"))))
         (name **title**)
         (archive (if (car (last (car **archive-block**))) t nil))
         (employerblock (parse-match header (compile-pattern ((a ((b c) (d lnk)) emp))
                                              (string= c "hiringOrganization"))))
         (employer-name **emp**)
         (employer-id (parse-integer (car (last (split-sequence:split-sequence #\/ **lnk**))) :junk-allowed t))
         (salaryblock (parse-match summary (compile-pattern ((div ((class l-paddings))
                                                                  (meta-1 ((itemprop-1 salaryCurrency) (content-1 CURRENCY)))
                                                                  (meta-2 ((itemprop-2 baseSalary) (content-2 VALUE)))
                                                                  SALARY-TEXT))
                                             (string= div "div")
                                             (string= class "class")
                                             (string= l-paddings "l-paddings")
                                             (string= salaryCurrency "salaryCurrency")
                                             (string= baseSalary "baseSalary")
                                             )))
         (salary-currency **currency**)
         (salary **value**)
         (salary-text **salary-text**)
         (cityblock (parse-match summary (compile-pattern ((a ((b c)) (d ((e f)) x)))
                                           (string= c "l-content-colum-2 b-v-info-content"))))
         (city **x**)
         (expblock (parse-match summary (compile-pattern ((a ((b c) (d e)) x))
                                          (string= e "experienceRequirements"))))
         (exp **x**)
         (description (parse-match infoblock (compile-pattern ((a ((b c) (d e)) &rest descr))
                                               (string= c "b-vacancy-desc-wrapper")
                                               (string= e "description"))))
         )
    description))

(print
  (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12325429"))))

(print
 (hh-parse-vacancy (hh-get-page "http://spb.hh.ru/vacancy/12321429")))



;;     (defun in-descr (par)
;;       (cond ((null par) nil)
;;             ((atom par) ;; (cond ((equal par '&rest) nil)
;;                         ;;       (t (setf result (append result (list par)))))
;;              (print par)
;;              )
;;             (t (progn
;;                  (in-descr (car par))
;;                  (in-descr (cdr par))))))

;;     (in-descr **descr**)
;;     ))

;;   (mapt



;; (defun map-tree (f tree)
;;   (typecase tree
;;     (cons
;;      (cons (map-tree f (car tree))
;;            (if (cdr tree)
;;                (map-tree f (cdr tree))
;;                nil)))
;;     (t (funcall f tree))))

;; (map-tree #'(lambda (x)
;;               (print x))
;;           '(compile-pattern ((a ((b c) (d e)) &rest descr))
;;             (string= c "b-vacancy-desc-wrapper")
;;             (string= e "description")))

;; (mapcar


;; (defun fold-left (function accumulator list)
;;   (typecase list
;;     (null accumulator)
;;     (cons (fold-left function
;;                      (funcall function accumulator (car list))
;;                      (cdr list)))))

;; (let ((res "xyz"))
;;   (fold-left #'(lambda (acc elt)
;;                  (concatenate 'string acc elt))
;;              res
;;              '("a" "b" "c" "d" "e")))

;; (defun fold-left* (function list)
;;     (fold-left function (car list) (cdr list)))

;; (fold-left* #'(lambda (acc elt)
;;                 (concatenate 'string acc elt))
;;             '("a" "b" "c" "d" "e"))

;; (defun left-folder (function accumulator)
;;   (lambda (list)
;;     (typecase list
;;       (null accumulator)
;;       (cons (fold-left function
;;                        (funcall function accumulator (car list))
;;                        (cdr list))))))

;; (let ((res "xyz"))
;;   (funcall (left-folder #'(lambda (acc elt)
;;                             (concatenate 'string acc elt))
;;                         res)
;;            '("a" "b" "c")))

;; (defun left-folder* (function)
;;   (lambda (list)
;;     (funcall (left-folder function (car list))
;;              (cdr list))))

;; (funcall (left-folder* #'(lambda (acc elt)
;;                            (concatenate 'string acc elt)))
;;          '("a" "b" "c"))

;; (defun fold-rigth (function accumulator list)
;;   (typecase list
;;     (null accumulator)
;;     (cons (let ((temp (fold-rigth function accumulator (cdr list))))
;;             (funcall function (car list) temp)))))

;; (let ((res "xyz"))
;;   (fold-rigth #'(lambda (acc elt)
;;                   (concatenate 'string acc elt))
;;               res
;;               '("a" "b" "c" "d" "e")))

;; (defun fold-rigth* (function list)
;;   (fold-rigth function (car list) (cdr list)))

;; (fold-rigth* #'(lambda (acc elt)
;;                  (concatenate 'string acc elt)) '("a" "b" "c" "d" "e"))

;; (defun right-folder* (function)
;;   (lambda (list)
;;     (funcall (right-folder function (car list))
;;              (cdr list))))


;; (funcall (right-folder* #'(lambda (acc elt)
;;                             (concatenate 'string acc elt)))
;;          nil)
;;          '("a" "b" "c"))

;; (defun flatten (tree)
;;   (fold-tree tree
;;              (lambda (e) e)
;;              (lambda (l r) (list l r))))

;; (defun flatten(lst)
;;   (mapcan #'(lambda(x)
;;               (if (consp x)
;;                   (flatten x)
;;                   (list x)))
;;           lst))

;; (defun flatten-1 (tree)
;;   (labels ((lbl (tree acc)
;;              (cond ((null tree) acc)
;;                    ((atom tree) (cons tree acc))
;;                    (t (lbl (car tree)
;;                            (lbl (cdr tree)
;;                                 acc))))))
;;     (lbl tree nil)))


;; (defstruct (node (:print-function
;;                   (lambda (n s d)
;;                     (declare (ignore d))
;;                     (format s "#<~A>" (node-elt n)))))
;;   elt
;;   (l nil)
;;   (r nil))

;; (node-elt (make-node :elt 'aaa))

;; (defun bst-insert (obj bst <)
;;   (if (null bst)
;;       (make-node :elt obj)
;;       (let ((elt (node-elt bst)))
;;         (if (eql obj elt)
;;             bst
;;             (if (funcall < obj elt)
;;                 (make-node
;;                  :elt elt
;;                  :l   (bst-insert obj (node-l bst) <)
;;                  :r   (node-r bst))
;;                 (make-node
;;                  :elt elt
;;                  :r   (bst-insert obj (node-r bst) <)
;;                  :l   (node-l bst)))))))

;; (defun bst-find (obj bst <)
;;   (if (null bst)
;;       nil
;;       (let ((elt (node-elt bst)))
;;         (if (eql obj elt)
;;             bst
;;             (if (funcall < obj elt)
;;                 (bst-find obj (node-l bst) <)
;;                 (bst-find obj (node-r bst) <))))))

;; (defun bst-min (bst)
;;   (and bst
;;        (or (bst-min (node-l bst)) bst)))

;; (defun bst-max (bst)
;;   (and bst
;;        (or (bst-max (node-r bst)) bst)))

;; (defun bst-traverse (fn bst)
;;   (when bst
;;     (bst-traverse fn (node-l bst))
;;     (funcall fn (node-elt bst))
;;     (bst-traverse fn (node-r bst))))

;; ;; >>> Replaces bst-remove from book, which was broken.

;; (defun bst-remove (obj bst <)
;;   (if (null bst)
;;       nil
;;       (let ((elt (node-elt bst)))
;;         (if (eql obj elt)
;;             (percolate bst)
;;             (if (funcall < obj elt)
;;                 (make-node
;;                  :elt elt
;;                  :l (bst-remove obj (node-l bst) <)
;;                  :r (node-r bst))
;;                 (make-node
;;                  :elt elt
;;                  :r (bst-remove obj (node-r bst) <)
;;                  :l (node-l bst)))))))

;; (defun percolate (bst)
;;   (let ((l (node-l bst)) (r (node-r bst)))
;;     (cond ((null l) r)
;;           ((null r) l)
;;           (t (if (zerop (random 2))
;;                  (make-node :elt (node-elt (bst-max l))
;;                             :r r
;;                             :l (bst-remove-max l))
;;                  (make-node :elt (node-elt (bst-min r))
;;                             :r (bst-remove-min r)
;;                             :l l))))))

;; (defun bst-remove-min (bst)
;;   (if (null (node-l bst))
;;       (node-r bst)
;;       (make-node :elt (node-elt bst)
;;                  :l   (bst-remove-min (node-l bst))
;;                  :r   (node-r bst))))

;; (defun bst-remove-max (bst)
;;   (if (null (node-r bst))
;;       (node-l bst)
;;       (make-node :elt (node-elt bst)
;;                  :l (node-l bst)
;;                  :r (bst-remove-max (node-r bst)))))


;; (bst-traverse #'print #S(node :elt 1 :l #S(node :elt 2)))

;; (bst-traverse #'print
;;               (make-node
;;                :elt 1
;;                :l (make-node
;;                    :elt 2
;;                    :l (make-node
;;                        :elt 3))))

;; (define 1)
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
