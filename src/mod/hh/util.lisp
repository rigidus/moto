;; [[file:hh.org::*Утилиты][utility_file]]
(in-package #:moto)

(defparameter *user-agent* "Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:33.0) Gecko/20100101 Firefox/33.0")

(defparameter *cookies*
  (list "portal_tid=1291969547067-10909"
        "__utma=189530924.115785001.1291969547.1297497611.1297512149.377"
        "__utmc=3521885"))

(setf *drakma-default-external-format* :utf-8)

(defun get-headers (referer)
  `(
    ("Accept" . "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8")
    ("Accept-Language" . "ru-RU,ru;q=0.8,en-US;q=0.5,en;q=0.3")
    ("Accept-Charset" . "utf-8")
    ("Referer" . ,referer)
    ;; ("Cookie" . ,(format nil "~{~a; ~}" *cookies*))
    ("Cookie" . "ad20c=2; ad17c=2; __utma=48706362.2093251633.1396569814.1413985658.1413990550.145; __utmz=48706362.1413926450.142.18.utmcsr=vk.com|utmccn=(referral)|utmcmd=referral|utmcct=/im; email=avenger-f%40yandex.ru; password=30e3465569cc7433b34d42baeadff18f; PHPSESSID=ms1rrsgjqvm3lhdl5af1aekvv0; __utmc=48706362; __utmb=48706362.5.10.1413990550")
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
;; utility_file ends here
