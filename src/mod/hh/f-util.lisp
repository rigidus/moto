;; [[file:hh.org::*Фунциональные утилиты][f_util]]
(in-package #:moto)

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
;; f_util ends here
