;; [[file:hh.org::*Фунциональные утилиты][f_util]]
(in-package #:moto)

(in-package #:moto)

(defun maptree-if (predicate transformer tree)
  (multiple-value-bind (t-tree control)
      (if (funcall predicate tree)
          (funcall transformer tree)
          (values tree #'mapcar))
    (if (and (consp t-tree)
             control)
        (funcall control
                 #'(lambda (x)
                     (maptree-if predicate transformer x))
                 t-tree)
        t-tree)))
(in-package #:moto)

(defmacro with-predict-maptree (pattern condition replace tree)
  (let ((lambda-param (gensym)))
    `(maptree-if #'(lambda (,lambda-param)
                     (and (consp ,lambda-param)
                        (funcall (with-predict-if ,pattern
                                   ,condition)
                                 ,lambda-param)))
                 ,replace
                 ,tree)))

;; (macroexpand-1
;;  '(with-predict-maptree (a b &rest c)
;;    (and (equal b 'ping))
;;    #'(lambda (x)
;;        (values `(,**a** pong ,@(cddr x)) #'mapcar))
;;    '(progn (ping (ping ping (ping 1))) ping)))

;; (with-predict-maptree (a b &rest c)
;;   (and (equal b 'ping))
;;   #'(lambda (x)
;;       (values `(,**a** pong ,@(cddr x)) #'mapcar))
;;   '(progn (ping (ping ping (ping 1))) ping))
(in-package #:moto)

(defmacro define (form* form)
  (etypecase form*
    (symbol (etypecase form
              ;; alias for function or macro
              (symbol `(defmacro ,form* (&rest args)
                         `(,',form ,@args)))
              ;; alias for lambda
              (cons   `(defun ,form* (&rest args)
                         (apply ,form args)))))
    (cons     ;; scheme-like function definition
     ` (defun ,(first form*) ,(rest form*)
         ,form))))
(in-package #:moto)

(define head car)
(define tail cdr)
(define \\   lambda)
(define $    funcall)
(in-package #:moto)

(defmacro define* (form* form)
  `(defun ,(first form*) ,(rest form*)
     (,(first form) ,@(rest form) ,@(rest form*))))
(in-package #:moto)

(define (self object) object)
(define (flip f)      (\\ (a b) ($ f b a)))
(define (curry f a)   (\\ (b)   ($ f a b)))
(define (curry* f g)  (\\ (a b) ($ f g a b)))
(define (compose f g) (\\ (a)   ($ f ($ g a))))
(in-package #:moto)

(define (foldl f a list)
    (typecase list
      (null a)
      (cons (foldl f ($ f a (head list)) (tail list)))))

(define (foldr f a list)
    (typecase list
      (null a)
      (cons ($ f (head list) (foldr f a (tail list))))))

(define (unfold f i p)
    (if ($ p i)
        (cons i '())
        (cons i (unfold f ($ f i) p))))

(define fold foldl)
(define my-reduce fold)
(in-package #:moto)

;; map & filter
(define (my-map f list) (foldr (\\ (x y) (cons ($ f x) y)) '() list))
(define (filter p list) (foldr (\\ (x y) (if ($ p x) (cons x y) y)) '() list))
(in-package #:moto)

;; functions for lists
(define (my-list &rest objs)         objs)
(define (my-length list)             (fold (\\ (x y) (1+ x)) 0 list))
(define (my-reverse list)            (fold (flip 'cons) '() list))
(define (my-append list &rest lists) (fold (flip (curry* 'foldr 'cons)) list lists))
(in-package #:moto)

;; functions for numbers
(define zero?                    (curry '= 0))
(define positive?                (curry '< 0))
(define negative?                (curry '> 0))
(define (odd? number)            (= (mod number 2) 1))
(define (even? number)           (= (mod number 2) 0))
(define (my-max a &rest numbers) (fold (\\ (y z) (if (> y z) y z)) a numbers))
(define (my-min a &rest numbers) (fold (\\ (y z) (if (< y z) y z)) a numbers))
(define (summa &rest numbers)    (fold '+ 0 numbers))
(define (product &rest numbers)  (fold '* 1 numbers))
(in-package #:moto)

;; functions for booleans
(define (my-and &rest list)   (fold 'and t list))
(define (my-or &rest list)    (fold 'or nil list))
(define (any? p &rest list)   (apply 'my-or (my-map p list)))
(define (every? p &rest list) (apply 'my-and (my-map p list)))

(in-package #:moto)

;; member & assoc
(flet ((helper (p op)
         (\\ (a next) (if (and (not a) ($ p ($ op next))) next a))))

  (define (my-member object list &key (test 'equal))
      (fold (helper (curry test object) 'self) nil list))

  (define (my-assoc object alist &key (test 'equal))
      (fold (helper (curry test object) 'car) nil alist)))
(in-package #:moto)

;; for (1 . (2 . 3)) trees

(define (my-append a b)
    (append (if (atom a) (list a) a)
            (if (atom b) (list b) b)))

(define (fold-tree f g tree)
    (typecase tree
      (atom ($ f tree))
      (cons ($ g (fold-tree f g (head tree))
               (fold-tree f g (tail tree))))))

(define* (summa/tree tree) (fold-tree 'self '+))
(define* (depth/tree tree) (fold-tree 'one 'max+1))
(define* (flatten tree)    (fold-tree 'self 'my-append))

(in-package #:moto)

(defun my-range (n)
  (let ((i 0))
    #'(lambda ()
        (if (< i n) (incf i) nil))))

(let ((f (my-range 3)))
  (list
   (funcall f)
   (funcall f)
   (funcall f)
   (funcall f)
   (funcall f)
))

(range 3)

(defmacro do-closure ((i clos) &body body)
  (let ((c (gensym)))
    `(let ((,c ,clos))
       (loop for ,i = (funcall ,c)
          while ,i do ,@body))))

(do-closure (i (my-range 100)) (print i))

 ;; (maptree-if #'(lambda (x)
 ;;                 (and (consp x)
 ;;                      (eq (car x) 'ping)))
 ;;             #'(lambda (x)
 ;;                 `(pong ,@(cdr x)))
 ;;             '(progn (ping (ping (ping 1)))))

 ;; (maptree-if #'(lambda (x)
 ;;                 (and (consp x)
 ;;                      (eq (car x) 'ping)))
 ;;               #'(lambda (x)
 ;;                   (values `(pong ,@(cdr x))
 ;;                           #'mapcar))
 ;;               '(progn (ping (ping (ping 1)))))

 ;; (defun map-in-tree (keys transformer tree)
 ;;   (maptree-if #'(lambda (x)
 ;;                   (and (consp x)
 ;;                        (member (car x) keys)))
 ;;               transformer
 ;;               tree))

 (declaim (inline zip))
 (defun zip (&rest args)
   "
 Zips the elements of @arg{args}.
 Example:
 @lisp
 > (zip '(2 3 4) '(a b c) '(j h c s))
 => ((2 A J) (3 B H) (4 C C))
 @end lisp
 "
   (apply #'map 'list #'list args))

 (defun symstuff (l)
   "From the Common Lisp Cookbook - http://cl-cookbook.sourceforge.net/macros.html
 Helper function to (build-symbol)"
   `(concatenate 'string
                 ,@(for (x :in l)
                        (cond ((stringp x)
                               `',x)
                              ((atom x)
                               `',(format nil "~a" x))
                              ((eq (car x) ':<)
                               `(format nil "~a" ,(cadr x)))
                              ((eq (car x) ':++)
                               `(format nil "~a" (incf ,(cadr x))))
                              (t
                               `(format nil "~a" ,x))))))

 (defmacro build-symbol (&rest l)
   "From the Common Lisp Cookbook - http://cl-cookbook.sourceforge.net/macros.html"
   (let ((p (find-if (lambda (x) (and (consp x) (eq (car x) ':package)))
                     l)))
     (cond (p
            (setq l (remove p l))))
     (let ((pkg (cond ((eq (cadr p) 'nil)
                       nil)
                      (t `(find-package ',(cadr p))))))
       (cond (p
              (cond (pkg
                     `(values (intern ,(symstuff l) ,pkg)))
                    (t
                     `(make-symbol ,(symstuff l)))))
             (t
              `(values (intern ,(symstuff l))))))))

 (defun remove-nth (n seq)
   "Remove nth element from sequence"
   (remove-if (constantly t) seq :start n :count 1))

 (defun make-hash (&rest keyvals)
   "Create a hash table given keys and values"
   (plist-hash-table keyvals))

 (defmacro make-hash* (&rest keyvals)
   "Make a hash table given key/value pairs, allowing use of prior key/val pairs in late r definitions"
   (loop while keyvals
      for k = (intern (symbol-name (pop keyvals)))
      for v = (pop keyvals)
      collect `(,k ,v) into letargs
      collect (make-keyword k) into objargs
      collect k into objargs
      finally (return
                `(let* (,@letargs)
                   (make-hash ,@objargs)))))

 (defun maphash2 (fn ht)
   "Returns a hash-table with the results of the function of key & value as values"
   (let ((ht-out (make-hash-table
                  :test (hash-table-test ht)
                  :size (hash-table-size ht)
                  :rehash-size (hash-table-rehash-size ht)
                  :rehash-threshold (hash-table-rehash-threshold ht))))
     (maphash #'(lambda (k v)
                  (setf (gethash k ht-out) (funcall fn k v)))
              ht)
     ht-out))

 (defun maphash-values2 (fn ht)
   "Returns a hash-table with the results of the function of value as values"
   (let ((ht-out (make-hash-table)))
     (maphash #'(lambda (k v) (setf (gethash k ht-out) (funcall fn v))) ht)
     ht-out))

 (defmacro swap (pl1 pl2)
   "Macro to swap two places"
   (let ((temp1-name (gensym)) ; don't clobber existing names
         (temp2-name (gensym)))
     `(let ((,temp1-name ,pl1)
            (,temp2-name ,pl2))
        (setf ,pl1 ,temp2-name)
        (setf ,pl2 ,temp1-name))))

 (defun print-hash-key-or-val (kv stream)
   (format stream (typecase kv
                    (keyword " :~a")
                    (string " \"~a\"")
                    (symbol " '~a")
                    (list " '~a")
                    (t " ~a")) kv))

 (defun printhash (h &optional (stream t))
   "Pretty print a hash table as :KEY VAL on separate lines"
   (format stream "#<HASH-TABLE~{~a~a~^~&~}>"
           (loop for k being the hash-keys in h using (hash-value v)
              collect (print-hash-key-or-val k nil)
              collect (print-hash-key-or-val v nil))))

 (defmacro lethash (keys h &body body)
   "Let form binding hash table entries to let variables names"
   (let ((ht (gensym)))
     `(let ((,ht ,h))
        (let ,(loop for key in keys
                 collect `(,key (gethash ,(make-keyword key) ,ht)))
          ,@body))))

 (defmacro with-keys (keys h &body body)
   "Make keys of hash table available to body for use & changable via setf"
   (let ((ht (gensym)))
     (loop for key in keys
        for newbody = (subst `(gethash ,(make-keyword key) ,ht) key body)
        then (subst `(gethash ,(make-keyword key) ,ht) key newbody)
        finally (return `(let ((,ht ,h))
                           ,@newbody)))))

 (defun linear-interpolation (ys xs x)
   "Linear interpolation: calculate y(x) at x given table of ys and xs. Also returns ind ex of lookup table interval. Works from first x to less than last x."
   (let* ((i (position x xs :test #'>= :from-end t))
          (x0 (elt xs i))
          (x1 (elt xs (1+ i)))
          (y0 (elt ys i))
          (y1 (elt ys (1+ i))))
     (+ y0 (* (- y1 y0) (- x x0) (/ (- x1 x0))))))

 (defun maptree (f tree)
   "Map a function on the leaves of a tree"
   (cond
     ((null tree) nil)
     ((atom tree) (funcall f tree))
     (t (cons (maptree f (car tree))
              (maptree f (cdr tree))))))

 (defmethod diff ((l list))
   "Return list of the 1st differences of given list: l(1)-l(0),...,l(n)-l(n-1)"
     (loop for i below (1- (length l))
        for li in l
        collect (- (elt l (1+ i)) li)))

 (defmethod diff ((v vector))
   "Return vector of the 1st differences of given vector: v(1)-v(0),...,v(n)-v(n-1)"
   (let* ((n (length v))
          (v2 (make-array (1- n))))
     (dotimes (i (1- n))
       (setf (aref v2 i) (- (aref v (1+ i)) (aref v i))))
     v2))

 (defun slot-ref (obj slots)
   "Reference nested objects by a list of successive slot names. For example, (slot-ref  o 'foo 'bar 'baz) should return (slot-value (slot-value (slot-value o 'foo) 'bar) 'baz) "
   (cond
     ((atom slots) (slot-value obj slots))
     ((null (cdr slots)) (slot-value obj (car slots)))
     (t (slot-ref (slot-value obj (first slots)) (rest slots)))))

 (defun slot-ref-set (obj slots val)
   "Set nested object slot reference to new value"
   (cond
     ((atom slots) (setf (slot-value obj slots) val))
     ((null (cdr slots)) (setf (slot-value obj (car slots)) val))
     (t (slot-ref-set (slot-value obj (first slots)) (rest slots) val))))

 (defsetf slot-ref slot-ref-set)

 (defmacro bind-nested-slots (forms obj &body body)
   "For each form of (VAR SLOT1 SLOT2 ...) bind VAR to (NESTED-SLOT OBJ SLOT1 SLOT2 ...) "
   `(let ,(loop for form in forms
             collect `(,(first form) (slot-ref ,obj ',(rest form))))
      ,@body))

 (defmacro defpfun (name args pargs &body body)
   "Define pandoric function given name, arguments, pandoric arguments,
 & body forms."
   `(setf (symbol-function ',name)
          (plambda ,args ,pargs
                   ,@body)))
;; f_util ends here
