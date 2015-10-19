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

;; Подключение к базе данных PostgreSQL
(defvar *db-name* "ylg_new")
(defvar *db-user* "ylg")
(defvar *db-pass* "6mEfBjyLrSzlE")
(defvar *db-serv* "localhost")

(defvar *db-spec* (list "ylg_new" "ylg" "6mEfBjyLrSzlE" "localhost"))

;; Подключение к базе данных Mysql
(defvar *mysql-db-host* "bkn.ru")
(defvar *mysql-db-database* "bkn_base")
(defvar *mysql-db-user* "root")
(defvar *mysql-db-password* "YGAhBawd1j~SANlw\"Y#l")
(defvar *mysql-db-port* 3306)

;; Макрос для подключения к mysql
(defmacro with-mysql-conn (spec &body body)
  `(let ((*mysql-conn-pool* (apply #'cl-mysql:connect ',spec)))
     (unwind-protect (progn
                       (cl-mysql:query  "SET NAMES 'utf8'")
                       ,@body)
       (cl-mysql:disconnect))))

(defmacro with-mysql (&body body)
  `(with-mysql-conn (:host "bkn.ru" :database "bkn_base" :user "root" :password "YGAhBawd1j~SANlw\"Y#l" :port 3306)
     ,@body))

;; clear db
(drop '("resume"))
;; (drop '("user" "role" "group" "user2group" "msg"
;;         "que" "quelt" "bratan" "cmpx" "plex" "crps" "flat"
;;         "city" "district" "metro" "deadline"))
;; globals ends here
