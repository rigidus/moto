;; [[file:karnaugh.org::*Сборка][Сборка:1]]
;; Макросы для корректного вывода ошибок
(ql:quickload "ltk")
(use-package :ltk)

(defmacro bprint (var)
  `(subseq (with-output-to-string (*standard-output*)  (pprint ,var)) 1))

(defmacro err (var)
  `(error (format nil "ERR:[~A]" (bprint ,var))))

(defclass agenda ()
  ((current-time  :initarg :current-time  :accessor current-time  :initform 0)
   (segments      :initarg :segments      :accessor segments      :initform nil)))

(defclass wire ()
  ((name               :initarg :name               :accessor name          :initform (gensym "WIRE-"))
   (signal-value       :initarg :signal-value       :accessor signal-value  :initform 0)
   (action-procedures  :initarg :action-procedures  :accessor action-procedures :initform nil)))

(defclass time-segment ()
  ((timepoint  :initarg :timepoint  :accessor timepoint  :initform 0)
   (queue      :initarg :queue     :accessor queue      :initform nil)))

(defclass queue ()
  ((front-ptr   :initarg :front-ptr   :accessor front-ptr :initform nil)
   (rear-ptr    :initarg :rear-ptr    :accessor rear-ptr  :initform nil)))

(defstruct point
  (x 0 :type integer)
  (y 0 :type integer))

(defstruct inout
  (coord nil :type point)
  (wire  nil :type symbol))

(defclass vis ()
  ((base     :initarg :base     :accessor base    :type point)
   (inputs   :initarg :inputs   :accessor inputs  :type list-of-inout :initform nil)
   (outputs  :initarg :outputs  :accessor outputs :type list-of-inout :initform nil)))

(defclass and-elt (vis) ())
(defclass or-elt  (vis) ())
(defclass not-elt (vis) ())

(defmethod get-drawer ((obj and-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 30) ,(+ y 0)))
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 10) ,(+ y 30)))
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 30) ,(+ y 30)))
      (create-arc canvas (+ x 15) y (+ x 45) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 10) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 10) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-line canvas `(,(+ x 45) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 15) (+ y 7) "and"))))

(defmethod get-drawer ((obj or-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 20) ,(+ y 0)))
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 10) ,(+ y 30)))
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 20) ,(+ y 30)))
      (create-arc canvas (+ x -15) (+ y 00) (+ x 45) (+ y 60) :start 30 :extent 60 :style "arc")
      (create-arc canvas (+ x -15) (+ y 30) (+ x 45) (- y 30) :start -30 :extent -60 :style "arc")
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 10) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 10) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-line canvas `(,(+ x 40) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 15) (+ y 7) "or"))))

(defmethod get-drawer ((obj not-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 10) ,(+ y 30)))
      (create-line canvas `(,(+ x 10) ,(+ y 00) ,(+ x 35) ,(+ y 15)))
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 35) ,(+ y 15)))
      (create-oval canvas (- (+ x 40) 5) (- (+ y 15) 5) (+ (+ x 40) 5) (+ (+ y 15) 5))
      (create-line canvas `(,(+ x 0) ,(+ y 15) ,(+ x 10) ,(+ y 15)))
      (create-oval canvas (+ x -1) (+ y 14) (+ x 1) (+ y 16))
      (create-line canvas `(,(+ x 45) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16)))))

(defun viz (canvas elts)
  (with-ltk ()
    (let ((ht (make-hash-table))
          (wires))
      (mapcar #'(lambda (elt)
                  (funcall (get-drawer elt) canvas)
                  (setf wires (append wires (inputs elt)))
                  (setf wires (append wires (outputs elt))))
              elts)
      (mapcar #'(lambda (x)
                  (setf (gethash (inout-wire x) ht)
                        (append (gethash (inout-wire x) ht)
                                (list (inout-coord x)))))
              wires)
      (maphash #'(lambda (k v)
                   (format t "~% ~A : ~A" k v)
                   (let ((first-point nil))
                     (loop :for n :in v :do
                        (if (null first-point)
                            (progn
                              (setf first-point n)
                              (unless (equal 0 (search "WIRE-" (symbol-name k)))
                                (create-text canvas
                                             (point-x n) (point-y n)
                                             (format nil "~A=~A" (symbol-name k)
                                                     (signal-value (symbol-value k))
                                                     ))))
                            ;; else
                            (progn
                              (create-line canvas
                                           `(,(point-x first-point) ,(point-y first-point)
                                              ,(point-x n) ,(point-y n)))
                              (setf first-point n))))))
               ht)
      (pack canvas))))


