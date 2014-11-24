;; [[file:trend.org::*Загрузчик данных из файлов][asm_loader]]
(in-package #:moto)
(in-package #:moto)

(defmacro awhen-file ((file files) &body body)
  `(aif (find ,file ,files :test #'string=)
        ,@body
        ""))
(in-package #:moto)

(defmacro loop-dir (var (&rest path) &body body)
  `(loop :for ,var :in (mapcar #'(lambda (x) (car (last (ppcre:split "\/" (directory-namestring x)))))
                               (explore-dir (format nil "~A~{~A/~}*.*" *data-path* (list ,@path)))) :do
      (multiple-value-bind (_ files)
          (explore-dir (format nil "~A~{~A/~}~A/*.*" *data-path* (list ,@path) ,var))
        (declare (ignore _))
        (let ((files (mapcar #'(lambda (x) (car (last (ppcre:split "\/" (file-namestring x)))))
                             files)))
          ,@body))))
(in-package #:moto)

(defmacro assoc-key (key alist)
  `(cdr (assoc ,key ,alist :test #'string=)))
(in-package #:moto)

(defun keyval (filename)
  (remove-if #'null
             (mapcar #'(lambda (in)
                         (let* ((pos (position #\: in :test #'char=)))
                           (if (null pos)
                               (warn (format nil "wrong param: ~A" in))
                               (let ((key (subseq in 0 pos))
                                     (val (subseq in (+ 1 pos))))
                                 (cons (string-trim '(#\NewLine #\Tab #\Space 
 #\﻿)
                                                    (ppcre:regex-replace-all "\\s+" key " "))
                                       (string-trim '(#\NewLine #\Tab #\Space 
 #\﻿)
                                                    (ppcre:regex-replace-all "\\s+" val " ")))))))
                     (ppcre:split #\Newline (alexandria:read-file-into-string filename)))))
(in-package #:moto)

(defun decoder-3-csv  (in-string)
  "Второе возвращаемое значение показывает, была ли закрыта кавычка, или строка
       закончилась посередине обрабатываемой ячейки, что указывает на разрыв строки"
  (let ((err))
    (values
     (mapcar #'(lambda (y) (string-trim '(#\Space #\Tab) y))
             (mapcar #'(lambda (y) (ppcre:regex-replace-all "\\s+" y " "))
                     (mapcar #'(lambda (y) (string-trim '(#\Space #\Tab #\") y))
                             (let ((inp) (sav) (acc) (res))
                               (loop :for cur :across in-string do
                                  ;; (print cur)
                                  (if (null inp)
                                      (cond ((equal #\" cur) (progn (setf inp t)
                                                                    ;; (print "open quote : inp t")
                                                                    ))
                                            ((equal #\, cur)  (progn (push "" res)
                                                                     ;; (print "next")
                                                                     ))
                                            ;; (t (print "unknown sign out of quite"))
                                            )
                                      ;; else
                                      (cond ((and (null sav) (equal #\" cur)) (progn (setf sav t)
                                                                                     ;; (print "close quote : sav t")
                                                                                     ))
                                            ((and sav (equal #\" cur)) (progn (setf sav nil)
                                                                              ;; (print (list ".." #\"))
                                                                              (push #\" acc)))
                                            ((and sav (equal #\, cur)) (progn (setf sav nil)
                                                                              (setf inp nil)
                                                                              (push (coerce (reverse acc) 'string) res)
                                                                              ;; (print "inp f")
                                                                              (setf acc nil)))
                                            ((equal #\Return cur)      nil)
                                            (t (progn (push cur acc)
                                                      ;; (print (list "." cur))
                                                      )))))
                               (when acc
                                 ;; незакрытая кавычка
                                 (if (and inp (null sav))
                                     (setf err t))
                                 ;; (print (list ":" inp sav acc res))
                                 (push (coerce (reverse acc) 'string) res))
                               (reverse res)))))
     err)))

(defun xls-processor (infile)
  (let* ((result)
         (output (with-output-to-string (*standard-output*)
                   (let* ((proc (sb-ext:run-program "/usr/bin/xls2csv"
                                                    (list "-q3" (format nil "~a" infile)) :wait nil :output :stream)))
                     (with-open-stream (in (sb-ext:process-output proc))
                       (loop :for i from 1 do
                          (tagbody loop-body
                             (handler-case
                                 (let ((in-string (read-line in)))
                                   (format nil "~A" in-string)
                                   ;; начинаем декодировать
                                   (tagbody start-decoding
                                      (multiple-value-bind (line err-string-flag)
                                          (decoder-3-csv in-string)
                                        (when err-string-flag
                                          (setf in-string (concatenate 'string in-string (read-line in)))
                                          ;; (format t "~%warn-broken-string [~a] ~a~%" i in-string)
                                          (incf i)
                                          (go start-decoding))
                                        (format t "~%~%str: ~a~%lin: ~a" in-string (bprint line))
                                        (unless (null line)
                                          (handler-case
                                              (push line result)
                                            (SB-INT:SIMPLE-PARSE-ERROR () nil))
                                          )))
                                   )
                               (END-OF-FILE () (return i)))))))
                   )))
    (declare (ignore output))
    ;; output
    (reverse result)))

(defun load-data ()
  ;; Для каждой подпапке в папке данных..
  (loop-dir cmpx ()
     ;; Создаем комплекс и заполняем адрес, если удалось найти соответствующий файл
       (format t "~%-~A" cmpx)
       (let ((cmpx-id (id (make-cmpx :name cmpx))))
         ;; Если найден файл с данными ЖК - обновим созданную очередь ЖК
         (awhen-file ("complex.txt" files)
           ;; Прочитать, разбить построчно, отделить ключи от значений, убрать ведущие, ведомые и повторяющиеся пробелы
           (let ((complex (keyval (format nil "~A~A/~A" *data-path* cmpx it))))
             (format t "~% ~A - ~A" it (bprint complex))
             (upd-cmpx (get-cmpx cmpx-id)
                       (list
                        :addr (assoc-key "Адрес" complex)
                        :district-id (let ((obj (find-district :name (assoc-key "Район" complex))))
                                       (if (null obj)
                                           (warn (format nil "Район ~A не найден в таблице районов" (assoc-key "Район" complex)))
                                           (id (car obj))))
                        :metro-id    (let ((obj (find-metro :name (assoc-key "Метро" complex))))
                                       (if (null obj)
                                           (warn (format nil "Метро ~A не найдено в таблице метро" (assoc-key "Метро" complex)))
                                           (id (car obj))))))))
         ;; Для каждой подпапки в папке комплекса, кроме планировок, рендеров и хода строительства:
         (loop-dir plex (cmpx)
              (unless (or (string= plex "Планировки")
                          (string= plex "Рендеры")
                          (string= plex "Ход строительства"))
                ;; Создаем очередь ЖК
                (format t "~%--~A" plex)
                (let ((plex-id (id (make-plex :name plex :cmpx-id cmpx-id))))
                  ;; Если найден файл с данными очереди ЖК - обновим созданную очередь ЖК
                  (awhen-file ("data.txt" files)
                    (let ((data (keyval (format nil "~A~A/~A/~A" *data-path* cmpx plex it))))
                      (format t "~%  ~A - ~A" it (bprint data))
                      (upd-plex (get-plex plex-id)
                                (list :deadline-id (let ((dd (assoc-key "Срок сдачи" data)))
                                                     (format t "~%   dd: ~A | ~A"
                                                             dd
                                                             (awhen (find-deadline :name (assoc-key "Срок сдачи" data))
                                                               (id (car it))))
                                                     (awhen (find-deadline :name (assoc-key "Срок сдачи" data))
                                                       (id (car it))))
                                      :finishing   (assoc-key "Отделка" data)
                                      :ipoteka     (or (string= "да" (assoc-key "ипотека" data)))
                                      :installment (or (string= "да" (assoc-key "рассрочка" data)))
                                      :subsidy     (or (string= "да" (assoc-key "субсидия" data)))
                                      :distance    (assoc-key "Расстояние до метро" data)))
                      (format t "~%   rr: ~A" (deadline-id (get,-plex plex-id)))
                      ))
                  ;; Для каждой подпапки в папке очереди ЖК, кроме планировок, рендеров и хода строительства:
                  (loop-dir crps (cmpx plex)
                       (unless (or (string= crps "Планировки")
                                   (string= crps "Рендеры")
                                   (string= crps "Ход строительства"))
                         ;; Создаем корпус
                         (format t "~%---~A" crps)
                         (let ((crps-id (id (make-crps :name crps :plex-id plex-id))))
                           ;; Если найден файл с планировками объекта
                           (awhen-file ("квартиры.xls" files)
                             (loop :for item :in (cdr (xls-processor (format nil "~A~A/~A/~A/~A" *data-path* cmpx plex crps it))) :do
                                (format t "~%   ~A" (bprint item))
                                (make-flat :crps-id crps-id
                                           :rooms (parse-integer (nth 0 item))
                                           :area-sum (nth 1 item)
                                           :area-living (nth 2 item)
                                           :area-kitchen (nth 3 item)
                                           :balcon (nth 4 item)
                                           :sanuzel (if (string= "" (nth 5 item)) t nil)
                                           :price (parse-integer (nth 6 item)))))))))))))
  (format t "~%-=finish=-"))

(load-data)
;; asm_loader ends here
