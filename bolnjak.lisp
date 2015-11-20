
(defparameter *months* '((1 January)
                         (2 February)
                         (3 March)
                         (4 April 120)
                         (5 May 120)
                         (6 June 120)
                         (7 July 120)
                         (8 August 120)
                         (9 September 90)
                         (10 October 90)
                         (11 November 90)
                         (12 December)))

(defparameter *average* (/ (loop :for month :in *months* :when (not (null (nth 2 month)))
                              :sum (nth 2 month))
                           (coerce (length *workmonths*) 'single-float)))

(defparameter *avg-months* (loop :for month :in *months*
                              :collect
                              (if (null (nth 2 month))
                                  (append month (list *average*))
                                  month)))

(defparameter *average-per-month* (/ (loop
                                        :for month
                                        :in *avg-months*
                                        :sum (nth 2 month))
                                     12.0))


(defparameter *average-per-day* (/ (* 24 *average-per-month*) 730.0))


(defparameter *result* (* (/ (* *average-per-day* 9) 100.0) 60)
