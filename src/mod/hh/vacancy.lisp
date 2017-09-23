(in-package :moto)

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

(defmacro define-rule ((name antecedent) &body consequent)
  `(progn
     (mapcar #'(lambda (rule)
                 ;; (when (string= "acitve" (state rule))
                   (del-rule (id rule)))
                 ;; )
             (find-rule :name ,(symbol-name name)))
     (list
      (alexandria:named-lambda
          ,(intern (concatenate 'string (symbol-name name) "-ANTECEDENT-" (symbol-name (gensym)))) (vacancy)
        ,antecedent)
      (alexandria:named-lambda
          ,(intern (concatenate 'string (symbol-name name) "-CONSEQUENT-" (symbol-name (gensym)))) (vacancy)
        (let ((result (progn ,@consequent)))
          (values vacancy result)))
      (make-rule :name ,(symbol-name name)
                 :user-id 1
                 :rank 100
                 :ruletype ":TEASER"
                 :antecedent ,(bprint antecedent)
                 :consequent ,(bprint consequent)
                 :notes ""
                 :state ":ACTIVE"))))

;; expand

;; (macroexpand-1
;;  '(define-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                 (not (contains "Java" (getf vacancy :name)))))
;;    (setf (getf vacancy :interesting) t)
;;    :stop))

;; test

;; (define-rule (hi-salary-java (and (> (getf vacancy :salary) 70000)
;;                                   (not (contains "Java" (getf vacancy :name)))))
;;   (setf (getf vacancy :interesting) t)
;;   :stop)

;; (let ((rule (car (find-rule :name "HI-SALARY-JAVA")))
;;       (vacancy '(:name "Python" :salary 80000)))
;;   (if (funcall (eval (read-from-string (format nil "(lambda (vacancy) ~A)" (antecedent rule))))
;;                vacancy)
;;       (progn
;;         (multiple-value-bind (vacancy-result rule-result)
;;             (funcall (eval `(lambda (vacancy)
;;                               (let ((result (progn ,@(read-from-string (consequent rule)))))
;;                                 (values vacancy result))))
;;                      vacancy)
;;         (setf vacancy vacancy-result)
;;         (print (format nil "vacancy: ~A ||| rule-result: ~A" (bprint vacancy-result) (bprint rule-result)))
;;         ))))

