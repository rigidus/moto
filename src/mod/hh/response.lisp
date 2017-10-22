(in-package :moto)

(named-readtables:in-readtable :fare-quasiquote)

(in-package #:moto)

(in-package #:moto)

(in-package #:moto)


(defun extract-responds-results (tree)
  (block subtree-extract
    (mtm (`("tbody" NIL ,@rest)
           (return-from subtree-extract rest))
         tree)))

(make-transform (response-date)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))
          ("span" (("class" "responses-date")) ,result))
    `(:response-date ,result)))

(make-transform (response-date-dimmed)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))
          ("span" (("class" "responses-date responses-date_dimmed"))
                  ,result))
    `(response-date ,result)))

(make-transform (result-date)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))
          ("span" (("class" "responses-date")) ,result-date))
    `(:result-date, result-date)))

(make-transform (result-deny)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))
          ("span" (("class" "negotiations__denial")) "Отказ")) `(:result "Отказ")))

(make-transform (result-invite)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))
          ("span" (("class" "negotiations__invitation")) "Приглашение")) `(:result "Приглашение")))

(make-transform (result-no-view)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap")) "Не просмотрен") `(:result "Не просмотрен")))

(make-transform (result-view)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap")) "Просмотрен") `(:result "Просмотрен")))

(make-transform (result-archive)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap")) "В архиве") `(:archive t)))

(make-transform (responses-vacancy)
  (`("td" (("class" "prosper-table__cell"))
          ("div" (("class" "responses-vacancy-wrapper"))
                 ("div" (("class" "responses-vacancy"))
                        ("a"
                         (("class" ,_) ("target" "_blank") ("href" ,vacancy-link))
                         ,vacancy-name))
                 ("div" (("class" "responses-company")) ,emp-name)))
    `(:vacancy-link ,vacancy-link :vacancy-name ,vacancy-name :emp-name ,emp-name)))

(make-transform (responses-vacancy-disabled)
  (`("td" (("class" "prosper-table__cell")) ("div" (("class" "responses-vacancy responses-vacancy_disabled")) ,vacancy-name)
          ("div" (("class" "responses-company")) ,emp-name))
    `(:vacancy-name ,vacancy-name :emp-name ,emp-name :disabled t)))

(make-transform (topic)
  (`("tr" (("data-hh-negotiations-responses-topic-id" ,topic-id) ("class" ,_)) ,@rest)
    `((:topic-id ,topic-id) ,rest)))


(defparameter *transform-trash* '("responses-trash" "cell_nowrap" "responses-bubble" "prosper-table__cell" "cell_print_hidden"))


(make-transform (responses-trash)
  (`("td" (("class" "prosper-table__cell")) ("div" (("class" "responses-trash")) ,@rest)) "responses-trash"))

(make-transform (cell_nowrap)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_nowrap"))) "cell_nowrap"))

(make-transform (responses-bubble)
  (`("td" (("class" "prosper-table__cell")) ("span" (("class" "responses-bubble HH-Responses-NotificationIcon")))) "responses-bubble"))

(make-transform (prosper-table__cell)
  (`("td" (("class" "prosper-table__cell")) ,@rest) "prosper-table__cell"))


(make-transform (cell_print_hidden)
  (`("td" (("class" "prosper-table__cell prosper-table__cell_print-hidden"))
          ,@rest) "cell_print_hidden"))


(defun hh-parse-responds (html)
  "Получение списка вакансий из html"
  (dbg "hh-parse-responds")
  (setf *last-parse-data* html)
  (->> (html-to-tree html)
       (extract-responds-results)
       (transform-response-date)
       (transform-response-date-dimmed)
       ;; (transform-result-date)
       (transform-result-deny)
       (transform-result-invite)
       (transform-result-no-view)
       (transform-result-view)
       (transform-result-archive)
       ;; (transform-responses-vacancy)
       ;; (transform-responses-vacancy-disabled)
       (transform-topic)
       (transform-responses-vacancy)
       ;; trash
       (transform-responses-trash)
       (transform-cell_nowrap)
       (transform-responses-bubble)
       (transform-prosper-table__cell)
       (transform-cell_print_hidden)
       ;; filter trash data
       (maptree-if #'consp
                   #'(lambda (x)
                       (values
                        (remove-if #'(lambda (x)
                                       (when (stringp x)
                                         (or
                                          (string= x "div")
                                          (find x *transform-trash* :test #'string=)
                                          )))
                                   x)
                        #'mapcar)))
       ;; linearize for each elt
       (mapcar #'(lambda (tree)
                   (let ((linearize))
                     (maptree #'(lambda (x)
                                  (setf linearize
                                        (append linearize (list x))))
                              tree)
                     linearize)))
       ))

;; (print
;;  (hh-parse-responds *last-parse-data*))


;; (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (print
;;    (hh-parse-responds
;;     (hh-get-page "https://spb.hh.ru/applicant/negotiations?page=1" cookie-jar *hh_account* "https://spb.hh.ru" ))))

(in-package :moto)

(defmethod process-respond (respond)
  ;; Найти src-id вакансии
  (let ((src-id (car (last (split-sequence:split-sequence #\/ (getf respond :vacancy-link))))))
    ;; (unless (null src-id)
    (dbg (format nil "~A : [~A] ~A " src-id (getf respond :result) (getf respond :vacancy-name)))
    ;; (print respond)
    ;; Если такая вакансия есть в бд
    (let ((target (car (find-vacancy :src-id src-id))))
      (unless (null target)
        (dbg (format nil " | ~A" (state target)))
        ;; Все обнаруженные на странице отзывов вакансии следует пометить как :responded, если они имеют статус :unsort :interesting или :uninteresting
        (if (or (equal (state target) ":UNSORT")
                (equal (state target) ":INTERESTING")
                (equal (state target) ":UNINTERESTING"))
            (progn
              (dbg (format nil "~% ~A -> SET RESPONDED" (state target)))
              (takt target :responded)))
        ;; Для всех полученных вакансий, статус которых отличается от "Не просмотрен"..
        (unless (equal "Не просмотрен" (getf respond :result))
          ;; и у нее статус UNSORT, RESPONDED или BEENVIEWED  - установить статус
          (when (or (equal ":UNSORT" (state target))
                    (equal ":RESPONDED" (state target))
                    (equal ":BEENVIEWED" (state target)))
            (cond ((equal "Просмотрен" (getf respond :result))
                   (takt target :beenviewed))
                  ((equal "Отказ" (getf respond :result))
                   (takt target :reject))
                  ((equal "Приглашение" (getf respond :result))
                   (takt target :invite))
                  ((equal "Не просмотрен" (getf respond :result))
                   nil)
                  (t (err (format nil "unk respond state ~A" (state target))))))))))
  respond)

(let ((cookie-jar (make-instance 'drakma:cookie-jar)))
  (defmethod response-factory ((vac-src (eql 'hh)) src-account)
    (let ((url      "https://spb.hh.ru/applicant/negotiations?page=~A")
          (page     0)
          (responds nil))
      (alexandria:named-lambda get-responds ()
        (labels ((load-next-responds-page ()
                   (dbg "load-next-responds-page (page=~A)" page)
                   (let ((next-responds-page-url (format nil url page))
                         (referer (if (= page 0) "https://spb.hh.ru"(format nil url (- page 1)))))
                     (multiple-value-bind (next-responds-page new-cookies ref-url)
                         (hh-get-page next-responds-page-url cookie-jar src-account referer)
                       (setf cookie-jar new-cookies)
                       (setf responds (hh-parse-responds next-responds-page))
                       (incf page)
                       (when (equal 0 (length responds))
                         (dbg "~~ FIN")
                         (return-from get-responds 'nil)))))
                 (get-respond ()
                   (dbg "get-respond")
                   (when (equal 0 (length responds))
                     (load-next-responds-page))
                   (prog1 (car responds)
                     (setf responds (cdr responds)))))
          (tagbody get-new-respond
             (let ((current-respond (process-respond (get-respond))))
               (if (null current-respond)
                   (go get-new-respond)
                   (return-from get-responds current-respond)))))))))

(defun run-response ()
  (make-event :name "run-response"
              :tag "parser-run"
              :msg (format nil "Сбор откликов и приглашений")
              :author-id 0
              :ts-create (get-universal-time))
  (let ((archive-cnt 0))
    (let ((gen (response-factory 'hh *hh_account*)))
      (loop :for i :from 1 :to 700 :do
         (let ((target (funcall gen)))
           (when (null target)
             (return-from run-response 'FIN-NIL))
           (when (getf target :archive)
             (incf archive-cnt))
           (when (> archive-cnt 140)
             (return-from run-response 'ARCHIVE))
           ;; (print target)
           ))
      (return-from run-response 'loop))))

;; (run-response)
