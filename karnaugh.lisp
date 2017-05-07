;; [[file:karnaugh.org::*Сборка][Сборка:1]]
;; Макросы для корректного вывода ошибок
(ql:quickload "ltk")
(use-package :ltk)

(defun ltk::create-rectangle (canvas x0 y0 x1 y1 &key (fill "#e0e0e0") (outline "black"))
  (ltk::format-wish "senddata [~a create rectangle ~a ~a ~a ~a -fill ~A -outline ~A]"
                    (ltk::widget-path canvas)
                    (ltk::tk-number x0) (ltk::tk-number y0) (ltk::tk-number x1) (ltk::tk-number y1)
                    fill outline)
  (ltk::read-data))

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
  (coord   nil :type point)
  (is-out  nil :type boolean)
  (wire    nil :type symbol))

(defclass vis ()
  ((base     :initarg :base     :accessor base    :type point)
   (inputs   :initarg :inputs   :accessor inputs  :type list-of-inout :initform nil)
   (outputs  :initarg :outputs  :accessor outputs :type list-of-inout :initform nil)))

(defclass and-elt  (vis) ())
(defclass nand-elt (vis) ())
(defclass or-elt   (vis) ())
(defclass nor-elt  (vis) ())
(defclass xor-elt  (vis) ())
(defclass nxor-elt (vis) ())
(defclass not-elt  (vis) ())
(defclass conn-elt (vis) ())


(defmethod get-drawer ((obj and-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
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

(defmethod get-drawer ((obj nand-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 32) ,(+ y 0)))
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 10) ,(+ y 30)))
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 32) ,(+ y 30)))
      (create-arc canvas (+ x 15) y (+ x 50) (+ y 30) :start -90 :extent 72 :style "arc")
      (create-arc canvas (+ x 15) y (+ x 50) (+ y 30) :start 90 :extent -72 :style "arc")
      (create-oval canvas (- (+ x 49) 4) (- (+ y 15) 4) (+ (+ x 49) 4) (+ (+ y 15) 4))
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 10) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 10) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 13) (+ y 7) "nand"))))

(defmethod get-drawer ((obj or-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 20) ,(+ y 0)))
      (create-arc canvas (- x 0) y (+ x 15) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 20) ,(+ y 30)))
      (create-arc canvas (+ x -15) (+ y 00) (+ x 45) (+ y 60) :start 30 :extent 60 :style "arc")
      (create-arc canvas (+ x -15) (+ y 30) (+ x 45) (- y 30) :start -30 :extent -60 :style "arc")
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 14) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 14) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-line canvas `(,(+ x 40) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 20) (+ y 7) "or"))))

(defmethod get-drawer ((obj nor-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 20) ,(+ y 0)))
      (create-arc canvas (- x 0) y (+ x 15) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 20) ,(+ y 30)))
      (create-arc canvas (+ x -11) (+ y 00) (+ x 50) (+ y 60) :start 30 :extent 60 :style "arc")
      (create-arc canvas (+ x -11) (+ y 30) (+ x 50) (- y 30) :start -30 :extent -60 :style "arc")
      (create-oval canvas (- (+ x 49) 4) (- (+ y 15) 4) (+ (+ x 49) 4) (+ (+ y 15) 4))
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 14) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 14) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 19) (+ y 7) "nor"))))

(defmethod get-drawer ((obj xor-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 20) ,(+ y 0)))
      (create-arc canvas (- x 5) y (+ x 10) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-arc canvas (- x 0) y (+ x 15) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 20) ,(+ y 30)))
      (create-arc canvas (+ x -11) (+ y 00) (+ x 50) (+ y 60) :start 30 :extent 60 :style "arc")
      (create-arc canvas (+ x -11) (+ y 30) (+ x 50) (- y 30) :start -30 :extent -60 :style "arc")
      ;; (create-oval canvas (- (+ x 49) 4) (- (+ y 15) 4) (+ (+ x 49) 4) (+ (+ y 15) 4))
      (create-line canvas `(,(+ x 45) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 14) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 14) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 19) (+ y 7) "xor"))))

