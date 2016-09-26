(eval-when (:compile-toplevel :load-toplevel :execute)
  (require '#:cl-gtk2-gtk)
  (require '#:cl-gtk2-cairo))

;; (ql:quickload "cl-cairo2")
;; (ql:quickload "cl-gtk2-gtk")
;; (ql:quickload "cl-gtk2-cairo")


;; Определим пакет sample1 с необходимыми зависимостями
(defpackage #:sample1
  (:shadowing-import-from #:cairo #:scale #:rectangle #:pointer)
  (:use #:cl #:gtk #:gdk #:gobject #:cl-gtk2-cairo #:cairo)
  (:export #:run))

;; И смело переходим в него
(in-package #:sample1)

(defun screen-drawer (w h)
  (set-source-rgb 1 1 1) ;выберем цвет заливки фона
  (paint) ;заливаем
  (set-line-width 4) ;выбираем толщину линии
  (set-source-rgb 0 0 0) ;задаем цвет линии
  (move-to 0 0) ;перемещаемся в точку 0 0
  (line-to w h) ;проводим линию в точку w h
  (rectangle 10 10 40 40)
  (move-to 10 10)
  (stroke))

(defun nnn (widget)
  ;;в дальнейшем нам может потребоваться информация о размерах виджета. Размеры мы биндим к переменным w и h.
  (multiple-value-bind (w h) (gdk:drawable-get-size (widget-window widget))
    ;;привяжем контекст cairo к виджету area.
    (with-gdk-context (ctx (widget-window widget))
      (with-context (ctx)
        ;;чтобы не нагромождать код, вынесу все рисование в функцию screen-drawer. Этой функции я передаю и параметры w и h.
        (screen-drawer w h)
        nil))))

(defun run ()
  (within-main-loop
    (let ((window (make-instance 'gtk-window))
          (area (make-instance 'drawing-area)))
      (connect-signal area "expose-event"
                      (lambda (widget event)
                        (declare (ignore widget event))
                        (nnn area)
                        ))
      (container-add window area)
      (widget-show window))))


;; (run)



(let ((surface nil))
  (defun example-drawing ()
    (within-main-loop
      (let ((window (make-instance 'gtk-window
                                   :type :toplevel
                                   :title "Example Drawing"))
            (frame (make-instance 'gtk-frame
                                  :shadow-type :in))
            (area (make-instance 'gtk-drawing-area
                                 :width-request 250
                                 :height-request 200)))
        (g-signal-connect window "destroy"
                          (lambda (widget)
                            (declare (ignore widget))
                            (leave-gtk-main)))
        ;; Signals used to handle the backing surface
        (g-signal-connect area "draw"
                          (lambda (widget cr)
                            (declare (ignore widget))
                            (let ((cr (pointer cr)))
                              (cairo-set-source-surface cr surface 0.0 0.0)
                              (cairo-paint cr)
                              (cairo-destroy cr)
                              +gdk-event-propagate+)))
        (g-signal-connect area "configure-event"
                          (lambda (widget event)
                            (declare (ignore event))
                            (when surface
                              (cairo-surface-destroy surface))
                            (setf surface
                                  (gdk-window-create-similar-surface
                                   (gtk-widget-window widget)
                                   :color
                                   (gtk-widget-get-allocated-width widget)
                                   (gtk-widget-get-allocated-height widget)))
                            ;; Clear surface
                            (let ((cr (cairo-create surface)))
                              (cairo-set-source-rgb cr 1.0 1.0 1.0)
                              (cairo-paint cr)
                              (cairo-destroy cr))
                            (format t "leave event 'configure-event'~%")
                            +gdk-event-stop+))
        ;; Event signals
        (g-signal-connect area "motion-notify-event"
                          (lambda (widget event)
                            (format t "MOTION-NOTIFY-EVENT ~A~%" event)
                            (when (member :button1-mask (gdk-event-motion-state event))
                              (let ((cr (cairo-create surface))
                                    (x (gdk-event-motion-x event))
                                    (y (gdk-event-motion-y event)))
                                (cairo-rectangle cr (- x 3.0) (- y 3.0) 6.0 6.0)
                                (cairo-fill cr)
                                (cairo-destroy cr)
                                (gtk-widget-queue-draw-area widget
                                                            (truncate (- x 3.0))
                                                            (truncate (- y 3.0))
                                                            6
                                                            6)))
                            ;; We have handled the event, stop processing
                            +gdk-event-stop+))
        (g-signal-connect area "button-press-event"
                          (lambda (widget event)
                            (format t "BUTTON-PRESS-EVENT ~A~%" event)
                            (if (eql 1 (gdk-event-button-button event))
                                (let ((cr (cairo-create surface))
                                      (x (gdk-event-button-x event))
                                      (y (gdk-event-button-y event)))
                                  (cairo-rectangle cr (- x 3.0) (- y 3.0) 6.0 6.0)
                                  (cairo-fill cr)
                                  (cairo-destroy cr)
                                  (gtk-widget-queue-draw-area widget
                                                              (truncate (- x 3.0))
                                                              (truncate (- y 3.0))
                                                              6
                                                              6))
                                ;; Clear surface
                                (let ((cr (cairo-create surface)))
                                  (cairo-set-source-rgb cr 1.0 1.0 1.0)
                                  (cairo-paint cr)
                                  (cairo-destroy cr)
                                  (gtk-widget-queue-draw widget)))))
        (gtk-widget-add-events area
                               '(:button-press-mask
                                 :pointer-motion-mask))
        (gtk-container-add frame area)
        (gtk-container-add window frame)
        (gtk-widget-show-all window)))))

(example-drawing)


(cl-gtk2-cairo-demo:demo)
