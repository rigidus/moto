
(in-package #:moto)

(restas:define-route flat ("/flat/:flatid")
  (with-wrapper
    (let ((flat (get-flat 1)))
      (flattpl:flatpage
       (list
        :rooms (let ((r (rooms flat)))
                 (cond ((equal 0 r) "Квартира-студия")
                       ((equal 1 r) "1-комнатная квартира")
                       ((equal 2 r) "2-комнатная квартира")
                       ((equal 3 r) "3-комнатная квартира")
                       ((equal 4 r) "4-комнатная квартира")
                       (t (err "unc rooms value"))))
        )))))
