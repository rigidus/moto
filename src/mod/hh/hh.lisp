(in-package #:moto)

(in-package #:moto)

(defun hh-get-page (url)
  "Получение страницы"
  (flexi-streams:octets-to-string
   (drakma:http-request url
                        :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:34.0) Gecko/20100101 Firefox/34.0"
                        :additional-headers `(("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
                                              ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
                                              ("Accept-Charset" . "utf-8")
                                              ("Referer" . "http://spb.hh.ru/")
                                              ("Cookie" . "redirect_host=spb.hh.ru; regions=2; __utma=192485224.1206865564.1390484616.1410378170.1417257232.29; __utmz=192485224.1390484616.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); _xsrf=85014f262b894a1e9fc57b4b838e48e8; hhtoken=ES030IVQP52ULPbRqN9DQOcMIR!T; hhuid=x_FxSYWUbySJe1LhHIQxDA--; hhrole=anonymous; GMT=3; display=desktop; unique_banner_user=1418008672.846376826735616")
                                              ("Cache-Control" . "max-age=0"))
                        :force-binary t)
   :external-format :utf-8))
(in-package #:moto)

(defun hh-parse-vacancy-teasers (html)
  "Получение списка вакансий из html"
  (let* ((cut (ppcre:scan-to-strings
               (format nil "~A(.*)~A"
                       "<table class=\"l-table entry-content\" data-qa=\"vacancy-serp__results\">"
                       "<div class=\"g-hidden b-select-icon-popup HH-VacancyToFavorite-LimitPopup\">")
               html))
         (cut-without-tail (subseq cut 0 (- (length cut) 74)))
         (parsed (html5-parser:node-to-xmls (html5-parser:parse-html5-fragment cut-without-tail)))
         (rows   (cddr (nth 2 (car parsed)))))
    (remove-if
     #'null
     (loop :for row :in rows :collect
        (when (or (ppcre:scan-to-strings "vacancy-serp__vacancy_premium" (car (cdaadr row)))
                  (string= "b-vacancy-list-standard" (car (cdaadr row)))
                  (string= "b-vacancy-list-standard_plus" (car (cdaadr row))))
          (let* ((data (nth 3 row))
                 (hh-vacancy-a (cdr (caddr (caddr (caddr (caddr data))))))
                 (hh-vacancy-name (car (last hh-vacancy-a)))
                 (hh-vacancy-id (parse-integer (car (last (split-sequence:split-sequence #\/ (car (cdaddr (car hh-vacancy-a)))))) :junk-allowed t))
                 (hh-vacancy-date (caddr (cadddr (caddr data))))
                 (hh-vacancy-placetime (nth 4 (nth 4 (caddr data))))
                 (hh-salary-div (nth 5 (caddr data)))
                 (result (list :vacancy-name hh-vacancy-name
                               :vacancy-id hh-vacancy-id
                               :vacancy-date hh-vacancy-date
                               )))
            (when hh-vacancy-placetime
              (let ((hh-employer-name (car (last hh-vacancy-placetime)))
                    (hh-employer-id (parse-integer (car (last (split-sequence:split-sequence #\/ (car (cdaadr hh-vacancy-placetime))))) :junk-allowed t)))
                (setf result (append result (list :employer-name hh-employer-name
                                                  :employer-id hh-employer-id)))))
            (when (and hh-salary-div
                       (string= "b-vacancy-list-salary"  (car (cdaadr hh-salary-div))))
              (let ((hh-salary-currency (cadr (cadadr (caddr hh-salary-div))))
                    (hh-salary-base (parse-integer (cadr (cadadr (cadddr hh-salary-div))) :junk-allowed t))
                    (hh-salary-text (car (last hh-salary-div))))
                (setf result (append result (list :salary-currency hh-salary-currency
                                                  :salary-base hh-salary-base
                                                  :salary-text hh-salary-text)))))
            result))))))

(in-package #:moto)

(defparameter *programmin-and-development-profile*
  (make-profile :name "Программирование и разработка"
                :user-id 1
                :search-query "http://spb.hh.ru/search/vacancy?clusters=true&specialization=1.221&area=2&page=~A"
                :ts-create (get-universal-time)
                :ts-last (get-universal-time)))

(defparameter *collection*
  (make-collection :profile-id (id *programmin-and-development-profile*)
                   :ts-create (get-universal-time)
                   :ts-shedule (get-universal-time)
                   :state ":SHEDULED"))


(defun run-collect (collection)
  (let* ((profile      (get-profile (profile-id collection)))
         (search-str   (search-query profile))
         (all-teasers  nil))
    (block get-all-hh-teasers
      (loop :for num :from 0 :to 100 :do
         (print num)
         (let* ((url (format nil search-str num))
                (teasers (hh-parse-vacancy-teasers (hh-get-page url))))
           (if (equal 0 (length teasers))
               (return-from get-all-hh-teasers)
               (setf all-teasers (append all-teasers teasers)))))
      (print "over-100"))
    all-teasers))

(defparameter *teasers* (run-collect *collection*))

(length *teasers*)

(defun save-collect (all-teasers)
  (loop :for tea :in *teasers* :do
     (print tea)
     (make-vacancy :collection-id (id *collection*)
                   :name (getf tea :vacancy-name)
                   :rem-id (getf tea :vacancy-id)
                   :rem-date (getf tea :vacancy-date)
                   :rem-employer-name (getf tea :employer-name)
                   :rem-employer-id (aif (getf tea :employer-id)
                                         it
                                         0)
                   :currency (getf tea :salary-currency)
                   :salary (aif (getf tea :salary-base)
                                it
                                0)
                   :salary-text (getf tea :salary-text)
                   :state ":TEASER"
                   )))

(save-collect *teasers*)


;; Тестируем hh
(defun hh-test ()
  
  
  (dbg "passed: hh-test~%"))
(hh-test)
