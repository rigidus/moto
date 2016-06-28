;; [[file:resume.org::*Сборка][resume]]
(in-package #:moto)

(defmacro assembly-post (&body body)
  `(format nil "~{~A~^&~}"
           (mapcar #'(lambda (x)
                       (format nil "~A=~A" (car x) (cdr x)))
                   ,@body)))

(defmacro send-post ((url cookie-jar cookie-alist) &body body)
  `(drakma:http-request
    ,url
    :user-agent "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:42.0) Gecko/20100101 Firefox/42.0"
    :method :post
    :content (assembly-post ,@body)
    :content-type "application/x-www-form-urlencoded; charset=UTF-8"
    :redirect 10
    :additional-headers
    `(("Accept" . "*/*")
      ("Accept-Language" . "en-US,en;q=0.5")
      ("X-Xsrftoken" . ,(cdr (assoc "_xsrf" ,cookie-alist :test #'equal)))
      ("X-Requested-With" . "XMLHttpRequest")
      ("Referer" . ,,url)
      ("Connection" . "keep-alive")
      ("Pragma" . "no-cache")
      ("Cache-Control" . "no-cache"))
    :cookie-jar ,cookie-jar
    :force-binary t))

(defmacro send-post-multiple-values ((personal-url cookie-jar cookie-alist &body alist) &body body)
  `(multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
       (send-post (,personal-url ,cookie-jar ,cookie-alist) ,@alist)
     ,@body))

(defmacro with-cookie-alist ((cookie-jar) &body body)
  `(let ((cookie-alist (mapcar #'(lambda (cookie)
                                   (cons (drakma:cookie-name cookie) (drakma:cookie-value cookie)))
                               (drakma:cookie-jar-cookies ,cookie-jar))))
     ,@body))

(defmacro with-set-resume-section ((section-url &body post-data) &body body)
  ;; Сначала запросим основную страницу резюме
  `(let ((main-url (format nil "http://spb.hh.ru/applicant/resumes/view?resume=~A" resume-id)))
     (multiple-value-bind (response cookie-jar url)
         (hh-get-page main-url cookie-jar *hh_account* "http://spb.hh.ru")
       ;; Теперь запрашиваем section-url
       (multiple-value-bind (response cookie-jar url)
           (hh-get-page ,section-url cookie-jar *hh_account* "http://spb.hh.ru")
         (with-cookie-alist (cookie-jar)
           (send-post-multiple-values (,section-url cookie-jar cookie-alist ,@post-data)
             ,@body))))))

(in-package #:moto)

(defun set-resume-personal (cookie-jar resume &optional (resume-id ""))
  (with-set-resume-section ((format nil "http://spb.hh.ru/applicant/resumes/edit/personal?resume=~A" resume-id)
                            `(("lastName.string" . ,(drakma:url-encode (last-name resume) :utf-8))
                              ("firstName.string" . ,(drakma:url-encode (first-name resume) :utf-8))
                              ("middleName.string" . ,(drakma:url-encode (middle-name resume) :utf-8))
                              ("birthday.date" . ,(drakma:url-encode (birthday resume) :utf-8))
                              ("gender.string" . ,(drakma:url-encode (gender resume) :utf-8))
                              ("area.string" . ,(drakma:url-encode (area resume) :utf-8))
                              ("metro.string" . ,(drakma:url-encode (metro resume) :utf-8))
                              ("relocation.string" . ,(drakma:url-encode (relocation resume) :utf-8))
                              ("relocationArea.string" . ,(drakma:url-encode (relocation-area resume) :utf-8))
                              ("businessTripReadiness.string" . ,(drakma:url-encode (business-trip-readiness resume) :utf-8))
                              ("citizenship" . ,(drakma:url-encode (citizen-ship resume) :utf-8))
                              ("citizenship.string" . ,(drakma:url-encode (citizen-ship resume) :utf-8))
                              ("workTicket" . ,(drakma:url-encode (work-ticket resume) :utf-8))
                              ("workTicket.string" . ,(drakma:url-encode (work-ticket resume) :utf-8))
                              ("travelTime.string" . ,(drakma:url-encode (travel-time resume) :utf-8)))
                            )
    (values
     uri
     headers
     (flexi-streams:octets-to-string body-or-stream :external-format :utf-8))))

;; (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (print (set-resume-personal cookie-jar (car (all-resume)))))

(in-package #:moto)

(defun set-resume-contacts (cookie-jar resume &optional (resume-id ""))
  (with-set-resume-section ((format nil "http://spb.hh.ru/applicant/resumes/edit/contacts?resume=~A" resume-id)
                            `(("phone.type" . "cell")
                              ("phone.country" . ,(drakma:url-encode (cell-phone-country resume) :utf-8))
                              ("phone.city" . ,(drakma:url-encode (cell-phone-city resume) :utf-8))
                              ("phone.number" . ,(drakma:url-encode (cell-phone-number resume) :utf-8))
                              ("phone.comment" . ,(drakma:url-encode (cell-phone-comment resume) :utf-8))
                              ("phone.type" . "home")
                              ("phone.country" . ,(drakma:url-encode (home-phone-country resume) :utf-8))
                              ("phone.city" . ,(drakma:url-encode (home-phone-city resume) :utf-8))
                              ("phone.number" . ,(drakma:url-encode (home-phone-number resume) :utf-8))
                              ("phone.comment" . ,(drakma:url-encode (home-phone-comment resume) :utf-8))
                              ("phone.type" . "work")
                              ("phone.country" . ,(drakma:url-encode (home-phone-country resume) :utf-8))
                              ("phone.city" . ,(drakma:url-encode (home-phone-city resume) :utf-8))
                              ("phone.number" . ,(drakma:url-encode (home-phone-number resume) :utf-8))
                              ("phone.comment" . ,(drakma:url-encode (home-phone-comment resume) :utf-8))
                              ("email.string" . ,(drakma:url-encode (email-string resume) :utf-8))
                              ("preferredContact.string" . ,(drakma:url-encode (preferred-contact resume) :utf-8))
                              ("personalSite.type" . "icq")
                              ("personalSite.url" . ,(drakma:url-encode (icq resume) :utf-8))
                              ("personalSite.type" . "skype")
                              ("personalSite.url" . ,(drakma:url-encode (skype resume) :utf-8))
                              ("personalSite.type" . "freelance")
                              ("personalSite.url" . ,(drakma:url-encode (freelance resume) :utf-8))
                              ("personalSite.type" . "moi_krug")
                              ("personalSite.url" . ,(drakma:url-encode (moi_krug resume) :utf-8))
                              ("personalSite.type" . "linkedin")
                              ("personalSite.url" . ,(drakma:url-encode (linkedin resume) :utf-8))
                              ("personalSite.type" . "facebook")
                              ("personalSite.url" . ,(drakma:url-encode (facebook resume) :utf-8))
                              ("personalSite.type" . "livejournal")
                              ("personalSite.url" . ,(drakma:url-encode (livejournal resume) :utf-8))
                              ("personalSite.type" . "personal")
                              ("personalSite.url" . ,(drakma:url-encode (personal-site resume) :utf-8)))
                            )
    (values
     uri
     headers
     (flexi-streams:octets-to-string body-or-stream :external-format :utf-8))))

;; (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;   (print
;;    (set-resume-contacts cookie-jar (car (all-resume))
;;                         ;; "8eb43271ff030a44e00039ed1f735871443047"
;;                         )))
;; resume ends here