(defmethod get-drawer ((obj nxor-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 20) ,(+ y 0)))
      (create-arc canvas (- x 3) y (+ x 7) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-arc canvas (- x 0) y (+ x 12) (+ y 30) :start -90 :extent 180 :style "arc")
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 20) ,(+ y 30)))
      (create-arc canvas (+ x -11) (+ y 00) (+ x 50) (+ y 60) :start 30 :extent 60 :style "arc")
      (create-arc canvas (+ x -11) (+ y 30) (+ x 50) (- y 30) :start -30 :extent -60 :style "arc")
      (create-oval canvas (- (+ x 49) 4) (- (+ y 15) 4) (+ (+ x 49) 4) (+ (+ y 15) 4))
      (create-line canvas `(,(+ x 0) ,(+ y 09) ,(+ x 12) ,(+ y 09)))
      (create-oval canvas (+ x -1) (+ y 08) (+ x 1) (+ y 10))
      (create-line canvas `(,(+ x 0) ,(+ y 21) ,(+ x 12) ,(+ y 21)))
      (create-oval canvas (+ x -1) (+ y 20) (+ x 1) (+ y 22))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16))
      (create-text canvas (+ x 15) (+ y 7) "nxor"))))

(defmethod get-drawer ((obj not-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 55) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 10) ,(+ y 0) ,(+ x 10) ,(+ y 30)))
      (create-line canvas `(,(+ x 10) ,(+ y 00) ,(+ x 35) ,(+ y 15)))
      (create-line canvas `(,(+ x 10) ,(+ y 30) ,(+ x 35) ,(+ y 15)))
      (create-oval canvas (- (+ x 40) 5) (- (+ y 15) 5) (+ (+ x 40) 5) (+ (+ y 15) 5))
      (create-line canvas `(,(+ x 0) ,(+ y 15) ,(+ x 10) ,(+ y 15)))
      (create-oval canvas (+ x -1) (+ y 14) (+ x 1) (+ y 16))
      (create-line canvas `(,(+ x 45) ,(+ y 15) ,(+ x 55) ,(+ y 15)))
      (create-oval canvas (+ x 54) (+ y 14) (+ x 56) (+ y 16)))))

(defmethod get-drawer ((obj conn-elt))
  (let ((x (point-x (base obj)))
        (y (point-y (base obj))))
    (lambda (canvas)
      (create-rectangle canvas x y (+ x 20) (+ y 30) :fill "#d0d0d0" :outline "#c0c0c0")
      (create-line canvas `(,(+ x 0) ,(+ y 15) ,(+ x 20) ,(+ y 15)))
      (create-oval canvas (+ x -1) (+ y 14) (+ x 1) (+ y 16))
      (create-oval canvas (+ x 19) (+ y 14) (+ x 21) (+ y 16)))))

(defun viz (canvas elts)
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
                              (list x))))
            wires)
    (maphash #'(lambda (wire inouts)
                 ;; (format t "~% ~A : ~A" wire inouts)
                 (let ((first-inout nil))
                   (loop :for inout :in inouts :do
                      (if (null first-inout)
                          (progn
                            (setf first-inout inout)
                            (unless (equal 0 (search "WIRE-" (symbol-name wire)))
                              (create-text canvas
                                           (if (inout-is-out inout)
                                               (+ 3 (point-x (inout-coord inout)))
                                               (- (point-x (inout-coord inout)) 30))
                                           (if (inout-is-out inout)
                                               (point-y (inout-coord inout))
                                               (- (point-y (inout-coord inout)) 13))
                                           (format nil "~A=~A" (symbol-name wire)
                                                   (signal-value (symbol-value wire))))))
                          ;; else
                          (progn
                            ;; (create-line canvas `(,(point-x (inout-coord first-inout))
                            ;;                        ,(point-y (inout-coord first-inout))
                            ;;                        ,(point-x (inout-coord inout))
                            ;;                        ,(point-y (inout-coord inout))))
                            (create-line canvas `(,(point-x (inout-coord first-inout))
                                                   ,(point-y (inout-coord first-inout))
                                                   ,(point-x (inout-coord first-inout))
                                                   ,(point-y (inout-coord inout))))
                            (create-line canvas `(,(point-x (inout-coord first-inout))
                                                   ,(point-y (inout-coord inout))
                                                   ,(point-x (inout-coord inout))
                                                   ,(point-y (inout-coord inout))))
                            (setf first-inout inout))))))
             ht)))


