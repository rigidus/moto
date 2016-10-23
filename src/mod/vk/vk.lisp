(in-package #:moto)

(in-package #:moto)

(in-package :moto)

(defun vkapi-get-call-url (method-name parameters &optional (access_token "") (v "5.59"))
  (format nil "https://api.vk.com/method/~A?~A&~A&v=~A"
          method-name
          (format nil "~{~A~}"
                  (loop :for (name . value) :in parameters :collect
                     (format nil "&~A=~A" name value)))
          (if (equal "" access_token)
              ""
              (format nil "access_token=~A" access_token))
          v))
(in-package #:moto)

(defun api-call (method-name parameters &optional (access_token "") (v "5.59"))
  (let ((response   "")
        (cookie-jar (make-instance 'drakma:cookie-jar))
        (url (vkapi-get-call-url method-name parameters access_token v)))
    (multiple-value-bind (response cookie-jar url)
        (multiple-value-bind (body-or-stream status-code headers uri stream must-close reason-phrase)
            (drakma:http-request url :user-agent *user-agent* :force-binary t :cookie-jar cookie-jar :redirect 10)
          (dbg "-- ~A : ~A" status-code url)
          (setf response (flexi-streams:octets-to-string body-or-stream :external-format :utf-8))))
    response))

(defun get-friends (id)
  (let* ((rs)
         (cnt)
         (response (api-call "friends.get" `(("user_id" . ,id)
                                             ("fields"  . "nickname"))))
         (json (json:decode-json-from-string response)))
    (destructuring-bind ((status &rest rest))
        json
      (ecase status
        (:error    (progn
                     (print rest)
                     (error "vkerror")))
        (:response ;; (destructuring-bind (count items)
                   ;;     (setf results (cdr rest)))
         (setf cnt (cdar rest))
         (setf rs (cdadr rest)))))
    (values rs cnt)))

(print
 (loop :for item :in (get-friends 2646565) :collect
    (let ((acc))
      (loop :for (key . val) :in item :do
         (setf acc (append acc (list key val))))
      (format nil "~A~A~A"
              (getf acc :last--name)
              (let ((nick (getf acc :nickname)))
                (if (or (null nick)
                        (equal "" nick))
                    " "
                    (format nil " ~A " nick)))
              (getf acc :first--name)))))


(in-package #:moto)

;; Тестируем
(defun hh-test ()
  (in-package #:moto)
  
  (defparameter *test-id* "298302")
  (in-package #:moto)
  
  (let ((friends (get-friends *test-id*)))
    (assert (listp friends))
    (assert (not (equal 0 (length (get-friends *test-id*))))))
  (dbg "passed: vk-test~%"))

(hh-test)
