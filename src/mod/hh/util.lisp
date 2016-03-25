;; [[file:hh.org::*Утилиты][utility_file]]
(in-package #:moto)

(defparameter *user-agent* "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0")

(defparameter *cookies*
  (list "portal_tid=1291969547067-10909"
        "__utma=189530924.115785001.1291969547.1297497611.1297512149.377"
        "__utmc=3521885"))

(setf *drakma-default-external-format* :utf-8)

(defun get-headers (referer)
  `(
    ("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
    ("Accept-Charset" . "utf-8")
    ("Referer" . ,referer)
    ;; ("Cookie" . ,(format nil "~{~a; ~}" *cookies*))
    ("Cookie" . "ad20c=2; ad17c=2; __utma=48706362.2093251633.1396569814.1413985658.1413990550.145; __utmz=48706362.1413926450.142.18.utmcsr=vk.com|utmccn=(referral)|utmcmd=referral|utmcct=/im; email=avenger-f%40yandex.ru; password=30e3465569cc7433b34d42baeadff18f; PHPSESSID=ms1rrsgjqvm3lhdl5af1aekvv0; __utmc=48706362; __utmb=48706362.5.10.1413990550")
    ))

(defmacro web (to ot)
  (let ((x-to (append '(format nil) to))
        (x-ot (append '(format nil) ot)))
    `(let ((r (sb-ext:octets-to-string
               (drakma:http-request ,x-to
                                    :user-agent *user-agent*
                                    :additional-headers (get-headers ,x-ot)
                                    :redirect 10
                                    :force-binary t)
               :external-format :utf-8)))
       r)))

(defmacro fnd (var pattern)
  `(multiple-value-bind (all matches)
       (ppcre:scan-to-strings ,pattern ,var)
     (let ((str (format nil "~a" matches)))
       (subseq str 2 (- (length str) 1)))))

(defun merge-plists (&rest plists)
  "Merge all the given plists into a new plist. The new plist has all
the keys from each plist, with values of keys in later lists
overriding the values of the same keys in earlier plists.
No particular order of key/value pairs is guaranteed.
E.g.:
> (merge-plists '(:a 1 :b 2) '(:a 3 :c 4) '(:d 5))
(:D 5 :C 4 :A 3 :B 2)"
(let ((result (copy-list (first plists))))
  (dolist (plist (rest plists))
    (do* ((prop (first plist) (first plist))
          (value (second plist) (second plist))
          (oldpl plist plist)
          (plist plist (cddr plist)))
         ((not oldpl))
      (setf (getf result prop) value)))
  result))

;; eval-always

(defmacro eval-always (&body body)
  "Wrap <_:arg body /> in <_:fun eval-when /> with all keys \(compile, load and execute) mentioned"
  `(eval-when (:compile-toplevel :load-toplevel :execute)
     ,@body))

;; #` syntax

;; (eval-always
;;   (defun |#`-reader| (stream char arg)
;;     "Literal syntax for zero/one/two argument lambdas.
;; Use @ as the function's argument, % as the second.
;; Examples:
;; CL-USER> #`(+ 2 @)
;; \(lambda (&optional x y)
;;    (+ 2 x))
;; CL-USER>  #`((1+ @) (print @))
;; \(lambda (&optional x y)
;;    (1+ x)
;;    (print x))
;; CL-USER> #`(+ 1 2)
;; \(lambda (&optional x y)
;;    (+ 1 2))
;; CL-USER>  #`(+ @ %)
;; \(lambda (&optional x y)
;;    (+ x y))
;; "
;;     (declare (ignore char arg))
;;     (let ((sexp (read stream t nil t))
;;           (x (gensym "X"))
;;           (y (gensym "Y")))
;;       `(lambda (&optional ,x ,y)
;;          (declare (ignorable ,x)
;;                   (ignorable ,y))
;;          ,@(subst y '%
;;                   (subst x '@
;;                          (if (listp (car sexp))
;;                              sexp
;;                              (list sexp)))))))
;;   ;; set #`
;;   (set-dispatch-macro-character #\# #\` #'|#`-reader|))

;; anaphoric

(eval-always
 (defmacro if-it (test then &optional else)
   "Like IF. IT is bound to TEST."
   `(let ((it ,test))
      (if it ,then ,else))))

(eval-always
 (defmacro when-it (test &body body)
   "Like WHEN. IT is bound to TEST."
   `(let ((it ,test))
      (when it
        ,@body))))

(eval-always
 (defmacro and-it (&rest args)
   "Like AND. IT is bound to the value of the previous AND form."
   (cond ((null args) t)
         ((null (cdr args)) (car args))
         (t `(when-it ,(car args) (and-it ,@(cdr args)))))))

(eval-always
 (defmacro dowhile-it (test &body body)
   "Like DOWHILE. IT is bound to TEST."
   `(do ((it ,test ,test))
        ((not it))
      ,@body)))

;; (eval-always
;;  (defmacro cond-it (&body body)
;;    "Like COND. IT is bound to the passed COND test."
;;    `(let (it)
;;       (cond
;;         ,@(mapcar #``((setf it ,(car @)) ,(cadr @))
;;                   ;; uses the fact, that SETF returns the value set
;;                   body)))))

;; maybe

(defmacro maybecall (val &rest funs)
  `(and-it ,val
           ,@(mapcar (lambda (fun)
                       `(funcall ,fun it))
                     funs)))

(defmacro maybe (form)
  "Return a value, returned by a <_:arg form /> or nil, if <_:class error /> is signalled"
  `(restart-case
       (handler-bind ((error #'(lambda (c)
                                 (declare (ignore condition))
                                 (invoke-restart 'skip))))
         ,form)
     (skip () nil)))
;; utility_file ends here
