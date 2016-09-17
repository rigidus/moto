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


(run)