(in-package #:moto)

(defun process (vacancy rules)
  (dbg ":process: (count rules: ~A)" (length rules))
  (let ((vacancy vacancy))
    (tagbody
     renew
       (loop :for rule :in rules :do
          (progn
            (declaim #+sbcl(sb-ext:muffle-conditions style-warning))
            (let ((ant (read-from-string (format nil "(lambda (vacancy) ~A)" (antecedent rule))))
                  (con (read-from-string (consequent rule))))
              (when (funcall (eval ant) vacancy)
                (dbg ":process: rule #~A match : ~A" (id rule) (name rule))
                (dbg ":process: ant : ~A" (bprint ant))
                ;; (dbg ":process: con : ~%~A" (bprint con))
                (multiple-value-bind (vacancy-result rule-result)
                    (funcall (eval `(lambda (vacancy)
                                      (let ((result (progn ,@con)))
                                        (values vacancy result))))
                             vacancy)
                  (setf vacancy vacancy-result)
                  (when (equal rule-result :stop)
                    (return-from process vacancy))
                  (when (equal rule-result :renew)
                    (go renew)))))
            (declaim #+sbcl(sb-ext:unmuffle-conditions style-warning)))))
    vacancy))

;; example for verify rules
(defun dbg-rule-vac (vac-id rule-id)
  (let ((vacancy      (car (find-vacancy vac-id)))
        (antecedent   (read-from-string (format nil "(lambda (vacancy) ~A)" (antecedent (get-rule rule-id))))))
    (values
     (funcall (eval antecedent) (get-obj-data vacancy))
     (getf (get-obj-data vacancy) :name)
     antecedent)))

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-vacancy-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-VACANCY-IF-"(symbol-name name))) ,antecedent)
     (dbg "drop vacancy: ~A : ~A"
          (getf (getf vacancy :vacancy) :name)
          (getf (getf vacancy :company) :emp-name))
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

(defmacro define-drop-all-vacancy-when-already-worked (&rest employers)
  `(list ,@(loop :for emp :in employers :collect
              `(define-drop-vacancy-rule (already-worked (contains (getf (getf vacancy :company) :emp-name) ,emp))
                   (dbg "   - already worked")))))

;; expand
;; (macroexpand-1 '(define-drop-all-vacancy-when-already-worked "Webdom" "Semrush" "Пулково-Сервис"))

;; (LIST
;;  (DEFINE-DROP-VACANCY-RULE (ALREADY-WORKED
;;                             (CONTAINS (GETF VACANCY :EMP-NAME) "Webdom"))
;;    (DBG "   - already worked"))
;;  (DEFINE-DROP-VACANCY-RULE (ALREADY-WORKED
;;                             (CONTAINS (GETF VACANCY :EMP-NAME) "Semrush"))
;;    (DBG "   - already worked"))
;;  (DEFINE-DROP-VACANCY-RULE (ALREADY-WORKED
;;                             (CONTAINS (GETF VACANCY :EMP-NAME)
;;                                       "Пулково-Сервис"))
;;    (DBG "   - already worked")))

;; test

;; (define-drop-all-vacancy-when-already-worked "Webdom" "Semrush" "Пулково-Сервис")

;; (define-drop-all-vacancy-when-already-worked "Webdom" "Semrush" "Пулково-Сервис" "FBS")
(in-package #:moto)

;; (define-drop-vacancy-rule (already-exists-in-db (not (null (find-vacancy :src-id (getf (getf vacancy :vacancy) :id)))))
;;     ;; (let ((exists (car (find-vacancy :src-id (getf vacancy :id)))))
;;     (dbg "   - already exists"))
;; ;; )
;; (in-package #:moto)

;; (define-rule (set-tags t)
;;     ;; Превращаем описание вакансии в plain-text с минимумом знаков препринания, а потом разбиваем по пробелам,
;;     ;; чтобы получить список слов, отсортированный по частоте встречаемости
;;     ;; Из этого списка слов мы хотим найти все термины. Терминами могут быть:
;;     ;; - аббревитуры технологий
;;     ;; - названия технологий и продуктов, известные нам.
;;     ;; Мы считаем интересными те слова, которые содержат только английские буквы (пусть даже и в нижнем регистре)
;;     ;; Можно еще выявлять наиболее часто встречающиеся элементы (https://habrahabr.ru/post/167177/)
;;     ;; Найденные абревиатуры кладем в поле tags
;;     (let ((hash (make-hash-table :test #'equal))
;;           (result))
;;       (mapcar #'(lambda (trm)
;;                   (multiple-value-bind (result exist)
;;                       (gethash trm hash)
;;                     (if (null exist)
;;                         (setf (gethash trm hash) 1)
;;                         (setf (gethash trm hash) (+ 1 result)))))
;;               (ppcre:split "\\s+"
;;                            (ppcre:regex-replace-all
;;                             "\\s+" (->  (replace-all (bprint (getf vacancy :descr)) "(:P)" "")
;;                                         (replace-all "(:B)" "")
;;                                         (replace-all "(:LI)" "")
;;                                         (replace-all "(:UL)" "")
;;                                         (replace-all "(" "")
;;                                         (replace-all ")" "")
;;                                         (replace-all "\"" "")
;;                                         (replace-all "/" " ")
;;                                         (replace-all "," "")
;;                                         (replace-all ":" "")
;;                                         (replace-all ";" "")
;;                                         (replace-all "-" ""))
;;                             " ")))
;;       (maphash #'(lambda (k v)
;;                    (setf result (append result (list (list v k)))))
;;                hash)
;;       ;; (dbg "~A" (bprint result))
;;       (setf result (remove-if #'(lambda (x)
;;                                   (block the-filter
;;                                     ;; Известные нам слова
;;                                     (if (or (equal "1С" (cadr x))
;;                                             ;; need more ...
;;                                             )
;;                                         (return-from the-filter nil))
;;                                     (loop :for char :across (cadr x) :do
;;                                        (if (< 1 (length (subseq (bprint char) 2)))
;;                                            (return-from the-filter t)))
;;                                     nil))
;;                               result))
;;       (sort result #'(lambda (a b)
;;                        (< (car a) (car b))))
;;       (setf (getf vacancy :tags)
;;             (bprint result))
;;       ))
(in-package #:moto)

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
  ;; (format t "~%")
  ;; (format t (bprint vacancy))           ;
  (loop :for section-key :in vacancy by #'cddr  :do
     (format t "~%_______~%~A" (bprint (list section-key (getf vacancy section-key)))))
  ;; (format t "~%~A :~A: ~A [~A]"
  ;;      (getf vacancy :salary-text)
  ;;      (getf vacancy :currency)
  ;;      (getf vacancy :name)
  ;;      (getf vacancy :id))
  ;; (format t "~%~A" (getf vacancy :emp-name))
  ;; (format t "~A" (show-descr (getf vacancy :descr)))
  )

(define-rule (z-print t)
  (show-vacancy vacancy))
(in-package #:moto)

(in-package #:moto)

(defparameter *saved-vacancy* nil)

(defmethod save-vacancy (vac)
  (let* ((src-id    (.> getf vac -> :teaser :id))
         (old-vac   (car (find-vacancy :src-id src-id)))
         (*new-vac*
          (list
           :src-id      src-id
           :name        (.> getf vac -> :teaser :name)
           :currency    (aif (.> getf vac -> :teaser-compensation :currency) it "")
           :salary      (aif (.> getf vac -> :teaser-compensation :salary) it 0)
           :base-salary (aif (.> getf vac -> :teaser-compensation :salary) it 0)
           :salary-text (aif (.> getf vac -> :teaser-compensation :salary-text) it "")
           :salary-max  (aif (.> getf vac -> :teaser-compensation :salary-max) it 0)
           :salary-min  (aif (.> getf vac -> :teaser-compensation :salary-min) it 0)
           :emp-id      (aif (.> getf vac -> :teaser-emp :emp-id) it 0)
           :emp-name    (.> getf vac -> :teaser-emp :emp-name)
           :city        (trim (.> getf vac -> :vacancy-place :city))
           :metro       ""
           :experience  (.> getf vac -> :vacancy-exp :exp)
           :archive     (.> getf vac -> :teaser :archived)
           :date        (aif (.> getf vac -> :teaser :date) it "")
           :respond     ""
           :state       (if nil ":RESPONDED" ":UNSORT")
           :descr       (bprint (.> getf vac -> :vacancy-descr :long-descr))
           :notes       ""
           :tags        "" ;; (aif (getf vac :tags) it "")
           :response    ""

           :emptype     (aif (.> getf vac -> :vacancy-jobtype :emptype) it "")
           :workhours   (aif (.> getf vac -> :vacancy-jobtype :workhours) it "")
           :skills      (aif (.> getf vac -> :vacancy-skills :list-of-skilss) (bprint it) "")
           :datetime    (aif (.> getf vac -> :vacancy-date :datetime) it "")
           :date-text   (aif (.> getf vac -> :vacancy-date :datetext) it "")
           :responsibility (let ((resp (aif (.> getf vac -> :teaser-descr :responsibility) it "")))
                             (if (stringp resp) resp ""))
           :requirement (aif (.> getf vac -> :teaser-descr :requirement) it "")
           :addr        (aif (.> getf vac -> :addr :addr-with-map) it "")
           :street-addr (aif (.> getf vac -> :addr :street-addr) it "")

           )))
    (declare (special *new-vac*))
    (if (null old-vac)
        (progn
          (eval `(make-vacancy ,@*new-vac*)))
        ;; else
        (progn
          (upd-vacancy old-vac *new-vac*)))))

(define-rule (z-save t)
  (save-vacancy vacancy)
  :stop)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-teaser-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-TEASER-IF-"(symbol-name name))) ,antecedent)
     (dbg "drop-teaser-rule: [https://spb.hh.ru/vacancy/~A] ~A"
          (getf (getf vacancy :vacancy) :id)
          (getf (getf vacancy :vacancy) :name))
     ;; (dbg (bprint vacancy))
     ,@consequent
     (setf vacancy nil)
     :stop))

;; expand

;; (print
;;  (macroexpand-1
;;   '(define-drop-teaser-rule
;;     (hi-salary-java (and (> (getf (getf vacancy :compensation) :salary) 70000)
;;                      (not (contains "Java" (getf (getf vacancy :vacancy) :name)))))
;;     (print (getf vacancy :vacancy) :name)
;;     (print (getf (getf vacancy :compensation) :salary)))))

;; (DEFINE-RULE (DROP-TEASER-IF-HI-SALARY-JAVA
;;               (AND (> (GETF (GETF VACANCY :COMPENSATION) :SALARY) 70000)
;;                    (NOT
;;                     (CONTAINS "Java" (GETF (GETF VACANCY :VACANCY) :NAME)))))
;;   (DBG "drop teaser: ~A-~A (~A) ~A"
;;        (GETF (GETF VACANCY :COMPENSATION) :SALARY-MIN)
;;        (GETF (GETF VACANCY :COMPENSATION) :SALARY-MAX)
;;        (GETF (GETF VACANCY :COMPENSATION) :CURRENCY)
;;        (GETF (GETF VACANCY :VACANCY) :NAME))
;;   (PRINT (GETF VACANCY :VACANCY) :NAME)
;;   (PRINT (GETF (GETF VACANCY :COMPENSATION) :SALARY))
;;   (SETF VACANCY NIL)
;;   :STOP)
(in-package #:moto)

(defmacro define-drop-teaser-by-name-rule (str &body consequent)
  `(define-drop-teaser-rule (,(intern (concatenate 'string "NAME-CONTAINS-" (string-upcase (ppcre:regex-replace-all "\\s+" str "-"))))
                              (contains (getf (getf vacancy :vacancy) :name) ,str))
     (dbg "  - name contains \"~A\"" ,str)
     ,@consequent))

;; expand

;; (print
;;  (macroexpand-1
;;   '(define-drop-teaser-by-name-rule "Android")))

;; (DEFINE-DROP-TEASER-RULE (NAME-CONTAINS-ANDROID
;;                           (CONTAINS (GETF (GETF VACANCY :VACANCY) :NAME)
;;                                     "Android"))
;;   (DBG "  - name contains \"~A\"" "Android"))

;; test

;; (define-drop-teaser-by-name-rule "Android")

;; (#<FUNCTION (LABELS DROP-TEASER-IF-NAME-CONTAINS-ANDROID-ANTECEDENT-G2507)
;;             {100455A44B}>
;;             #<FUNCTION (LABELS DROP-TEASER-IF-NAME-CONTAINS-ANDROID-CONSEQUENT-G2508)
;;             {10045E5C4B}>
;;             #<RULE {10045FE523}>)
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

;; (define-drop-teaser-rule
;;     (salary-1-no (null (getf vacancy :compensation)))
;;   (dbg "- no salary"))

;; (define-drop-teaser-rule (salary-2-low (or
;;                                         (and (equal (getf vacancy :currency) "RUR")
;;                                              (< (getf vacancy :salary-max) 90000))
;;                                         (and (equal (getf vacancy :currency) "USD")
;;                                              (< (getf vacancy :salary-max) (floor 90000 58)))
;;                                         (and (equal (getf vacancy :currency) "EUR")
;;                                              (< (getf vacancy :salary-max) (floor 90000 61)))
;;                                         ))
;;   (dbg "- low salary"))

;; (define-drop-teaser-rule (iOS (contains-in-words (string-downcase (getf vacancy :name)) "ios"))
;;   (dbg "  - name contains iOS"))

;; (define-drop-teaser-rule (FrontEnd (contains-in-words (string-downcase (getf vacancy :name)) "front"))
;;   (dbg "  - name contains FrontEnd"))

;; (define-drop-teaser-rule (Manager (contains-in-words (string-downcase (getf vacancy :name)) "менеджер"))
;;   (dbg "  - name contains менеджер"))

;; (define-drop-teaser-rule (Saler (contains-in-words (string-downcase (getf vacancy :name)) "продаж"))
;;   (dbg "  - name contains продаж"))

;; (define-drop-teaser-rule (DotNet (contains-in-words (string-downcase (getf vacancy :name)) ".net"))
;;   (dbg "  - name contains .net"))


;; (define-drop-all-teaser-when-name-contains-rule
;;     "Python" "Django"
;;     "1C" "1С"
;;     "C++" "С++"
;;     "Ruby" "Ruby on Rails"
;;     "Go"
;;     "Q/A" "QA"
;;     "Unity" "Unity3D"
;;     "Flash"
;;     "Java"
;;     "Android"
;;     "ASP"
;;     "Objective-C"
;;     "Delphi"
;;     "Sharepoint"
;;     "PL/SQL"
;;     "Oracle"
;;     "Node"
;;     "тестировщик"
;;     "Системный администратор"
;;     "Трафик-менеджер"
;;     "Traffic" "Трафик"
;;     "Медиабайер" "Media Buyer" "Медиабаер"
;;     "SAP"
;;     "маркетолог"
;;     "SMM"
;;     "DevOps"
;;     "Axapta"
;;     "designer"
;;     "Дизайнер"
;;     "Designer"
;;     "UX"
;;     "по ремонту"
;;     "Помощник"
;;     "Верстальщик"
;;     "Smolensk" "Львов")

;; (mapcar #'(lambda (x)
;;             (del-vacancy (id x)))
;;         (find-vacancy :state ":UNSORT"))

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

(defmethod process-teaser :around (current-teaser src-account referer)
  (dbg ":process-teaser :around:")
  (aif (process current-teaser (rules-for-teaser))
       (process (call-next-method it) (rules-for-vacancy))
       nil))

(in-package #:moto)

(in-package #:moto)



(defun make-hh-url (city prof-area &optional specs)
  "https://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&items_on_page=100&no_magic=true&page=~A")

;; test
;; (make-hh-url "spb" "Информационные технологии, интернет, телеком" "Программирование, Разработка")

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)

(defparameter *hh_account* (make-srcaccount :user_id 1
                                            :src_source "hh"
                                            :src_login "avenger-f@yandex.ru"
                                            :src_password "jGwPswRAfU6sKEhVXX"
                                            :src_fio "Михаил Михайлович Глухов"
                                            :state ":ACTIVE"))

(defparameter *user-agent* "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:35.0) Gecko/20100101 Firefox/35.0")

(defparameter *additional-headers* `(("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                                     ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
                                     ("Accept-Charset" . "utf-8")))

(defparameter *cookies* nil)  ;; deprecated, use cookie-jar in closure

(defun is-logged (html)
  "Проверяем наличие в html блока 'Войти'"
  (let ((res (not (contains html "data-qa=\"mainmenu_loginForm\">Войти</div>"))))
    (dbg ":is-logged: ~A" res)
    res))

(defun get-cookies-alist (cookie-jar)
  "Получаем alist с печеньками из cookie-jar"
  (loop :for cookie :in (drakma:cookie-jar-cookies cookie-jar) :append
     (list (cons (drakma:cookie-name cookie) (drakma:cookie-value cookie)))))

(defun recovery-login (src-account)
  ;; Сначала заходим на главную как будто первый раз, без печенек
  (setf drakma:*header-stream* nil)
  (let* ((start-uri "https://spb.hh.ru/")
         (cookie-jar (make-instance 'drakma:cookie-jar))
         (additional-headers *additional-headers*)
         (response (drakma:http-request start-uri
                                        :user-agent *user-agent*
                                        :additional-headers additional-headers
                                        :force-binary t
                                        :cookie-jar cookie-jar
                                        :redirect 10
                                        ))
         ;; (tree ;; (html5-parser:node-to-xmls ;; !=!
         ;;        (html5-parser:parse-html5-fragment
         ;;         (flexi-streams:octets-to-string response :external-format :utf-8)
         ;;         :dom :xmls
         ;;         ;; )
         ;;         ))
         )
    ;; Теперь попробуем использовать печеньки для логина
    ;; GMT=3 ;; _xsrf=  ;; hhrole=anonymous ;; hhtoken= ;; hhuid= ;; regions=2 ;; unique_banner_user=
    ;; И заходим с вот-таким гет-запросом:
    ;; username=avenger-f@ya.ru ;; password=jGwPswRAfU6sKEhVXX ;; backurl=https://spb.hh.ru/ ;; remember=yes ;; action="Войти" ;; _xsrf=
    ;; (setf drakma:*header-stream* *standard-output*)
    (let* ((post-parameters `(("username" . ,(src_login src-account))
                              ("password" . ,(src_password src-account))
                              ("backUrl"  . "https://spb.hh.ru/")
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
                                            :force-binary t
                                            :redirect 10))
           (html (flexi-streams:octets-to-string response-2 :external-format :utf-8)))
      (when (contains html "Неправильные имя и/или пароль - попробуйте, пожалуйста, снова.")
        (err "login failed"))
      (when (contains html "Что-то пошло не так")
        (err "login error"))
      (when (contains html (src_fio src-account))
        (return-from recovery-login
          (values ;; (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment html))
                  html
                  cookie-jar-2)))
      (err "login exception"))))

(define-condition hh-404-error (error)
  ((url  :initarg :url :reader url)
   (text :initarg :text :reader text)))

(defparameter *need-start* t)

(defun hh-get-page (url cookie-jar src-account referer)
  "Получение страницы"
  ;; Если ни одного запроса еще не было - сделаем запрос к главной и снимем флаг
  (when *need-start*
    (drakma:http-request "https://spb.hh.ru/" :user-agent *user-agent* :redirect 10
                         :force-binary t     :cookie-jar cookie-jar)
    (setf referer "https://spb.hh.ru/")
    (setf *need-start* nil))
  ;; Делаем основной запрос, по урлу из параметров, сохраняя результат в response
  ;; и обновляя cookie-jar
  (let ((response   "")
        (repeat-cnt 0))
    (tagbody repeat
       (multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
           (drakma:http-request
            url :user-agent *user-agent* :force-binary t :cookie-jar cookie-jar :redirect 10
            :additional-headers (append *additional-headers*
                                        `(("Referer" . ,referer))))
         (dbg ":hh-get-page: ~A : ~A" status-code url)
         (when (equal 404 status-code)
           (error 'hh-404-error :url url :text (flexi-streams:octets-to-string body-or-stream :external-format :utf-8)))
         (setf response (flexi-streams:octets-to-string body-or-stream :external-format :utf-8)))
       ;; Если мы не залогинены:
       (unless (is-logged response)
         ;; Проверяем, не превышено ли кол-во попыток восстановления
         (when (> repeat-cnt 3)
           ;; Если их больше трех - сигнализируем ошибку
           (err "max recovery-login try"))
         ;; Пытаемся восстановить сессию
         (multiple-value-bind (recovery-html recovery-cookie-jar)
             (recovery-login src-account)
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

;; (hh-get-page "https://spb.hh.ru/applicant/negotiations?wed=1"
;;              (make-instance 'drakma:cookie-jar)
;;              "https://spb.hh.ru/")

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

(defun html-to-tree (html)
  ;; (html5-parser:node-to-xmls
  (html5-parser:parse-html5-fragment html :dom :xmls))

(defun tree-to-html (tree &optional (step 0))
  (macrolet ((indent () `(make-string (* 3 step) :initial-element #\Space)))
    (labels ((paired (subtree)
               (format nil "~A<~A~A>~%~A~4:*~A</~A>~%"
                       (indent)
                       (car subtree)
                       (format nil "~:[~; ~1:*~{~A~^ ~}~]"
                               (mapcar #'(lambda (attr)
                                           (let ((key (car attr))
                                                 (val (cadr attr)))
                                             (format nil "~A=\"~A\"" key val)))
                                       (cadr subtree)))
                       (format nil "~{~A~}"
                               (progn
                                 (incf step)
                                 (let ((ret (mapcar #'(lambda (x)
                                                        (subtree-to-html x step))
                                                    (cddr subtree))))
                                   (decf step)
                                   ret)))))
             (singled (subtree)
               (format nil "~A<~A~A />~%"
                       (indent)
                       (car subtree)
                       (format nil "~:[~; ~1:*~{~A~^ ~}~]"
                               (mapcar #'(lambda (attr)
                                           (let ((key (car attr))
                                                 (val (cadr attr)))
                                             (format nil "~A=\"~A\"" key val)))
                                       (cadr subtree)))))
             (subtree-to-html (subtree &optional (step 0))
               (cond ((stringp subtree) (format nil "~A~A~%" (indent) subtree))
                     ((numberp subtree) (format nil "~A~A~%" (indent) subtree))
                     ((listp   subtree)
                      (let ((tag (car subtree)))
                        (cond ((or (equal tag "img")
                                   (equal tag "link")
                                   (equal tag "meta"))  (singled subtree))
                              (t (paired subtree)))))
                     (t (format nil "[:err:~A]" subtree)))))
      (reduce #'(lambda (a b) (concatenate 'string a b))
              (mapcar #'(lambda (x) (subtree-to-html x step))
                      tree)))))

;; (print (tree-to-html '(("fragment" (("b" "1") ("c" "2"))
;;                         ("link" (("rel" "stylesheet") ("href" "/css/bootstrap.min.css")))
;;                         ("section" ()
;;                          ("h3" () "Как проектируюттся IP-блоки и системы на кристалле")
;;                          ("p"  () "Юрий Панчул прочитал эту лекцию в Алма-Ате, а пока доступно"
;;                                ("a" (("href" "https://www.youtube.com/watch?v=sPaMiEunT_M"))
;;                                     "видео")
;;                                ", а также его"
;;                                ("a" (("href" "https://habrahabr.ru/post/309570/"))
;;                                     "отчетный пост")
;;                                "на хабре."))))))

;; =>
;; "<fragment b=\"1\" c=\"2\">
;;    <link rel=\"stylesheet\" href=\"/css/bootstrap.min.css\" />
;;    <section>
;;       <h3>
;;          Как проектируюттся IP-блоки и системы на кристалле
;;       </h3>
;;       <p>
;;          Юрий Панчул прочитал эту лекцию в Алма-Ате, а пока доступно
;;          <a href=\"https://www.youtube.com/watch?v=sPaMiEunT_M\">
;;             видео
;;          </a>
;;          , а также его
;;          <a href=\"https://habrahabr.ru/post/309570/\">
;;             отчетный пост
;;          </a>
;;          на хабре.
;;       </p>
;;    </section>
;; </fragment>
;; "

(in-package #:moto)

(defun extract-search-results (tree)
  (block subtree-extract
    (mtm (`("div"
            (("data-qa" "vacancy-serp__results"))
            ,@rest)
           (return-from subtree-extract rest))
         tree)))

(in-package #:moto)

(defun attrs-to-plist (attrs)
  (mapcan #'(lambda (x)
              (list (intern (string-upcase (car x)) :keyword) (cadr x)))
          attrs))

;; (attrs-to-plist '(("href" "/employer/3127") ("class" "bloko-link bloko-link_secondary")
;;                   ("data-qa" "vacancy-serp__vacancy-employer")))
;; => (:HREF "/employer/3127" :CLASS "bloko-link bloko-link_secondary" :DATA-QA
;;           "vacancy-serp__vacancy-employer")

(defun plist-to-attrs (attrs)
  (loop :for attr :in attrs :by #'cddr :collect
     (list (string-downcase (symbol-name attr)) (getf attrs attr))))

;; (plist-to-attrs '(:HREF "/employer/3127" :CLASS "bloko-link bloko-link_secondary" :DATA-QA
;;                   "vacancy-serp__vacancy-employer"))
;; => (("href" "/employer/3127") ("class" "bloko-link bloko-link_secondary")
;;         ("data-qa" "vacancy-serp__vacancy-employer"))

(defun maptreefilter (tree)
  (when (listp tree)
    (when (and (listp (car tree)) (equal '("target" "_blank") (car tree)))
      (setf tree (cdr tree)))
    (when (and (listp (car tree)) (equal "script" (caar tree)))
      (setf tree (cdr tree)))
    (when (and (listp (car tree)) ;; fix error if car is not list
               (or (equal "div" (caar tree))
                   (equal "span" (caar tree))
                   (equal "a" (caar tree))
                   (equal "td" (caar tree))
                   (equal "th" (caar tree))
                   (equal "table" (caar tree))
                   ))
      (let ((attrs (attrs-to-plist (cadar tree)))
            (rest  (cddar tree))
            (name   nil))
        ;; data-qa is primary target for new name
        (aif (getf attrs :data-qa)
             (progn
               (setf name it))
             ;; else: class is secondary target for new name
             (aif (getf attrs :class)
                  (progn
                    (setf name it))))
        (when name
          (if (or (equal name "search-result-description__item")
                  (equal name "search-result-item__control"))
              ;; Убиваем ненужное, если оно есть
              (setf (car tree) name)
              ;; else
              (progn
                (remf attrs :data-qa)
                (remf attrs :class)
                (setf (caar tree) name) ;; new name
                (setf (cadar tree) (plist-to-attrs attrs)) ;; new attrs
                ))))))
  (cond
    ((null tree) nil)
    ((atom tree) tree)
    (t (cons (maptreefilter (car tree))
             (maptreefilter (cdr tree))))))

(in-package #:moto)

(defmacro make-detect ((name) &body body)
  (let ((param   (gensym)))
    `(defun ,(intern (format nil "DETECT-~A" (string-upcase (symbol-name name)))) (,param)
       (mtm ,@body
            ,param))))

(in-package #:moto)

(make-detect (responder)
  (`("vacancy-serp__vacancy_responded"
     (("href" ,_)) "Вы откликнулись")
    `(:teaser (:status "responded"))))

(make-detect (respond-topic)
  (`("g-attention m-attention_good b-vacancy-message"
     NIL
     "Вы уже откликались на эту вакансию. "
     ("a" (("href" ,topic))
          "Посмотреть отклики."))
    `(:respond (:respond-topic ,topic))))

(make-detect (rejecter)
  (`("vacancy-serp__vacancy_rejected"
     (("href" "/negotiations/gotopic?vacancy_id=20255184")) "Вам отказали")
    `(:teaser (:status "rejected"))))

(make-detect (title)
  (`("search-result-item__head"
     NIL
     ("vacancy-serp__vacancy-title"
      (("href" ,href) ,@rest)
      ,title))
    `(:teaser (:id ,(parse-integer (car (last (split-sequence:split-sequence #\/ href))))
                    :href ,href
                    :name ,title
                    :archived nil))))

(make-detect (or-title-archived)
  (`("search-result-item__head"
     NIL
     ("vacancy-serp__vacancy-title"
      (("href" ,href) ,@rest)
      ,title)
     " ("
     ("strong" (("data-qa" "vacancy-serp__vacancy_archived"))
               "Вакансия была перенесена в архив")
     ")")
    `(:teaser (:id ,(parse-integer (car (last (split-sequence:split-sequence #\/ href))))
                    :href ,href
                    :name ,title
                    :archived t))))

(make-detect (schedule)
  (`("vacancy-serp__vacancy-work-schedule"
     NIL ,schedule)
    `(:teaser-conditions (:schedule schedule))))

(make-detect (responsibility)
  (`("vacancy-serp__vacancy_snippet_responsibility"
     NIL
     ,responsibility)
    `(:teaser-descr (:responsibility ,responsibility))))

(make-detect (requirement)
  (`("vacancy-serp__vacancy_snippet_requirement"
     NIL
     ,requirement)
    `(:teaser-descr (:requirement ,requirement))))

(make-detect (insider-teaser)
  (`("vacancy-serp__vacancy-interview-insider"
     (("href" ,insider))
     "Посмотреть интервью о жизни в компании")
    `(:teaser-descr (:insider ,insider))))

(make-detect (company)
  (`("search-result-item__company"
     NIL
     ("vacancy-serp__vacancy-employer"
      (("href" ,href))
      ,emp-name)
     ,@rest)
    `(:teaser-emp
      (:emp-name ,emp-name
       :href ,href
       :emp-id ,(parse-integer
                 (car (last (split-sequence:split-sequence #\/ href))) :junk-allowed t)))))

(make-detect (company-anon)
  (`("search-result-item__company"
     NIL
     ,anon
     ,@rest)
    `(:teaser-emp (:emp-name ,anon :anon t))))

(make-detect (addr)
  (`("search-result-item__info"
     NIL
     ("vacancy-serp__vacancy-address" NIL ,address ,@restaddr) "  •  "
     ("vacancy-serp__vacancy-date" NIL ,date)
     ,@rest)
    `(:teaser-emp (:addr ,address)
      :teaser (:date ,date))))

(make-detect (compensation)
  (`("vacancy-serp__vacancy-compensation"
     NIL
     ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
     ("meta" (("itemprop" "baseSalary") ("content" ,salary)))
     ,salary-text)
    (let ((currency currency)
          (salary-text (ppcre:regex-replace-all " " salary-text ""))
          (salary-min nil)
          (salary-max nil))
      (cond ((equal currency "RUR")
             (setf salary-text (ppcre:regex-replace-all " руб." salary-text "")))
            ((equal currency "USD")
             (setf salary-text (ppcre:regex-replace-all " USD" salary-text "")))
            ((equal currency "EUR")
             (setf salary-text (ppcre:regex-replace-all " EUR" salary-text "")))
            ((equal currency "UAH")
             (setf salary-text (ppcre:regex-replace-all " грн." salary-text "")))
            ((equal currency nil)
             'nil)
            (t (progn
                 (print currency)
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
      `(:teaser-compensation (:currency ,currency
                                        :salary ,(parse-integer salary)
                                        :salary-text ,salary-text
                                        :salary-min ,salary-min
                                        :salary-max ,salary-max)))))

(make-detect (teaser-finalizer)
  (`(,_
     NIL
     ,_
     ("search-result-description"
      NIL
      "search-result-description__item"
      ("search-result-description__item search-result-description__item_primary"
       NIL
       ,@contents)
      ,@rest))
    contents))

(in-package #:moto)

(defun plistp (param)
  "Test wheather PARAM is a properly formed pparam."
  (when (listp param)
    (loop :for rest :on param :by #'cddr
       :unless (and (keywordp (car rest))
                    (cdr rest))
       :do (return nil)
       :finally (return param))))

(in-package #:moto)

(defun my-merge-plists (p1 p2)
  (loop with notfound = '#:notfound
     for (indicator value) on p1 by #'cddr
     when (eq (getf p2 indicator notfound) notfound)
     do (progn
          (push value p2)
          (push indicator p2)))
  p2)

(in-package #:moto)

(defun tree-plist-p (pl)
  "Returns T if PL is a plist (list with alternating keyword elements). "
  (cond ((null pl)                 t)
        ((and (listp pl)
              (keywordp (car pl))
              (cdr pl))            (tree-plist-p (cddr pl)))
        ((and (listp pl)
              (listp (car pl)))    (and (tree-plist-p (car pl))
                                        (tree-plist-p (cdr pl))))
        (t                         (progn
                                     ;; (print pl)
                                     nil))))

(in-package #:moto)

(defun compactor (param)
  (let ((ht  (make-hash-table :test #'equal))
        (result-vacancy))
    (mapcar #'(lambda (section)
                (assert (equal (logand (length section) 1) 0)) ;; even length
                (loop :for key :in section :by #'cddr :do
                   (assert (equal (type-of key) 'keyword))
                   (let ((new-val (getf section key)))
                     (assert (plistp new-val))
                     (multiple-value-bind (old-val present)
                         (gethash key ht)
                       (setf (gethash key ht)
                             (if (not present)
                                 new-val
                                 (my-merge-plists old-val new-val)))))))
            param)
    (maphash #'(lambda (k v) (push (list k v) result-vacancy)) ht)
    (mapcan #'identity (reverse result-vacancy))))

(define-condition malformed-vacancy (error)
  ((text :initarg :text :reader text)))

(defparameter *last-parse-data* nil)

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (dbg ":hh-parse-vacancy-teasers:")
  (setf *last-parse-data* html)
  (->> (html-to-tree html)
       (extract-search-results)
       (maptreefilter)
       (detect-responder)
       (detect-rejecter)
       (detect-title)
       (detect-or-title-archived)
       (detect-schedule)
       (detect-responsibility)
       (detect-requirement)
       (detect-insider-teaser)
       (detect-company)
       (detect-company-anon)
       (detect-addr)
       (detect-compensation)
       (detect-teaser-finalizer)
       (mapcar #'(lambda (vacancy)
                   (if (not (tree-plist-p vacancy))
                       (progn
                         (dbg "[~A]" (bprint vacancy))
                         ;; error if malformed plist
                         (error 'malformed-vacancy :text))
                       ;; else
                       (compactor vacancy)
                       ;; vacancy
                       )))
       ))

;; (print (hh-parse-vacancy-teasers *last-parse-data*))

;; (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (hh-parse-vacancy-teasers
;;    (hh-get-page "https://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true" temp-cookie-jar "https://spb.hh.ru/")))


;; (mapcar #'(lambda (x)
;;             (del-vacancy (id x)))
;;         (find-vacancy :state ":UNINTERESTING"))

(in-package #:moto)

(in-package #:moto)

(defun extract-vacancy (tree)
  (block subtree-extract
    (mtm (`("div" (("class" "nopaddings") ("itemscope" "itemscope")
                   ("itemtype" "http://schema.org/JobPosting"))
                  ,@rest)
           (return-from subtree-extract rest))
         tree)))

(in-package #:moto)

(defun transform-description (tree-descr)
  (labels ((rem-space (tree)
             (cond ((consp tree) (cons (rem-space (car tree))
                                       (rem-space (remove-if #'(lambda (x) (equal x " "))
                                                             (cdr tree)))))
                   (t tree))))
    (append `((:p))
            (mtm (`("p" nil ,@in) `((:p) ,@in))
                 (mtm (`("ul" nil ,@in) `((:ul) ,@in))
                      (mtm (`("li" nil ,@in) `((:li) ,@in))
                           (mtm (`("em" nil ,@in) `((:b) ,@in))
                                (mtm (`("strong" nil ,@in) `((:b) ,@in))
                                     (mtm (`("br") `((:br)))
                                          (rem-space tree-descr))))))))))

(in-package #:moto)

(make-detect (script)
  (`("script" (("data-name" ,name) ("data-params" ,params)))
    `(:empty (:script ,name :params ,params))))

(make-detect (insider-vacancy)
  (`("bloko-gap bloko-gap_left"
     (("xmlns:b" "http://hhru.github.com/bloko/"))
     ("b-insider-interview"
      NIL
      ("a" (("href" ,insider-href))
           "Посмотреть интервью о жизни в компании")))
    `(:empty (:insider ,insider-href))))

(make-detect (branded)
  (`("vacancy-branded" NIL ,@data)
    `(:branded ,(block subtree-extract
                       (mtm (`("l-paddings b-vacancy-desc g-user-content" NIL ,payload)
                              (return-from subtree-extract payload))
                            data)))))

(make-detect (branded2)
  (`("branded-vacancy"
     NIL
     ,content
     ,@_)
    `(:branded-vacancy ,content)))

(make-detect (gap)
  (`("bloko-gap bloko-gap_bottom bloko-gap_left" NIL ,@_)
    `(:empty (:gap "controls"))))

(make-detect (vacancy-custom)
  (`("b-vacancy-custom g-round"
     NIL
     ("meta" (("itemprop" "title") ("content" ,_)))
     ("h1" (("class" "title b-vacancy-title")) ,title)
     ,@emp)
    `(:vacancy (:title ,title) :emp ,emp)))

(make-detect (l)
  (`("l"
     NIL
     ("tbody"
      NIL ("tr"
           NIL
           ("l-cell"
            (("colspan" "2"))
            ,@l)
           ("l-cell" ,@_))))
    `(:l ,l)))

(make-detect (emp)
  (`("employer-marks g-clearfix"
     NIL
     ("companyname" NIL
                    ("a" (("itemprop" "hiringOrganization") ("href" ,emp-href)) ,emp-name)
                    ,@_))
    `(:emp-name ,emp-name :emp-href ,emp-href)))

(make-detect (emp-anon)
  (`("employer-marks g-clearfix"
     NIL
     ("companyname" NIL
                    ,emp-name
                    ("bloko-link"
                     (("href" ,emp-href))
                     ,@_)))
    `(:emp-name ,emp-name :emp-href ,emp-href)))

(make-detect (vacancy-info)
  (`("b-vacancy-info"
     NIL
     ("l-content-3colums"
      NIL
      ("tbody"
       NIL
       ("tr"
        NIL
        ("l-content-colum-1 b-v-info-title" NIL ("l-paddings" NIL "Уровень зарплаты"))
        ("l-content-colum-2 b-v-info-title" NIL ("l-paddings" NIL "Город"))
        ("l-content-colum-3 b-v-info-title" NIL ("l-paddings" NIL "Требуемый опыт работы")))
       ,info
       )))
    `(:vac-info ,info)))

(make-detect (vac-info-tr)
  (`("tr"
     NIL
     ("l-content-colum-1 b-v-info-content"
      NIL
      ("l-paddings"
       NIL
       ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
       ("meta" (("itemprop" "baseSalary") ("content" ,base-salary)))
       ,salary-text))
     ("l-content-colum-2 b-v-info-content"
      NIL
      ("l-paddings" NIL ,city ,@metro))
     ("l-content-colum-3 b-v-info-content"
      NIL
      ("l-paddings" (("itemprop" "experienceRequirements")) ,exp)))
    `(:vacancy-compensation (:currency ,currency :base-salary ,base-salary :salary-text ,salary-text)
                            :vacancy-place (:city ,city)
                            :vacancy-exp (:exp ,exp)
                            :vacancy-place (:metro ,(mapcar #'(lambda (x) (car (last x)))
                                                            (remove-if-not #'listp metro))))))

(make-detect (or-vac-info-tr-no-salary)
  (`("tr"
     NIL
     ("l-content-colum-1 b-v-info-content"
      NIL
      ("l-paddings" NIL " з/п не указана"))
     ("l-content-colum-2 b-v-info-content" NIL ("l-paddings" NIL ,city ,@metro))
     ("l-content-colum-3 b-v-info-content"
      NIL
      ("l-paddings" (("itemprop" "experienceRequirements")) ,exp)))
    `(:vacancy-place (:city ,city)
                     :vacancy-exp (:exp ,exp)
                     :vacancy-place (:metro ,(mapcar #'(lambda (x) (car (last x)))
                                       (remove-if-not #'listp metro))))))

(make-detect (container)
  (`("l-content-2colums b-vacancy-container"
     NIL
     ("tbody"
      NIL
      ("tr"
       NIL
       ,col-1
       ,col-2)))
    `(:cols (:col-1 ,col-1 :col-2 ,col-2))))

(make-detect (col-1)
  (`("l-content-colum-1"
     (("colspan" "2"))
     ,hypercontext
     ,_) ;; response-block
    `(:hypercontext ,hypercontext)))

(make-detect (hypercontext)
  (`("div"
     (("id" "hypercontext"))
     ("index" NIL ,@rest))
    `(:hype ,rest)))

(make-detect (descr-outer-block)
  (`("bloko-gap bloko-gap_bottom"
     NIL
     ("l-paddings b-vacancy-desc g-user-content"
      NIL
      ,descr))
    `(:vacancy-descr ,descr)))

(make-detect (longdescr)
  (`("b-vacancy-desc-wrapper"
     (("itemprop" "description"))
     ,@descr)
    `(:long-descr ,(transform-description descr))))

(make-detect (vacancy-address)
  (`(,(or "span" "b-vacancy-address l-paddings")
      (("itemprop" "jobLocation") ("itemscope" "itemscope")
       ("itemtype" "http://schema.org/Place"))
      ("meta" (("itemprop" "name") ("content" ,_)))
      ("h3" (("class" "b-subtitle")) "Адрес")
      ("b-employer-office-address"
       (("itemprop" "address") ("itemscope" "itemscope")
        ("itemtype" "http://schema.org/PostalAddress"))
       ("meta"
        (("itemprop" "streetAddress") ("content" ,street-addr)))
       ("div" NIL
              ("vacancy-address-with-map" NIL ,addr-with-map)
              ,@_)))
    `(:addr (:street-addr ,street-addr :addr-with-map ,addr-with-map))))

(make-detect (jobtype)
  (`("b-vacancy-employmentmode l-paddings"
     NIL
     ("h3" (("class" "b-subtitle")) "Тип занятости")
     ("l-content-paddings"
      NIL
      ("span" (("itemprop" "employmentType")) ,emptype) ", "
      ("span" (("itemprop" "workHours")) ,workhours)))
    `(:vacancy-jobtype (:emptype ,emptype :workhours ,workhours))))

(make-detect (closed-contacts)
  (`("l-paddings"
     NIL
     ("noindex"
      NIL
      ("vacancy-contacts vacancy-contacts_closed"
       NIL
       (:EMPTY ,_)
       (:EMPTY ,_)
       ("h3" (("id" "expand-vacancy-contacts"))
             ("show-employer-contacts" (("data-toggle" ""))
                                       ("bloko-link-switch" NIL "Показать контактную информацию"))
             ("vacancy-contacts__title-opened" NIL "Контактная информация"))
       ,contacts)))
    `(:closed ,contacts)))

(make-detect (contacts-body)
  (`("vacancy-contacts__body"
     NIL
     ("l-content-paddings" NIL ,@rest))
    `(:contacts ,@rest)))

(make-detect (contacts-fio)
  (`("vacancy-contacts__fio" NIL ,fio)
    `(:fio ,fio)))

(make-detect (contacts-list)
  (`("vacancy-contacts__list"
     NIL
     ("tbody" NIL ,@rest))
    `(:contacts-list ,rest)))

(make-detect (contacts-tr)
  (`("tr" NIL
          ("vacancy-contacts__list-title" NIL ,_)
          ("td" NIL ,@contacts-data))
    `(:contacts-tr ,contacts-data)))

(make-detect (contacts-phone)
  (`("vacancy-contacts__phone" NIL ,phone ("vacancy-contacts__comment" NIL ,phone-comment))
    `(:phone ,phone :phone-comment ,phone-comment)))

(make-detect (contacts-mail)
  (`("vacancy-contacts__email" (("href" ,mail-link) ("rel" "nofollow")) ,email)
    `(:mail-link ,mail-link :email ,email)))

(make-detect (contacts-tr)
  (`("tr" NIL
          ("vacancy-contacts__list-title" NIL ,_)
          ("td" NIL ,contacts-data))
    `(:contacts-tr ,contacts-data)))

(make-detect (contacts-list)
  (`("vacancy-contacts__list"
     NIL
     ("tbody" NIL ,@rest))
    `(:contacts-list ,rest)))

(make-detect (closed-contacts)
  (`("l-paddings"
     NIL
     ("noindex"
      NIL
      ("vacancy-contacts vacancy-contacts_closed"
       NIL
       (:EMPTY ,_)
       (:EMPTY ,_)
       ("h3" (("id" "expand-vacancy-contacts"))
             ("show-employer-contacts" (("data-toggle" ""))
                                       ("bloko-link-switch" NIL "Показать контактную информацию"))
             ("vacancy-contacts__title-opened" NIL "Контактная информация"))
       ,contacts)))
    contacts))

(make-detect (logo)
  (`("b-vacancy-companylogo"
     NIL
     ("a" (("href" ,logo-href))
          ("img" (("src" ,logo-img) ("border" "0") ("alt" ,logo-alt)))))
    `(:logo-href ,logo-href
                 :logo-img ,logo-img
                 :logo-alt ,logo-alt)))

(make-detect (date)
  (`("l-content-paddings"
     NIL
     ("vacancy-sidebar"
      NIL
      "Дата публикации вакансии "
      ("time"
       (("class" "vacancy-sidebar__publication-date")
        ("itemprop" "datePosted")
        ("datetime" ,datetime))
       ,date-text))
     ,@_)
    `(:datetime ,datetime :date-text ,date-text :disabled nil)))

(make-detect (or-date-with-disabled)
  (`("l-content-paddings"
     NIL
     ("vacancy-sidebar"
      NIL
      "Дата публикации вакансии "
      ("time"
       (("class" "vacancy-sidebar__publication-date")
        ("itemprop" "datePosted")
        ("datetime" ,datetime))
       ,date-text))
     ("vacancy__print-info vacancy__print-info_noscreen"
      NIL
      "Вакансия доступна для соискателей с инвалидностью"))
    `(:datetime ,datetime :date-text ,date-text :disabled t)))


(make-detect (response-block)
  (`("vacancy-response-block HH-VacancyResponsePopup-ResponseBlock" NIL ,@_)
    `(:response-block "empty")))

(make-detect (vacancy-view-banners)
  (`("vacancy-view-banners" NIL ,@_)
    `(:empty (:vacancy-view-banners "empty"))))

(make-detect (column-2)
  (`("l-content-colum-2" NIL ,logo ,date ,@_)
    `(:column-2 (:vacancy-logo ,logo :vacancy-date ,date))))

(make-detect (meta)
  (`("meta" (("itemprop" ,prop) ("content" ,content)))
    `(:meta (,(intern (string-upcase prop) :keyword) ,content))))

(make-detect (skill-element)
  (`("skills-element"
     (("data-tag-id" ,tag))
     ("bloko-tag__section bloko-tag__section_text"
      (("title" ,title))
      ("bloko-tag__text" NIL ,tagtext)))
    `(:skill (:tag ,tag :title ,title :tagtext ,tagtext))))

(make-detect (skills)
  (`("l-paddings" NIL ("h3" (("class" "b-subtitle")) "Ключевые навыки") ,@rest)
    `(:vacancy-skills (:list-of-skilss ,(mapcar #'cadadr rest)))))

(make-detect (joblocation)
  (`("span"
     (("itemprop" "jobLocation") ("itemscope" "itemscope")
      ("itemtype" "http://schema.org/Place"))
     ("meta" (("itemprop" "name") ("content" ,name)))
     ("span"
      (("itemprop" "address") ("itemscope" "itemscope")
       ("itemtype" "http://schema.org/PostalAddress"))
      ("meta" (("itemprop" "addressLocality") ("content" ,addresslocality)))))
    `(:vacancy-address (:location ,name :addresslocality ,addresslocality))))

(make-detect (handicap)
  (`("vacancy__info vacancy__info_handicapped vacancy__info_noprint"
     NIL
     ("bloko-link-switch bloko-link-switch_inherited" (("data-toggle" "")) ,handicap)
     ("vacancy__info-expandable"
      NIL
      ("vacancy-info-tip" NIL"Это означает готовность компании рассматривать соискателей на равных на основании деловых качеств. Соискатель оценивает самостоятельно, насколько требования вакансии сопоставимы с его индивидуальными особенностями.")))
    `(:vacancy-handicap (:msg ,handicap))))


(make-detect (compact-l)
  (`(:VACANCY (:TITLE ,title) :EMP ((:L ((:EMP-NAME ,emp-name :EMP-HREF ,emp-href)))))
    `(:vacancy (:title ,title) :vacancy-emp (:EMP-NAME ,emp-name :EMP-HREF ,emp-href))))

(make-detect (compact-info)
  (`(:VAC-INFO ,info)
    `(,@info)))

(make-detect (compact-contacts)
  (`(:CONTACTS (:FIO ,fio) (:CONTACTS-LIST ,contacts-trs))
    `(:vacancy-contacts (:trs ,(append `((:CONTACTS-TR
                                  ((:FIO ,fio)))) contacts-trs)))))

(make-detect (columns)
  (`(:COLS
     (:COL-1
      (:HYPERCONTEXT
       (:HYPE
        (,@rest-1)))
      :COL-2
      (:COLUMN-2
       ,col-2)))
    `(:infoblock-1 ,rest-1 :infoblock-2 ,col-2)))

(make-detect (branded-hype)
  (`(:BRANDED-VACANCY
     (:HYPE
      ((:BRANDED
        ,descr)
       ,@rest)))
    (mapcan #'identity (append `((:vacancy-descr ,descr)) rest))))

(make-detect (compact-infoblock)
  (`(:INFOBLOCK-1 ,infoblock-1 :INFOBLOCK-2 ,infoblock-2)
    (mapcan #'identity (append infoblock-1 (list infoblock-2)))))

(defun hh-parse-vacancy (html)
  "Получение вакансии из html"
  (dbg ":hh-parse-vacancy:")
  (setf *last-parse-data* html)
  (let ((candidat (->> (html-to-tree html)
                       (extract-vacancy)
                       (maptreefilter)
                       (detect-script)
                       (detect-insider-vacancy)
                       (detect-branded)
                       (detect-branded2)
                       (detect-gap)
                       (detect-vacancy-custom)
                       (detect-l)
                       (detect-emp)
                       (detect-emp-anon)
                       (detect-vacancy-info)
                       (detect-vac-info-tr)
                       (detect-or-vac-info-tr-no-salary)
                       (detect-container)
                       (detect-col-1)
                       (detect-hypercontext)
                       (detect-descr-outer-block)
                       (detect-longdescr)
                       (detect-respond-topic)
                       (detect-vacancy-address)
                       (detect-jobtype)
                       (detect-closed-contacts)
                       (detect-contacts-body)
                       (detect-contacts-fio)
                       (detect-contacts-list)
                       (detect-contacts-tr)
                       (detect-contacts-phone)
                       (detect-contacts-mail)
                       (detect-logo)
                       (detect-date)
                       (detect-or-date-with-disabled)
                       (detect-vacancy-view-banners)
                       (detect-column-2)
                       (detect-response-block)
                       (detect-skill-element)
                       (detect-skills)
                       (detect-joblocation)
                       (detect-handicap)
                       (detect-compact-l)
                       (detect-compact-contacts)
                       (detect-compact-info)
                       (detect-columns)
                       (detect-branded-hype)
                       (detect-meta)
                       (detect-compact-infoblock)
                       )))
    (if (not (tree-plist-p candidat))
        (progn
          (dbg "~A" (bprint candidat))
          (error 'malformed-vacancy :text))
        (let* ((non-compacted-vacancy candidat)
               (compacted-vacancy (compactor candidat))
               )
          ;; non-compacted-vacancy
          compacted-vacancy
        ))
    ;; (print candidat)
    ;; (print (compactor candidat))
    ;; candidat
    ))

;; (print (hh-parse-vacancy *last-parse-data*))


;; (defparameter *last-vacancy-html*
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-get-page "https://spb.hh.ru/vacancy/17527227" temp-cookie-jar *hh_account* "https://spb.hh.ru/")))

;; (defparameter *last-vacancy-html*
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-get-page "https://spb.hh.ru/vacancy/18108178" temp-cookie-jar *hh_account* "https://spb.hh.ru/")))

;; (defparameter *last-vacancy-html*
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-get-page "https://spb.hh.ru/vacancy/17527227" temp-cookie-jar *hh_account* "https://spb.hh.ru/")))

;; (defparameter *last-vacancy-html*
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-get-page "https://spb.hh.ru/vacancy/22262525" temp-cookie-jar *hh_account* "https://spb.hh.ru/")))

;; (defparameter *last-vacancy-html*
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-get-page "https://spb.hh.ru/vacancy/22518184" temp-cookie-jar *hh_account* "https://spb.hh.ru/")))



;; (let ((sections (hh-parse-vacancy *last-vacancy-html*)))
;;   (loop :for section-key :in sections by #'cddr  :do
;;      (format t "~%_______~%~A" (bprint (list section-key (getf sections section-key))))))

;; (print (hh-parse-vacancy *last-vacancy-html*))

;; (print
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-parse-vacancy (hh-get-page "https://spb.hh.ru/vacancy/16606806" temp-cookie-jar *hh_account* "https://spb.hh.ru/"))))

(let ((cookie-jar (make-instance 'drakma:cookie-jar)))
  ;; ------- эта функция вызывается из get-vacancy, которую возвращает factory
  (defmethod process-teaser (current-teaser src-account referer)
    (dbg ":process-teaser:")
    (let* ((vac-plist (plistp current-teaser))
           ;; (none (print vac-plist))
           (vac-id (if vac-plist
                       (getf (getf current-teaser :teaser) :id)
                       (getf (getf (car current-teaser) :vacancy) :id)))
           (vacancy-page (format nil "https://spb.hh.ru/vacancy/~A" vac-id)))
      (multiple-value-bind (vacancy new-cookies ref-url)
          (hh-get-page vacancy-page cookie-jar src-account referer)
        (setf cookie-jar new-cookies)
        (restart-case
            (aif (hh-parse-vacancy vacancy)
                 (merge-plists current-teaser it)
                 nil)
          (skip () nil)))))
  ;; ------- эта функция возвращает get-vacancy, которая является генератором вакансий
  (defmethod factory ((vac-src (eql 'hh)) src-account city prof-area &optional spec)
    (dbg ":factory:")
    ;; closure
    (let ((url        (make-hh-url city prof-area spec))
          (page       0)
          (teasers    nil))
      ;; returned function-generator in closure
      (alexandria:named-lambda get-vacancy ()
        (labels (;; Загружает следующую страницу тизеров в TEASERS
                 (LOAD-NEXT-TEASERS-PAGE ()
                   (dbg ":load-next-teasers-page: (page=~A)" page)
                   (let* ((next-teasers-page-url (format nil url page))
                          (referer (if (= page 0) "https://spb.hh.ru" (format nil url (- page 1)))))
                     (handler-case
                         (multiple-value-bind (next-teasers-page new-cookies ref-url)
                             (hh-get-page next-teasers-page-url cookie-jar src-account referer)
                           (setf cookie-jar new-cookies)
                           (setf teasers (hh-parse-vacancy-teasers next-teasers-page))
                           (incf page)
                           (when (equal 0 (length teasers))
                             (dbg "~~ FIN(0)")
                             (return-from get-vacancy 'nil)))
                       (hh-404-error (err)
                         (progn
                           (dbg "~~ FIN(404) : ~A" (url err))
                           (return-from get-vacancy 'nil))))))
                 ;; Возвращает следующий тизер из пула тизеров.
                 ;; Если пул пуст, то вызывает LOAD-NEXT-TEASER-PAGE чтобы наполнить его
                 (GET-TEASER ()
                   (dbg ":get-teaser:")
                   (when (equal 0 (length teasers))
                     (load-next-teasers-page))
                   (prog1 (car teasers)
                     (setf teasers (cdr teasers)))))
          (tagbody get-new-teaser
             (let* ((teaser (get-teaser))
                    (current-vacancy (process-teaser teaser src-account (format nil url page))))
               (if (null current-vacancy)
                   (go get-new-teaser)
                   (return-from get-vacancy current-vacancy)))))))))

;; (let ((gen (factory 'hh "spb" "Информационные технологии, интернет, телеком"
;;                     "Программирование, Разработка")))
;;   (loop :for i :from 1 :to 100 :do
;;      ;; (dbg "~A" i)
;;      (let ((vacancy (funcall gen)))
;;        (when (null vacancy)
;;          (return))))))

;; moved (in-package #:moto)
;; moved 
;; moved (defparameter *saved-vacancy* nil)
;; moved 
;; moved (defmethod save-vacancy (vac)
;; moved   (let* ((src-id    (.> getf vac -> :teaser :id))
;; moved          (old-vac   (car (find-vacancy :src-id src-id)))
;; moved          (*new-vac*
;; moved           (list
;; moved            :src-id      src-id
;; moved            :name        (.> getf vac -> :teaser :name)
;; moved            :currency    (aif (.> getf vac -> :teaser-compensation :currency) it "")
;; moved            :salary      (aif (.> getf vac -> :teaser-compensation :salary) it 0)
;; moved            :base-salary (aif (.> getf vac -> :teaser-compensation :salary) it 0)
;; moved            :salary-text (aif (.> getf vac -> :teaser-compensation :salary-text) it "")
;; moved            :salary-max  (aif (.> getf vac -> :teaser-compensation :salary-max) it 0)
;; moved            :salary-min  (aif (.> getf vac -> :teaser-compensation :salary-min) it 0)
;; moved            :emp-id      (aif (.> getf vac -> :teaser-emp :emp-id) it 0)
;; moved            :emp-name    (.> getf vac -> :teaser-emp :emp-name)
;; moved            :city        (trim (.> getf vac -> :vacancy-place :city))
;; moved            :metro       ""
;; moved            :experience  (.> getf vac -> :vacancy-exp :exp)
;; moved            :archive     (.> getf vac -> :teaser :archived)
;; moved            :date        (aif (.> getf vac -> :teaser :date) it "")
;; moved            :respond     ""
;; moved            :state       (if nil ":RESPONDED" ":UNSORT")
;; moved            :descr       (bprint (.> getf vac -> :vacancy-descr :long-descr))
;; moved            :notes       ""
;; moved            :tags        "" ;; (aif (getf vac :tags) it "")
;; moved            :response    ""
;; moved 
;; moved            :emptype     (aif (.> getf vac -> :vacancy-jobtype :emptype) it "")
;; moved            :workhours   (aif (.> getf vac -> :vacancy-jobtype :workhours) it "")
;; moved            :skills      (aif (.> getf vac -> :vacancy-skills :list-of-skilss) (bprint it) "")
;; moved            :datetime    (aif (.> getf vac -> :vacancy-date :datetime) it "")
;; moved            :date-text   (aif (.> getf vac -> :vacancy-date :datetext) it "")
;; moved            :responsibility (let ((resp (aif (.> getf vac -> :teaser-descr :responsibility) it "")))
;; moved                              (if (stringp resp) resp ""))
;; moved            :requirement (aif (.> getf vac -> :teaser-descr :requirement) it "")
;; moved            :addr        (aif (.> getf vac -> :addr :addr-with-map) it "")
;; moved            :street-addr (aif (.> getf vac -> :addr :street-addr) it "")
;; moved 
;; moved            )))
;; moved     (declare (special *new-vac*))
;; moved     (if (null old-vac)
;; moved         (progn
;; moved           (eval `(make-vacancy ,@*new-vac*)))
;; moved         ;; else
;; moved         (progn
;; moved           (upd-vacancy old-vac *new-vac*)))))

(in-package #:moto)

(defun send-respond (vacancy-id cookie-jar resume-id letter)
  (let ((url (format nil "https://spb.hh.ru/vacancy/~A" vacancy-id)))
    ;; Сначала запрашиваем страницу
    (multiple-value-bind (response cookie-jar url)
        (hh-get-page url cookie-jar *hh_account* "https://spb.hh.ru")
      ;; Потом запрашиваем всплывающее окно (X-Requested-With: XMLHttpRequest, Referer)
      (let ((url-popup (format nil "https://spb.hh.ru/applicant/vacancy_response/popup?vacancyId=~A&autoOpen=no&isTest=no&withoutTest=no" vacancy-id)))
        (multiple-value-bind (response cookie-jar url)
            (hh-get-page url-popup cookie-jar *hh_account* url)
          ;; Тут можно было бы проанализировать форму на предмет соответствия выбираемых резюме
          (let ((cookie-alist (mapcar #'(lambda (cookie)
                                          (cons (drakma:cookie-name cookie) (drakma:cookie-value cookie)))
                                      (drakma:cookie-jar-cookies cookie-jar))))
            ;; Теперь отправляем POST-запрос
            (let ((resp (drakma:http-request
                         "https://spb.hh.ru/applicant/vacancy_response/popup"
                         :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"
                         :method :post
                         :content (format nil "~{~A~^&~}"
                                          (mapcar #'(lambda (x)
                                                      (format nil "~A=~A" (car x) (cdr x)))
                                                  `(("vacancy_id" . ,(format nil "~A" vacancy-id))
                                                    ("resume_id" . ,(format nil "~A" resume-id))
                                                    ("letter" . ,(drakma:url-encode letter :utf-8))
                                                    ("_xsrf" . ,(cdr (assoc "_xsrf" cookie-alist :test #'equal)))
                                                    ("ignore_postponed" . "true"))))
                         :content-type "application/x-www-form-urlencoded; charset=UTF-8"
                         :additional-headers
                         `(("Accept" . "*/*")
                           ("Accept-Language" . "en-US,en;q=0.5")
                           ("Accept-Encoding" . "gzip, deflate")
                           ("X-Xsrftoken" . ,(cdr (assoc "_xsrf" cookie-alist :test #'equal)))
                           ("X-Requested-With" . "XMLHttpRequest")
                           ("Referer" . ,(format nil "https://spb.hh.ru/vacancy/~A" vacancy-id))
                           ("Connection" . "keep-alive")
                           ("Pragma" . "no-cache")
                           ("Cache-Control" . "no-cache")
                           )
                         :cookie-jar cookie-jar
                         :redirect 10
                         :force-binary t)))
              (flexi-streams:octets-to-string resp :external-format :utf-8))))))))

;; (print
;;  (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;    (send-respond "15382394" cookie-jar "39357756" "letter")))

(defun run ()
  (make-event :name "run"
              :tag "parser-run"
              :msg (format nil "Сбор вакансий")
              :author-id 0
              :ts-create (get-universal-time))
  (let ((gen (factory 'hh *hh_account* "spb" "Информационные технологии, интернет, телеком"
                      "Программирование, Разработка")))
    (loop :for i :from 1 :to 100 :do
       (dbg ":run: i=~A" i)
       (let ((vacancy (funcall gen)))
         (when (null vacancy)
           (return))))))

;; (run)
