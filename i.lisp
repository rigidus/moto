(asdf:oos 'asdf:load-op :drakma)
(asdf:oos 'asdf:load-op :anaphora)
(asdf:oos 'asdf:load-op :split-sequence)
(asdf:oos 'asdf:load-op :cl-ppcre)

(use-package :drakma)
(use-package :anaphora)
(use-package :split-sequence)
(use-package :cl-ppcre)


(defun get-headers (referer)
  `(("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    ("Accept-Language" . "en-us,en;q=0.5")
    ("Accept-Charset" . "ISO-8859-1,utf-8;q=0.7,*;q=0.7")
    ("Referer" . ,referer)
    ("Cookie" . ,(format nil "~{~a; ~}" *cookies*))))


(defmacro web (to ot)
  (let ((x-to (append '(format nil) to))
        (x-ot (append '(format nil) ot)))
    `(let ((r (http-request ,x-to
                            :user-agent *user-agent*
                            :additional-headers (get-headers ,x-ot))))
       r)))


(defun replace-all (string part replacement &key (test #'char=))
  "Returns a new string in which all the occurences of the part
is replaced with replacement."
  (with-output-to-string (out)
    (loop with part-length = (length part)
       for old-pos = 0 then (+ pos part-length)
       for pos = (search part string
                         :start2 old-pos
                         :test test)
       do (write-string string out
                        :start old-pos
                        :end (or pos (length string)))
       when pos do (write-string replacement out)
       while pos)))


(defun get-links (page)
  (mapcar #'(lambda (x)
              (replace-all (subseq x 41) ".html" ""))
          (all-matches-as-strings "http:\\/\\/moto.auto.ru\\/motorcycle\\/used\\/sale\\/(.)*\.html"
                                  (scan-to-strings "(?s)<table cellpadding=\"0\" cellspacing=\"0\" class=\"list\">(.*)<div class=\"content pager\">"
                                                   (web ("http://all.auto.ru/list/?category_id=1&section_id=1&currency_key=RUR&country_id=1&has_photo=0&region_id=89&sort_by=2&output_format=1&submit=%D0%9D%D0%B0%D0%B9%D1%82%D0%B8&_p=~A" page)
                                                        ("http://all.auto.ru/"))))))



(defparameter *user-agent* "Mozilla/5.0 (X11; U; Linux i686; ru; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.04 (lucid) Firefox/3.6.13")
(defparameter *cookies*
  (list "portal_tid=1291969547067-10909"
        "__utma=189530924.115785001.1291969547.1297497611.1297512149.377"
        "__utmc=3521885"))
(defparameter *items* (make-hash-table :test #'equal))


(loop :for page :from 30 :upto 40 :do
   (let ((links (get-links page)))
     (unless links
       (loop-finish))
     (loop :for link :in links :do
        (print link)
        (setf (gethash link *items*) ""))))


(defun get-item (link)
  (flet ((getint (str)
           (let ((rs ""))
             (do-matches-as-strings (m "\\d" str)
               (setf rs (concatenate 'string rs m)))
             (unless (equal rs "")
               (parse-integer rs))))
         (in-strong (str)
           (let ((b (scan-to-strings "<strong>(.)*</strong>" str)))
             (subseq b 8 (- (length b) 9)))))
    (let* ((pg                 (web ("http://moto.auto.ru/motorcycle/used/sale/~A.html" link)
                                    ("http://moto.auto.ru/")))
           (cost               (getint (scan-to-strings "<p class=\"cost\">(.)*\\d+(.)*руб." pg)))
           (sale-info-block    (scan-to-strings "(?s)sale-info(.)*card_char" pg))
           (kubatura           (getint (scan-to-strings "id=\"card-engine_key\"><big><strong>(.)*см" sale-info-block)))
           (year               (getint (scan-to-strings "id=\"card-year\"><big><strong>(.)*</strong>" sale-info-block)))
           (probeg             (in-strong (scan-to-strings "id=\"card-run\"><big><strong>(.)*</strong>" sale-info-block)))
           (custom-block       (let ((a (scan-to-strings "id=\"card-custom_key\">(.)*</dd>" sale-info-block)))
                                 (scan-to-strings ">(.)*<" a)))
           (split-list         (split "/" custom-block))
           (presence           (let ((a (car split-list)))
                                 (subseq a 1 (- (length a) 1))))
           (docum              (let ((a (cadr split-list)))
                                 (subseq a 1 (- (length a) 1))))
           (message            (let* ((a (scan-to-strings "(?s)<h3 class=\"sale\">Дополнительная информация:<\\/h3>(.)*<div id=\"sale-contact\">" pg))
                                      (b (scan-to-strings "(?s)</b>(.)*</p>" a)))
                                 (when b
                                   (subseq b 4 (- (length b) 4)))))
           (contact            (in-strong (scan-to-strings "(?s)<dt>Контактное лицо:</dt>(.)*</dd><dt>E-mail:</dt>" pg)))
           (phone              (scan-to-strings "(?s)Телефон(.)*<div id=\"sale-photo\">" pg)) ;; TODO
           (sale-phote) ;; TODO
           (counters)   ;; TODO
           )
      phone
      )))

(print
 (get-item "766510-82317"))

(print
 (get-item "681190-741b40"))







"<div id=\"sale-photo\">
<p><img id=\"show-big-photo\" class=\"ligthWindow\" src=\"http://is.auto.ru/all/images/c3/01/c3015706.jpg\" alt=\"Нажмите, чтобы увеличить\" title=\"Нажмите, чтобы увеличить\" width=\"456\" height=\"342\" /></p>
<ul>
<li class=\"selected\"><div class=\"overlay\"></div><a href=\"/motorcycle/used/sale/766510-82317_173650710.html\" rel=\"is.auto.ru|c3015706\" class=\"sprite-thumb sp1\">Фото 1</a></li><li><a href=\"/motorcycle/used/sale/766510-82317_173650746.html\" rel=\"is.auto.ru|c6a40354\" class=\"sprite-thumb sp2\">Фото 2</a></li><li><a href=\"/motorcycle/used/sale/766510-82317_173650778.html\" rel=\"is.auto.ru|40a208b8\" class=\"sprite-thumb sp3\">Фото 3</a></li><li><a href=\"/motorcycle/used/sale/766510-82317_173650816.html\" rel=\"is.auto.ru|d191d489\" class=\"sprite-thumb sp4\">Фото 4</a></li><li><a href=\"/motorcycle/used/sale/766510-82317_173650846.html\" rel=\"is.auto.ru|dfe35cd4\" class=\"sprite-thumb sp5\">Фото 5</a></li>
</ul>
</div>"


"<div class=\"columns sale-counter\">
<p class=\"c\">Дата обновления &ndash; <strong>01.07.2012</strong></p>
<p class=\"c\">Просмотров объявления &ndash; <strong>503</strong></p>
<p class=\"c\">Срок хранения &ndash; до <strong>31.07.2012</strong></p>


</div>
"
