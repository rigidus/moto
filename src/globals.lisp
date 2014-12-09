;; [[file:doc.org::*Глобальные определения][globals]]
;;;; Copyright © 2014 Glukhov Mikhail. All rights reserved.
;;;; Licensed under the GNU AGPLv3
(in-package #:moto)

;; Подключение к базе данных
(defvar *db-name* "ylg_new")
(defvar *db-user* "ylg")
(defvar *db-pass* "6mEfBjyLrSzlE")
(defvar *db-serv* "localhost")

(defvar *db-spec* (list "ylg_new" "ylg" "6mEfBjyLrSzlE" "localhost"))

;; clear db
(drop '("user" "role" "group" "user2group" "avatar" "msg"
        "que" "quelt" "bratan" "cmpx" "plex" "crps" "flat"
        "city" "district" "metro" "deadline"))
;; globals ends here