(defparameter *the-agenda* (make-instance 'agenda))
(defparameter *inverter-delay* 2)
(defparameter *and-gate-delay* 3)
(defparameter *or-gate-delay* 5)


(defmethod empty ((obj queue))
  (null (front-ptr obj)))

(defmethod front ((obj queue))
  (if (empty obj)
      (err "front-queue: empty queue")
      (car (front-ptr obj))))

(defmethod insert ((obj queue) item)
  (let ((new-pair (cons item '())))
    (cond ((empty obj)
           (progn
             (setf (front-ptr obj) new-pair)
             (setf (rear-ptr obj) new-pair)))
          (t
           (progn
             (setf (cdr (rear-ptr obj)) new-pair)
             (setf (rear-ptr obj) new-pair))))
    obj))

(defmethod del ((obj queue))
  (cond ((empty obj) (err "delete-queue: empty"))
        (t (setf (front-ptr obj) (cdr (front-ptr obj)))))
  obj)


(defmethod empty ((obj agenda))
  (null (segments obj)))

(defparameter *the-agenda* (make-instance 'agenda))

(defun belongs-before (time segments)
  (or (null segments)
      (< time (timepoint (car segments)))))

(defun make-new-time-segment (time action)
  (let ((que (make-instance 'queue)))
    (insert que action)
    (make-instance 'time-segment :timepoint time :queue que)))

(defun add-to-segments (segments time action)
  (if (equal (timepoint (car segments)) time)
      (insert (queue (car segments)) action)
      ;; else
      (let ((rest (cdr segments)))
        (if (belongs-before time rest)
            (setf (cdr segments)
                  (append (cdr segments)
                          (list (make-new-time-segment time action))))
            ;; else
            (add-to-segments rest time action)))))

(defmethod add-to-agenda ((obj agenda) time action)
  (let ((segments (segments obj)))
    (if (belongs-before time segments)
        (setf (segments obj)
              (append (segments obj)
                      (list (make-new-time-segment time action))))
        ;; else
        (add-to-segments segments time action))))

(defmethod after-delay ((obj agenda) delay action)
  (add-to-agenda obj
                 (+ delay (current-time obj))
                 action))

(defmethod remove-first-agenda-item ((obj agenda))
  (let ((segments (segments obj)))
    (when (null segments)
      (err "remove-first-agenda-item: empty segments"))
    (let ((que (queue (car segments))))
      (del que)
      (if (empty que)
          (setf (segments obj)
                (cdr (segments obj)))))))

(defmethod first-agenda-item ((obj agenda))
  (if (null (segments obj))
      (err "agenda empty")
      (let ((first-seg (car (segments obj))))
        (setf (current-time obj) (timepoint first-seg))
        (front (queue first-seg)))))

(defmethod propagate ((obj agenda))
  (if (empty obj)
      (return-from propagate nil)
      ;; else
      (let ((first-item (first-agenda-item obj)))
        (funcall first-item)
        (remove-first-agenda-item obj)
        (propagate obj))))


(defmethod get-signal ((obj wire))
  (signal-value obj))

(defmethod set-signal ((obj wire) new-value)
  (if (not (equal (signal-value obj) new-value))
      (progn
        (setf (signal-value obj) new-value)
        (loop :for procedure :in (action-procedures obj) :do (funcall procedure)))))

(defmethod add-action ((obj wire) procedure)
  (setf (action-procedures obj)
        (append (action-procedures obj) (list procedure)))
  (funcall procedure))


(defun logical-not (s)
  (cond ((equal s 0) 1)
        ((equal s 1) 0)
        (t (err "logical not error signal"))))

(defun inverter (input output coord-x coord-y)
  (let* ((obj (make-instance 'not-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 15))
                 :wire (name input))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :wire (name output))))
    (flet ((invert-input ()
             (let ((new-value (logical-not (get-signal input))))
               (after-delay *the-agenda* *inverter-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action input #'invert-input))
    obj))

(defun logical-and (a b)
  (cond ((and (equal a 1) (equal b 1)) 1)
        ((and (equal a 0) (equal b 1)) 0)
        ((and (equal a 1) (equal b 0)) 0)
        ((and (equal a 0) (equal b 0)) 0)
        (t (err "logical-and error signal"))))

(defun and-gate (a1 a2 output coord-x coord-y)
  (let* ((obj (make-instance 'and-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 09))
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :wire (name output))))
    (flet ((and-action-procedure ()
             (let ((new-value (logical-and (get-signal a1) (get-signal a2))))
               (after-delay *the-agenda*  *and-gate-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action a1 #'and-action-procedure)
      (add-action a2 #'and-action-procedure))
    obj))

(defun logical-or (a b)
  (cond ((and (equal a 1) (equal b 1)) 1)
        ((and (equal a 0) (equal b 1)) 1)
        ((and (equal a 1) (equal b 0)) 1)
        ((and (equal a 0) (equal b 0)) 0)
        (t (err "logical-or error signal"))))

(defun or-gate (a1 a2 output coord-x coord-y)
  (let* ((obj (make-instance 'or-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 09))
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :wire (name output))))
    (flet ((or-action-procedure ()
             (let ((new-value (logical-or (get-signal a1) (get-signal a2))))
               (after-delay *the-agenda* *or-gate-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action a1 #'or-action-procedure)
      (add-action a2 #'or-action-procedure))
    obj))


(defun half-adder (a b s c coord-x coord-y
                   &key (d (make-instance 'wire)) (e (make-instance 'wire)))
  (list
   (or-gate a b d (+ coord-x 15) (+ coord-y 0))
   (and-gate a b c (+ coord-x 0) (+ coord-y 50))
   (inverter c e (+ coord-x 60) (+ coord-y 50))
   (and-gate d e s (+ coord-x 90) (+ coord-y 6))))

(defun full-adder (a b c-in sum c-out coord-x coord-y
                   &key
                     (s (make-instance 'wire))
                     (c1 (make-instance 'wire))
                     (c2 (make-instance 'wire)))
  (append
   (half-adder b c-in s c1 coord-x (+ 0 coord-y))
   (half-adder a s sum c2 (+ coord-x 150) coord-y)
   (list
    (or-gate c1 c2 c-out 200 200))))


(defun probe (name wire)
  (add-action wire #'(lambda ()
                       (format t "~%name: ~A; time: ~A; value: ~A"
                               name
                               (current-time *the-agenda*)
                               (get-signal wire)))))

(defparameter *input-1* (make-instance 'wire :name '|a|))
(defparameter *input-2* (make-instance 'wire :name '|b|))
(defparameter *sum* (make-instance 'wire :name '|sum|))
(defparameter *carry* (make-instance 'wire :name '|cf|))

(probe 'sum *sum*)
(probe 'carry *carry*)
(half-adder *input-1* *input-2* *sum* *carry*)
(set-signal *input-1* 1)
(propagate *the-agenda*)

(set-signal *input-2* 1)
(propagate *the-agenda*)

;; (mapcar #'(lambda (x)
;;             (list (timepoint x) (front-ptr (queue x))))
;;         (segments *the-agenda*))


(let ((a (make-instance 'wire :name 'a))
      (b (make-instance 'wire :name 'b))
      (s (make-instance 'wire :name 's))
      (c (make-instance 'wire :name 'c)))
  (declare (special a))
  (declare (special b))
  (declare (special s))
  (declare (special c))
  (let ((elts (half-adder a b s c 50 50))
        (canvas (make-instance 'canvas)))
    (set-signal a 1)
    (set-signal b 1)
    (propagate *the-agenda*)
    ;; (print elts))
    (viz canvas elts)))

(let ((s (make-instance 'wire :name 's))
      (c1 (make-instance 'wire :name 'c1))
      (c2 (make-instance 'wire :name 'c2)))
  (declare (special s))
  (declare (special c1))
  (declare (special c2))
  (let ((a (make-instance 'wire :name 'a))
        (b (make-instance 'wire :name 'b))
        (c-in (make-instance 'wire :name 'c-in))
        (sum (make-instance 'wire :name 'sum))
        (c-out (make-instance 'wire :name 'c-out)))
    (declare (special cf))
    (declare (special a))
    (declare (special b))
    (declare (special c-in))
    (declare (special sum))
    (declare (special c-out))
    (let ((elts (full-adder a b c-in sum c-out 20 20 :s s :c1 c1 :c2 c2))
          (canvas (make-instance 'canvas)))
      (set-signal a 1)
      (set-signal c-in 1)
      (propagate *the-agenda*)
      ;; (print elts))
      (viz canvas elts))))
;; Сборка:1 ends here
