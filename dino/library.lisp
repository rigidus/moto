(eval-when (:compile-toplevel :load-toplevel :execute)
  #-clx
  (ql:quickload 'clx)
  #-zpng
  (ql:quickload 'zpng))

(use-package :xlib)

(defmacro with-default-display ((display &key (force nil)) &body body)
  `(let ((,display (xlib:open-default-display)))
     (unwind-protect
          (unwind-protect
               ,@body
            (when ,force
              (xlib:display-force-output ,display)))
       (xlib:close-display ,display))))

(defmacro with-default-display-force ((display) &body body)
  `(with-default-display (,display :force t) ,@body))

(defmacro with-default-screen ((screen) &body body)
  (let ((display (gensym)))
    `(with-default-display (,display)
       (let ((,screen (xlib:display-default-screen ,display)))
         ,@body))))

(defmacro with-default-window ((window) &body body)
  (let ((screen (gensym)))
    `(with-default-screen (,screen)
       (let ((,window (xlib:screen-root ,screen)))
         ,@body))))

(defun raw-image->png (data width height)
  (let* ((png (make-instance 'zpng:png :width width :height height
                             :color-type :truecolor-alpha
                             :image-data data))
         (data (zpng:data-array png)))
    (dotimes (y height)
      (dotimes (x width)
        ;; BGR -> RGB, ref code: https://goo.gl/slubfW
        ;; diffs between RGB and BGR: https://goo.gl/si1Ft5
        (rotatef (aref data y x 0) (aref data y x 2))
        (setf (aref data y x 3) 255)))
    png))

(defparameter *full-coefficient* 10)

(let ((memoization nil))
  (defun x-size ()
    (if (null memoization)
        (setf memoization (multiple-value-list
                           (with-default-screen (s)
                             (values
                              (screen-width s)
                              (screen-height s))))))
    (eval `(values ,@memoization))))

(defun surround ()
  ;; (floor
  ;;  (multiple-value-bind (default-width default-height)
  ;;      (x-size)
  ;;    (floor (+ default-width default-height) 6))
  ;;  *full-coefficient*)
  100
  )

(defun img-get-pnt (img x y)
  (multiple-value-bind (default-width default-height)
      (x-size)
    (if (and (> x 0) (> y 0) (< x default-width) (< y default-height))
        (list
         (aref (zpng:data-array img) y x 0)
         (aref (zpng:data-array img) y x 1)
         (aref (zpng:data-array img) y x 2)
         (aref (zpng:data-array img) y x 3))
        nil)))

(defun img-set-pnt (img x y &key red green blue trans)
  (multiple-value-bind (default-width default-height)
      (x-size)
    (when (and (> x 0) (> y 0) (< x default-width) (< y default-height))
      (when red
        (setf (aref (zpng:data-array img) y x 0) red))
      (when green
        (setf (aref (zpng:data-array img) y x 1) green))
      (when blue
        (setf (aref (zpng:data-array img) y x 2) blue))
      (when trans
        (setf (aref (zpng:data-array img) y x 3) trans))
      )))

(defun img-draw-line (img x1 y1 x2 y2 &key red green blue)
  "Алгоритм Брезенхема для рисования линии"
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
                 (img-set-pnt img y x :red red :green green :blue blue)
                 (img-set-pnt img x y :red red :green green :blue blue))
         (setf var-error (- var-error delta-y))
         (when (< var-error 0)
           (incf y y-step)
           (incf var-error delta-x))))
    img))

(defun get-screenshoot (start-x start-y end-x end-y)
  (with-default-window (w)
    (raw-image->png
     (get-raw-image w :x start-x :y start-y :width end-x :height end-y :format :z-pixmap)
     end-x end-y)))

(defun get-random-points (start-x start-y end-x end-y)
  (let ((x-rnd-cnt (floor (- end-x start-x) *full-coefficient*))
        (y-rnd-cnt (floor (- end-y start-y) *full-coefficient*))
        (points))
    (loop :for y-idx :from start-y :to (+ start-y y-rnd-cnt) :do
       (loop :for x-idx :from start-x :to (+ start-x x-rnd-cnt) :do
          (let ((random-y (+ start-y (random end-y)))
                (random-x (+ start-x (random end-x))))
            (push (list random-x random-y) points))))
    points))

(defun get-nearest-points (h-x pnt-x pnt-y &key img)
  "Ищем в хеш-таблице h-x ближайшую точку справа внизу от заданной,
   отстоящую не более чем на (surround) пикселей"
  (declare (ignore img))
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
       ;; (when img ;; dbg out img
       ;;   (loop :for item-y :from pnt-y :to (+ (surround) pnt-y) :do
       ;;      (img-set-pnt img item-x item-y :blue 255)))
       )
    (setf nearest-points (cdr nearest-points))
    (setf nearest-points (loop :for (nearest-x nearest-y) :in nearest-points :collect
                            (let* ((dist-x  (- nearest-x pnt-x))
                                   (dist-y  (- nearest-y pnt-y))
                                   (quattro (+ (* dist-x dist-x) (* dist-y dist-y))))
                              ;; (when img
                              ;;   (img-draw-line img pnt-x pnt-y nearest-x nearest-y :green 255))
                              (list nearest-x nearest-y quattro))))
    (eval `(values ,@(mapcar #'(lambda (x) `(quote ,x))
                             (sort nearest-points #'(lambda (a b) (> (nth 2 a) (nth 2 b)))))))))

(multiple-value-bind (default-width default-height)
    (x-size)
  (let* ((img (get-screenshoot 0 0 default-width default-height))
         (img2 (make-instance 'zpng:png :width default-width :height default-height :color-type :truecolor-alpha))
         (random-points (get-random-points 0 0 default-width default-height))
         (h-x (make-hash-table)))
    ;; make h-x
    (loop :for (x y) :in random-points :do
       (if (null (gethash x h-x))
           (setf (gethash x h-x) (list y))
           (setf (gethash x h-x) (append (list y) (gethash x h-x)))))
    ;; dbg out h-x
    ;; (maphash #'(lambda (k v)
    ;;              (print (list k v)))
    ;;          h-x)
    ;; dbg (если показывать эти точки алгоритм создания блоков не может найти равнозаполненные области)
    (loop :for (pnt-x pnt-y) :in random-points :do
       (img-set-pnt img pnt-x pnt-y :trans 0))
    (loop
       :repeat 1
       :for (pnt-x pnt-y) :in random-points :do
       (print (multiple-value-list (get-nearest-points h-x 100 100 :img img)))
       ;; (tagbody
       ;;    ;; Ищем области, залитые одним цветом
       ;;    ;; (loop :for near-pnt :in (multiple-value-list (get-nearest-points h-x pnt-x pnt-y :img img)) :do
       ;;    (let ((near-pnt (get-nearest-points h-x pnt-x pnt-y :img img)))
       ;;      (when near-pnt
       ;;        (destructuring-bind (near-x near-y quattro)
       ;;            near-pnt
       ;;          (declare (ignore quattro))
       ;;          (when (and near-x near-y)
       ;;            (let ((test-pnt-color))
       ;;              (loop :for test-pnt-x :from pnt-x :to near-x :do
       ;;                 (loop :for test-pnt-y :from pnt-y :to near-y :do
       ;;                    (let ((cur-pnt (img-get-pnt img test-pnt-x test-pnt-y)))
       ;;                      (if (null test-pnt-color)
       ;;                          (setf test-pnt-color cur-pnt)
       ;;                          (if (not (equal test-pnt-color cur-pnt))
       ;;                              (go end-entry))
       ;;                          ))))
       ;;              ;; Нашли, теперь надо
       ;;              (loop :for test-pnt-x :from pnt-x :to near-x :do
       ;;                 (loop :for test-pnt-y :from pnt-y :to near-y :do
       ;;                    (img-set-pnt img test-pnt-x test-pnt-y :trans 0)))
       ;;              ;; (img-draw-line img pnt-x pnt-y pnt-x near-y :red 255)
       ;;              ;; (img-draw-line img pnt-x pnt-y near-x pnt-y :red 255)
       ;;              ;; (img-draw-line img near-x pnt-y near-x near-y :red 255)
       ;;              ;; (img-draw-line img pnt-x near-y near-x near-y :red 255)
       ;;              )))))
       ;;  end-entry)
       )
    ;; write png
    (zpng:write-png img "cell.png")))


(multiple-value-bind (default-width default-height)
    (x-size)
  (let ((default-width 200)
        (default-height 100))
  (let* (;; (img (get-screenshoot 0 0 default-width default-height))
         (img2 (make-instance 'zpng:png :width default-width :height default-height
                              :color-type :truecolor-alpha)))
    (loop :for y :from 0 :to default-height :do
       (loop :for x :from 0 :to default-width :do
          (img-set-pnt img2 x y :red 0 :green 0 :blue 0 :trans 255)))
    (img-set-pnt img2 (floor default-width 2) 0 :green 255 :blue 255 :trans 255)
    ;; write png
    (zpng:write-png img2 "cell.png"))))
