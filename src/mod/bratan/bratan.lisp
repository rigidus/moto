
(in-package #:moto)

;; (asdf:oos 'asdf:load-op :drakma)
;; (asdf:oos 'asdf:load-op :anaphora)
;; (asdf:oos 'asdf:load-op :split-sequence)
;; (asdf:oos 'asdf:load-op :cl-ppcre)

;; (use-package :drakma)
;; (use-package :anaphora)
;; (use-package :split-sequence)
;; (use-package :cl-ppcre)

(defparameter *user-agent* "Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.04 (lucid) Firefox/3.6.13")

(defparameter *cookies*
  (list "portal_tid=1291969547067-10909"
        "__utma=189530924.115785001.1291969547.1297497611.1297512149.377"
        "__utmc=3521885"))

(setf *drakma-default-external-format* :utf-8)

(defun get-headers (referer)
  `(
    ;; ("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    ("Accept-Language" . "en-us,en;q=0.5")
    ("Accept-Charset" . "utf-8")
    ("Referer" . ,referer)
    ;; ("Cookie" . ,(format nil "~{~a; ~}" *cookies*))
    ))


(defmacro web (to ot)
  (let ((x-to (append '(format nil) to))
        (x-ot (append '(format nil) ot)))
    `(let ((r (sb-ext:octets-to-string
               (drakma:http-request ,x-to
                                    :user-agent *user-agent*
                                    :additional-headers (get-headers ,x-ot)
                                    :force-binary t)
               :external-format :utf-8)))
       r)))

(defmacro fnd (var pattern)
  `(multiple-value-bind (all matches)
       (ppcre:scan-to-strings ,pattern ,var)
     (let ((str (format nil "~a" matches)))
       (subseq str 2 (- (length str) 1)))))


(defun get-user-page (user-id)
  (let* ((page (web ("http://www.motobratan.ru/users/~A.html" user-id)
                    ("http://www.motobratan.ru/")))
         (head (fnd page "(?s)<div class=\"headClass\">(.*)<div class=\"clear\">")))
    (list
     :name (fnd head "<h1>(.*)</h1>")
     :last-seen (fnd head "<div class=\"link flow small\">(.*)</div>")
     :distrinkt (fnd head "<div class=\"item flow\">(.*)</div>")
     :registration (fnd head "<noindex><div class=\"flow\">(.*)</div></noindex>")
     :age (fnd head "<div class=\"flow\">(.*)<span class=\"small gray\">")
     :birthday (fnd head "<span class=\"small gray\">(.*)</span></div>")
     :blood (fnd head "<noindex><div class=\"\">(.*)</div></noindex>")
     :moto-exp (fnd head "<noindex><div class=\"\">(.*)</div></noindex>")
     :phone (fnd head "<div class=\"item flow\">(.*)</div>")
     )))

(get-user-page 35273)

;; (defun get-links (page)
;;   (mapcar #'(lambda (x)
;;               (replace-all (subseq x 41) ".html" ""))
;;           (all-matches-as-strings "http:\\/\\/moto.auto.ru\\/motorcycle\\/used\\/sale\\/(.)*\.html"
;;                                   (scan-to-strings "(?s)<table cellpadding=\"0\" cellspacing=\"0\" class=\"list\">(.*)<div class=\"content pager\">"
;;                                                    (web ("http://all.auto.ru/list/?category_id=1&section_id=1&currency_key=RUR&country_id=1&has_photo=0&region_id=89&sort_by=2&output_format=1&submit=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8&_p=~A" page)
;;                                                         ("http://all.auto.ru/"))))))


;; (loop :for page :from 30 :upto 40 :do
;;    (let ((links (get-links page)))
;;      (unless links
;;        (loop-finish))
;;      (loop :for link :in links :do
;;         (print link)
;;         (setf (gethash link *items*) ""))))


;; (defun get-item (link)
;;   (flet ((getint (str)
;;            (let ((rs ""))
;;              (do-matches-as-strings (m "\\d" str)
;;                (setf rs (concatenate 'string rs m)))
;;              (unless (equal rs "")
;;                (parse-integer rs))))
;;          (in-strong (str)
;;            (let ((b (scan-to-strings "<strong>(.)*</strong>" str)))
;;              (subseq b 8 (- (length b) 9)))))
;;     (let* ((pg                 (web ("http://moto.auto.ru/motorcycle/used/sale/~A.html" link)
;;                                     ("http://moto.auto.ru/")))
;;            (cost               (getint (scan-to-strings "<p class=\"cost\">(.)*\\d+(.)*руб." pg)))
;;            (sale-info-block    (scan-to-strings "(?s)sale-info(.)*card_char" pg))
;;            (kubatura           (getint (scan-to-strings "id=\"card-engine_key\"><big><strong>(.)*см" sale-info-block)))
;;            (year               (getint (scan-to-strings "id=\"card-year\"><big><strong>(.)*</strong>" sale-info-block)))
;;            (probeg             (in-strong (scan-to-strings "id=\"card-run\"><big><strong>(.)*</strong>" sale-info-block)))
;;            (custom-block       (let ((a (scan-to-strings "id=\"card-custom_key\">(.)*</dd>" sale-info-block)))
;;                                  (scan-to-strings ">(.)*<" a)))
;;            (split-list         (split "/" custom-block))
;;            (presence           (let ((a (car split-list)))
;;                                  (subseq a 1 (- (length a) 1))))
;;            (docum              (let ((a (cadr split-list)))
;;                                  (subseq a 1 (- (length a) 1))))
;;            (message            (let* ((a (scan-to-strings "(?s)<h3 class=\"sale\">Дополнительная информация:<\\/h3>(.)*<div id=\"sale-contact\">" pg))
;;                                       (b (scan-to-strings "(?s)</b>(.)*</p>" a)))
;;                                  (when b
;;                                    (subseq b 4 (- (length b) 4)))))
;;            (contact            (in-strong (scan-to-strings "(?s)<dt>Контактное лицо:</dt>(.)*</dd><dt>E-mail:</dt>" pg)))
;;            (phone              (scan-to-strings "(?s)Телефон(.)*<div id=\"sale-photo\">" pg)) ;; TODO
;;            (sale-phote) ;; TODO
;;            (counters)   ;; TODO
;;            )
;;       phone
;;       )))

;; (print
;;  (get-item "766510-82317"))

;; (print
;;  (get-item "681190-741b40"))
