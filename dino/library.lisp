(in-package :cl-autogui)

(defparameter *full-coefficient* 10)

(defun x-size ()
  (with-default-screen (s)
    (values
     (screen-width s)
     (screen-height s))))

(defun x-size ()
  (values 800 600))

(defun surround ()
  (floor
   (multiple-value-bind (default-width default-height)
       (x-size)
     (floor (+ default-width default-height) 6))
   *full-coefficient*))

(defun image-get-pnt (image x y)
  (multiple-value-bind (default-width default-height)
      (x-size)
    (if (and (< x default-width) (< y default-height))
        (list
         (aref (zpng:data-array image) y x 0)
         (aref (zpng:data-array image) y x 1)
         (aref (zpng:data-array image) y x 2))
        nil)))

(defun image-set-pnt (image x y &key red green blue)
  (multiple-value-bind (default-width default-height)
      (x-size)
    (when (and (< x default-width) (< y default-height))
      (when red
        (setf (aref (zpng:data-array image) y x 0) red))
      (when green
        (setf (aref (zpng:data-array image) y x 1) green))
      (when blue
        (setf (aref (zpng:data-array image) y x 2) blue)))))

(defun image-draw-line (image x1 y1 x2 y2 &key red green blue)
  (declare (type integer x1 y1 x2 y2))
  (let* ((dist-x (abs (- x1 x2)))
         (dist-y (abs (- y1 y2)))
         (steep (> dist-y dist-x)))
    (when steep
      (psetf x1 y1 y1 x1
             x2 y2 y2 x2))
    (when (> x1 x2)
      (psetf x1 x2 x2 x1
             y1 y2 y2 y1))
    (let* ((delta-x (- x2 x1))
           (delta-y (abs (- y1 y2)))
           (var-error (floor delta-x 2))
           (y-step (if (< y1 y2) 1 -1))
           (y y1))
      (loop
         :for x :upfrom x1 :to x2
         :do (if steep
                 (image-set-pnt image y x :red red :green green :blue blue)
                 (image-set-pnt image x y :red red :green green :blue blue)
                 )
         (setf var-error (- var-error delta-y))
         (when (< var-error 0)
           (incf y y-step)
           (incf var-error delta-x))))
    image))


(defun get-nearest-point (h-x pnt-x pnt-y &key image)
  (let ((nearest-points))
    (loop :for item-x :from pnt-x :to (+ (surround) pnt-x) :do
       (let ((nearest-y (car (sort
                              (remove-if #'(lambda (z)
                                             (or (< z pnt-y)
                                                 (> z (+ pnt-y (surround)))))
                                         (gethash item-x h-x))
                              #'<))))
         (unless (null nearest-y)
           (setf nearest-points (append nearest-points (list (list item-x nearest-y))))
           ))
       ;; (when image ;; dbg out img
       ;;   (loop :for item-y :from pnt-y :to (+ (surround) pnt-y) :do
       ;;      (image-set-pnt image item-x item-y :blue 255)))
       )
    (setf nearest-points (cdr nearest-points))
    (setf nearest-points (loop :for (nearest-x nearest-y) :in nearest-points :collect
                            (let* ((dist-x  (- nearest-x pnt-x))
                                   (dist-y  (- nearest-y pnt-y))
                                   (quattro (+ (* dist-x dist-x) (* dist-y dist-y))))
                              ;; (when image
                              ;;   (image-draw-line image pnt-x pnt-y nearest-x nearest-y :green 255))
                              (list nearest-x nearest-y quattro))))
    (car (sort nearest-points #'(lambda (a b) (< (nth 2 a) (nth 2 b)))))))


(multiple-value-bind (default-width default-height) (x-size)
  (let ((y-rnd-cnt (floor default-height *full-coefficient*))
        (x-rnd-cnt (floor default-width  *full-coefficient*)))
    (with-default-window (w)
      (let ((image
             (raw-image->png
              (get-raw-image w :x 0 :y 0 :width default-width :height default-height :format :z-pixmap)
              default-width default-height))
            (starters ()))
        (loop :for y-idx :from 0 :to y-rnd-cnt :do
           (loop :for x-idx :from 0 :to x-rnd-cnt :do
              (let ((random-y (random (- default-height 1)))
                    (random-x (random (- default-width 1))))
                (push (list random-x random-y) starters))))
        (let ((h-x (make-hash-table)))
          (loop :for (x y) :in starters :do
             (if (null (gethash x h-x))
                 (setf (gethash x h-x) (list y))
                 (setf (gethash x h-x) (append (list y) (gethash x h-x)))))
          ;; (maphash #'(lambda (k v)
          ;;              (print (list k v)))
          ;;          h-x)
          ;; (loop :for (pnt-x pnt-y) :in starters :do
          ;;    (image-set-pnt image pnt-x pnt-y :red 255 :green 0 :blue 0))
          ;; get random point
          (loop :repeat 200 :do
             (tagbody
                (destructuring-bind (pnt-x pnt-y)
                    (nth (random (length starters)) starters)
                  (let* ((nearest (get-nearest-point h-x pnt-x pnt-y :image image))
                         (nearest-x (car nearest))
                         (nearest-y (cadr nearest)))
                    (when (and nearest-x nearest-y)
                      (let ((test-pnt-color)
                            (tested-points))
                        (loop :for test-pnt-x :from pnt-x :to nearest-x :do
                           (loop :for test-pnt-y :from pnt-y :to nearest-y :do
                              (let ((cur-pnt (image-get-pnt image test-pnt-x test-pnt-y)))
                                (if (null test-pnt-color)
                                    (setf test-pnt-color cur-pnt)
                                    (if (not (equal test-pnt-color cur-pnt))
                                        (go end-entry))))))
                        (loop :for test-pnt-x :from pnt-x :to nearest-x :do
                           (loop :for test-pnt-y :from pnt-y :to nearest-y :do
                              (image-set-pnt image test-pnt-x test-pnt-y :blue 255)))))))
              end-entry)))
        ;; write png
        (zpng:write-png image "cell.png")))))
