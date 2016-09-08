(in-package :cl-autogui)

(defparameter *full-coefficient* 10)

(defun x-size ()
  (with-default-screen (s)
    (values
     (screen-width s)
     (screen-height s))))

(defun x-size ()
  (values 800 600))

(multiple-value-bind (default-width default-height) (x-size)
  (let ((y-rnd-cnt (floor default-height *full-coefficient*))
        (x-rnd-cnt (floor default-width  *full-coefficient*)))
    (with-default-window (w)
      (let ((image
             (raw-image->png
              (get-raw-image w :x 0 :y 0 :width default-width :height default-height :format :z-pixmap)
              default-width default-height))
            (starters ())
            (y-array (make-array (+ 1 y-rnd-cnt) :element-type `(integer 0 ,(+ 1 x-rnd-cnt)) :initial-element 0))
            (x-array (make-array (+ 1 x-rnd-cnt) :element-type `(integer 0 ,(+ 1 y-rnd-cnt)) :initial-element 0)))
        (loop :for y-idx :from 0 :to y-rnd-cnt :do
           (loop :for x-idx :from 0 :to x-rnd-cnt :do
              (let ((random-y (random default-height))
                    (random-x (random default-width)))
                (push (list random-x random-y) starters))))
        (loop :for (x y) :in starters :do
           (setf (aref (zpng:data-array image) y x 0) 255))
        (zpng:write-png image "cell.png")
        (sort starters #'(lambda (a b)
                           (> (cadr a) (cadr b))))
        ))))
