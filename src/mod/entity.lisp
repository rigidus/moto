;;;; entity.lisp

(in-package #:moto)

(defmacro define-entity (name desc &rest tail)
  (let ((*package* (symbol-package name)))
    `(progn
       
       ;; entity-class
       ,(let ((table (intern (symbol-name name))))
         `(defclass ,name ()
           ,(mapcar #'(lambda (x)
                        (list
                         (car x)
                         :col-type (cadr x)
                         :initarg  (intern (symbol-name (car x)) :keyword)
                         :accessor (car x)))
                    (car tail))
           (:metaclass dao-class)
           (:table-name ,table)
           (:keys ,(caaar tail))))
       
       ;; make-entity-table
       ,(let ((table (intern (symbol-name name))))
         `(defun ,(intern (concatenate 'string "MAKE-" (symbol-name name) "-TABLE")) ()
           (with-connection *db-spec*
             (unless (table-exists-p (string-downcase (symbol-name ',table)))
               (execute (dao-table-definition ',table))))))
       
       ;; make-entity
       ,(let ((table (intern (symbol-name name))))
         `(defun ,(intern (concatenate 'string "MAKE-" (symbol-name name))) (&rest initargs)
           (with-connection *db-spec*
             (apply #'make-dao (list* ',table initargs)))))
       
       ;; upd-entity
       (defmethod ,(intern (concatenate 'string "UPD-" (symbol-name name))) ((obj ,name) &optional args)
         (progn
           ,@(loop for accessor in (car tail) :collect
                  `(setf (,(car accessor) obj)
                         (or (getf args ,(intern (symbol-name (car accessor)) :keyword))
                             (,(car accessor) obj))))
           (with-connection *db-spec*
             (update-dao obj))))
       
       ;; del-entity
       ,(let ((table (intern (symbol-name name))))
         `(defun ,(intern (concatenate 'string "DEL-" (symbol-name name))) (id)
           (with-connection *db-spec*
             (delete-dao (get-dao ',table id)))))
       
       ;; all-entity
       ,(let ((table (intern (symbol-name name))))
         `(defun ,(intern (concatenate 'string "ALL-" (symbol-name name))) ()
           (with-connection *db-spec*
             (select-dao ',table))))
       
       ;; get-entity (by id)
       ,(let ((table      (intern (symbol-name name)))
              (get-entity (intern (concatenate 'string "GET-" (symbol-name name)))))
         `(defun ,get-entity (id &rest flds)
           (when (not (typep id 'integer))
             (err 'param-get-entity-is-not-integer))
           (with-connection *db-spec*
             (let ((obj (select-dao ',table (:= :id id)))
                   (rs))
               (when (null obj)
                 (return-from ,get-entity nil))
               (setf obj (car obj))
               (when (null obj)
                 (return-from ,get-entity nil))
               (when (null flds)
                 (return-from ,get-entity obj))
               (loop :for fld :in flds :collect
                  (setf (getf rs (intern (symbol-name fld) :keyword))
                        (funcall (intern (symbol-name fld) (find-package ,(symbol-name name)))
                                 obj)))
               rs))))
       
       ;; find-entity
       ,(let ((table (intern (symbol-name name))))
         `(defun ,(intern (concatenate 'string "FIND-" (symbol-name name))) (&rest args)
           (with-connection *db-spec*
             (query-dao ',table
                        (sql-compile
                         (list :select :* :from ',table
                               :where (make-clause-list ':and ':= args)))))))
       
       ;; show-entity
       (defmethod ,(intern "TO-HTML") ((obj ,name) &optional &key filter)
         (with-connection *db-spec*
           (concatenate 'string
                        "<form id='"
                        ,(string-downcase (symbol-name name))
                        "-form'>"
                        ,@(loop :for (fld-name fld-type) :in (car tail) :collect
                             (list
                              (intern (concatenate 'string
                                                   "SHOW-FLD-"
                                                   (if (symbolp fld-type)
                                                       (symbol-name fld-type)
                                                       (format nil "~{~A~^-~}"
                                                               (mapcar #'(lambda (x)
                                                                           (symbol-name x))
                                                                       fld-type)))))
                              (list fld-name 'obj)))
                        "</form>")))
       )))

(defmacro define-automat (name desc &rest tail)
  (let ((package (symbol-package name)))
    (let ((upd-entity (intern (concatenate 'string "UPD-" (symbol-name name))))
          (fields (append (car tail) '((state (or db-null varchar)))))
          (state  (intern "STATE" package))
          (trans  (intern "TRANS" package))
          (takt   (intern "TAKT" package))
          (make-table (intern (concatenate 'string "MAKE-"  (symbol-name name) "-TABLE"))))
      `(progn
         (define-entity ,name ,desc ,fields)
         (,make-table)
         ,(let ((all-states (cadr tail)))
               `(progn
                  ,@(loop :for (from-state to-state event) :in (caddr tail) :collect
                       (if (or (null (find from-state all-states))
                               (null (find to-state all-states)))
                           (err (format nil "unknown state: ~A -> ~A" from-state to-state))
                           `(defmethod ,trans ((obj ,name)
                                               (from-state (eql ,from-state))
                                               (to-state (eql ,to-state)))
                              (prog1 (,(intern (symbol-name event) *package*))
                                (,upd-entity obj (list :state ,(bprint to-state)))))))
                  (defmethod ,takt ((obj ,name) new-state)
                    (,trans obj (read-from-string (,state obj)) new-state))))))))


;; Тестируем сущности
(defun entity-test ()
  
  (when (with-connection *db-spec*
            (query (:select 'table_name :from 'information_schema.tables :where
                            (:and (:= 'table_schema "public")
                                  (:= 'table_name "entity123")))))
    (with-connection *db-spec*
      (query (:drop-table 'entity123))))
  
  (define-entity entity123 "Тестовая сущность"
    ((id serial)
     (email varchar)
     (name (or db-null varchar))))
  
  (make-entity123-table)
  
  (assert (not (null (with-connection *db-spec*
                       (query (:select 'table_name :from 'information_schema.tables :where
                                       (:and (:= 'table_schema "public")
                                             (:= 'table_name "entity123"))))))))
  
  (make-entity123 :email "test-email-1" :name "test-name-1")
  
  (assert (not (null (with-connection *db-spec*
                       (query (:select '* :from 'entity123))))))
  
  (assert (not (null (get-entity123 1))))
  
  (upd-entity123 (get-entity123 1) (list :name "new-name"))
  
  (assert (equal "new-name" (name (get-entity123 1))))
  
  (assert (equal "new-name"
                 (caar
                  (with-connection *db-spec*
                    (query (:select 'name :from 'entity123 :where (:= 'id 1)))))))
  
  (del-entity123 1)
  
  (assert (null (with-connection *db-spec*
                  (query (:select '* :from 'entity123 :where (:= 'id 1))))))
  
  (make-entity123 :email "test-email-2" :name "test-name-2")
  (make-entity123 :email "test-email-3" :name "test-name-3")
  
  (assert (equal 2 (length (all-entity123))))
  
  (assert (equal "test-email-3"
                 (email (car (find-entity123 :name "test-name-3")))))
  
  (with-connection *db-spec*
    (query (:drop-table 'entity123)))
  (dbg "passed: entity-test~%"))
(entity-test)


;; Тестируем автоматы
(defun automat-test ()
  
  (when (with-connection *db-spec*
            (query (:select 'table_name :from 'information_schema.tables :where
                            (:and (:= 'table_schema "public")
                                  (:= 'table_name "automat123")))))
    (with-connection *db-spec*
      (query (:drop-table 'automat123))))
  
  (define-automat automat123 "Тестовый автомат"
    ((id serial)
     (email varchar)
     (name (or db-null varchar)))
    (:on :off :broken)
    ((:on      :off     :switch-off)
     (:off     :on      :switch-on)
     (:on      :broken  :fault)
     (:broken  :off     :stop)))
  
  (assert (not (null (with-connection *db-spec*
                       (query (:select 'table_name :from 'information_schema.tables :where
                                       (:and (:= 'table_schema "public")
                                             (:= 'table_name "automat123"))))))))
  
  (assert (not (null
                (with-connection *db-spec*
                  (query (:select 'column_name :from 'information_schema.columns :where
                                  (:and (:= 'table_schema  "public")
                                        (:= 'table_name    "automat123")
                                        (:= 'column_name   "state"))))))))
  
  (make-automat123 :email "test-email-1" :name "test-name-1")
  
  (upd-automat123 (get-automat123 1) (list :state ":off"))
  
  (defun switch-off ()
    :switch-off)
  
  (defun switch-on ()
    :switch-on)
  
  (defun fault ()
    :fault)
  
  (defun stop ()
    :stop)
  
  (assert (equal '((:SWITCH-ON ":ON") (:SWITCH-OFF ":OFF") (:SWITCH-ON ":ON")
                   (:FAULT ":BROKEN") (:STOP ":OFF"))
                 (loop :for new-state :in '(:on :off :on :broken :off) :collect
                    (list (takt (get-automat123 1) new-state)
                          (state (get-automat123 1))))))
  (assert (not (null
                (with-connection *db-spec*
                  (query (:select 'state :from 'automat123 :where
                                  (:and
                                   (:= 'id 1)
                                   (:= 'state ":OFF"))))))))
  (let ((test t) (err nil))
    (handler-case
        (progn
          (takt (get-automat123 1) :broken)
          (setf test nil))
      (simple-error ()
        (setf err t))
      (assert (and test err))))
  
  (with-connection *db-spec*
    (query (:drop-table 'automat123)))
  (dbg "passed: automat-test~%"))
(automat-test)

(in-package #:moto)

(defun compute-outgoing-states (the-class source-state)
  (let ((applicable-methods))
    (loop :for trans-method :in (closer-mop:generic-function-methods #'trans) :do
       (let ((specializers (closer-mop:method-specializers trans-method)))
         (when (and (equal the-class (class-name (car specializers)))
                    (equal source-state (closer-mop:eql-specializer-object (cadr specializers))))
           (push (closer-mop:eql-specializer-object (nth 2 specializers)) applicable-methods))))
    applicable-methods))

;; (compute-outgoing-states 'vacancy :responded)

(in-package #:moto)

(defmethod possible-trans ((obj t))
  (compute-outgoing-states
   (class-name (class-of obj))
   (intern (subseq (state obj) 1) :keyword)))

;; (possible-trans (get-vacancy 1))
