
(in-package #:moto)



(defun loginform-ctrl (request)
  (aif (check-auth-data (get-auth-data request))
       (progn
         (setf (session-value current-user) it)
         (auth-success))
       (auth-fail)))

(defun logout-ctrl (request)
  (delete-session-value current-user)
  (logout))





(defun is-logged (request)
  ( (session-value current-user



<<auth-success>
