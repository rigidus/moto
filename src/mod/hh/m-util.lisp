;; [[file:hh.org::*Макроутилиты][m_util]]
(in-package #:moto)

(in-package #:moto)


(defmacro !cons (car cdr)
  "Destructive: Set CDR to the cons of CAR and CDR."
  `(setq ,cdr (cons ,car ,cdr)))


(defmacro !cdr (list)
  "Destructive: Set LIST to the cdr of LIST."
  `(setq ,list (cdr ,list)))


(defmacro --each (list &rest body)
  "Anaphoric form of `-each'."
  ;; (declare (debug (form body))
  ;;          (indent 1))
  (let ((l (make-symbol "list")))
    `(let ((,l ,list)
           (it-index 0))
       (while ,l
         (let ((it (car ,l)))
           ,@body)
         (setq it-index (1+ it-index))
         (!cdr ,l)))))

(defun -each (list fn)
  "Call FN with every item in LIST. Return nil, used for side-effects only."
  (--each list (funcall fn it)))


(defmacro --map-when (pred rep list)
  "Anaphoric form of `-map-when'."
  ;; (declare (debug (form form form)))
  (let ((r (make-symbol "result")))
    `(let (,r)
       (--each ,list (!cons (if ,pred ,rep it) ,r))
       (nreverse ,r))))


(defun -map-when (pred rep list)
  "Return a new list where the elements in LIST that does not match the PRED function
     are unchanged, and where the elements in LIST that do match the PRED function are mapped
     through the REP function.

     Alias: `-replace-where'

     See also: `-update-at'"
  (--map-when (funcall pred it) (funcall rep it) list))


(defmacro -> (x &optional form &rest more)
  "Thread the expr through the forms. Insert X as the second item
in the first form, making a list of it if it is not a list
already. If there are more forms, insert the first form as the
second item in second form, etc."
  (cond
    ((null form) x)
    ((null more) (if (listp form)
                     `(,(car form) ,x ,@(cdr form))
                     (list form x)))
    (:else `(-> (-> ,x ,form) ,@more))))

;; (-> 5 1- ODDP)
;; => (-> (-> 5 1-) ODDP)
;; => (ODDP (-> 5 1-))
;; => (ODDP (1- 5))

;; (sb-cltl2:macroexpand-all '(-> 'first (cons 'second) (cons 'third)))
;; => (CONS (CONS 'FIRST 'SECOND) 'THIRD)

(defmacro ->> (x &optional form &rest more)
  "Thread the expr through the forms. Insert X as the last item
in the first form, making a list of it if it is not a list
already. If there are more forms, insert the first form as the
last item in second form, etc."
  (cond
    ((null form) x)
    ((null more) (if (listp form)
                     `(,@form ,x)
                     (list form x)))
    (:else `(->> (->> ,x ,form) ,@more))))

;; (sb-cltl2:macroexpand-all '(->> 'first (cons 'second) (cons 'third)))
;; => (CONS 'THIRD (CONS 'SECOND 'FIRST))


(defmacro .> (fn x chain &rest more)
  "Chainer for accessors like getf and gethash"
  `(,chain ,x ,@(mapcar #'(lambda (x) (list fn x)) more)))

;; (macroexpand-1 '(.> getf y -> :second :third))
;; ;; => (-> Y (GETF :SECOND) (GETF :THIRD))
;; (sb-cltl2:macroexpand-all '(-> Y (GETF :SECOND) (GETF :THIRD)))
;; ;; => (GETF (GETF Y :SECOND) :THIRD)

;; (macroexpand-1 '(.> gethash y ->> :second :third))
;; ;; => (->> Y (GETHASH :SECOND) (GETHASH :THIRD))
;; (sb-cltl2:macroexpand-all '(->> Y (GETHASH :SECOND) (GETHASH :THIRD)))
;; ;; => (GETHASH :THIRD (GETHASH :SECOND Y))



(defmacro --> (x form &rest more)
  "Thread the expr through the forms. Insert X at the position
signified by the token `it' in the first form. If there are more
forms, insert the first form at the position signified by `it' in
in second form, etc."
  (if (null more)
      (if (listp form)
          (--map-when (eq it 'it) x form)
          (list form x))
      `(--> (--> ,x ,form) ,@more)))

;; (sb-cltl2:macroexpand-all
;;  '(--> "test" (list* it '(:a)) reverse (getf it :a)))
;; => (GETF (REVERSE (LIST* "test" '(:A))) :A)


(defmacro -some-> (x &optional form &rest more)
  "When expr is non-nil, thread it through the first form (via `->'),
     and when that result is non-nil, through the next form, etc."
  (if (null form) x
      (let ((result (make-symbol "result")))
        `(-some-> (-when-let (,result ,x)
                    (-> ,result ,form))
                  ,@more))))


(defmacro -some->> (x &optional form &rest more)
  "When expr is non-nil, thread it through the first form (via `->>'),
     and when that result is non-nil, through the next form, etc."
  (if (null form) x
      (let ((result (make-symbol "result")))
        `(-some->> (-when-let (,result ,x)
                     (->> ,result ,form))
                   ,@more))))


(defmacro -some--> (x &optional form &rest more)
  "When expr in non-nil, thread it through the first form (via `-->'),
     and when that result is non-nil, through the next form, etc."
  (if (null form) x
      (let ((result (make-symbol "result")))
        `(-some--> (-when-let (,result ,x)
                     (--> ,result ,form))
                   ,@more))))
;; m_util ends here
