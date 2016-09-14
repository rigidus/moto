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
    (if (and (>= x 0) (>= y 0) (< x default-width) (< y default-height))
        (list
         (aref (zpng:data-array img) y x 0)
         (aref (zpng:data-array img) y x 1)
         (aref (zpng:data-array img) y x 2)
         (aref (zpng:data-array img) y x 3))
        nil)))

(defun img-set-pnt (img x y &key red green blue trans)
  (multiple-value-bind (default-width default-height)
      (x-size)
    (when (and (>= x 0) (>= y 0) (< x default-width) (< y default-height))
      (when red
        (setf (aref (zpng:data-array img) y x 0) red))
      (when green
        (setf (aref (zpng:data-array img) y x 1) green))
      (when blue
        (setf (aref (zpng:data-array img) y x 2) blue))
      (when trans
        (setf (aref (zpng:data-array img) y x 3) trans))
      )))

(defun img-draw-line (img x1 y1 x2 y2 &key red green blue trans)
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
                 (img-set-pnt img y x :red red :green green :blue blue :trans trans)
                 (img-set-pnt img x y :red red :green green :blue blue :trans trans))
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
    (remove-duplicates points)))

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

(defclass pnt ()
  ((x-↖  :initarg :x-↖  :accessor x-↖ )
   (y-↖  :initarg :y-↖  :accessor y-↖ )
   (x-↘  :initarg :x-↘  :accessor x-↘ )
   (y-↘  :initarg :y-↘  :accessor y-↘ )
   (rgb-color  :initarg :rgb-color  :accessor rgb-color)
   (blocked-width  :initarg :blocked-width   :accessor blocked-width  :initform nil)
   (blocked-height :initarg :blocked-height  :accessor blocked-height :initform nil)
   (merged         :initarg :merged          :accessor merged         :initform nil)
   (deleted        :initarg :deleted         :accessor deleted        :initform nil)))

(define-condition no-pnt () ())

