
(in-package #:moto)

;; Подключение к базе данных
(defvar *db-name* "ylg_new")
(defvar *db-user* "ylg")
(defvar *db-pass* "6mEfBjyLrSzlE")
(defvar *db-serv* "localhost")

(defvar *db-spec* (list "ylg_new" "ylg" "6mEfBjyLrSzlE" "localhost"))

;; clear db
(let ((tables '("user" "role" "group" "user2group" "avatar" "msg" "flat" "que" "quelt" "bratan" "cmpx" "plex")))
  (flet ((rmtbl (tblname)
           (when (with-connection *db-spec*
                   (query (:select 'table_name :from 'information_schema.tables :where
                                   (:and (:= 'table_schema "public")
                                         (:= 'table_name tblname)))))
             (with-connection *db-spec*
               (query (:drop-table (intern (string-upcase tblname))))))))
    (loop :for tblname :in tables :collect
       (rmtbl tblname))))