(defparameter *the-agenda* (make-instance 'agenda))
(defparameter *inverter-delay* 2)
(defparameter *conn-delay* 1)
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
                 :is-out nil
                 :wire (name input))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :is-out t
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
                 :is-out nil
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :is-out nil
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :is-out t
                 :wire (name output))))
    (flet ((and-action-procedure ()
             (let ((new-value (logical-and (get-signal a1) (get-signal a2))))
               (after-delay *the-agenda*  *and-gate-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action a1 #'and-action-procedure)
      (add-action a2 #'and-action-procedure))
    obj))

(defun nand-gate (a1 a2 output coord-x coord-y)
  (let* ((obj (make-instance 'nand-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 09))
                 :is-out nil
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :is-out nil
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :is-out t
                 :wire (name output))))
    (flet ((and-action-procedure ()
             (let ((new-value (logical-not (logical-and (get-signal a1) (get-signal a2)))))
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
                 :is-out nil
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :is-out nil
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :is-out t
                 :wire (name output))))
    (flet ((or-action-procedure ()
             (let ((new-value (logical-or (get-signal a1) (get-signal a2))))
               (after-delay *the-agenda* *or-gate-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action a1 #'or-action-procedure)
      (add-action a2 #'or-action-procedure))
    obj))

(defun nor-gate (a1 a2 output coord-x coord-y)
  (let* ((obj (make-instance 'nor-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 09))
                 :is-out nil
                 :wire (name a1))
                (make-inout
                 :coord (make-point :x x :y (+ y 21))
                 :is-out nil
                 :wire (name a2))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 55) :y (+ y 15))
                 :is-out t
                 :wire (name output))))
    (flet ((or-action-procedure ()
             (let ((new-value (logical-not (logical-or (get-signal a1) (get-signal a2)))))
               (after-delay *the-agenda* *or-gate-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action a1 #'or-action-procedure)
      (add-action a2 #'or-action-procedure))
    obj))

(defun conn (input output coord-x coord-y)
  (let* ((obj (make-instance 'conn-elt :base (make-point :x coord-x :y coord-y)))
         (x (point-x (base obj)))
         (y (point-y (base obj))))
    (setf (inputs obj)
          (list (make-inout
                 :coord (make-point :x x :y (+ y 15))
                 :is-out nil
                 :wire (name input))))
    (setf (outputs obj)
          (list (make-inout
                 :coord (make-point :x (+ x 20) :y (+ y 15))
                 :is-out t
                 :wire (name output))))
    (flet ((conn-input ()
             (let ((new-value (get-signal input)))
               (after-delay *the-agenda* *conn-delay*
                            (lambda ()
                              (set-signal output new-value))))))
      (add-action input #'conn-input))
    obj))


(defun half-adder (a b s c coord-x coord-y
                   &key (a1 (make-instance 'wire)) (a2 (make-instance 'wire))
                     (b1 (make-instance 'wire)) (b2 (make-instance 'wire))
                     (c1 (make-instance 'wire))
                     (d (make-instance 'wire))  (e (make-instance 'wire)))
  (list
   (conn a a1 (+ coord-x 0) (+ coord-y 0))
   (conn a1 a2 (+ coord-x 70) (+ coord-y 0))
   (conn b b1 (+ coord-x 0) (+ coord-y 40))
   (conn b b2 (+ coord-x 125) (+ coord-y 40))
   (or-gate a2 b2 d (+ coord-x 195) (+ coord-y 6))
   (and-gate b2 a1 c1 (+ coord-x 195) (+ coord-y 56))
   (inverter c1 e (+ coord-x 305) (+ coord-y 56))
   (and-gate d e s (+ coord-x 360) (+ coord-y 12))
   (conn c1 c (+ coord-x 400) (+ coord-y 80))))

(defun full-adder (a b c sum c-out coord-x coord-y
                   &key
                     (a20   (make-instance 'wire))

                     (s   (make-instance 'wire))
                     (cf1 (make-instance 'wire))
                     (cf2 (make-instance 'wire))

                     (a11 (make-instance 'wire))
                     (a12 (make-instance 'wire))
                     (b11 (make-instance 'wire))
                     (b12 (make-instance 'wire))
                     (c11 (make-instance 'wire))

                     (a21 (make-instance 'wire))
                     (a22 (make-instance 'wire))
                     (b21 (make-instance 'wire))
                     (b22 (make-instance 'wire))
                     (c21 (make-instance 'wire))

                     (d1  (make-instance 'wire))
                     (e1  (make-instance 'wire))
                     (d2  (make-instance 'wire))
                     (e2  (make-instance 'wire)))
  (append
   (list (conn a a20 coord-x coord-y))
   (half-adder b c s   cf1 coord-x         (+ coord-y 28)
               :a1 a11 :a2 a12 :b1 b11 :b2 b12 :c1 c11 :d d1 :e e1)
   (half-adder a20 s sum cf2 (+ coord-x 460) coord-y
               :a1 a21 :a2 a22 :b1 b21 :b2 b22 :c1 c21 :d d2 :e e2)
   (list
    (or-gate cf2 cf1 c-out 980 152))))


;; (defun probe (name wire)
;;   (add-action wire #'(lambda ()
;;                        (format t "~%name: ~A; time: ~A; value: ~A"
;;                                name
;;                                (current-time *the-agenda*)
;;                                (get-signal wire)))))

;; (defparameter *input-1* (make-instance 'wire :name '|a|))
;; (defparameter *input-2* (make-instance 'wire :name '|b|))
;; (defparameter *sum* (make-instance 'wire :name '|sum|))
;; (defparameter *carry* (make-instance 'wire :name '|cf|))
;;
;; (probe 'sum *sum*)
;; (probe 'carry *carry*)
;; (half-adder *input-1* *input-2* *sum* *carry*)
;; (set-signal *input-1* 1)
;; (propagate *the-agenda*)
;;
;; (set-signal *input-2* 1)
;; (propagate *the-agenda*)
;;
;; ;; (mapcar #'(lambda (x)
;; ;;             (list (timepoint x) (front-ptr (queue x))))
;; ;;         (segments *the-agenda*))


(defmacro declare-wires ((&rest wires) &body body)
  `(let ,(loop :for wire :in wires :collect
            `(,wire (make-instance 'wire :name ',wire)))
     ,@(loop :for wire :in wires :collect
          `(declare (special ,wire)))
     ,@body))

(defmacro ltk-show (elts width height scroll-width scroll-height)
  `(with-ltk ()
     (let* ((sc (make-instance 'scrolled-canvas :borderwidth 2 :relief :raised))
            (canvas (canvas sc))
            (down nil)
            (drag nil))
       (configure canvas :borderwidth 2 :relief :sunken :width ,width :height ,height)
       (pack sc :side :top :fill :both :expand t)
       (scrollregion canvas 0 0 ,scroll-width ,scroll-height)
       (bind canvas "<ButtonPress-1>"
             (lambda (evt)
               (let ((elt2 (remove-if #'(lambda (elt)
                                          (or ;; (equal (type-of elt) 'conn-elt)
                                               (let* ((point (base elt))
                                                      (x (point-x point))
                                                      (y (point-y point)))
                                                 (or
                                                  (< (event-x evt) x)
                                                  (< (event-y evt) y)
                                                  (> (event-x evt) (+ 55 x))
                                                  (> (event-y evt) (+ 30 y))))))
                                      elts)))
                 (unless (null elt2)
                   (setf drag (car elt2))
                   (create-text canvas 15 7 (bprint elt2)  :fill "red")
                   (setf down (make-point :x (event-x evt) :y (event-y evt)))))))
       (bind canvas "<ButtonRelease-1>" (lambda (evt)
                                          (declare (ignore evt))
                                          (setf down nil)
                                          (setf drag nil)
                                          (clear canvas)
                                          (viz canvas ,elts)))
       (bind canvas "<Motion>"
             (lambda (evt)
               (when down
                 (setf down (make-point :x (event-x evt) :y (event-y evt)))
                 (unless (null drag)
                   (loop :for input :in (append (inputs drag) (outputs drag)) :do
                      (let ((dif-x (- (point-x (inout-coord input)) (point-x (base drag))))
                            (dif-y (- (point-y (inout-coord input)) (point-y (base drag)))))
                        (setf (point-x (inout-coord input)) (+ (event-x evt) dif-x))
                        (setf (point-y (inout-coord input)) (+ (event-y evt) dif-y))
                        ))
                   (setf (point-x (base drag)) (event-x evt))
                   (setf (point-y (base drag)) (event-y evt))
                   (funcall (get-drawer drag) canvas)))))
       (viz canvas ,elts))))

(declare-wires (a b a1 a2 b1 b2 c1 d e s c)
  (let ((elts (half-adder a b s c 50 50
                          :a1 a1 :a2 a2 :b1 b1 :b2 b2 :c1 c1 :d d :e e)))
    (set-signal a 1)
    (set-signal b 1)
    (propagate *the-agenda*)
    (ltk-show elts 600 300 600 300)))

(declare-wires
    (a a20 b c sum c-out s cf1 cf2 a11 a12 b11 b12 c11 a21 a22 b21 b22 c21 d1 e1 d2 e2)
  (let ((elts (full-adder a b c sum c-out 50 50
                          :a20 a20
                          :s s :cf1 cf1 :cf2 cf2 :a11 a11 :a12 a12 :b11 b11 :b12 b12
                          :c11 c11 :a21 a21 :a22 a22 :b21 b21 :b22 b22 :c21 c21
                          :d1 d1 :e1 e1 :d2 d2 :e2 e2)))
    (set-signal a 0)
    (set-signal b 0)
    (set-signal c 1)
    (propagate *the-agenda*)
    (print (list
            (get-signal a)
            (get-signal b)
            (get-signal c)
            (get-signal sum)
            (get-signal c-out)))
    (ltk-show elts 1200 300 1200 300)))
;; Сборка:1 ends here
