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

(in-package #:moto)

(defun set-resume-position (cookie-jar resume &optional (resume-id ""))
  (with-set-resume-section ((format nil "http://spb.hh.ru/applicant/resumes/edit/position?resume=~A" resume-id)
                            (append
                             `(("title.string" . ,(drakma:url-encode "Программист" :utf-8))
                               ("profArea"     . ,(drakma:url-encode (prof-area resume) :utf-8)))
                             (mapcar #'(lambda (x)
                                         `("specialization.string" . ,(drakma:url-encode x :utf-8)))
                                     (split-sequence:split-sequence #\Space (specializations resume)))
                             `(("profarea" . "")
                               ("profarea" . "1")
                               ("profarea" . "2")
                               ("profarea" . "3")
                               ("profarea" . "4")
                               ("profarea" . "5")
                               ("profarea" . "6")
                               ("profarea" . "7")
                               ("profarea" . "8")
                               ("profarea" . "9")
                               ("profarea" . "10")
                               ("profarea" . "11")
                               ("profarea" . "12")
                               ("profarea" . "13")
                               ("profarea" . "14")
                               ("profarea" . "16")
                               ("profarea" . "17")
                               ("profarea" . "18")
                               ("profarea" . "19")
                               ("profarea" . "20")
                               ("profarea" . "21")
                               ("profarea" . "22")
                               ("profarea" . "23")
                               ("profarea" . "24")
                               ("profarea" . "25")
                               ("profarea" . "26")
                               ("profarea" . "15")
                               ("profarea" . "27")
                               ("profarea" . "29")
                               ("salary.amount" . ,(drakma:url-encode (salary-amount resume) :utf-8))
                               ("salary.currency" . ,(drakma:url-encode (salary-currency resume) :utf-8))
                               ("employment.string" . ,(drakma:url-encode (employment resume) :utf-8))
                               ("workSchedule.string" . ,(drakma:url-encode (work-schedule resume) :utf-8)))
                             ))
    (values
     uri
     headers
     (flexi-streams:octets-to-string body-or-stream :external-format :utf-8))))

;; (print
;;  (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;    (set-resume-position cookie-jar (car (all-resume))
;;                         ;; "8eb43271ff030a44e00039ed1f735871443047"
;;                         )))

(in-package #:moto)

(defun set-resume-education (cookie-jar resume &optional (resume-id ""))
  (with-set-resume-section ((format nil "http://spb.hh.ru/applicant/resumes/edit/education?resume=~A" resume-id)
                            (append
                             `(("educationLevel.string" . ,(drakma:url-encode (education-level-string resume) :utf-8)))
                             (let ((primary-education-id (car (split-sequence:split-sequence #\Space (educations resume)))))
                               (if (null primary-education-id)
                                   (err "error education-id")
                                   (let ((education (get-education (parse-integer primary-education-id))))
                                     `(("primaryEducation.id"            . ,(let ((it (education-id education)))
                                                                                 (if (equal 0 it)
                                                                                     ""
                                                                                     (drakma:url-encode it :utf-8))))
                                       ("primaryEducation.name"          . ,(drakma:url-encode (name education) :utf-8))
                                       ("primaryEducation.universityId"  . ,(drakma:url-encode (format nil "~A" (university-id education)) :utf-8))
                                       ("primaryEducation.facultyId"     . ,(let ((it (faculty-id education)))
                                                                                 (if (equal 0 it)
                                                                                     ""
                                                                                     (drakma:url-encode it :utf-8))))
                                       ("primaryEducation.organization"  . ,(drakma:url-encode (organization education) :utf-8))
                                       ("primaryEducation.result"        . ,(drakma:url-encode (result education) :utf-8))
                                       ("primaryEducation.specialtyId"   . ,(drakma:url-encode (format nil "~A" (specialty-id education)) :utf-8))
                                       ("primaryEducation.year"          . ,(drakma:url-encode (format nil "~A" (year education)) :utf-8))))))
                             `(("primaryEducation.id" . "")
                               ("primaryEducation.name" . "")
                               ("primaryEducation.universityId" . "")
                               ("primaryEducation.facultyId" . "")
                               ("primaryEducation.organization" . "")
                               ("primaryEducation.result" . "")
                               ("primaryEducation.specialtyId" . "")
                               ("primaryEducation.year" . "")
                               ("additionalEducation.id" . ,(drakma:url-encode (additional-education-id resume) :utf-8))
                               ("additionalEducation.name" . ,(drakma:url-encode (additional-education-name resume) :utf-8))
                               ("additionalEducation.organization" . ,(drakma:url-encode (additional-education-organization resume) :utf-8))
                               ("additionalEducation.result" . ,(drakma:url-encode (additional-education-result resume) :utf-8))
                               ("additionalEducation.year" . ,(drakma:url-encode (additional-education-year resume) :utf-8))
                               ("certificate.id" . ,(drakma:url-encode (certificate-id resume) :utf-8))
                               ("certificate.type" . ,(drakma:url-encode (certificate-type resume) :utf-8))
                               ("certificate.selected" . ,(drakma:url-encode (certificate-selected resume) :utf-8))
                               ("certificate.ownerName" . ,(drakma:url-encode (certificate-ownerName resume) :utf-8))
                               ("certificate.transcriptionId" . ,(drakma:url-encode (certificate-transcription-id resume) :utf-8))
                               ("certificate.password" . ,(drakma:url-encode (certificate-password resume) :utf-8))
                               ("certificate.title" . ,(drakma:url-encode (certificate-title resume) :utf-8))
                               ("certificate.achievementDate" . ,(drakma:url-encode (certificate-achievementDate resume) :utf-8))
                               ("certificate.url" . ,(drakma:url-encode (certificate-url resume) :utf-8))
                               ("attestationEducation.id" . ,(drakma:url-encode (attestation-education-id resume) :utf-8))
                               ("attestationEducation.name" . ,(drakma:url-encode (attestation-education-name resume) :utf-8))
                               ("attestationEducation.organization" . ,(drakma:url-encode (attestation-education-organization resume) :utf-8))
                               ("attestationEducation.result" . ,(drakma:url-encode (attestation-education-result resume) :utf-8))
                               ("attestationEducation.year" . ,(drakma:url-encode (attestation-education-year resume) :utf-8)))
                             (let ((langs))
                               (mapcar #'(lambda (x)
                                           (let ((lang (get-lang (parse-integer x))))
                                             (push `("language.id"     . ,(drakma:url-encode (format nil "~A"(lang-id lang))     :utf-8)) langs)
                                             (push `("language.degree" . ,(drakma:url-encode (format nil "~A" (lang-degree lang)) :utf-8)) langs)
                                             ))
                                       (split-sequence:split-sequence #\Space (languages resume)))
                               (reverse langs))
                             `(
                               ("_xsrf"                          . ,(cdr (assoc "_xsrf" cookie-alist :test #'equal))))
                             )
                            )
    (values
     uri
     headers
     (flexi-streams:octets-to-string body-or-stream :external-format :utf-8))))

;; (print
;;  (let ((cookie-jar (make-instance 'drakma:cookie-jar)))
;;    (set-resume-education cookie-jar (car (all-resume))
;;                      ;; "8eb43271ff030a44e00039ed1f735871443047"
;;                      )))

;; resume ends here
