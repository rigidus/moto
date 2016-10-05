;; [[file:doc.org::*Утилиты][utility_file]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
   ;;;; Licensed under the GNU AGPLv3
   ;;;; util.lisp

(in-package #:moto)

;; Превращает инициализированные поля объекта в plist
(defun get-obj-data (obj)
  (let ((class (find-class (type-of obj)))
        (result))
    (loop :for slot :in (closer-mop:class-direct-slots class) :collect
       (let ((slot-name (closer-mop:slot-definition-name slot)))
         (when (slot-boundp obj slot-name)
           (setf result
                 (append result (list (intern (symbol-name slot-name) :keyword)
                                      (funcall slot-name obj)))))))
    result))

;; Assembly WHERE clause
(defun make-clause-list (glob-rel rel args)
  (append (list glob-rel)
          (loop
             :for i
             :in args
             :when (and (symbolp i)
                        (getf args i)
                        (not (symbolp (getf args i))))
             :collect (list rel i (getf args i)))))

;; Макросы для корректного вывода ошибок
(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defmacro err (var)
  `(error (format nil "ERR:[~A]" (bprint ,var))))

;; Отладочный вывод
(defparameter *dbg-enable* t)
(defparameter *dbg-indent* 1)

(defun dbgout (out)
  (when *dbg-enable*
    (format t (format nil "~~%~~~AT~~A" *dbg-indent*) out)))

(defmacro dbg (frmt &rest params)
  `(dbgout (format nil ,frmt ,@params)))

;; (macroexpand-1 '(dbg "~A~A~{~A~^,~}" "zzz" "34234" '(1 2 3 4)))

(defun anything-to-keyword (item)
  (intern (string-upcase (format nil "~a" item)) :keyword))

(defun alist-to-plist (alist)
  (if (not (equal (type-of alist) 'cons))
      alist
      ;;else
      (loop
         :for (key . value)
         :in alist
         :nconc (list (anything-to-keyword key) value))))

;; Враппер управляет сесииями и выводит все в основной (root-овый) шаблон
;; Если необходимо вывести ajax-данные, использует специальный тип ошибки

(define-condition ajax (error)
  ((output :initarg :output :reader output)))

(defmacro with-wrapper (&body body)
  `(progn
     (hunchentoot:start-session)
     (let* ((*current-user* (hunchentoot:session-value 'current-user))
            (retval))
       (declare (special *current-user*))
       (handler-case
           (let ((output (with-output-to-string (*standard-output*)
                           (setf retval ,@body))))
             (tpl:louis
              (list :title ""
                    :header (tpl:header (list :login (head-login-block)
                                              :search
                                              (ps-html
                                              ((:form :action "/hh/search" :method "get" :novalidate "" :name "article-search" :class "header-search" :id="article-search")
                                               ((:fieldset)
                                                ((:legend :class "hidden") "search")
                                                ((:div :class "input-container hide-label")
                                                 ((:label :for "header-search-q") "Поиск вакансий и фирм")
                                                 ((:input :name "q" :id "header-search-q" :class "input-text form-element header-search__input"
                                                          :maxlength "50" :required "required" :autocomplete "off" :value (aif (get-parameter "q") it "") :type "text")))
                                                ((:button :type "submit" :class "button button--header-search" :value "")
                                                 ((:span :class "button__icon sprite") "Search")))))))
                    :content retval
                    :footer (tpl:footer (list :dbg (format nil "<pre>~A</pre>" output))))))
         (ajax (ajax) (output ajax))))))

;; Для того чтобы генерировать и выводить элементы форм, напишем хелперы:

;; (defun input (type &key name value other)
;;   (format nil "~%<input type=\"~A\"~A~A~A/>" type
;;           (if name  (format nil " name=\"~A\"" name) "")
;;           (if value (format nil " value=\"~A\"" value) "")
;;           (if other (format nil " ~A" other) "")))

;; ;; (input "text" :name "zzz" :value 111)
;; ;; (input "submit" :name "submit-btn" :value "send")

;; (defmacro select ((name &optional attrs) &body options)
;;   `(format nil "~%<select name=\"~A\"~A>~{~%~A~}~%</select>"
;;            ,name
;;            (aif ,attrs (format nil " ~A" it) "")
;;            (loop :for (name value selected) :in ,@options :collect
;;               (format nil "<option value=\"~A\"~A>~A</option>"
;;                       value
;;                       (if selected (format nil " ~A" selected) "")
;;                       name))))

;; (defun fld (name &optional (value ""))
;;   (input "text" :name name :value value))

;; (defun btn (name &optional (value ""))
;;   (input "button" :name name :value value))

;; (defun hid (name &optional (value ""))
;;   (input "hidden" :name name :value value))

;; (defun submit (&optional value)
;;   (if value
;;       (input "submit" :value value)
;;       (input "submit")))

;; (defun act-btn (act data title)
;;   (format nil "~%~{~%~A~}"
;;           (list
;;            (hid "act"  act)
;;            (hid "data" data)
;;            (submit title))))

;; (defmacro row (title &body body)
;;   `(format nil "~%<tr>~%<td>~A</td>~%<td>~A~%</td>~%</tr>"
;;            ,title
;;            ,@body))

;; ;; (row "thetitrle" (submit))

;; (defun td (dat)
;;   (format nil "~%<td>~%~A~%</td>" dat))

;; (defun tr (&rest dat)
;;   (format nil "~%<tr>~%~{~A~}~%</tr>"
;;           dat))

;; ;; (tr "wfewf")
;; ;; (tr "wfewf" 1111)

;; (defun frm (contents &key name (method "POST") action)
;;   (format nil "~%<form method=\"~A\"~A~A>~{~A~}~%</form>"
;;           method
;;           (if name (format nil " name=\"~A\"" name) "")
;;           (if action (format nil " action=\"~A\"" action) "")
;;           (if (consp contents)
;;               contents
;;               (list contents))))

;; ;; (frm "form-content" :name "nnnnn")

;; (defun tbl (contents &key name border)
;;   (format nil "~%<table~A~A>~{~A~}~%</table>"
;;           (if name (format nil " name=\"~A\"" name) "")
;;           (if border (format nil " border=\"~A\"" border) "")
;;           (if (consp contents)
;;               contents
;;               (list contents))))

;; ;; (tbl (list "zzz") :name "table")

;; ;; (frm (tbl (list (row "username" (fld "user")))))

;; Макрос создает маршрут и маршрут-контроллер, таким образом,
;; чтобы связать действия контроллера и кнопки
(defmacro define-page (name url (&body body) &rest rest)
  (let ((name-ctrl (intern (format nil "~A-CTRL" (symbol-name name)))))
    `(symbol-macrolet (,@(loop :for (act exp body) :in rest :collect
                            `(,(intern (format nil "%~A%" (symbol-name act))) ,exp)))
       (restas:define-route ,name (,url)
         (with-wrapper
           ,body))
       (restas:define-route ,name-ctrl (,url :method :post)
         (with-wrapper
           (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
             (cond
               ,@(append
                  (loop :for (act exp body) :in rest :collect
                     `((string= ,(symbol-name act) (getf p :act))
                       ,body))
                  `((t (format nil "unk act : ~A" (bprint p))))))))))))

;; Чтобы выводить коллекции напишем макрос

(defmacro with-collection ((item collection) &body body)
  `(loop :for ,item :in ,collection :collect
      ,@body))

;; Чтобы выводить элемент коллекции напишем макрос

(defmacro with-element ((item elt) &body body)
  `(let ((,item ,elt))
     (list
      ,@body)))

(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
      is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))

(defun explore-dir (path)
  (let ((raw (directory path))
        (dirs)
        (files))
    (mapcar #'(lambda (x)
                (if (cl-fad:directory-pathname-p x)
                    (push x dirs)
                    (push x files)))
            raw)
    (values dirs files raw)))

;; clear-db
(defun drop (tbl-lst)
  (let ((tables tbl-lst))
    (flet ((rmtbl (tblname)
             (when (with-connection *db-spec*
                     (query (:select 'table_name :from 'information_schema.tables :where
                                     (:and (:= 'table_schema "public")
                                           (:= 'table_name tblname)))))
               (with-connection *db-spec*
                 (query (:drop-table (intern (string-upcase tblname))))))))
      (loop :for tblname :in tables :collect
         (rmtbl tblname)))))

;; contains
(defun contains (string pattern)
  (if (search pattern string)
      t))

;; contains in words
(defun contains-in-words (string pattern)
  (reduce #'(lambda (a b)
              (or a b))
          (mapcar #'(lambda (x)
                      (contains x pattern))
                  (ppcre:split "\\W+" string))
          :initial-value nil))

;; empty
(defun empty (string)
  (if (or (null string)
          (equal "" string))
      t))
;; utility_file ends here
