
(in-package #:moto)

;; Сущность роли
(define-entity flat "Сущность роли"
  ((id serial)
   (plex-id (or db-null integer))
   (rooms (or db-null integer))
   (area-sum (or db-null integer))
   (area-living (or db-null integer))
   (area-kitchen (or db-null integer))
   (price (or db-null integer))
   (subsidy (or db-null boolean))
   (finishing (or db-null boolean))
   (ipoteka (or db-null boolean))
   (installment (or db-null boolean))
   (balcon (or db-null varchar))
   (sanuzel (or db-null boolean))))

(make-flat-table)

(make-flat :rooms 1 :price 2589000)

(in-package #:moto)

(restas:define-route flat ("/flat/:flatid")
  (with-wrapper
    (let ((flat (get-flat 1)))
      (trendtpl:flatpage
       (list
        :rooms (let ((r (rooms flat)))
                 (cond ((equal 0 r) "Квартира-студия")
                       ((equal 1 r) "1-комнатная квартира")
                       ((equal 2 r) "2-комнатная квартира")
                       ((equal 3 r) "3-комнатная квартира")
                       ((equal 4 r) "4-комнатная квартира")
                       (t (err "unknown rooms value"))))
        :id (id flat)
        :price (price flat)
        :rooms (rooms flat)
        :area_living (area-living flat)
        :area_sum (area-sum flat)
        :area_kitchen (area-kitchen flat)
        :sanuzel (sanuzel flat)
        :finishing (finishing flat)
        :balcon (balcon flat)
        )))))


;; Тестируем trend
(defun trend-test ()
  
  ;; ;; Зарегистрируем четырех пользователей
  ;; (let ((alice (create-user "alice" "aXJAVtBT" "alice@mail.com"))
  ;;       (bob   (create-user "bob"   "pDa84LAh" "bob@mail.com"))
  ;;       (carol (create-user "carol" "zDgjGus7" "carol@mail.com"))
  ;;       (dave  (create-user "dave"  "6zt5GmvE" "dave@mail.com")))
  ;;   ;; Пусть Алиса пошлет Бобу сообщение
  ;;   (let* ((test-trend "Привет, Боб, это Алиса!")
  ;;          (trend-id (create-trend alice bob test-trend)))
  ;;     ;; Проверим, что сообщение существует
  ;;     (assert (get-trend trend-id))
  ;;     ;; Проверим, что оно находится в статусе "недоставлено"
  ;;     (assert (equal ":UNDELIVERED" (state (get-trend trend-id))))
  ;;     ;; Пусть второй пользователь запросит кол-во непрочитанных сообщений
  ;;     (let ((undelivered-trend-cnt (get-undelivered-trend-cnt bob)))
  ;;       ;; Проверим, что там одно непрочитанное сообщение
  ;;       (assert (equal 1 undelivered-trend-cnt))
  ;;       ;; Пусть второй пользователь запросит идентификаторы всех своих непрочитанных сообщений
  ;;       (let ((undelivered-trend-ids (get-undelivered-trend-ids alice bob)))
  ;;         ;; Проверим, что в списке идентификторов непрочитанных сообщений один элемент
  ;;         (assert (equal 1 (length undelivered-trend-ids)))
  ;;         ;; Получим это сообщение
  ;;         (let* ((read-trend-id (car undelivered-trend-ids))
  ;;                (read-trend (delivery-trend read-trend-id)))
  ;;           ;; Проверим, что это именно то сообщение, которое послал первый пользователь
  ;;           (assert (equal test-trend (trend read-trend)))
  ;;           ;; Проверим, что сообщение теперь доставлено
  ;;           (assert (equal ":DELIVERED" (state (get-trend read-trend-id))))))))
  ;;   ;; Пусть Боб ответит Алисе и напишет Кэрол
  ;;   (sleep 1)
  ;;   (let* ((reply-bob-to-alice "Здравствуй, Алиса, я получил твое письмо. Я напишу Кэрол что ты нашла меня")
  ;;          (reply-bob-to-alice-id (create-trend bob alice reply-bob-to-alice)))
  ;;     (sleep 1)
  ;;     (let* ((trend-bob-to-carol "Кэрол, передаю привет от Алисы. Боб.")
  ;;            (trend-bob-to-carol-id (create-trend bob carol trend-bob-to-carol)))
  ;;       (sleep 1)
  ;;       ;; Пусть Дэйв напишет Бобу
  ;;       (let* ((trend-dave-to-bob "Привет, Боб, я хочу добавить тебя в друзья")
  ;;              (trend-dave-to-bob-id (create-trend dave bob trend-dave-to-bob)))
  ;;         ;; Получим последние диалоги Боба
  ;;         (let ((last-dialogs (get-last-trend-dialog-ids-for-user-id bob)))
  ;;           ;; (dbg "~%~A" (bprint last-dialogs))
  ;;           ;; Проверим, что в имеем три диалога
  ;;           (assert (equal 3 (length last-dialogs)))
  ;;           ;; Проверим, что сообщения правильно упорядочены
  ;;           (assert (equal (list trend-dave-to-bob-id
  ;;                                trend-bob-to-carol-id
  ;;                                reply-bob-to-alice-id)
  ;;                          (mapcar #'car last-dialogs)))))))
  ;;   (logout-user dave)
  ;;   (logout-user carol)
  ;;   (logout-user bob)
  ;;   (logout-user alice))
  (dbg "passed: trend-test~%"))
(trend-test)