(defun get-rgb (img x y)
  (let ((pnt (img-get-pnt img x y)))
    (when (null pnt)
      (error 'no-pnt))
    pnt))

(defun get-rgb-list (img coords)
  (mapcar #'(lambda (coord-elt)
              (destructuring-bind (x y)
                  coord-elt
                (get-rgb img x y)))
          coords))

(defun tester (a b)
  (if (and (equal a b)
           (equal '(255) (subseq a 3 4)))
      a
      nil))

(defun test-pnt (img obj coords)
  (handler-case
      (reduce #'tester (get-rgb-list img coords) :initial-value (rgb-color obj))
    (no-pnt () nil)))

(defun hit-pnt (img coords)
  (mapcar #'(lambda (coord-elt)
              (destructuring-bind (x y)
                  coord-elt
                (img-set-pnt img x y :trans 0)))
          coords))

(defmethod dbg ((obj pnt))
  (format t "~% ~A : ~A ----------------------------"    (x-↖  obj) (y-↖  obj))
  (format t "~% |             ~A : ~A               "    (- (x-↘  obj) (x-↖  obj)) (- (y-↘  obj) (y-↖  obj)))
  (format t "~% ---------------------------- ~A : ~A~%"  (x-↘  obj) (y-↘  obj)))

(defmacro find-near-obj (primary-coord secondary-coord base-name test-name container)
  ;; Мы должны найти все объекты, у которых:
  ;; (and
  ;;   x-↖  на единицу больше чем наш x-↘  и
  ;;   y-↖  верхний/левый меньше чем наш  y-↘ верхний/левый
  ;;   у-↘  нижний/правый больше чем наш y-↖ нижний/правый
  ;;   и rgb-color совпадает c нашим
  ;; Пока ищем неоптимально, просматривая весь список объектов, потом надо будет индексировать объекты по их координатам (TODO)
  ;; (format t  "~%---BASE: x = ~A | y-↑ = ~A | y-↓ = ~A" (x-↘  ,base-name) (y-↖  ,base-name) (y-↘  ,base-name))
  (let ((primary-coord-↘  (intern (concatenate 'string (symbol-name primary-coord) "-↘")))
        (primary-coord-↖  (intern (concatenate 'string (symbol-name primary-coord) "-↖")))
        (secondary-coord-↘  (intern (concatenate 'string (symbol-name secondary-coord) "-↘")))
        (secondary-coord-↖  (intern (concatenate 'string (symbol-name secondary-coord) "-↖")))
        )
    `(remove-if-not #'(lambda (,test-name)
                        (and
                         (equal (+ 1 (,primary-coord-↘  ,base-name)) (,primary-coord-↖  ,test-name))
                         (<= (,secondary-coord-↖  ,base-name) (,secondary-coord-↘  ,test-name))
                         (>= (,secondary-coord-↘  ,base-name) (,secondary-coord-↖  ,test-name))
                         (equal (rgb-color ,base-name) (rgb-color ,test-name))
                         ))
                    ,container)))

;; (macroexpand-1 '(find-near-obj x y obj test-obj objects))

(defun run ()
  (multiple-value-bind (default-width default-height)
      (x-size)
    (let* ((img (get-screenshoot 0 0 default-width default-height))
           (img2 (make-instance 'zpng:png :width default-width :height default-height :color-type :truecolor-alpha))
           (random-points (get-random-points 0 0 default-width default-height))
           (h-x (make-hash-table))
           (objects))
      ;; make h-x
      (loop :for (x y) :in random-points :do
         (if (null (gethash x h-x))
             (setf (gethash x h-x) (list y))
             (setf (gethash x h-x) (append (list y) (gethash x h-x)))))
      ;; dbg out h-x
      ;; (maphash #'(lambda (k v)
      ;;              (print (list k v)))
      ;;          h-x)
      (loop :for (pnt-x pnt-y) :in random-points :do
         (push
          (make-instance 'pnt :x-↖  pnt-x  :y-↖  pnt-y  :x-↘  pnt-x :y-↘  pnt-y
                         :rgb-color (img-get-pnt img pnt-x pnt-y))
          objects)
         (img-set-pnt img pnt-x pnt-y :trans 0))
      ;; Выполняем итерации для увеличения всех объектов
      (loop :for iteration :from 0 :to 22 :do
         (format t "~%================================================================= iteration: ~A" iteration)
         (tagbody start-iteration
            ;; Для всех известных объектов, исключая удаленные
            (setf objects (remove-if #'(lambda (obj) (deleted obj)) objects))
            (loop :for obj :in objects :do
               (tagbody start-object
                  ;; Пытаемся расширяться по горизонтали, если это возможно
                  (unless (or (deleted obj) (merged obj) (blocked-width obj))
                    (let ((height (+ 1 (- (y-↘  obj) (y-↖  obj)))))
                      ;; Вычисляем координаты точек расширения
                      (let ((coords (loop :for y :from (y-↖  obj) :to (y-↘  obj) :collect `(,(+ 1 (x-↘  obj)) ,y))))
                        ;; Для каждой из них проверяем возможность занять эту точку
                        (if (not (null (test-pnt img obj coords)))
                            ;; Занять можно - расширяем горизонталь и помечаем точки на картинке
                            (progn (incf (x-↘  obj)) (hit-pnt img coords))
                            ;; Занять нельзя - но это еще не конец - попробуем выполнить слияние, если размер точки больше единицы
                            (progn
                              (when (and (> (- (x-↘  obj) (x-↖  obj))  1)     (> (- (y-↘  obj) (y-↖  obj))  1))
                                (loop :for test-obj :in (find-near-obj x y obj test-obj objects) :do
                                   (let ((yy (sort (list (y-↖  obj) (y-↖  test-obj) (y-↘  obj) (y-↘  test-obj)) #'<))
                                         (xx (sort (list (x-↖  obj) (x-↖  test-obj) (x-↘  obj) (x-↘  test-obj)) #'<))
                                         (union-coords))
                                     ;; Собираем координаты точкек, которые нужно заполнить для слияния
                                     (loop :for y :from (car yy) :to (car (last yy)) :do
                                        (loop :for x :from (car xx) :to (car (last xx)) :do
                                           (unless (or (and (<= y (y-↘  obj))  (>= y (y-↖  obj))  (<= x (x-↘  obj))  (>= x (x-↖  obj)))
                                                       (and (<= y (y-↘  test-obj))  (>= y (y-↖  test-obj))  (<= x (x-↘  test-obj))  (>= x (x-↖  test-obj))))
                                             (push (list x y) union-coords))))
                                     ;; (print union-coords)
                                     ;; (mapcar #'(lambda (coord-elt)
                                     ;;             (destructuring-bind (x y)
                                     ;;                 coord-elt
                                     ;;               (img-set-pnt img x y :red 0 :green 127 :blue 127 :trans 175)))
                                     ;;         union-coords)
                                     ;; Проверяем, можно ли их занть
                                     (if (not (null (test-pnt img obj union-coords)))
                                         ;; Занять можно
                                         (progn
                                           ;; Заполняем точки
                                           (hit-pnt img union-coords)
                                           ;; Сливаем общие координаты их и заносим новый объект к остальным объектам
                                           (push (make-instance 'pnt :x-↖  (car xx)  :y-↖  (car yy)  :x-↘  (car (last xx)) :y-↘  (car (last yy))
                                                                :rgb-color (rgb-color obj) #|:merged t|#)
                                                 objects)
                                           ;; Исходные объекты помечаем для удаляения
                                           (setf (deleted obj) t)
                                           (setf (deleted test-obj) t)
                                           ;; Отладочный вывод в консоль
                                           ;; (print 'merged-horizontal)
                                           ;; Переходим напрямую к следующему объекту
                                           (go end-object))
                                         ;; Занять нельзя - тут можно еще скорректировать попавшие под руку блоки но пока ничего не делаем
                                         'todo))))
                              ;; Если мы оказались здесь, значит слияния невозможны - блокируем расширение вправо
                              ;; Строго говоря в будущем ситуация может и измениться поэтому может и не стоит
                              (setf (blocked-width obj) t)
                              )))))
                  ;; Пытаемся расширяться по вертикали, если это возможно
                  (unless (or (deleted obj) (merged obj) (blocked-height obj))
                    (let ((width (+ 1 (- (x-↘  obj) (x-↖  obj)))))
                      ;; Вычисляем координаты точек расширения
                      (let ((coords (loop :for x :from (x-↖  obj) :to (x-↘  obj) :collect `(,x ,(+ 1 (y-↘  obj))))))
                        ;; Для каждой из них проверяем возможность занять эту точку
                        (if (not (null (test-pnt img obj coords)))
                            ;; Занять можно - расширяем вертикаль и помечаем точки на картинке
                            (progn (incf (y-↘  obj)) (hit-pnt img coords))
                            ;; Занять нельзя - но это еще не конец - попробуем выполнить слияние, если размер точки больше единицы
                            (progn
                              ;; ------------- TESTED BEGIN
                              (when (and (> (- (x-↘  obj) (x-↖  obj))  1)     (> (- (y-↘  obj) (y-↖  obj))  1))
                                (loop :for test-obj :in (find-near-obj y x obj test-obj objects) :do
                                   (let ((yy (sort (list (y-↖  obj) (y-↖  test-obj) (y-↘  obj) (y-↘  test-obj)) #'<))
                                         (xx (sort (list (x-↖  obj) (x-↖  test-obj) (x-↘  obj) (x-↘  test-obj)) #'<))
                                         (union-coords))
                                     ;; Собираем координаты точкек, которые нужно заполнить для слияния
                                     (loop :for y :from (car yy) :to (car (last yy)) :do
                                        (loop :for x :from (car xx) :to (car (last xx)) :do
                                           (unless (or (and (<= x (x-↘  obj))  (>= x (x-↖  obj))  (<= y (y-↘  obj))  (>= y (y-↖  obj)))
                                                       (and (<= x (x-↘  test-obj))  (>= x (x-↖  test-obj))  (<= y (y-↘  test-obj))  (>= y (y-↖  test-obj))))
                                             (push (list x y) union-coords))))
                                     ;; (print union-coords)
                                     ;; (mapcar #'(lambda (coord-elt)
                                     ;;             (destructuring-bind (x y)
                                     ;;                 coord-elt
                                     ;;               (img-set-pnt img x y :red 0 :green 127 :blue 127 :trans 175)))
                                     ;;         union-coords)
                                     ;; Проверяем, можно ли их занть
                                     (if (not (null (test-pnt img obj union-coords)))
                                         ;; Занять можно
                                         (progn
                                           ;; Заполняем точки
                                           (hit-pnt img union-coords)
                                           ;; Сливаем общие координаты их и заносим новый объект к остальным объектам
                                           (push (make-instance 'pnt :x-↖  (car xx)  :y-↖  (car yy)  :x-↘  (car (last xx)) :y-↘  (car (last yy))
                                                                :rgb-color (rgb-color obj) #|:merged t|#)
                                                 objects)
                                           ;; Исходные объекты помечаем для удаляения
                                           (setf (deleted obj) t)
                                           (setf (deleted test-obj) t)
                                           ;; Отладочный вывод в консоль
                                           ;; (print 'merged-vertical)
                                           ;; Переходим напрямую к следующему объекту
                                           (go end-object))
                                         ;; Занять нельзя - тут можно еще скорректировать попавшие под руку блоки но пока ничего не делаем
                                         'todo))))
                              ;; ------------- TESTED END

                              ;; Если мы оказались здесь, значит слияния невозможны - блокируем расширение вниз
                              (setf (blocked-height obj) t)
                              )))))
                end-object))
          end-iteration))
      ;; Выводим в картинку
      (mapcar #'(lambda (obj)
                  (let ((red) (green) (blue) (trans 255))
                    (cond ((merged obj) (progn
                                          (setf red 255)
                                          (setf green 255)
                                          (setf blue 255)
                                          (setf trans 255)))
                          ((and (blocked-width obj) (blocked-height obj)) (progn
                                                                            (setf red 255)))
                          ((or (blocked-width obj) (blocked-height obj))  (progn
                                                                            (setf blue 255)))
                          (t (setf green 255)))
                    (img-draw-line img (x-↖ obj) (y-↖  obj) (x-↖  obj) (y-↘  obj) :red red :green green :blue blue :trans trans)
                    (img-draw-line img (x-↖ obj) (y-↖  obj) (x-↘  obj) (y-↖  obj) :red red :green green :blue blue :trans trans)
                    (img-draw-line img (x-↘ obj) (y-↘  obj) (x-↘  obj) (y-↖  obj) :red red :green green :blue blue :trans trans)
                    (img-draw-line img (x-↘ obj) (y-↘  obj) (x-↖  obj) (y-↘  obj) :red red :green green :blue blue :trans trans)))
              objects)
      ;; Записываем картинку
      (zpng:write-png img "cell.png"))))

(run)

;; Нужен диффер кода


;;;; sexp-diff.scm - stolen from Racket/unstable


;;; diff-sexp.lisp -- diffs s-expressions based on Levenshtein-like edit distance.

;; Author:Michael Weber <michaelw@foldr.org>
;; Date:2005-09-03
;; Modified:2005-09-04
;; Modified:2005-09-07
;; Modified:2005-09-15
;; Modified:    2010-06-22 (Ported to racket by Vincent St-Amour)
;;
;; This code is in the Public Domain.

;;; Description:

;; DIFF-SEXP computes a diff between two s-expressions which minimizes
;; the number of atoms in the result tree, also counting edit
;; conditionals #:new, #:old.

;;; Examples:

;; > (sexp-diff
;;    '(DEFUN F (X) (+ (* X 2) 1))
;;    '(DEFUN F (X) (- (* X 2) 3 1)))
;; ((DEFUN F (X) (#:new - #:old + (* X 2) #:new 3 1)))
;; > (sexp-diff
;;    '(DEFUN F (X) (+ (* X 2) 4 1))
;;    '(DEFUN F (X) (- (* X 2) 5 3 1)))
;; ((DEFUN F (X) (#:new - #:old + (* X 2) #:new 5 #:new 3 #:old 4 1)))
;; > (sexp-diff
;;    '(DEFUN F (X) (+ (* X 2) 4 4 1))
;;    '(DEFUN F (X) (- (* X 2) 5 5 3 1)))
;; ((DEFUN F (X) #:new (- (* X 2) 5 5 3 1) #:old (+ (* X 2) 4 4 1)))

;;; Todo:

;; * Support for moved subtrees
;; * The algorithm treats vectors, arrays, etc. as opaque objects
;; * This article might describe a better method (unchecked):
;;   HÃ©lÃ¨ne Touzet: "A linear tree edit distance algorithm for similar ordered trees"
;;   LIFL - UMR CNRS 8022 - UniversitÃ© Lille 1
;;   59 655 Villeneuve d'Ascq cedex, France
;;   Helene.Touzet@lifl.fr


;; (module sexp-diff (sexp-diff)
;;         (import scheme chicken)
;;         (use srfi-1)


;;         ;; Computes the number of atoms contained in TREE.
;;         (define (tree-size tree)
;;             (if (pair? tree)
;;                 (apply + 1 (map tree-size tree))
;;                 1))


;;         (define-record edit-record
;;             type   ; 'unchanged | 'deletion | 'insertion | 'update | 'compound
;;           edit-distance
;;           change); CHANGE | (OLD . NEW) | (CHANGE ...)

;;         (define (make-unchanged-record change)
;;             (make-edit-record 'unchanged (tree-size change) change))

;;         (define (make-deletion-record change)
;;             (make-edit-record 'deletion (add1 (tree-size change)) change))

;;         (define (make-insertion-record change)
;;             (make-edit-record 'insertion (add1 (tree-size change)) change))

;;         (define (make-update-record old new)
;;             (make-edit-record 'update
;;                               (+ 1 (tree-size old)
;;                                  1 (tree-size new))
;;                               (cons old new)))

;;         (define (make-compound-record changes)
;;             (make-edit-record
;;              'compound
;;              (apply + (map edit-record-edit-distance changes))
;;              changes))

;;         (define (make-empty-compound-record)
;;             (make-compound-record '()))

;;         (define (make-extend-compound-record r0 record)
;;             (make-compound-record (cons record (get-change r0))))

;;         (define (unchanged-record? r) (eq? (edit-record-type r) 'unchanged))
;;         (define (deletion-record? r) (eq? (edit-record-type r) 'deletion))
;;         (define (insertion-record? r) (eq? (edit-record-type r) 'insertion))
;;         (define (compound-record? r) (eq? (edit-record-type r) 'compound))
;;         (define (update-record? r) (eq? (edit-record-type r) 'update))

;;         (define (get-change record) (edit-record-change record))

;;         (define (render-difference record)
;;             (cond [(insertion-record? record)
;;                   (list '#:new (edit-record-change record))]
;;                   [(deletion-record? record)
;;                   (list '#:old (edit-record-change record))]
;;                   [(update-record? record)
;;                   (let ((change (edit-record-change record)))
;;                     (list '#:old (car change)
;;                           '#:new (cdr change)))]
;;                           [(unchanged-record? record)
;;                           (list (edit-record-change record))]
;;                           [(compound-record? record)
;;                           (list (fold (lambda (r res)
;;                                         (append res (render-difference r)))
;;                                       '()
;;                                       (reverse (edit-record-change record))))]))

;;         ;; Returns record with minimum edit distance.
;;         (define (min/edit record . records)
;;             (fold-right (lambda (a b)
;;                           (if (<= (edit-record-edit-distance a)
;;                                   (edit-record-edit-distance b))
;;                               a
;;                               b))
;;                         record
;;                         records))

;;         ;; Prepares initial data vectors for Levenshtein algorithm from LIST.
;;         (define (initial-distance function lst)
;;             (let ((seq (make-vector (add1 (length lst)) (make-empty-compound-record))))
;;               (do ((i 0 (add1 i))
;;                    (elt lst (cdr elt)))
;;                   ((null? elt))
;;                 (vector-set! seq (add1 i)
;;                              (make-extend-compound-record (vector-ref seq i)
;;                                                           (function (car elt)))))
;;               seq))

;;         ;; Calculates the minimal edits needed to transform OLD-TREE into NEW-TREE.
;;         ;; It minimizes the number of atoms in the result tree, also counting
;;         ;; edit conditionals.
;;         (define (levenshtein-tree-edit old-tree new-tree)
;;             (cond
;;               ((equal? old-tree new-tree)
;;                (make-unchanged-record old-tree))
;;               ((not (and (pair? old-tree) (pair? new-tree)))
;;                (make-update-record old-tree new-tree))
;;               (else
;;                (min/edit
;;                 (make-update-record old-tree new-tree)
;;                 (let* ((best-edit #f)
;;                        (row (initial-distance make-deletion-record old-tree))
;;                        (col (initial-distance make-insertion-record new-tree)))
;;                   (do ((new-part new-tree (cdr new-part))
;;                        (currentlist (cdr (vector->list col)) (cdr currentlist)))
;;                       ((or (null? new-part) (null? currentlist)))
;;                     (let ((current (car currentlist)))
;;                       (do ((old-part old-tree (cdr old-part))
;;                            (row-idx 0 (add1 row-idx)))
;;                           ((null? old-part))
;;                         (set! best-edit
;;                               (min/edit
;;                                (make-extend-compound-record
;;                                 (vector-ref row (add1 row-idx))
;;                                 (make-insertion-record (car new-part)))
;;                                (make-extend-compound-record
;;                                 current
;;                                 (make-deletion-record (car old-part)))
;;                                (make-extend-compound-record
;;                                 (vector-ref row row-idx)
;;                                 (levenshtein-tree-edit (car old-part) (car new-part)))))
;;                         (vector-set! row row-idx current)
;;                         (set! current best-edit)))
;;                     (vector-set! row (sub1 (vector-length row)) best-edit))
;;                   best-edit)))))

;;         ;; Computes a diff between OLD-TREE and NEW-TREE which minimizes the
;;         ;; number of atoms in the result tree, also counting inserted edit conditionals
;;         ;; #:new, #:old.
;;         (define (sexp-diff old-tree new-tree)
;;             (render-difference (levenshtein-tree-edit old-tree new-tree)))

;;         )

(defun x-size ()
  (values 20 10))

(defun get-pnt-hlp (img x y)
  (let ((rs (img-get-pnt img x y)))
    (if (null rs)
      nil
      (equal 255 (car rs)))))

(defmacro rule (src dst)
  (let ((and-statement `(and ,@(loop
                                 :for idx :from -1 :to 1
                                 :for rul :in (mapcar #'(lambda (x) (equal #\1 x)) (coerce src 'list))
                                 :collect (let ((payload `(get-pnt-hlp img2 (+ x ,idx) y)))
                                            (if rul payload `(not ,payload)))))))
    `(when ,and-statement
       ,(if (equal 1 dst)
            `(img-set-pnt img2 x (+ 1 y) :red 255)
            `(img-set-pnt img2 x (+ 1 y) :red 0)))))

(multiple-value-bind (default-width default-height)
    (x-size)
  (let* ((img2 (make-instance 'zpng:png :width default-width :height default-height
                              :color-type :truecolor-alpha)))
    (loop :for y :from 0 :to default-height :do
       (loop :for x :from 0 :to default-width :do
          (img-set-pnt img2 x y :red 0 :green 0 :blue 0 :trans 255)))
    (img-set-pnt img2 (floor default-width 2) 0 :red 255 :green 0 :blue 0 :trans 255)
    (loop :for y :from 0 :to default-height :do
       (loop :for x :from 0 :to default-width :do
          (rule "111" 0)
          (rule "110" 0)
          (rule "101" 0)
          (rule "100" 1)
          (rule "011" 1)
          (rule "010" 1)
          (rule "001" 1)
          (rule "000" 0)
          ))
    ;; write png
    (zpng:write-png img2 "cell.png")))
