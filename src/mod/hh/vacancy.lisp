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
  ;; (dbg "process (count rules: ~A)" (length rules))
  (let ((vacancy vacancy))
    (tagbody
     renew
       (loop :for rule :in rules
          :do
          (progn
            (declaim #+sbcl(sb-ext:muffle-conditions style-warning))
            (if (funcall (eval (read-from-string (format nil "(lambda (vacancy) ~A)" (antecedent rule))))
                         vacancy)
                (progn
                  ;; (dbg ": ~A : ~A" (id rule) (name rule))
                  (multiple-value-bind (vacancy-result rule-result)
                      (funcall (eval `(lambda (vacancy)
                                        (let ((result (progn ,@(read-from-string (consequent rule)))))
                                          (values vacancy result))))
                               vacancy)
                    (setf vacancy vacancy-result)
                    (when (equal rule-result :stop)
                      (return-from process vacancy))
                    (when (equal rule-result :renew)
                      (go renew)))
                  ))
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

(defmacro define-drop-all-vacancy-when-already-worked (&rest employers)
  `(list ,@(loop :for emp :in employers :collect
              `(define-drop-vacancy-rule (already-worked (contains (getf vacancy :emp-name) ,emp))
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

(define-drop-all-vacancy-when-already-worked "Webdom" "Semrush" "Пулково-Сервис" "FBS")
(in-package #:moto)

(define-drop-vacancy-rule (already-exists-in-db (not (null (find-vacancy :src-id (getf vacancy :id)))))
    ;; (let ((exists (car (find-vacancy :src-id (getf vacancy :id)))))
    (dbg "   - already exists"))
;; )
(in-package #:moto)

(define-rule (set-tags t)
    ;; Превращаем описание вакансии в plain-text с минимумом знаков препринания, а потом разбиваем по пробелам,
    ;; чтобы получить список слов, отсортированный по частоте встречаемости
    ;; Из этого списка слов мы хотим найти все термины. Терминами могут быть:
    ;; - аббревитуры технологий
    ;; - названия технологий и продуктов, известные нам.
    ;; Мы считаем интересными те слова, которые содержат только английские буквы (пусть даже и в нижнем регистре)
    ;; Можно еще выявлять наиболее часто встречающиеся элементы (https://habrahabr.ru/post/167177/)
    ;; Найденные абревиатуры кладем в поле tags
    (let ((hash (make-hash-table :test #'equal))
          (result))
      (mapcar #'(lambda (trm)
                  (multiple-value-bind (result exist)
                      (gethash trm hash)
                    (if (null exist)
                        (setf (gethash trm hash) 1)
                        (setf (gethash trm hash) (+ 1 result)))))
              (ppcre:split "\\s+"
                           (ppcre:regex-replace-all
                            "\\s+" (->  (replace-all (bprint (getf vacancy :descr)) "(:P)" "")
                                        (replace-all "(:B)" "")
                                        (replace-all "(:LI)" "")
                                        (replace-all "(:UL)" "")
                                        (replace-all "(" "")
                                        (replace-all ")" "")
                                        (replace-all "\"" "")
                                        (replace-all "/" " ")
                                        (replace-all "," "")
                                        (replace-all ":" "")
                                        (replace-all ";" "")
                                        (replace-all "-" ""))
                            " ")))
      (maphash #'(lambda (k v)
                   (setf result (append result (list (list v k)))))
               hash)
      ;; (dbg "~A" (bprint result))
      (setf result (remove-if #'(lambda (x)
                                  (block the-filter
                                    ;; Известные нам слова
                                    (if (or (equal "1С" (cadr x))
                                            ;; need more ...
                                            )
                                        (return-from the-filter nil))
                                    (loop :for char :across (cadr x) :do
                                       (if (< 1 (length (subseq (bprint char) 2)))
                                           (return-from the-filter t)))
                                    nil))
                              result))
      (sort result #'(lambda (a b)
                       (< (car a) (car b))))
      (setf (getf vacancy :tags)
            (bprint result))
      ))
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
  (format t "~%")
  (format t "~%~A :~A: ~A [~A]"
       (getf vacancy :salary-text)
       (getf vacancy :currency)
       (getf vacancy :name)
       (getf vacancy :id))
  (format t "~%~A" (getf vacancy :emp-name))
  (format t "~A" (show-descr (getf vacancy :descr))))
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

(define-rule (z-print t)
  (show-vacancy vacancy))
(in-package #:moto)

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
                       :emp-id (aif (getf vacancy :emp-id) it 0)
                       :emp-name (getf vacancy :emp-name)
                       :city (getf vacancy :city)
                       :metro (getf vacancy :metro)
                       :experience (getf vacancy :exp)
                       :archive (getf vacancy :archive)
                       :date (getf vacancy :date)
                       :respond (aif (getf vacancy :respond) it "")
                       :state (if (getf vacancy :respond) ":RESPONDED" ":UNSORT")
                       :descr (bprint (getf vacancy :descr))
                       :notes ""
                       :tags (aif (getf vacancy :tags) it "")
                       :response "Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90")))))
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
                       :emp-id (aif (getf vacancy :emp-id) it 0)
                       :emp-name (getf vacancy :emp-name)
                       :city (getf vacancy :city)
                       :metro (getf vacancy :metro)
                       :experience (getf vacancy :exp)
                       :archive (getf vacancy :archive)
                       :date (getf vacancy :date)
                       :respond (aif (getf vacancy :respond) it "")
                       :state (if (getf vacancy :respond) ":RESPONDED" ":UNSORT")
                       :descr (bprint (getf vacancy :descr))
                       :notes ""
                       :tags (aif (getf vacancy :tags) it "")
                       :response "Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90")))))

(define-rule (z-save t)
  (save-vacancy vacancy)
  :stop)

(in-package #:moto)

(in-package #:moto)

(defmacro define-drop-teaser-rule ((name antecedent) &body consequent)
  `(define-rule (,(intern (concatenate 'string "DROP-TEASER-IF-"(symbol-name name))) ,antecedent)
     ;; (dbg "v1: ~A" (bprint vacancy))
     (dbg "drop teaser: ~A-~A (~A) ~A" (getf vacancy :salary-min) (getf vacancy :salary-max) (getf vacancy :currency) (getf vacancy :name))
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
     (dbg "  - name contains \"~A\"" ,str)
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
  (dbg "  - no salary"))

(define-drop-teaser-rule (salary-2-low (or
                                        (and (equal (getf vacancy :currency) "RUR")
                                             (< (getf vacancy :salary-max) 90000))
                                        (and (equal (getf vacancy :currency) "USD")
                                             (< (getf vacancy :salary-max) (floor 90000 73)))
                                        (and (equal (getf vacancy :currency) "EUR")
                                             (< (getf vacancy :salary-max) (floor 90000 80)))
                                        ))
  (dbg "  - low salary"))

(define-drop-teaser-rule (iOS (contains-in-words (string-downcase (getf vacancy :name)) "ios"))
  (dbg "  - name contains iOS"))

(define-drop-teaser-rule (FrontEnd (contains-in-words (string-downcase (getf vacancy :name)) "front"))
  (dbg "  - name contains FrontEnd"))

(define-drop-teaser-rule (Manager (contains-in-words (string-downcase (getf vacancy :name)) "менеджер"))
  (dbg "  - name contains менеджер"))

(define-drop-teaser-rule (Saler (contains-in-words (string-downcase (getf vacancy :name)) "продаж"))
  (dbg "  - name contains продаж"))

(define-drop-teaser-rule (DotNet (contains-in-words (string-downcase (getf vacancy :name)) ".net"))
  (dbg "  - name contains .net"))


(define-drop-all-teaser-when-name-contains-rule
    "Python" "Django"
    "1C" "1С"
    "C++" "С++"
    "Ruby" "Ruby on Rails"
    "Go"
    "Q/A" "QA"
    "C#"
    "Unity" "Unity3D"
    "Flash"
    "Java"
    "Android"
    "ASP"
    "Objective-C"
    "Delphi"
    "Sharepoint"
    "PL/SQL"
    "Oracle"
    "Node"
    "тестировщик"
    "Системный администратор"
    "Трафик-менеджер"
    "Traffic" "Трафик"
    "Медиабайер" "Media Buyer" "Медиабаер"
    "SAP"
    "маркетолог"
    "SMM"
    "DevOps"
    "Axapta"
    "designer"
    "Дизайнер"
    "Designer"
    "UX"
    "по ремонту"
    "Помощник"
    "Верстальщик"
    "Smolensk" "Львов")

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
  (dbg "process-teaser :around")
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
  (dbg ":: is-logged")
  (not (contains html "data-qa=\"mainmenu_loginForm\">Войти</div>")))

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
         (dbg "-- ~A : ~A" status-code url)
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
          ((equal currency "UAH")
           (setf salary-text (ppcre:regex-replace-all " грн." salary-text "")))
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
;;  (hh-get-page "https://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true"))

(defun html-to-tree (html)
  ;; (html5-parser:node-to-xmls
  (html5-parser:parse-html5-fragment html :dom :xmls
                                     ))

;; (print
;;  (html-to-tree *last-parse-data*))

(defun extract-search-results (tree)
  (block subtree-extract
    (mtm (`("div"
            (("class" "search-result")
             ("data-qa" "vacancy-serp__results"))
            ,@rest)
           (return-from subtree-extract rest))
         tree)))

(defparameter *detect-garbage* '("premium" "response-trigger" "vacancy-responded" "star" "trigger-button"
                                 "response-popup-link" "vacancy-response-popup-script" "emp-logo"
                                 "search-result-description" "search-result-description-with-garbage" "search-result-description-empty"
                                 "search-result-description-primary" "hrbrand" "noindex" "script"
                                 "bloko-icon-phone" "bloko-contact" "bloko-icon-initial-action" "bloko-icon-done-initial-action" "span"))


(defmacro make-detect ((name) &body body)
  (let ((param   (gensym))
        ;; (carlast (car (last (car body))))
        )
    ;; (awhen (stringp carlast)
    ;;   (setf *detect-garbage*
    ;;         (remove-duplicates (append *detect-garbage*
    ;;                                    (list carlast)) :test #'string=)))
    `(defun ,(intern (format nil "DETECT-~A" (string-upcase (symbol-name name)))) (,param)
       (mtm ,@body
            ,param))))

(make-detect (date)
  (`("span" (("class" "b-vacancy-list-date")
             ("data-qa" "vacancy-serp__vacancy-date")) ,date)
    (list :date (progn
                  ;; (print date)
                  (if (null date) "" date)))))

(make-detect (platform)
  (`("span"
     (("class" "vacancy-list-platform")
      ("data-qa" "vacancy-serp__vacancy_career"))
     "  •  " ("span" (("class" "vacancy-list-platform__name"))
                     "CAREER.RU"))
    (list :platform 'career.ru)))

(make-detect (metro)
  (`("span" (("class" "metro-station"))
            ("span" (("class" "metro-point") ("style" ,_))) ,metro)
    (list :metro (aif metro it ""))))

(make-detect (address)
  (`("span" (("class" "searchresult__address")
             ("data-qa" "vacancy-serp__vacancy-address")) ,city ,@rest)
    (let ((metro (loop :for item in rest :do
                    (when (and (consp item) (equal :metro (car item)))
                      (return (cadr item))))))
      (list :city city :metro (aif metro it "")))))

(make-detect (info)
  (`("div" (("class" "search-result-item__info")) ,@rest)
    (loop :for item :in rest :when (consp item) :append item)))

(make-detect (emp)
  (`("div" (("class" "search-result-item__company"))
           ("a" (("href" ,emp-id)
                 ("class" "link-secondary")
                 ("data-qa" "vacancy-serp__vacancy-employer"))
                ,emp-name) ,@rest)
    (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-id)))
                                 :junk-allowed t)
          :emp-name (string-trim '(#\Space #\Tab #\Newline) emp-name))))

(make-detect (emp-anon)
  (`("div" (("class" "search-result-item__company")) ,@text)
    (list :emp-anon text)))

(make-detect (salary)
  (`("div" (("class" "b-vacancy-list-salary") ("data-qa" "vacancy-serp__vacancy-compensation"))
           ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
           ("meta" (("itemprop" "baseSalary") ("content" ,salary))) ,salary-text)
    (list :currency currency :salary (parse-integer salary) :salary-text salary-text)))

(make-detect (interview)
  (`("a" (("class" "interview-insider__link                   m-interview-insider__link-searchresult")
          ("href" ,href)
          ("data-qa" "vacancy-serp__vacancy-interview-insider"))
         "Посмотреть интервью о жизни в компании")
    (list :interview href)))

;; ("a" (("class" "interview-insider__link                   m-interview-insider__link-searchresult")
;;       ("href" ,href)
;;       ("data-qa" "vacancy-serp__vacancy-interview-insider"))
;;      "Посмотреть интервью о жизни в компании")

(make-detect (name)
  (`("div" (("class" "search-result-item__head"))
           ("a" (("class" ,(or "search-result-item__name search-result-item__name_standard"
                               "search-result-item__name search-result-item__name_standard_plus"
                               "search-result-item__name search-result-item__name_premium"
                               "search-result-item__name search-result-item__name_premium HH-LinkModifier"
                               "search-result-item__name search-result-item__name_standard HH-LinkModifier"
                               "search-result-item__name search-result-item__name_standard_plus HH-LinkModifier"))
                 ("data-qa" "vacancy-serp__vacancy-title") ("href" ,id) ("target" "_blank")) ,name) ,@rest)
    (list :id (parse-integer (car (last (split-sequence:split-sequence #\/ id)))) :name name)))

(make-detect (description)
  (`("div" (("class" "search-result-item__description")) ,@rest)
    (loop :for item :in rest :when (consp item) :append item)))

(make-detect (snippet)
  (`("div"
     (("class" "search-result-item__snippet")
      ("data-qa" "vacancy-serp__vacancy_snippet_requirement"))
     ,text)
    (list :snippet text)))

(make-detect (premium)
  (`(("data-qa" "vacancy-serp__vacancy vacancy-serp__vacancy_premium")
     ("class"
      "search-result-item search-result-item_premium  search-result-item_premium"))
    "premium"))

(make-detect (standart)
  (`("div"
     (("data-qa" "vacancy-serp__vacancy")
      ("class" "search-result-item search-result-item_standard "))
     ,@rest)
    rest))

(make-detect (standart-plus)
  (`("div"
     (("data-qa" "vacancy-serp__vacancy")
      ("class" "search-result-item search-result-item_standard_plus "))
     ,@rest)
    rest))

(make-detect (response-trigger)
  (`("script" (("data-name" "HH/VacancyResponseTrigger") ("data-params" ""))) "response-trigger"))

(make-detect (vacancy-responded)
  (`("a" (("href" ,_) ("target" "_blank") ("class" ,_)
          ("data-qa" "vacancy-serp__vacancy_responded")) "Вы откликнулись") "vacancy-responded"))

(make-detect (search-result-description)
  (`(("class" "search-result-description")) "search-result-description"))

(make-detect (search-result-description-empty)
  (`(("class" "search-result-description")) "search-result-description-empty"))

(make-detect (search-result-description-non-empty)
  (`("div" (("class" "search-result-description")) ,@rest) rest))

(make-detect (star)
  (`("div" (("class" "search-result-description__item"))
           ("div" (("class" "search-result-item__star"))
                  ,@_)) "star"))

(make-detect (trigger-button)
  (`(("class" "search-result-item__button HH-VacancyResponseTrigger-Button")) "trigger-button"))

(make-detect (response-popup-link)
  (`("div" (("class" "search-result-item__response"))
           ("a" (("href" ,_)
                 ("class" "bloko-button HH-VacancyResponsePopup-Link")
                 ("data-qa" "vacancy-serp__vacancy_response"))
                "Откликнуться")) "response-popup-link"))

(make-detect (response-popup-script )
  (`("script"
     (("data-name" "HH/VacancyResponsePopup")
      ("data-params" ,_))) "vacancy-response-popup-script"))

(make-detect (emp-logo)
  (`("div" (("class" "search-result-description__item"))
           ("a" (("href" ,emp-id)
                 ("data-qa" "vacancy-serp__vacancy-employer-logo")
                 ("class" "search-result-item__company-image-link"))
                ("img"
                 (("src" ,emp-img) ("alt" ,emp-alt)
                  ("class" "search-result-item__logo")))))
    "emp-logo"))

(make-detect (search-result-description)
  (`("div" (("class" "search-result-description__item"))) "search-result-description"))


(make-detect (search-result-description-empty)
  (`("div" (("class" "search-result-description__item")) ,_) "search-result-description-empty"))

(make-detect (search-result-description-with-garbage)
  (`("div" (("class" "search-result-description__item"))  ,@rest)
    "search-result-description-with-garbage"))

(make-detect (search-result-description-primary)
  (`(("class" "search-result-description__item search-result-description__item_primary")) "search-result-description-primary"))

(make-detect (hrbrand)
  (`("a" (("title" "Премия HRBrand") ("href" ,_) ("rel" "nofollow")
          ("class" ,_)
          ("data-qa" ,_)) " ") "hrbrand"))

(make-detect (vacancy_snippet_responsibility)
  (`("div" (("class" "search-result-item__snippet")
            ("data-qa" "vacancy-serp__vacancy_snippet_responsibility"))
           ,text)
    (list :snippet_responsibility text)))

(make-detect (noindex)
  (`("div" (("class" "search-result-description__item")) "noindex" "hrbrand"
           "/noindex")
    "noindex"))

(make-detect (script)
  (`("script" ,@rest) "script"))

(make-detect (bloko-icon-initial-action)
  (`(("class" "bloko-icon bloko-icon_done bloko-icon_initial-action")) "bloko-icon-initial-action"))

(make-detect (bloko-icon-done-initial-action)
  (`(("class" "bloko-icon bloko-icon_done bloko-icon_done-initial-action")) "bloko-icon-done-initial-action"))

(make-detect (bloko-icon-phone)
  (`(("class" "bloko-icon bloko-icon_phone")) "bloko-icon-phone"))

(make-detect (bloko-contact)
  (`("div" (("class" "search-result-item__phone"))
           ("button"
            (("class" "bloko-button") ("data-qa" "vacancy-serp__vacancy_contacts"))
            "script" "bloko-icon-phone" "script"
            ("div"
             (("class" "g-hidden HH-VacancyContactsLoader-Content")
              ("data-attach" "dropdown-content-placeholder")))))
    "bloko-contact"))

(make-detect (bloko-button-rest)
  (`(:CITY ,city ,@rest)
    (append `(:CITY ,city ,(remove-if #'(lambda (x)
                                          (or
                                           (member x '("div" "trigger-button" "vacancy-response-popup-script" "response-popup-link") :test #'equal)
                                           (listp x)))
                                      rest)))))

(defun detect-garbage-elts (tree)
  (mtm (`("a" (("class" _) ("href" _) ("data-qa" "vacancy-serp__vacancy-interview-insider"))
              "Посмотреть интервью о жизни в компании") 'INTERVIEW)
       (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_invited")
                    ("data-qa" "vacancy-serp__vacancy_invited")) "Вы приглашены!") '(:INVITED "invited"))
            (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_discard")
                         ("data-qa" "vacancy-serp__vacancy_rejected")) "Вам отказали") '(:DECINE "decine"))
                 (mtm (`("a" (("href" ,_) ("target" "_blank") ("class" "search-result-item__label search-result-item__label_discard")
                              ("data-qa" "vacancy-serp__vacancy_rejected")) "Вам отказали") '(:REJECTED "regected"))
                      (mtm (`("div" (("class" "search-result-item__image")) ,_) ':ITEM-IMAGE)
                           tree))))))

(defparameter *last-parse-data* nil)

;; (print *last-parse-data*)

;; (print
;;  (hh-parse-vacancy-teasers *last-parse-data*)
;;  )

(defun tree-plist-p (pl)
  "Returns T if L is a plist (list with alternating keyword elements). "
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

;; (untrace tree-plist-p)

;; (tree-plist-p
;;  '("div" "premium" "response-trigger" "vacancy-responded"
;;    ("star"
;;     ("div" "search-result-description-primary"
;;      (:ID 12359860 :NAME "ASP.NET MVC Developer")
;;      (:SNIPPET_RESPONSIBILITY ("resp" NIL))
;;      (:SNIPPET
;;       "Опыт коммерческой разработки на платформе .NET with C# - не менее 2 лет. ASP.NET MVC. HTML, CSS, JavaScript. SQL Server. ")
;;      (:EMP-ID 208902 :EMP-NAME "ЗАО Аркадия")
;;      (:CITY "Санкт-Петербург" (:METRO "" :DATE "6 апреля")))
;;     "emp-logo" "search-result-description")))


(define-condition malformed-vacancy (error)
  ((text :initarg :text :reader text)))

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (dbg "hh-parse-vacancy-teasers")
  (setf *last-parse-data* html)
  (->> (html-to-tree html)
       (extract-search-results)
       (detect-platform)
       (detect-date)
       (detect-metro)
       (detect-address)
       (detect-info)
       (detect-emp)
       (detect-emp-anon)
       (detect-salary)
       (detect-interview)
       (detect-name)
       (detect-snippet)
       (detect-premium)
       (detect-standart)
       (detect-standart-plus)
       (detect-response-trigger)
       (detect-garbage-elts)
       (detect-vacancy-responded)
       (detect-search-result-description)
       (detect-search-result-description-with-garbage)
       (detect-star)
       (detect-trigger-button)
       (detect-response-popup-link)
       (detect-response-popup-script)
       (detect-emp-logo)
       (detect-search-result-description)
       (detect-search-result-description-primary)
       (detect-search-result-description-empty)
       (detect-hrbrand)
       (detect-vacancy_snippet_responsibility)
       (detect-noindex)
       (detect-bloko-icon-phone)
       (detect-bloko-icon-initial-action)
       (detect-bloko-icon-done-initial-action)
       (detect-script)
       (detect-bloko-contact)
       (detect-search-result-description-non-empty)
       (detect-bloko-button-rest)
       ;; filter garbage data
       (maptree-if #'consp
                   #'(lambda (x)
                       (values
                        (remove-if #'(lambda (x)
                                       (when (stringp x)
                                         (or
                                          (string= x "div")
                                          (find x *detect-garbage* :test #'string=)
                                          )))
                                   x)
                        #'mapcar)))
       ;; error if malformed plist
       (mapcar #'(lambda (x)
                   (if (not (tree-plist-p x))
                       (progn
                         (dbg "~A" (bprint x))
                         (error 'malformed-vacancy :text))
                       x)))
       ;; linearize for each elt
       (mapcar #'(lambda (tree)
                   (let ((linearize))
                     (maptree #'(lambda (x)
                                  (setf linearize
                                        (append linearize (list x))))
                              tree)
                     linearize)))
       ;; parse-salary
       (mapcar #'parse-salary)
       ))

;; (print
;;  (hh-parse-vacancy-teasers *last-parse-data*))

;; (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (hh-parse-vacancy-teasers
;;    (hh-get-page "https://spb.hh.ru/search/vacancy?text=&specialization=1&area=2&salary=&currency_code=RUR&only_with_salary=true&experience=doesNotMatter&order_by=salary_desc&search_period=30&items_on_page=100&no_magic=true" temp-cookie-jar "https://spb.hh.ru/")))

;; (print
;;  *last-parse-data*)

;; (mapcar #'(lambda (x)
;;             (del-vacancy (id x)))
;;         (find-vacancy :state ":UNINTERESTING"))

(in-package #:moto)

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

(defun header-extractor (tree)
  (mtm (`("div" (("class" "b-vacancy-custom g-round")) ("meta" (("itemprop" "title") ("content" ,_)))
                ("h1" (("class" "title b-vacancy-title")) ,name ,@archive) ,@rest)
         (return-from header-extractor
           (append (list :name name :archive (if archive t nil))
                   ;; (block emp-block (mtm (`("div" (("class" "companyname")) ("a" (("itemprop" "hiringOrganization") ("href" ,emp-lnk)) ,emp-name))
                   ;;                         (return-from emp-block
                   ;;                           (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-lnk))) :junk-allowed t)
                   ;;                                 :emp-name emp-name)))
                   ;;                       rest))
                   )))
       tree))

(defun company-extractor (tree)
  (let ((candidat (mtm (`("a" (("itemprop" "hiringOrganization") ("href" ,emp-lnk)) ,emp-name)
                       (return-from company-extractor
                         (list :emp-id (parse-integer (car (last (split-sequence:split-sequence #\/ emp-lnk))) :junk-allowed t)
                               :emp-name emp-name)))
                     tree)))
    (if (not (tree-plist-p candidat))
        (list :emp-id 0
              :emp-name "")
        candidat)))

(defun salary-extractor (tree)
  (let ((salary-result (block salary-extract
                         (mtm (`("div" (("class" "l-paddings"))
                                       ("meta" (("itemprop" "salaryCurrency") ("content" ,currency)))
                                       ("meta" (("itemprop" "baseSalary") ("content" ,base-salary)))
                                       ,salary-text)
                                (return-from salary-extract (list :currency currency :base-salary (parse-integer base-salary) :salary-text salary-text)))
                              tree))))
    (if (equal 6 (length salary-result))
        salary-result
        (list :currency nil :base-salary nil :salary-text nil))))

(defun city-extractor (tree)
  (let ((city-result (block city-extract (mtm (`("td" (("class" "l-content-colum-2 b-v-info-content")) ("div" (("class" "l-paddings")) ,city))
                                                (return-from city-extract (list :city city))) tree))))
    (if (equal 2 (length city-result)) city-result (list :city nil))))

(defun exp-extractor (tree)
  (let ((exp-result (block exp-extract (mtm (`("td" (("class" "l-content-colum-3 b-v-info-content"))
                                                    ("div" (("class" "l-paddings") ("itemprop" "experienceRequirements")) ,exp))
                                              (return-from exp-extract (list :exp exp))) tree))))
    (if (equal 2 (length exp-result)) exp-result (list :exp nil))))

(defun respond-extractor (tree)
  (let ((respond-result (block respond-extract (mtm (`("div" (("class" "g-attention m-attention_good b-vacancy-message"))
                                                             "Вы уже откликались на эту вакансию. "
                                                             ("a" (("href" ,resp)) "Посмотреть отклики."))
                                                      (return-from respond-extract (list :respond resp))) tree))))
    (if (equal 2 (length respond-result)) respond-result (list :respond nil))))

(defun descr-extractor (tree)
  (block descr-extract
    (mtm (`("div" (("class" "b-vacancy-desc-wrapper") ("itemprop" "description")) ,@descr)
           (return-from descr-extract (list :descr (transform-description descr)))) tree)))

(defun hh-parse-vacancy (html)
  (dbg "hh-parse-vacancy")
  (let* ((tree (html-to-tree html))
         (candidat (append (header-extractor tree)
                           (company-extractor tree)
                           (salary-extractor tree)
                           (city-extractor tree)
                           (exp-extractor tree)
                           (respond-extractor tree)
                           (descr-extractor tree))))
    (if (not (tree-plist-p candidat))
        (progn
          (dbg "~A" (bprint candidat))
          (error 'malformed-vacancy :text))
        candidat)))


;; (print
;;  (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;    (hh-parse-vacancy (hh-get-page "https://spb.hh.ru/vacancy/12561525" temp-cookie-jar *hh_account* "https://spb.hh.ru/"))))


;; (print
;;   (let ((temp-cookie-jar (make-instance 'drakma:cookie-jar)))
;;     (hh-parse-vacancy (hh-get-page "https://spb.hh.ru/vacancy/16606806" temp-cookie-jar *hh_account* "https://spb.hh.ru/"))))

(let ((cookie-jar (make-instance 'drakma:cookie-jar)))
  ;; ------- эта функция вызывается из get-vacancy, которую возвращает factory
  (defmethod process-teaser (current-teaser src-account referer)
    (dbg "process-teaser")
    (let ((vacancy-page (format nil "https://spb.hh.ru/vacancy/~A" (getf current-teaser :id))))
      (multiple-value-bind (vacancy new-cookies ref-url)
          (hh-get-page vacancy-page cookie-jar src-account referer)
        (setf cookie-jar new-cookies)
        (aif (hh-parse-vacancy vacancy)
             (merge-plists current-teaser it)
             nil))))
  ;; ------- эта функция возвращает get-vacancy, которая является генератором вакансий
  (defmethod factory ((vac-src (eql 'hh)) src-account city prof-area &optional spec)
    (dbg "factory")
    ;; closure
    (let ((url        (make-hh-url city prof-area spec))
          (page       0)
          (teasers    nil))
      ;; returned function-generator in closure
      (alexandria:named-lambda get-vacancy ()
        (labels ((load-next-teasers-page ()
                   (dbg "load-next-teasers-page (page=~A)" page)
                   (let* ((next-teasers-page-url (format nil url page))
                          (referer (if (= page 0) "https://spb.hh.ru"(format nil url (- page 1)))))
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
                           (return-from get-vacancy 'nil))))
                     ))
                 (get-teaser ()
                   ;; (dbg "get-teaser")
                   (when (equal 0 (length teasers))
                     (load-next-teasers-page))
                   (prog1 (car teasers)
                     (setf teasers (cdr teasers)))))
          (tagbody get-new-teaser
             (let ((current-vacancy (process-teaser (get-teaser) src-account (format nil url page))))
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
;; moved (defmethod save-vacancy (vacancy)
;; moved   (setf *saved-vacancy*
;; moved         (append *saved-vacancy*
;; moved                 (list (make-vacancy
;; moved                        :src-id (getf vacancy :id)
;; moved                        :name (getf vacancy :name)
;; moved                        :currency (getf vacancy :currency)
;; moved                        :salary (aif (getf vacancy :salary) it 0)
;; moved                        :base-salary (aif (getf vacancy :base-salary) it 0)
;; moved                        :salary-text (getf vacancy :salary-text)
;; moved                        :salary-max (getf vacancy :salary-max)
;; moved                        :salary-min (getf vacancy :salary-min)
;; moved                        :emp-id (aif (getf vacancy :emp-id) it 0)
;; moved                        :emp-name (getf vacancy :emp-name)
;; moved                        :city (getf vacancy :city)
;; moved                        :metro (getf vacancy :metro)
;; moved                        :experience (getf vacancy :exp)
;; moved                        :archive (getf vacancy :archive)
;; moved                        :date (getf vacancy :date)
;; moved                        :respond (aif (getf vacancy :respond) it "")
;; moved                        :state (if (getf vacancy :respond) ":RESPONDED" ":UNSORT")
;; moved                        :descr (bprint (getf vacancy :descr))
;; moved                        :notes ""
;; moved                        :tags (aif (getf vacancy :tags) it "")
;; moved                        :response "Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90")))))
;; moved (in-package #:moto)
;; moved 
;; moved (defparameter *saved-vacancy* nil)
;; moved 
;; moved (defmethod save-vacancy (vacancy)
;; moved   (setf *saved-vacancy*
;; moved         (append *saved-vacancy*
;; moved                 (list (make-vacancy
;; moved                        :src-id (getf vacancy :id)
;; moved                        :name (getf vacancy :name)
;; moved                        :currency (getf vacancy :currency)
;; moved                        :salary (aif (getf vacancy :salary) it 0)
;; moved                        :base-salary (aif (getf vacancy :base-salary) it 0)
;; moved                        :salary-text (getf vacancy :salary-text)
;; moved                        :salary-max (getf vacancy :salary-max)
;; moved                        :salary-min (getf vacancy :salary-min)
;; moved                        :emp-id (aif (getf vacancy :emp-id) it 0)
;; moved                        :emp-name (getf vacancy :emp-name)
;; moved                        :city (getf vacancy :city)
;; moved                        :metro (getf vacancy :metro)
;; moved                        :experience (getf vacancy :exp)
;; moved                        :archive (getf vacancy :archive)
;; moved                        :date (getf vacancy :date)
;; moved                        :respond (aif (getf vacancy :respond) it "")
;; moved                        :state (if (getf vacancy :respond) ":RESPONDED" ":UNSORT")
;; moved                        :descr (bprint (getf vacancy :descr))
;; moved                        :notes ""
;; moved                        :tags (aif (getf vacancy :tags) it "")
;; moved                        :response "Здравствуйте, я подхожу под ваши требования. Когда можно договориться о собеседовании? Михаил 8(911)286-92-90")))))

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
       (dbg "~A" i)
       (let ((vacancy (funcall gen)))
         (when (null vacancy)
           (return))))))

;; (run)
