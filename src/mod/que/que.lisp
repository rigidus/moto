
(in-package #:moto)

(in-package #:moto)

;; search
(defun search-que (name)
  (aif (find-que :name name)
       (id (car it))
       nil))

;; all
(defun all-que-names ()
  (mapcar #'name (all-que)))
(in-package #:moto)

;; make
(defun ensure-que (name)
  (aif (search-que name)
       it
       (prog1  (make-que :name name)
         (dbg "Создана очередь ~A" name))))

;; del
(defun destroy-que (name)
  (aif (search-que name)
       (prog1 (del-que (id it))
         (dbg "Удалена очередь ~A" name))
       (err "destroy-que error: que not found")))
(in-package #:moto)

;; clear
(defun clear-que (name)
  (aif (search-que name)
       (progn
         (with-connection *db-spec*
           (query (:delete-from 'quelt :where (:= 'que_id it))))
         (dbg "Очередь ~A очищена" name))
       (err "clear-que error: que not found")))

;; all
(defun all-que-elts (name)
  (aif (search-que name)
       (mapcar #'text
               (find-quelt :que-id it))
       (err "all-que-elts: que not found")))
(in-package #:moto)

;; add
(defun add-to-que (que-name text)
  (aif (search-que que-name)
       (make-quelt :que-id it :text text)
       (err "add-to-que error: que not found")))

;; del
(defun del-from-que (que-name text)
  (aif (search-que que-name)
       (aif (find-quelt :que-id it :text text)
            (del-quelt (id (car it)))
            (err "add-to-que error: quelt not found"))
       (err "add-to-que error: que not found")))

;; find
(defun find-in-que (que-name text)
  (aif (search-que que-name)
       (aif (find-quelt :que-id it :text text)
            (car it)
            (err "add-to-que error: quelt not found"))
       (err "add-to-que error: que not found")))
(in-package #:moto)

;; subscribe
(defun subscribe (que elt)
  (add-to-que que elt))

;; unsubscribe
(defun unsubscribe (que elt)
  (del-from-que que elt))
(in-package #:moto)

;; mapcar-que
(defun mapcar-que (que-name fn)
  (aif (search-que que-name)
       (mapcar #'(lambda (x)
                   (apply fn (list (text x))))
               (find-quelt :que-id it))))
(in-package #:moto)

;; snd
(defun snd (que-name msg)
  (mapcar-que que-name msg))


;; Тестируем авторизацию
(defun que-test ()
  (in-package #:moto)
  
  ;; tests
  (progn
    (ensure-que "Q-1")
    (ensure-que "Q-2")
    (ensure-que "Q-3")
    (assert (string= (bprint (all-que-names))
                     "(\"Q-1\" \"Q-2\" \"Q-3\")"))
    (add-to-que "Q-1" "test")
    (add-to-que "Q-1" 7)
    (assert (string= (bprint (all-que-elts "Q-1"))
                     "(\"test\" \"7\")"))
    (assert (find-in-que "Q-1" "7"))
    (del-from-que "Q-1" "test")
    (assert (string= (bprint (all-que-elts "Q-1"))
                     "(\"7\")"))
    (assert (equal (bprint (snd "Q-1" #'(lambda (x) x)))
                   "(\"7\")")))
  (dbg "passed: que-test~%"))
(que-test)
