;; [[file:trend.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы

(in-package #:moto)

(defun get-cmpx-from-src-bd (from cnt)
  (let* ((raw-query "
                    SELECT DISTINCT
                        REPLACE(REPLACE(bkn.name, '«', ''), '»', '') AS name,
                        u.unidecode AS unidecode,
                        du.unidecode AS developer_unidecode,
                        toguid(ap.id) AS complexId,
                        ap.regionId AS regionId,
                        REPLACE(REPLACE(d.name, '«', ''), '»', '') AS developer,
                        toguid(d.id) AS developerId,
                        CONCAT('/BuildingComplexes/complex/', u.unidecode) AS complexLink,
                        CONCAT('/BuildingComplexes/developers/', du.unidecode) AS developerLink,
                        ap.city_name AS city_name,
                        ap.street_name AS street_name,
                        sbw.name AS subway,
                        ap.subway1Id AS subwayId,
                        ap.district_name AS district,
                        ap.districtId AS districtId,
                        ap.latitude,
                        ap.longitude,
                        ap.nb_sourceId AS sourceId,
                        (SELECT
                                CONCAT('http://alexander.pro.bkn.ru/images/b_preview/',
                                            filename)
                            FROM
                                bkn_base.nb_photos ph
                            WHERE
                                ph.objectId = ap.id
                            LIMIT 1) AS photo,
                        (SELECT
                                COUNT(*)
                            FROM
                                bkn_base.nb_photos ph
                            WHERE
                                ph.objectId = ap.id) AS pcount,
                        (SELECT
                                status_buildId
                            FROM
                                bkn_base.nb_block bl
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND bl.statusId = 1
                            ORDER BY bl.status_buildId
                            LIMIT 1) AS status_buildId,
                        (SELECT
                                CONCAT(bl.quarter_end, '-', bl.year_end)
                            FROM
                                bkn_base.nb_block bl
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND bl.statusId = 1
                                    AND bl.quarter_end IS NOT NULL
                                    AND bl.year_end IS NOT NULL
                            ORDER BY bl.year_end
                            LIMIT 1) AS year_end_min_string,
                        (SELECT
                                CONCAT(bl.quarter_end, '-', bl.year_end)
                            FROM
                                bkn_base.nb_block bl
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND bl.statusId = 1
                                    AND bl.quarter_end IS NOT NULL
                                    AND bl.year_end IS NOT NULL
                            ORDER BY bl.year_end DESC
                            LIMIT 1) AS year_end_max_string,
                        (SELECT
                                COUNT(*)
                            FROM
                                bkn_base.nb_block bl
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND bl.statusId = 1
                            ORDER BY bl.year_end DESC
                            LIMIT 1) AS bcount,
                        (SELECT
                                MIN(amount)
                            FROM
                                bkn_base.nb_appartment apa
                                    INNER JOIN
                                bkn_base.nb_block bl ON apa.nb_blockId = bl.id
                                    AND bl.statusId = 1
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND apa.statusId = 1
                                    AND apa.obj_typeId IN (1 , 3, 6)) AS minamount,
                        (SELECT
                                MIN(amount_metr)
                            FROM
                                bkn_base.nb_appartment apa
                                    INNER JOIN
                                bkn_base.nb_block bl ON apa.nb_blockId = bl.id
                                    AND bl.statusId = 1
                            WHERE
                                bl.nb_complexId = ap.id
                                    AND apa.statusId = 1
                                    AND apa.obj_typeId IN (1 , 3, 6)) AS minamount_metr
                    FROM
                        bkn_base.nb_complex bkn
                            INNER JOIN
                        bkn_base.nb_complex ap FORCE INDEX (AP) ON bkn.id = ap.bknid
                            AND ap.nb_sourceId IN (1 , 3)
                            AND ap.statusId = 1
                            AND ap.isPrivate = 0
                            LEFT JOIN
                        bkn_base.subway sbw ON sbw.id = ap.subway1Id
                            INNER JOIN
                        bkn_base.developer d ON d.id = ap.developerId
                            INNER JOIN
                        bkn_base.unidecode u ON u.guid = ap.id AND u.type = 0
                            INNER JOIN
                        bkn_base.unidecode du ON du.guid = d.id AND du.type = 1
                            INNER JOIN
                        bkn_base.nb_block b ON b.nb_complexId = ap.id
                            AND b.statusId = 1
                            INNER JOIN
                        bkn_base.nb_appartment a ON b.id = a.nb_blockId AND a.statusId = 1
                            AND a.obj_typeId IN (1 , 3, 6)
                    WHERE
                        bkn.nb_sourceId = 2 AND bkn.statusId = 1
                    ORDER BY ap.name
                    LIMIT $from, $cnt;
                    ")
         (query-1 (replace-all raw-query "$from" (format nil "~A" from)))
         (query-2 (replace-all query-1 "$cnt" (format nil "~A" cnt)))
         (result (cl-mysql:query query-2))
         (fields (mapcar #'(lambda (x)
                             (intern (string-upcase (car x)) :keyword))
                         (cadar result)))
         (data   (caar  result)))
    (mapcar #'(lambda (elt)
                (loop
                   :for idx :from 0
                   :for in :in elt :append
                   (list (nth idx fields) in)))
            data)))

;; (get-cmpx-from-src-bd 0 1)

;; ~/quicklisp/dists/quicklisp/software/cl-mysql-20120208-git/
;; (when (null (string-to-date (subseq string 0 10)))
;;   (return-from string-to-universal-time 2208988800))

(in-package #:moto)

(defun import-cmpx ()
  (dbg "trend: import-cmpx started~%")
  (mapcar #'(lambda (cmpx)
              (let ((flag-match nil))
                (block try-match
                  (mapcar #'(lambda (candidat)
                              (when (is-match-cmpx cmpx candidat)
                                (dbg " :match cmpx ~A:~A" (getf cmpx :complexId) (getf cmpx :name))
                                (check-and-update-cmpx cmpx candidat)
                                (setf flag-match t)
                                (return-from try-match))
                              )
                          (find-simular-cmpx cmpx))
                  (unless flag-match
                    (dbg " :NEW cmpx ~A:~A" (getf cmpx :complexId) (getf cmpx :name))
                    (check-and-import cmpx)))))
          (get-cmpx-from-src-bd 0 999)))

;; (import-cmpx)

(defun check-and-import (cmpx)
  (let ((developer-guid (getf cmpx :developerId)))
    (unless (car (find-developer :guid developer-guid))
      (import-developer developer-guid)))
  (make-cmpx
   :guid (getf cmpx :complexId)
   :nb_sourceId (getf cmpx :sourceId)
   :statusId 1;;(getf cmpx :status_buildid)
   :developerId (getf cmpx :developerId)
   :date_insert "1970-10-10 23:00"
   :regionId (getf cmpx :regionId)
   :districtId (getf cmpx :districtId)
   :district_name (getf cmpx :district)
   :city_name (getf cmpx :city_name)
   :street_name (getf cmpx :street_name)
   :subway1Id 0
   :subway2Id 0
   :subway3Id 0
   :name (getf cmpx :name)
   :note ""
   :longitude (getf cmpx :longitude)
   :latitude (getf cmpx :latitude)
   :dateUpdate "1970-10-10 23:00"
   :isPrivate 0
   :bknId nil))

   ;; :NAME "Триумф Парк"
   ;; :UNIDECODE "triumf_park"
   ;; :DEVELOPER_UNIDECODE        "pietra-8_ooo"
   ;; :DEVELOPER "Петра-8 ООО"
   ;; :COMPLEXLINK "/BuildingComplexes/complex/triumf_park"
   ;; :DEVELOPERLINK "/BuildingComplexes/developers/pietra-8_ooo"
   ;; :SUBWAY "Звездная"
   ;; :SUBWAYID 16
   ;; :LATITUDE 299133397139/5000000000
   ;; :LONGITUDE 151666688919/5000000000
   ;; :PHOTO         "http://alexander.pro.bkn.ru/images/b_preview/ae16995aa94afab0a"
   ;; :PCOUNT 1
   ;; :YEAR_END_MIN_STRING "2-2016"
   ;; :YEAR_END_MAX_STRING "3-2017"
   ;; :BCOUNT 4
   ;; :MINAMOUNT 86034/25
   ;; :MINAMOUNT_METR 0


(defun check-and-update-cmpx (cmpx candidat)
  (upd-cmpx candidat (list :name (getf cmpx :name)
                           :date_insert "1970-10-10 23:00"
                           :dateupdate "1970-10-10 23:00")))

(defun find-simular-cmpx (cmpx)
  (let ((result))
    (block check-name
      (setf result
            (append result
                     (find-cmpx :name (getf cmpx :name)))))
    (remove-duplicates result)))

;; (find-sumular-cmpx (car (get-cmpx-from-src-bd 0 1)))

(in-package #:moto)

(defun is-match-cmpx (cmpx candidat)
  (and
   (equal (name candidat) (getf cmpx :name))
   (equal (developerId candidat) (getf cmpx :developerId))))

(in-package #:moto)

(defun import-developer (developer-guid)
  (dbg " :NEW developer ~A" developer-guid)
  (let* ((raw-query "
                     SELECT
                         toguid(d.id) AS guid,
                         REPLACE(REPLACE(d.name, '«', ''), '»', '') AS name,
                         d.deleted,
                         d.address,
                         d.url,
                         d.phone,
                         d.note,
                         c.phone,
                         c.logo,
                         c.url,
                         c.email,
                         CONVERT (c.enabled, SIGNED) AS enabled,
                         c.name
                     FROM
                         bkn_base.developer d
                             INNER JOIN
                         bkn_base.developer_customs c ON c.developerId = d.id
                     WHERE
                         d.id = guidtobinary('$developerId')
                    ")
         (query-1 (replace-all raw-query "$developerId" (format nil "~A" developer-guid)))
         (result (cl-mysql:query query-1))
         (fields (mapcar #'(lambda (x)
                             (intern (string-upcase (car x)) :keyword))
                         (cadar result)))
         (data   (caar  result)))
    (mapcar #'(lambda (elt)
                (loop
                   :for idx :from 0
                   :for in :in elt :append
                   (list (nth idx fields) in)))
            data)))

(import-developer "6945CE85-8335-11E4-B6C0-448A5BD44C07")

;; (in-package #:moto)

;; (defun sanitize-cmpx (x)
;;   (list
;;    :guid (nth 0 x)
;;    :nb_sourceId (nth 1 x)
;;    :statusId (nth 2 x)
;;    :date_insert "1970-01-01 00:00:00"
;;    ;; :date_insert (nth 3 x)
;;    :date_update "1970-01-01 00:00:00"
;;    ;; :date_update (let ((tmp (nth 4 x)))
;;    ;;                (if (null tmp)
;;    ;;                    "1970-01-01 00:00:00"
;;    ;;                    "1970-01-01 00:00:00"
;;    ;;                    ;; tmp
;;    ;;                    ))
;;    :regionId (nth 5 x)
;;    :districtId (nth 6 x)
;;    :district_name (nth 7 x)
;;    :city_name (nth 8 x)
;;    :street_name (nth 9 x)
;;    :subway1Id (let ((tmp (nth 10 x)))
;;                 (if (null tmp)
;;                     0
;;                     tmp))
;;    :subway2Id (let ((tmp (nth 11 x)))
;;                 (if (null tmp)
;;                     0
;;                     tmp))
;;    :subway3Id (let ((tmp (nth 12 x)))
;;                 (if (null tmp)
;;                     0
;;                     tmp))
;;    :name (nth 13 x)
;;    :note (let ((note (nth 14 x)))
;;            (if (null note)
;;                ""
;;                (let ((proc (sb-ext:run-program "/usr/bin/php" (list "-r" (format nil "echo(strip_tags(\"~A\"));" (replace-all note "\"" "\\\""))) :output :stream :wait nil)))
;;                  (let ((in-string ""))
;;                    (with-open-stream (stream (sb-ext:process-output proc))
;;                      ;; (finish-output *stream*)
;;                      (loop :for iter :from 1 :do
;;                         (handler-case
;;                             (tagbody start-decoding
;;                                (setf in-string (concatenate 'string in-string (read-line stream)))
;;                                (incf iter)
;;                                (go start-decoding))
;;                           (END-OF-FILE () (return))))
;;                      (close stream))
;;                    in-string))))
;;    :longitude (nth 15 x)
;;    :latitude (nth 16 x)
;;    ;; :dateUpdate (nth 17 x)
;;    :dateUpdate "1970-01-01 00:00:00"
;;    :isPrivate (nth 18 x)
;;    :bknId (nth 19 x)
;;    :developerId (nth 20 x)))

;; ;; (print
;; ;;  (mapcar #'sanitize-cmpx
;; ;;          (caar
;; ;;           (get-cmpx-by-developer "6945DC73-8335-11E4-B6C0-448A5BD44C07"))))

;; (in-package #:moto)

;; (let ((all-cmpx-s))
;;   (mapcar #'(lambda (guid)
;;               (let ((cmpx-s (caar (get-cmpx-by-developer guid))))
;;                 (mapcar #'(lambda (cmpx)
;;                             (push (sanitize-cmpx cmpx) all-cmpx-s))
;;                        cmpx-s)))
;;          (mapcar #'guid (all-developer)))
;;   (mapcar #'(lambda (x)
;;               ;; (print x)
;;               (apply #'make-cmpx x))
;;           all-cmpx-s))
(in-package #:moto)

;; Страничка застройщика
(restas:define-route trnd-cmpx-page ("/trnd/cmpx/:guid")
  (let ((cmpx (find-cmpx :guid guid)))
    (if (null cmpx)
        ""
        (let ((cmpx (car cmpx)))
          (ps-html
           ((:a :href "/trnd/devs") "Все застройщики")
           ((:br))
           ((:br))
           ((:table :border 1)
            ((:tr)
             ((:td) "id")
             ((:td) (id cmpx)))
            ((:tr)
             ((:td) "guid")
             ((:td) (guid cmpx)))
             ((:tr)
             ((:td) "name")
             ((:td) (name cmpx)))
            ((:tr)
             ((:td) "statusId")
             ((:td) (statusId cmpx)))
            ((:tr)
             ((:td) "developer")
             ((:td) ((:a :href (format nil "/trnd/dev/~A" (developerId cmpx)))
                     (name (car (find-developer :guid (developerId cmpx)))))))
            ((:tr)
             ((:td) "longitude")
             ((:td) (longitude cmpx)))
            ((:tr)
             ((:td) "latitude")
             ((:td) (latitude cmpx)))
            ((:tr)
             ((:td) "latitude")
             ((:td) (latitude cmpx)))
            ((:tr)
             ((:td) "bknId")
             ((:td) (bknId cmpx))))
           (note cmpx)
           )))))

(in-package #:moto)

(defun get-active-developers ()
  (with-mysql
    (let ((cnt (caaaar (cl-mysql:query "SELECT count(id) FROM developer"))))
      (cl-mysql:query
       (replace-all "
                     SELECT
                         toguid(d.id) AS developerId,
                         REPLACE(REPLACE(d.name, '«', ''), '»', '') AS developer_name,
                         d.address,
                         d.url,
                         d.phone,
                         d.note
                     FROM
                         nb_complex cmpx
                     INNER JOIN
                         developer d  ON  d.id = cmpx.developerId
                     INNER JOIN
                         nb_complex ap FORCE INDEX (AP)  ON  cmpx.id = ap.bknid  AND  ap.nb_sourceId IN (1 , 3)  AND  ap.statusId = 1  AND  ap.isPrivate = 0
                     INNER JOIN
                         nb_block b  ON  b.nb_complexId = ap.id  AND  b.statusId = 1
                     INNER JOIN
                         nb_appartment a  ON  b.id = a.nb_blockId  AND  a.statusId = 1
                     WHERE
                         cmpx.nb_sourceId = 2  AND  cmpx.statusId = 1
                     GROUP BY d.id , d.name
                     ORDER BY d.name
                     LIMIT $limit;
                    "
                    "$limit"
                    (format nil "~A" cnt))))))

(in-package #:moto)

(defun sanitize-developer (x)
  (list
   :guid (nth 0 x)
   :name (nth 1 x)
   :address (nth 2 x)
   :url (nth 3 x)
   :phone (nth 4 x)
   :note (let ((note (nth 5 x)))
           (if (null note)
               ""
               (let ((proc (sb-ext:run-program "/usr/bin/php" (list "-r" (format nil "echo(strip_tags(\"~A\"));" (replace-all note "\"" "\\\""))) :output :stream :wait nil)))
                 (let ((in-string ""))
                   (with-open-stream (stream (sb-ext:process-output proc))
                     ;; (finish-output *stream*)
                     (loop :for iter :from 1 :do
                        (handler-case
                            (tagbody start-decoding
                               (setf in-string (concatenate 'string in-string (read-line stream)))
                               (incf iter)
                               (go start-decoding))
                          (END-OF-FILE () (return))))
                     (close stream))
                   in-string))))))

;; (mapcar
;;  #'sanitize-developer
;;  (caar (get-active-developers)))

(in-package #:moto)

(defun developers-from-mysql-to-pgsql ()
  (with-connection *db-spec*
    (query "TRUNCATE developer"))
  (mapcar #'(lambda (x)
              (apply #'make-developer (sanitize-developer x)))
          (caar (get-active-developers))))

;; (developers-from-mysql-to-pgsql)

(in-package #:moto)

;; Застройщики (все)
(restas:define-route trnd-devs ("/trnd/devs")
  (ps-html
   ((:form :method "POST")
    ((:table :border 1)
     (format nil "~{~A~}"
             (with-collection (i (sort (all-developer) #'(lambda (a b) (< (id a) (id b)))))
               (ps-html
                ((:tr)
                 ((:td) (id i))
                 ((:td) ((:a :href (format nil "/trnd/dev/~A" (guid i))) (name i)))))))
     ))))

;; Страничка застройщика
(restas:define-route trnd-dev-page ("/trnd/dev/:guid")
  (let ((dev (find-developer :guid guid)))
    (if (null dev)
        ""
        (let ((dev (car dev)))
          (ps-html
           ((:a :href "/trnd/devs") "Все застройщики")
           ((:br))
           ((:br))
           ((:table :border 1)
            ((:tr)
             ((:td) "id")
             ((:td) (id dev)))
            ((:tr)
             ((:td) "guid")
             ((:td) (guid dev)))
            ((:tr)
             ((:td) "name")
             ((:td) (name dev)))
            ((:tr)
             ((:td) "address")
             ((:td) (address dev)))
            ((:tr)
             ((:td) "url")
             ((:td) (url dev)))
            ((:tr)
             ((:td) "phone")
             ((:td) (phone dev))))
           (note dev)
           (let ((cmpx-s (find-cmpx :developerid guid)))
             (if (null cmpx-s)
                 "Нет комплексов"
                 (ps-html
                  ((:table :border 1)
                   (format nil "~{~A~}"
                           (mapcar #'(lambda (cmpx)
                                       (ps-html
                                        ((:tr)
                                         ((:td) (id cmpx))
                                         ((:td) ((:a :href (format nil "/trnd/cmpx/~A" (guid cmpx))) (name cmpx))))))
                                   cmpx-s))))))
           )))))

(in-package #:moto)

(defun get-blks-by-cmpx (guid)
  (with-mysql
    (cl-mysql:query
     (replace-all "
                   SELECT toguid(id), nb_sourceId, toguid(nb_complexId), statusId, status_buildId, house, block, litera, floors, quarter_end, year_end, house_typeId, toguid(bknId), dateUpdate, toguid(nb_complexId)
                   FROM nb_block
                   WHERE
                      nb_sourceId IN (2)
                   AND
                      nb_complexId = guidtobinary('$complexId')
                  "
                  "$complexId"
                  (format nil "~A" guid)))))

(get-blks-by-cmpx "9DFF6CEF-D7EE-11E4-9FBB-448A5BD44C07")

(in-package #:moto)

(defun sanitize-blk (x)
  (list
   :guid (nth 0 x)
   :nb_sourceId (nth 1 x)
   :nb_cmpxId (nth 2 x)
   :statusId (nth 3 x)
   :status_buildId (nth 4 x)
   :street "stub"
   :house (nth 5 x)
   :corpus (nth 6 x)
   :litera (nth 7 x)
   :floors (nth 8 x)
   :quarter_end (let ((tmp (nth 9 x)))
                (if (null tmp)
                    0
                    tmp))
   :year_end (let ((tmp (nth 10 x)))
                (if (null tmp)
                    0
                    tmp))
   :house_typeId (let ((tmp (nth 11 x)))
                (if (null tmp)
                    0
                    tmp))
   :bknId (nth 12 x)
   :dateUpdate "1970-01-01 00:00:00"
   ))

;; (print
;;  (mapcar #'sanitize-blk
;;          (caar
;;           (get-blks-by-cmpx "9DFF6CEF-D7EE-11E4-9FBB-448A5BD44C07"))))

;; (in-package #:moto)

;; (let ((all-blk-s))
;;   (mapcar #'(lambda (guid)
;;               (let ((blk-s (caar (get-blks-by-cmpx guid))))
;;                 (mapcar #'(lambda (blk)
;;                             (push (sanitize-blk blk) all-blk-s))
;;                        blk-s)))
;;          (mapcar #'guid (all-cmpx)))
;;   (mapcar #'(lambda (x)
;;               (print x)
;;               (apply #'make-blk x))
;;           all-blk-s))
(in-package #:moto)

(defparameter *trnd-pages*
  '((:title "Застройщики" :link "bldr")
    (:title "Жилые комплексы" :link "cmpx" )))

;; Меню модуля
(restas:define-route test-page ("/trnd")
  (format nil "~{~A~}"
          (mapcar #'(lambda (x)
                      (format nil "<a href=\"/trnd/~A\">~A</a><br />"
                              (getf x :link)
                              (getf x :title)))
                  *trnd-pages*)))

;; (in-package #:moto)

;; ((количество-комнат
;;   (radiobtn Студия 1 2 3 4+))
;;  (стоимость)
;;  (жилой-комплекс)
;;  (срок-сдачи)
;;  (расположение)
;;  (застройщик)
;;  (отделка))
;; (in-package #:moto)

;; ;; Страница загрузки данных
;; (restas:define-route load-data-page ("/load")
;;   (with-wrapper
;;     (concatenate
;;      'string
;;      "<h1>Загрузка данных из файлов</h1>"
;;      (if (null *current-user*)
;;          "Error: Незалогиненные пользователи не имеют права загружать данные"
;;          (frm (tbl
;;                (list
;;                 (row "" (let ((cmpx-s))
;;                           (loop-dir cmpx ()
;;                                (push cmpx cmpx-s))
;;                           (format nil "~{~A<br/>~}<br />" cmpx-s)))
;;                 (row "" (hid "load"))
;;                 (row "" (submit "Загрузить")))))))))

;; ;; Контроллер страницы регистрации
;; (restas:define-route load-ctrl ("/load" :method :post)
;;   (with-wrapper
;;     (let* ((p (alist-to-plist (hunchentoot:post-parameters*))))
;;       (if (equal (getf p :load) "")
;;           (load-data)
;;           "err"))))

;; (in-package #:moto)

;; (define-page all-cmpx-s "/cmpxs"
;;   (concatenate 'string "<h1>" "Жилые комплексы" "</h1>" ""
;;                "<br /><br />"
;;                (tbl
;;                 (with-collection (cmpx (funcall #'all-cmpx))
;;                   (tr
;;                    (td
;;                     (format nil "<a href=\"/~a/~a\~a</a>" "cmpx"
;;                     (id cmpx) (id cmpx)))
;;                    (td (name cmpx))
;;                    (td (addr cmpx))
;;                    (td (aif (district-id cmpx)
;;                             (name (get-district it))))
;;                    (td (aif (metro-id cmpx)
;;                             (name (get-metro it))))
;;                    (td (frm %del%))))
;;                 :border 1))
;;   (:del (act-btn "DEL" (id cmpx) "Удалить")
;;         (progn (del-cmpx (getf p :data)))))

;; (in-package #:moto)

;; (define-page cmpx "/cmpx/:cmpx-id"
;;   (let* ((i (parse-integer cmpx-id))
;;          (cmpx (get-cmpx i)))
;;     (if (null cmpx)
;;         "Нет такого жилого комплекса"
;;         (format nil "~{~A~}"
;;                 (list
;;                  (format nil "<h1>Страница жилого комплекса ~A</h1>" (id cmpx))
;;                  (format nil "<h2>Данные комплекса ~A</h2>" (name cmpx))
;;                  (tbl
;;                   (with-element (cmpx cmpx)
;;                     (row "Название" (name cmpx))
;;                     (row "Адрес" (addr cmpx))
;;                     (row "Район" (aif (district-id cmpx)
;;                                       (name (get-district it))))
;;                     (row "Метро" (aif (metro-id cmpx)
;;                                       (name (get-metro it)))))
;;                   :border 1)
;;                  (format nil "<h2>Очереди комплекса ~A</h2>~%~A"
;;                          (name cmpx)
;;                          (tbl
;;                           (with-collection (i (find-plex :cmpx-id i))
;;                             (tr
;;                              (td
;;                               (format nil "<a href=\"/~a/~a\~a</a>" "plex"
;;                                       (id i) (id i)))
;;                              (td (name i)) (td (frm %del%))))
;;                           :border 1))))))
;;   (:del (act-btn "DEL" (id i) "Удалить")
;;         (progn (del-plex (getf p :data)))))

;; (in-package #:moto)

;; (define-page plex "/plex/:plex-id"
;;   (let* ((i (parse-integer plex-id))
;;          (plex (get-plex i)))
;;     (if (null plex)
;;         "Нет такой очереди у этого жилого комплекса"
;;         (format nil "~{~A~}"
;;                 (list
;;                  (format nil "<h1>Страница очереди жилого комплекса</h1>")
;;                  (format nil "<h2>Данные очереди комплекса</h2>")
;;                  (tbl
;;                   (with-element (plex plex)
;;                     (row "Название" (name plex))
;;                     (row "Срок сдачи" (name (get-deadline (deadline-id plex))))
;;                     (row "Субсидия" (subsidy plex))
;;                     (row "Отделка" (finishing plex))
;;                     (row "Ипотека" (ipoteka plex))
;;                     (row "Рассрочка" (installment plex))
;;                     (row "Расстояние до метро" (distance plex)))
;;                   :border 1)
;;                   (format nil "<h2>Корпуса очереди жилого комплекса</h2>~%~A"
;;                          (tbl
;;                           (with-collection (i (find-crps :plex-id i))
;;                             (tr
;;                              (td
;;                               (format nil "<a href=\"/~a/~a\~a</a>" "crps"
;;                                       (id i) (id i)))
;;                              (td (name i)) (td (frm %del%))))
;;                           :border 1))))))
;;   (:del (act-btn "del" (id i) "Удалить")
;;         (progn (del-plex (getf p :data)))))

;; (in-package #:moto)

;; (define-page crps "/crps/:crps-id"
;;   (let* ((i (parse-integer crps-id))
;;          (crps (get-crps i)))
;;     (if (null crps)
;;         "Нет такой очереди у этого жилого комплекса"
;;         (format nil "~{~A~}"
;;                 (list
;;                  (format nil "<h1>Страница корпуса очереди жилого комплекса</h1>")
;;                  (format nil "<h2>Данные очереди комплекса</h2>")
;;                  (tbl
;;                   (with-element (crps crps)
;;                     (row "Название" (name crps)))
;;                   :border 1)
;;                   (format nil "<h2>Планировки корпуса очереди жилого комплекса</h2>~%~A"
;;                          (tbl
;;                           (with-collection (i (find-flat :crps-id i))
;;                             (tr
;;                              (td
;;                               (format nil "<a href=\"/~a/~a\~a</a>" "flat"
;;                                       (id i) (id i)))
;;                              (td (format nil "~A к.кв." (rooms i)))
;;                              (td (format nil "~:d руб." (price i)))
;;                              (td (frm %del%))))
;;                           :border 1))))))
;;   (:del (act-btn "DEL" (id i) "Удалить")
;;         (progn (del-flat (getf p :data)))))

;; (in-package #:moto)

;; (define-page flat "/flat/:flat-id"
;;   (let* ((i (parse-integer flat-id))
;;          (flat (get-flat i)))
;;     (if (null flat)
;;         "Нет такой квартиры"
;;         (format nil "~{~A~}"
;;                 (list
;;                  (format nil "<h1>Страница квартиры</h1>")
;;                  (format nil "<h2>Данные квартиры</h2>")
;;                  (tbl
;;                   (with-element (flat flat)
;;                     (row "Кол-во комнат" (rooms flat))
;;                     (row "Общая площадь" (area-living flat))
;;                     (row "Площадь кухни" (area-kitchen flat))
;;                     (row "цена" (format nil "~:d"(price flat)))
;;                     (row "балкон/лоджия" (balcon flat))
;;                     (row "Санузел" (sanuzel flat))
;;                     (row "" (frm %buy%))
;;                     )
;;                   :border 1)))))
;;   (:buy (act-btn "BUY" "BUY" "Купить")
;;         (progn 1)))

;; (in-package #:moto)

;; (define-page findpage "/find"
;;   (format nil "~{~A~}"
;;           (list
;;            (format nil "<h1>Страница поиска</h1>")
;;            (format nil "<h2>Простой поиск</h2>")
;;            (frm
;;             (tbl
;;              (list
;;               (row "Район"
;;                 (select ("district")
;;                   (list* (list "Не важен" "0")
;;                          (with-collection (i (all-district))
;;                            (list (name i)
;;                                  (id i))))))
;;               (row "Метро"
;;                 (select ("metro")
;;                   (list* (list "Любое" "0")
;;                          (with-collection (i (all-metro))
;;                            (list (name i)
;;                                  (id i))))))
;;               (row "Название ЖК"
;;                 (select ("cmpx")
;;                   (list* (list "Любой ЖК" "0")
;;                          (with-collection (i (all-cmpx))
;;                            (list (name i)
;;                                  (id i))))))
;;               (row "Кол-во комнат"
;;                 (tbl
;;                  (list
;;                   (row "" "Выберите не менее одного варианта")
;;                   (row (input "checkbox" :name "studio" :value t) "Студия")
;;                   (row (input "checkbox" :name "one" :value t) "Однокомнатная")
;;                   (row (input "checkbox" :name "two" :value t) "Двухкомнатная")
;;                   (row (input "checkbox" :name "three" :value t) "Трехкомнатная"))))
;;               (row "Срок сдачи (не позднее)"
;;                 (select ("deadline")
;;                   (list* (list "Не важен" "0")
;;                          (with-collection (i (all-deadline))
;;                            (list (name i)
;;                                  (id i))))))
;;               (row "Стоимость квартиры"
;;                 (tbl
;;                  (list
;;                   (row "" "Обязательные поля")
;;                   (row "от" (fld "price-from"))
;;                   (row "до" (fld "price-to")))))
;;               (row "" %find%))
;;              :border 1)
;;             :action "/results")))
;;   (:find (act-btn "FIND" "FIND" "Искать")
;;          "Err: redirect to /results!"))
;; (in-package #:moto)

;; (defmacro find-query (price-from price-to &optional &key district metro deadline cmpx studio one two three)
;;   `(with-connection *db-spec*
;;      (query
;;       (:limit
;;        (:select (:as 'district.name 'district)  (:as 'cmpx.name 'cmpx)
;;                 (:as 'metro.name    'metro)     'distance
;;                 (:as 'deadline.name 'deadline)  'finishing
;;                 'ipoteka  'installment  'rooms  'area-sum  'price
;;                 :from 'flat
;;                 :inner-join 'crps :on (:= 'flat.crps_id 'crps.id)
;;                 :inner-join 'plex :on (:= 'crps.plex_id 'plex.id)
;;                 :inner-join 'cmpx :on (:= 'plex.cmpx_id 'cmpx.id)
;;                 :inner-join 'district :on (:= 'cmpx.district_id 'district.id)
;;                 :inner-join 'metro :on (:= 'cmpx.metro_id 'metro.id)
;;                 :inner-join 'deadline :on (:= 'plex.deadline_id 'deadline.id)
;;                 :where (:and ,(remove-if #'null
;;                                          `(:or ,(when studio `(:= 'rooms 0))
;;                                                ,(when one    `(:= 'rooms 1))
;;                                                ,(when two    `(:= 'rooms 2))
;;                                                ,(when three  `(:= 'rooms 3))))
;;                              (:and (:> 'price ,price-from)
;;                                    (:< 'price ,price-to))
;;                              ,(if district
;;                                   `(:= 'district_id ,district)
;;                                   t)
;;                              ,(if metro
;;                                   `(:= 'metro_id ,metro)
;;                                   t)
;;                              ,(if deadline
;;                                   `(:<= 'deadline_id ,deadline)
;;                                   t)
;;                              ,(if cmpx
;;                                   `(:= 'cmpx_id ,cmpx)
;;                                   t)))
;;        2000))))

;; (define-page results "/results"
;;   (format nil "~{~A~}"
;;           (list
;;            (format nil "<h1>Страница поиска</h1>")
;;            (format nil "<h2>Простой поиск</h2>")
;;            "Пустой поисковый запрос"))
;;   (:find (act-btn "FIND" "FIND" "Искать")
;;          (format nil "~{~A~}"
;;                  (list
;;                   (format nil "~%<h1>Страница поиска</h1>")
;;                   (format nil "~%<h2>Выборка</h2>")
;;                   (format nil "~%<br /><br />Параметры поиска: ~A" (bprint p))
;;                   (format nil "~%<br /><br />~A"
;;                           (let* ((form `(find-query
;;                                          ,(parse-integer (getf p :price-from))
;;                                          ,(parse-integer (getf p :price-to))
;;                                          )))
;;                             (unless (equal "0" (getf p :district))
;;                               (setf form (append form (list :district (parse-integer (getf p :district))))))
;;                             (unless (equal "0" (getf p :metro))
;;                               (setf form (append form (list :metro (parse-integer (getf p :metro))))))
;;                             (unless (equal "0" (getf p :deadline))
;;                               (setf form (append form (list :deadline (parse-integer (getf p :deadline))))))
;;                             (unless (equal "0" (getf p :cmpx))
;;                               (setf form (append form (list :cmpx (parse-integer (getf p :cmpx))))))
;;                             (when (getf p :studio)
;;                               (setf form (append form (list :studio t))))
;;                             (when (getf p :one)
;;                               (setf form (append form (list :one t))))
;;                             (when (getf p :two)
;;                               (setf form (append form (list :two t))))
;;                             (when (getf p :three)
;;                               (setf form (append form (list :three t))))
;;                             (format nil "~%<br /><br />Запрос: ~A~%<br /><br />Результат: <br/><br />~A"
;;                                     (bprint form)
;;                                     (format nil "<table border=1><tr>~{~A~}</tr>~{~A~}</table>"
;;                                             (loop :for item :in '("Район" "Комплекс" "Метро" "Расстояние" "Срок сдачи"
;;                                                                   "Отделка" "Ипотека" "Рассрочка" "Кол-во комнат" "Общая площадь" "Цена") :collect
;;                                                (format nil "~%<th>~A</th>" item))
;;                                             (loop :for item :in (eval form) :collect
;;                                                (format nil "~%<tr>~{~A~}</tr>"
;;                                                        (loop :for item :in item :collect
;;                                                           (format nil "~%<td>~A</td>" item))))))))))))
;; iface ends here
