;; [[file:doc.org::*Глобальные определения][globals]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
(in-package #:moto)

;; One thing we have to do is make sure that CL-WHO and Parenscript
;; use different string delimiters so that literal strings will
;; work as intended in JavaScript code inlined in HTML element properties.
(setf *js-string-delimiter* #\")

;; без этого происходит ошибка при компиляции в js
(defparameter PARENSCRIPT::SUPPRESS-VALUES nil)

;; Подключение к базе данных
(defvar *db-name* "ylg_new")
(defvar *db-user* "ylg")
(defvar *db-pass* "6mEfBjyLrSzlE")
(defvar *db-serv* "localhost")

(defvar *db-spec* (list "ylg_new" "ylg" "6mEfBjyLrSzlE" "localhost"))

;; clear db
;; (drop '("user" "role" "group" "user2group" "msg"
;;         "que" "quelt" "bratan" "cmpx" "plex" "crps" "flat"
;;         "city" "district" "metro" "deadline"))
;; globals ends here
