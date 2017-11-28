;; [[file:hh-iface.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

(define-page hh "/hh"
  (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
         (breadcrumb (breadcrumb "Вакансии" ("/hh" . "HeadHunter")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (base-page (:breadcrumb breadcrumb)
      (content-box ()
        (heading ("Модуль HeadHunter") "Меню модуля"))
      (content-box ()
        ((:section :class "dnd-area")
         ((:ul :class "connected handles list" :id "not")
          ((:li)
           ((:a :href "/hh/vacs") "Отобранные вакансии") "")
          ((:li)
           ((:a :href "/hh/rules") "Правила обработки") "")
          ((:li)
           ((:a :href "/hh-doc") "Документация") ""))))
      (ps-html ((:span :class "clear")))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn nil)))
(in-package #:moto)

(defparameter *USD* 57)
(defparameter *EUR* 67)

(defun salary-equivalent (vac)
  (cond ((equal "USD" (currency vac)) (* *USD* (salary-max vac)))
        ((equal "EUR" (currency vac)) (* *EUR* (salary-max vac)))
        ((equal "RUR" (currency vac)) (* 1 (salary-max vac)))
        (t 0)))

(defun sort-vacancy-by-salary (a b)
  (let ((aa (salary-equivalent a))
        (bb (salary-equivalent b)))
    (> aa bb)))

(defun pretty-salary (vac)
  (format nil "~A ~A"
          (salary-max vac)
          (cond ((equal "USD" (currency vac)) "$")
                ((equal "EUR" (currency vac)) "€")
                ((equal "RUR" (currency vac)) "₽"))))


(defun canonicalize-salary (vac)
  (when (null (currency vac))
    (setf (currency vac) "NON"))
  (when (null (salary-max vac))
    (setf (salary-max vac) 0))
  (when (null (salary-min vac))
    (setf (salary-min vac) 0))
  (when (null (notes vac))
    (setf (notes vac) ""))
  (when (equal :null (state vac))
    (setf (state vac) ":UNSORT"))
  vac)

(defun make-ps-html-vac (x)
  (ps-html ((:li :id (src-id x)
                 :class (string-downcase (subseq (state x) 1))
                 :title (notes x))
            ((:span :class (if (empty (notes x)) "emptynotes" "notes"))
             (cond ((equal "USD" (currency x)) "$")
                   ((equal "EUR" (currency x)) "€")
                   ((equal "RUR" (currency x)) ""))
             (salary-max x))
            ((:a :href (format nil "/hh/vac/~A" (src-id x)))
             (name x)))))

(define-page vacs "/hh/vacs"
  (labels ((mrg (param)
             (if (null param)
                 ""
                 (reduce #'(lambda (x y) (concatenate 'string x (string #\NewLine) y))
                         (mapcar #'make-ps-html-vac
                                 (mapcar #'canonicalize-salary param))))))
    (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
           (sorted-vacs (sort vacs #'sort-vacancy-by-salary))
           (breadcrumb (breadcrumb "Вакансии" ("/hh" . "HeadHunter")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (base-page (:breadcrumb breadcrumb)
        ((:script)
         (ps
           (defun get-child-ids (selector)
             ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
           (defun save ()
             ((@ $ post) "#" (create :act "SAVE" :not ((@ (get-child-ids "#not") join)) :yep ((@ (get-child-ids "#yep") join)))
              (lambda (data status)
                (if (not (equal status "success"))
                    (alert (concatenate 'string "err-ajax-fail: " status))
                    (eval data))))
             false)))
        (content-box ()
          (heading ("Модуль HeadHunter")
            "В правой колонке - интересные вакансии, в левой - неинтересные. "
            ((:br))((:br))
            ((:span :class "unsort") "&nbsp;Желтым&nbsp;")
            " выделены вакансии, которые появились в момент последнего сбора данных. "
            "По умолчанию они помещаются в правый столбик - к интересующим вакансиям. "
            "После сортировки следует сохранить состояния вакансий и тогда выделение исчезнет. "
            ((:br))
            ((:span :class "responded") "&nbsp;Голубым&nbsp;") " выделены вакансии, на которые отправлен отзыв. "
            ((:br))
            ((:span :class "beenviewed") "&nbsp;Фиолетовым&nbsp;") " выделены вакансии, отзыв на которые был просмотрен. "
            ((:br))
            ((:span :class "reject") "&nbsp;Красным&nbsp;") " - если работодатель отказал. "
            "Можно попробовать откликнуться другим резюме или забить на вакансию и перенести ее в 'неинтересные' "
            ((:br))
            ((:span :class "invite") "&nbsp;Зеленым&nbsp;") " - если работодатель пригласил на собеседование. "
            ((:br))
            ((:span :class "interview") "&nbsp;Серым&nbsp;") " - если собеседование было пройдено. "
            ((:br))((:br))
            "Вакансии, к которым есть заметки, выделяются зарплатой на "
            ((:span :class "notes") "&nbsp;черном&nbsp;") " фоне. "
            "При наведении на такую вакансию можно увидеть текст заметки."))
        (content-box ()
          %SAVE%
          ((:section :class "dnd-area")
           ((:ul :class "connected handles list" :id "not")
            (mrg
            (remove-if-not #'(lambda (x)
                                    (equal ":UNINTERESTING" (state x)))
                                sorted-vacs
                                )
                                )
            )
           ((:ul :class "connected handles list no2" :id "yep")
            (mrg (remove-if #'(lambda (x)
                                (equal ":UNINTERESTING" (state x)))
                            sorted-vacs))
            ))
          )
        (ps-html ((:span :class "clear"))))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn
           (setf *tmp1* (split-sequence:split-sequence #\, (getf p :not)))
           (setf *tmp2* (split-sequence:split-sequence #\, (getf p :yep)))
           (mapcar #'(lambda (x)
                       (takt (car (find-vacancy :src-id (parse-integer x))) :uninteresting))
                   (split-sequence:split-sequence #\, (getf p :not)))
           (mapcar #'(lambda (x)
                       (let ((vac (car (find-vacancy :src-id (parse-integer x)))))
                         (when (or (equal (state vac) ":UNSORT")
                                   (equal (state vac) ":UNINTERESTING"))
                           (takt vac :interesting))))
                   (split-sequence:split-sequence #\, (getf p :yep)))
           (error 'ajax :output "window.location.href='/hh/vacs'"))))


(defun tgb (name on off &rest in)
  `(("button" (("type" "button") ("class" ,(format nil "btn btn-primary btn-~A" name))
               ("onclick" ,(format nil "tggl('~A', '~A', '.~A', '.btn-~A');"
                                   on off name name)))
              ,on)
    ("div" (("class" ,name)) ,@(mapcan #'identity in))))


(defun txt (text &optional (class ""))
  (let* ((start (position #\< text :test #'equal))
         (end   (position #\> text :test #'equal)))
    (if (or (null start)
            (null end))
        text
        ;; else
        (let ((in (remove-if #'(lambda (x) (equal x ""))
                             `(,(subseq text 0 start)
                                ("span" (("class" ,class))
                                        "&nbsp;"
                                        ,(subseq text (+ 1 start) end)
                                        "&nbsp;")
                                ,(subseq text (+ 1 end))))))
          `(("div" (("class" "txt")) ,@in))
          ))))

(defun legend ()
  (tgb "legend" "legend-on" "legend-off"
       (txt "<Желтым> выделены неотсортированные вакансии, которые появились в момент последнего сбора данных." "unsort")
       (txt "<Голубым> выделены вакансии, на которые отправлен отзыв." "responded")
       (txt "<Фиолетовым> выделены вакансии, отзыв на которые был просмотрен." "beenviewed")
       (txt "<Красным> - если работодатель отказал. Можно попробовать откликнуться другим резюме или просто отправить её в 'неинтересные'" "reject")
       (txt "<Зеленым> - если работодатель пригласил на собеседование." "invite")
       (txt "<Серым> - если собеседование было пройдено." "interview")
       (txt  "Вакансии, к которым есть заметки, выделяются зарплатой на <черном> фоне. При наведении на такую вакансию можно увидеть текст заметки." "notes")))

(defun link-css (&rest rest)
  (mapcar #'(lambda (x)
              `("link" (("rel" "stylesheet") ("href" ,(format nil "/css/~A.css" x)))))
          rest))

(defun script-js (&rest rest)
  (mapcar #'(lambda (x)
              `("script" (("type" "text/javascript") ("src" ,(format nil "/js/~A.js" x)))))
          rest))

(defun vac-col (col-class name id &rest rest)
  (print id)
  `(("div" (("class" ,(format nil "col ~A" col-class)))
           ("div" (("style" "text-align: center")) ,name)
           ("ul"  (("class" "connected handles list no2") ("id" ,id)) ;; error here
                  ,@(mapcar #'car rest)))))

(defun vac-elt (id class title noteclass notes name)
  `(("li"
     (("id" ,(format nil "~A" id)) ("class" ,class) ("title" ,title) ("draggable" "true")
      ("style" "display: list-item;"))
     ("span" (("class" ,noteclass)) ,notes)
     ("a" (("href" ,(format nil "/hh/vac/~A" id))) ,name))))


(defun html-page (&rest in-body)
  (concatenate
   'string
   "<!DOCTYPE html>"
   (format nil "~%")
   (tree-to-html
    `(("html"
       (("lang" "en"))
       ("head"
        ()
        ("meta" (("charset" "utf-8")))
        ("meta" (("name" "viewport")
                 ("content" "width=device-width, initial-scale=1, shrink-to-fit=no"))))
       ,@in-body)))))


(defun in-page-script ()
  `("script"
    (("type" "text/javascript"))
    ,(ps
      (defun get-child-ids (selector)
        ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
      (defun save ()
        ((@ $ post) "#" (create :act "SAVE" :not ((@ (get-child-ids "#not") join)) :yep ((@ (get-child-ids "#yep") join)))
         (lambda (data status)
           (if (not (equal status "success"))
               (alert (concatenate 'string "err-ajax-fail: " status))
               (eval data))))
        false))))

(defun show-vac-elt (vac class title noteclass)
  (vac-elt (src-id vac) class "" "emptynotes" (pretty-salary vac) (name vac)))

(defun vac-col-tree (sorted-vacs vac-type)
  (let ((target-state (format nil ":~A" (string-upcase vac-type))))
    (append (list (format nil "col-~A" vac-type) vac-type)
            (let ((filtered-vacs (remove-if-not #'(lambda (vac) (equal (state vac) target-state)) sorted-vacs)))
              (if filtered-vacs
                  (mapcar #'(lambda (vac) (show-vac-elt vac vac-type "" "emptynotes")) filtered-vacs)
                  (list (vac-elt 22604660 vac-type "" "emptynotes" "emptynotes" "DYMMY")))))))

(restas:define-route hhtest ("/hh/test")
  (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
         (sorted-vacs (sort vacs #'sort-vacancy-by-salary)))
    (html-page
     `("body"
       ()
       ,@(link-css "bootstrap.min" "b" "s")
       ,@(script-js "jquery-v-1.10.2" "jquery-ui-v-1.10.3" "modernizr" "jquery.sortable.original" "frp" "bootstrap.min" "b")
       ,(in-page-script)
       ("div"
        (("class" "container-fluid"))
        ,@(legend)
        ,@(tgb "graph" "graph-on" "graph-off"
               `(("div" (("style" "text-align: center; overflow: auto;"))
                        ("img" (("src" "/img/vacancy-state.png"))))))
        ,@`(,(car (tgb "col-uninteresting" "uninteresting-on" "uninteresting-off")))
        ,@`(,(car (tgb "col-unsort" "unsort-in" "unsort-off" `(()))))
        ,@`(,(car (tgb "col-interesting" "interesting-in" "interesting-off" `(()))))
        ("div" (("class" ""))
               ("button"
                (("type" "submit") ("class" "button") ("onclick" "save();return false;"))
                "SAVE"))
        ("div" (("class" "row no-gutters"))
               ,@(apply #'vac-col (vac-col-tree sorted-vacs "uninteresting"))
               ,@(apply #'vac-col (vac-col-tree sorted-vacs "unsort"))
               ,@(vac-col "col-interesting" "interesting" "yep"
                          (vac-elt 22604660 "unsort" "NULL" "emptynotes" "NILNULL" "DYMMY"))))))))

(in-package #:moto)

(define-page vacancy "/hh/vac/:src-id"
  (let ((vac (car (find-vacancy :src-id src-id))))
    (when (null vac)
      (return-from vacancy 404))
    (let* ((breadcrumb (if (null vac)
                           (breadcrumb "Не найдено" ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/vacs" . "Вакансии"))
                           (breadcrumb (name vac) ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/vacs" . "Вакансии"))))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*))))
           (text (parenscript::process-html-forms-lhtml (read-from-string (descr vac)))))
      (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
        (content-box ()
          (heading ((format nil "~A ~A" (name vac) (ps-html ((:span :style "color:red") (salary-text vac)))))
            (form ("chvacstateform" "")
              ((:table :border 0 :style "font-size: small;")
               ((:tr)
                ((:td) "id:")
                ((:td) (id vac))
                ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "src-id:")
                ((:td) ((:a :href (format nil "https://hh.ru/vacancy/~A" (src-id vac))) (src-id vac)))
                ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "archive:")
                ((:td) (archive vac))
                ((:td) "&nbsp;&nbsp;&nbsp;"))
               ((:tr)
                ((:td) "emp-id:")
                ((:td) (emp-id vac))
                ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "emp-name:")
                ((:td) ((:span :style "color:red") (emp-name vac)))
                ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "state:")
                ((:td) (state vac))
                ((:td) "&nbsp;&nbsp;&nbsp;"))
               ((:tr)
                ((:td) "city:")       ((:td) (city vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "metro:")      ((:td) (metro vac))                                   ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "state:")
                ((:td)
                 (fieldset ""
                   (eval
                    (macroexpand
                     (append `(select ("newstate" "" :default ,(subseq (state vac) 1)))
                             (list
                              (mapcar #'(lambda (x)
                                          (cons (symbol-name x) (symbol-name x)))
                                      (possible-trans vac))))))))
                ((:td) "&nbsp;&nbsp;&nbsp;"))
               ((:tr)
                ((:td) "experience:") ((:td) (experience vac))                              ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "date:")       ((:td) (date vac))                                    ((:td) "&nbsp;&nbsp;&nbsp;")
                ((:td) "state:")      ((:td) %CHSTATE%)                                     ((:td) "&nbsp;&nbsp;&nbsp;"))
               ))))
        (content-box ()
          ((:div :class "vacancy-descr") (format nil "~{~A~}" text)))
        (content-box ()
          (form ("tagform" nil :class "form-section-container")
            ((:div :class "form-section")
             (fieldset "Тэги"
               (textarea ("tags" "Тэги") (tags vac))
               (ps-html ((:span :class "clear")))))))
        (content-box ()
          (form ("vacform" nil :class "form-section-container")
            ((:div :class "form-section")
             (fieldset "Заметки"
               (textarea ("notes" "Заметки") (notes vac))
               (textarea ("response" "Сопроводительное письмо") (response vac))
               (ps-html ((:span :class "clear")))))
            %RESPOND% %SAVE%))
        (ps-html ((:span :class "clear"))))))
  (:chstate (ps-html ((:div :class "form-send-container")
                      (submit "Изменить" :name "act" :value "CHSTATE")))
            (progn
              ;; (id (upd-vacancy (car (find-vacancy :src-id src-id))
              ;;                  (list :notes (getf p :notes) :response (getf p :response))))
              (takt (car (find-vacancy :src-id src-id))
                    (intern (getf p :newstate) :keyword))
              (redirect (format nil "/hh/vac/~A" src-id))
              ))
  (:save (ps-html ((:div :class "form-send-container")
                   (submit "Сохранить вакансию" :name "act" :value "SAVE")))
         (progn
           (id (upd-vacancy (car (find-vacancy :src-id src-id))
                            (list :notes (getf p :notes) :response (getf p :response))))
           (redirect (format nil "/hh/vac/~A" src-id))))
  (:respond (ps-html
             ((:div :class "form-send-container")
              (eval
               (macroexpand
                (append '(select ("resume" "Выбрать резюме для отправки отклика:"))
                        (list
                         (mapcar #'(lambda (x) (cons (id x) (title x)))
                                 (sort (all-resume) #'(lambda (a b) (< (id a) (id b)))))))))
              (submit "Отправить отклик" :name "act" :value "RESPOND")))
            (progn
              (id (upd-vacancy (car (find-vacancy :src-id src-id))
                               (list :notes (getf p :notes) :response (getf p :response))))
              (dbg (send-respond
                    src-id
                    (res-id (get-resume (parse-integer (getf p :resume))))
                    (getf p :response)))
              (dbg (takt (car (find-vacancy :src-id src-id)) :responded)))))
(in-package #:moto)

(define-page rules "/hh/rules"
  (labels ((mrg (param)
             (if (null param)
                 ""
                 (reduce #'(lambda (x y)
                             (concatenate 'string x (string #\NewLine) y))
                         (mapcar #'(lambda (x)
                                     (ps-html ((:li :id (id x)
                                                    :class "" ;; (if (null (state x)) "" (string-downcase (subseq (state x) 1)))
                                                    :title "(notes x)")
                                               ((:span :class "emptynotes") " &nbsp; ")
                                               ((:a :href (format nil "/hh/rule/~A" (id x))) (name x)))))
                                 param)))))
    (let* ((breadcrumb (breadcrumb "Правила" ("/hh" . "HeadHunter")))
           (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
      (base-page (:breadcrumb breadcrumb)
        ((:script)
         (ps
           (defun get-child-ids (selector)
             ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
           (defun save ()
             ((@ $ post) "#" (create :act "SAVE" :not ((@ (get-child-ids "#not") join)) :yep ((@ (get-child-ids "#yep") join)))
              (lambda (data status)
                (if (not (equal status "success"))
                    (alert (concatenate 'string "err-ajax-fail: " status))
                    (eval data))))
             false)))
        (content-box ()
          (heading ("Правила обработки")
            "В правой колонке - Правила для тизеров, в левой - для вакансий. "))
        (content-box ()
          %SAVE%
          ((:section :class "dnd-area")
           ((:ul :class "connected handles list" :id "not")
            (mrg (rules-for-teaser)))
           ((:ul :class "connected handles list no2" :id "yep")
            (mrg (rules-for-vacancy)))))
        (ps-html ((:span :class "clear"))))))
  (:SAVE (ps-html
          ((:input :type "hidden" :name "act" :value "SAVE"))
          (submit "SAVE" :onclick "save();return false;"))
         (progn
           (setf *tmp1* (split-sequence:split-sequence #\, (getf p :not)))
           (setf *tmp2* (split-sequence:split-sequence #\, (getf p :yep)))
           (mapcar #'(lambda (x)
                       (takt (car (find-vacancy :src-id (parse-integer x))) :uninteresting))
                   (split-sequence:split-sequence #\, (getf p :not)))
           (mapcar #'(lambda (x)
                       (let ((vac (car (find-vacancy :src-id (parse-integer x)))))
                         (unless (equal (state vac) ":RESPONDED")
                           (takt vac :interesting))))
                   (split-sequence:split-sequence #\, (getf p :yep)))
           (error 'ajax :output "window.location.href='/hh/rules'"))))
(in-package #:moto)

(define-page rule "/hh/rule/:id"
  (let ((item (get-rule (parse-integer id))))
    (if (null item)
        (let ((breadcrumb (breadcrumb "Регистрация нового пользователя" ("/" . "Главная") ("/secondary" . "Второстепенная")))
              (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
          (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
            (content-box ()
              (system-msg ("caution")
                (let ((tmp ))
                  (ps-html ((:p) (format nil "К сожалению, такого правила нет! Наверное, это правило было удалено"))
                           (submit "Вернуться к списку правил"
                                   :onclick (format nil "window.location.href='/hh/rules'; return false;"))))))
            (ps-html ((:span :class "clear")))))
        ;; else - rule found
        (let* ((breadcrumb (if (null item)
                               (breadcrumb "Не найдено" ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/rules" . "Правила"))
                               (breadcrumb (name item) ("/" . "Главная") ("/hh" . "HeadHunter") ("/hh/rules" . "Правила"))))
               (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
          (standard-page (:breadcrumb breadcrumb :user user :menu (menu) :overlay (reg-overlay))
            (content-box ()
              (heading ((format nil "~A" (ps-html "Страница редактирования правила"))))
              (form ("ruleform" nil :class "form-section-container")
                ((:div :class "form-section")
                 (fieldset (format nil "Правило ~A:" (name item))
                   (input ("name" "Имя"  :value (name item)))
                   (input ("rank" "Ранг" :value (rank item)))
                   (fieldset ""
                     (eval
                      (macroexpand
                       (append `(select ("ruletype" "Тип правила" :default ,(subseq (ruletype item) 1)))
                               (list
                                (mapcar #'(lambda (x)
                                            (cons x x))
                                        '("TEASER" "VACANCY")))))))
                   (textarea ("antecedent" "Условие срабатывания") (antecedent item))
                   (textarea ("consequent" "Действие") (consequent item))
                   (textarea ("notes" "Заметки") (notes item))
                   (ps-html ((:span :class "clear")))))
                %SAVE%))
            (ps-html ((:span :class "clear")))))))
  (:save (ps-html ((:div :class "form-send-container")
                   (submit "Сохранить вакансию" :name "act" :value "SAVE")))
         (progn
           (id (upd-rule (get-rule (parse-integer id))
                         (list
                          :user-id *current-user*
                          :name (getf p :name)
                          :rank (getf p :rank)
                          :ruletype (format nil ":~A" (getf p :ruletype))
                          :antecedent (getf p :antecedent)
                          :consequent (getf p :consequent)
                          :notes (getf p :notes))))
           (redirect (format nil "/hh/rule/~A" id)))))
(in-package #:moto)

(restas:define-route hh-doc ("/hh-doc")
  (alexandria:read-file-into-string
   (merge-pathnames
    (pathname-parent-directory (pathname *base-path*))
    #P"hh.html")))
(in-package #:moto)

(define-page search-vacancy "/hh/search"
  (let* ((breadcrumb (breadcrumb "Поиск" ("/hh" . "HeadHunter")))
         (user       (if (null *current-user*) "Анонимный пользователь" (name (get-user *current-user*)))))
    (base-page (:breadcrumb breadcrumb)
      (content-box ()
        (heading ("Поиск по вакансиям в состоянии выше :RESPOND") ""))
      (content-box ()
        (let ((q (get-parameter "q")))
          (if (null q)
              "empty searchstring"
              (ps-html
               ((:ul)
                (format nil "~{~A~}"
                        (mapcar #'(lambda (x)
                                    (ps-html
                                     ((:li :style "padding: 3px")
                                      ((:a :href (format nil "/hh/vac/~A" (src-id (car x))))
                                       (name (car x))
                                       "&nbsp&nbsp:&nbsp&nbsp"
                                       (emp-name (car x))))))
                                (sort (remove-if #'(lambda (x)
                                                     (equal (cdr x) 0))
                                                 (mapcar #'(lambda (x)
                                                             (let ((rel 0))
                                                               (when (contains (string-downcase (name x)) (string-downcase q))
                                                                 (incf rel 3))
                                                               (when (contains (string-downcase (emp-name x)) (string-downcase q))
                                                                 (incf rel 5))
                                                               (when (contains (string-downcase (descr x)) (string-downcase q))
                                                                 (incf rel))
                                                               (cons x rel)))
                                                         (remove-if #'(lambda (x)
                                                                        (or (equal ":UNSORT" (state x)))
                                                                        (or (equal ":UNINTERESTING" (state x))))
                                                                    (all-vacancy))))
                                      #'(lambda (a b)
                                          (> (cdr a) (cdr b)))))))))))
      (ps-html ((:span :class "clear"))))))
(defparameter *slideshows* (make-hash-table :test 'equalp))

(defun add-slideshow (slideshow-name image-folder)
  (setf (gethash slideshow-name *slideshows*)
        (mapcar (lambda (pathname)
                  (url-encode (format nil "~a.~a"
                                      (pathname-name pathname)
                                      (pathname-type pathname))))
                (list-directory image-folder))))

(add-slideshow "img" "/home/rigidus/repo/moto/img/")
(add-slideshow "pic" "/home/rigidus/repo/moto/pic/")

(alexandria:hash-table-plist *slideshows*)

(defmacro/ps slideshow-image-uri (slideshow-name image-file)
  `(concatenate 'string ,slideshow-name "/" ,image-file))

(restas:define-route y ("y")
  (ps
    (define-symbol-macro fragment-identifier (@ window location hash))
    (defun show-image-number (image-index)
      (let ((image-name (aref *images* (setf *current-image-index* image-index))))
        (setf (chain document (get-element-by-id "slideshow-img-object") src)
              (slideshow-image-uri *slideshow-name* image-name)
              fragment-identifier
              image-name)))
    (defun previous-image ()
      (when (> *current-image-index* 0)
        (show-image-number (1- *current-image-index*))))
    (defun next-image ()
      (when (< *current-image-index* (1- (getprop *images* 'length)))
        (show-image-number (1+ *current-image-index*))))
    ;; this gives bookmarkability using fragment identifiers
    (setf (getprop window 'onload)
          (lambda ()
            (when fragment-identifier
              (let ((image-name (chain fragment-identifier (slice 1))))
                (dotimes (i (length *images*))
                  (when (string= image-name (aref *images* i))
                    (show-image-number i)))))))))

(defun slideshow-handler (slideshow-name)
  (let* ((images (gethash slideshow-name *slideshows*))
         (current-image-index (or (position (get-parameter "image") images :test #'equalp)
                                  0))
         (previous-image-index (max 0 (1- current-image-index)))
         (next-image-index (min (1- (length images)) (1+ current-image-index))))
    (with-html-output-to-string (s)
      (:html
       (:head
        (:title "Parenscript slideshow")
        (:script :type "text/javascript"
                 (str (ps* `(progn
                              (var *slideshow-name* ,slideshow-name)
                              (var *images* (array ,@images))
                              (var *current-image-index* ,current-image-index)))))
        (:script :type "text/javascript" :src "/y")
        )
       (:body
        (:div :id "slideshow-container"
              :style "width:100%;text-align:center"
              (:img :id "slideshow-img-object"
                    :src (slideshow-image-uri slideshow-name
                                              (elt images current-image-index)))
              :br
              (:a :href (format nil "?image=~a" (elt images previous-image-index))
                  :onclick (ps (previous-image) (return false))
                  "Previous")
              " "
              (:a :href (format nil "?image=~a" (elt images next-image-index))
                  :onclick (ps (next-image) (return false))
                  "Next")
              ))))))

(restas:define-route x ("/x")
  (slideshow-handler "pic"))

(restas:define-route z ("/z")
  (slideshow-handler "img"))
(in-package #:moto)

(restas:define-route mob ("mob")
  (progn
    "<!DOCTYPE HTML>
<html lang=\"ru\">
<head>
<title>Flexbox, теперь понятно — Пепелсбей.net</title>
<meta charset=\"utf-8\">
<meta name=\"viewport\" content=\"width=1274, user-scalable=no\">
<!-- link rel=\"stylesheet\" href=\"../shower/themes/ribbon/styles/screen.css\" -->
<style type=\"text/css\">
/**
 * Ribbon theme for Shower HTML presentation engine
 * shower-ribbon v1.1.0, https://github.com/shower/ribbon
 * Copyright © 2010–2015 Vadim Makeev, https://pepelsbey.net
 * Licensed under MIT license: github.com/shower/shower/wiki/MIT-License
 */
@charset \"UTF-8\";@font-face{font-family:'PT Sans';src:url(../fonts/PTSans.woff) format(\"woff\")}@font-face{font-weight:700;font-family:'PT Sans';src:url(../fonts/PTSans.Bold.woff) format(\"woff\")}@font-face{font-style:italic;font-family:'PT Sans';src:url(../fonts/PTSans.Italic.woff) format(\"woff\")}@font-face{font-style:italic;font-weight:700;font-family:'PT Sans';src:url(../fonts/PTSans.Bold.Italic.woff) format(\"woff\")}@font-face{font-family:'PT Sans Narrow';font-weight:700;src:url(../fonts/PTSans.Narrow.Bold.woff) format(\"woff\")}@font-face{font-family:'PT Mono';src:url(../fonts/PTMono.woff) format(\"woff\")}html,body,div,span,applet,object,iframe,h1,h2,h3,h4,h5,h6,p,blockquote,pre,a,abbr,acronym,address,big,cite,code,del,dfn,em,img,ins,kbd,q,s,samp,small,strike,strong,sub,sup,tt,var,b,u,i,center,dl,dt,dd,ol,ul,li,fieldset,form,label,legend,table,caption,tbody,tfoot,thead,tr,th,td,article,aside,canvas,details,embed,figure,figcaption,footer,header,hgroup,menu,nav,output,ruby,section,summary,time,mark,audio,video{margin:0;padding:0;border:0;font-size:100%;font:inherit;vertical-align:baseline}article,aside,details,figcaption,figure,footer,header,hgroup,menu,nav,section{display:block}body{line-height:1}ol,ul{list-style:none}blockquote,q{quotes:none}blockquote:before,blockquote:after,q:before,q:after{content:'';content:none}table{border-collapse:collapse;border-spacing:0}.shower{counter-reset:slide;font:25px/2 'PT Sans',sans-serif}@media print{.shower{text-rendering:geometricPrecision}}.shower a{color:#4b86c2;background:-webkit-linear-gradient(bottom,currentColor,currentColor .09em,transparent .09em,transparent)repeat-x;background:linear-gradient(to top,currentColor,currentColor .09em,transparent .09em,transparent)repeat-x;text-decoration:none}.caption{display:none;margin:0 0 50px;color:#3c3d40;text-shadow:0 1px 1px #8d8e90}.caption h1{font:700 50px/1 'PT Sans Narrow',sans-serif}.caption a{text-shadow:0 -1px 1px #1f3f60;background:0 0}.caption a:hover{color:#5e93c8}.badge{position:absolute;top:0;right:0;display:none;overflow:hidden;visibility:hidden;width:11em;height:11em;line-height:2.5;font-size:15px}.badge a{position:absolute;bottom:50%;right:-50%;left:-50%;visibility:visible;background:#4b86c2;box-shadow:0 0 1em rgba(0,0,0,.3);color:#fff;text-decoration:none;text-align:center;-webkit-transform-origin:50% 100%;-ms-transform-origin:50% 100%;transform-origin:50% 100%;-webkit-transform:rotate(45deg) translateY(-1em);-ms-transform:rotate(45deg) translateY(-1em);transform:rotate(45deg) translateY(-1em)}.badge a:hover{background:#568ec6}.region{display:none}.slide{position:relative;width:1024px;height:640px;background:#fff;color:#000;-webkit-print-color-adjust:exact;-webkit-text-size-adjust:none;-moz-text-size-adjust:none;-ms-text-size-adjust:none}@media print{.slide{page-break-before:always}}.slide:after{position:absolute;top:0;right:119px;padding:20px 0 0;width:50px;height:80px;background:url(../images/ribbon.svg) no-repeat;color:#fff;counter-increment:slide;content:counter(slide);text-align:center;font-size:20px}.slide>div{position:absolute;top:0;left:0;overflow:hidden;padding:105px 120px 0;width:784px;height:535px}.slide h2{margin:0 0 37px;color:#666;font:700 50px/1 'PT Sans Narrow',sans-serif}.slide p{margin:0 0 50px}.slide p.note{color:#999}.slide b,.slide strong{font-weight:700}.slide i,.slide em{font-style:italic}.slide code,.slide kbd,.slide mark,.slide samp{padding:3px 8px;border-radius:8px;color:#000}.slide kbd,.slide code,.slide samp{background:rgba(0,0,0,.07);color:#000;line-height:1;font-family:'PT Mono',monospace}.slide mark{background:#fafaa2}.slide sub,.slide sup{position:relative;line-height:0;font-size:75%}.slide sub{bottom:-.25em}.slide sup{top:-.5em}.slide blockquote{font-style:italic}.slide blockquote:before{position:absolute;margin:-16px 0 0 -80px;color:#ccc;font:200px/1 'PT Sans',sans-serif;content:'\201C'}.slide blockquote+figcaption{margin:-50px 0 50px;font-style:italic;font-weight:700}.slide ol,.slide ul{margin:0 0 50px;counter-reset:list}.slide ol li,.slide ul li{text-indent:-2em}.slide ol li:before,.slide ul li:before{display:inline-block;width:2em;color:#bbb;text-align:right}.slide ol ol,.slide ol ul,.slide ul ol,.slide ul ul{margin:0 0 0 2em}.slide ul>li:before{content:'\2022\00A0\00A0'}.slide ul>li:lang(ru):before{content:'\2014\00A0\00A0'}.slide ol>li:before{counter-increment:list;content:counter(list)\". \"}.slide pre{margin:0 0 49px;padding:1px 0 0;counter-reset:code;white-space:normal;-moz-tab-size:4;-o-tab-size:4;tab-size:4}.slide pre code{display:block;padding:0;background:0 0;white-space:pre;line-height:2}.slide pre code:before{position:absolute;margin-left:-50px;color:#bbb;counter-increment:code;content:counter(code,decimal-leading-zero)\".\"}.slide pre code:only-child:before{content:''}.slide pre mark.important{background:#c00;color:#fff}.slide pre mark.comment{padding:0;background:0 0;color:#999}.slide table{margin:0 0 50px;width:100%;border-collapse:collapse;border-spacing:0}.slide table th,.slide table td{background:-webkit-linear-gradient(bottom,#bbb,#bbb .055em,transparent .055em,transparent)repeat-x;background:linear-gradient(to top,#bbb,#bbb .055em,transparent .055em,transparent)repeat-x}.slide table th{text-align:left;font-weight:700}.slide table.striped tr:nth-child(even){background:#eee}.slide.cover,.slide.shout{z-index:1}.slide.cover:after,.slide.shout:after{visibility:hidden}.slide.cover{background:#000}.slide.cover img,.slide.cover svg,.slide.cover video,.slide.cover object,.slide.cover canvas,.slide.cover iframe{position:absolute;top:0;left:0;z-index:-1}.slide.cover.w img,.slide.cover.w svg,.slide.cover.w video,.slide.cover.w object,.slide.cover.w canvas,.slide.cover.w iframe{top:50%;width:100%;-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);transform:translateY(-50%)}.slide.cover.h img,.slide.cover.h svg,.slide.cover.h video,.slide.cover.h object,.slide.cover.h canvas,.slide.cover.h iframe{left:50%;height:100%;-webkit-transform:translateX(-50%);-ms-transform:translateX(-50%);transform:translateX(-50%)}.slide.cover.w.h img,.slide.cover.w.h svg,.slide.cover.w.h video,.slide.cover.w.h object,.slide.cover.w.h canvas,.slide.cover.w.h iframe{top:0;left:0;-webkit-transform:none;-ms-transform:none;transform:none}.slide.shout h2{position:absolute;top:50%;left:0;width:100%;text-align:center;line-height:1;font-size:150px;-webkit-transform:translateY(-50%);-ms-transform:translateY(-50%);transform:translateY(-50%)}.slide.shout h2 a{background:-webkit-linear-gradient(bottom,currentColor,currentColor .11em,transparent .11em,transparent)repeat-x;background:linear-gradient(to top,currentColor,currentColor .11em,transparent .11em,transparent)repeat-x}.slide .place{position:absolute;top:50%;left:50%;-webkit-transform:translate(-50%,-50%);-ms-transform:translate(-50%,-50%);transform:translate(-50%,-50%)}.slide .place.t.l,.slide .place.t.r,.slide .place.b.r,.slide .place.b.l{-webkit-transform:none;-ms-transform:none;transform:none}.slide .place.t,.slide .place.b{-webkit-transform:translate(-50%,0);-ms-transform:translate(-50%,0);transform:translate(-50%,0)}.slide .place.l,.slide .place.r{-webkit-transform:translate(0,-50%);-ms-transform:translate(0,-50%);transform:translate(0,-50%)}.slide .place.t,.slide .place.t.l,.slide .place.t.r{top:0}.slide .place.r{right:0;left:auto}.slide .place.b,.slide .place.b.r,.slide .place.b.l{top:auto;bottom:0}.slide .place.l{left:0}.slide footer{position:absolute;left:0;right:0;bottom:-640px;z-index:1;display:none;padding:20px 120px 4px;background:#fafaa2;box-shadow:0 0 0 2px #f0f0ac inset;-webkit-transition:bottom .3s;transition:bottom .3s}.slide footer p{margin:0 0 16px}.slide footer mark{background:rgba(255,255,255,.7)}.slide:hover footer{bottom:0}@media screen{.shower.list{position:absolute;clip:rect(0,auto,auto,0);padding:80px 0 40px 100px;background:#585a5e url(../images/linen.png)}}@media screen and (-webkit-min-device-pixel-ratio:2),screen and (min-resolution:192dpi){.shower.list{background-image:url(../images/linen@2x.png);background-size:256px}}@media screen{.shower.list .caption,.shower.list .badge{display:block}.shower.list .slide{float:left;margin:0 -412px -220px 0;-webkit-transform-origin:0 0;-ms-transform-origin:0 0;transform-origin:0 0;-webkit-transform:scale(.5);-ms-transform:scale(.5);transform:scale(.5)}}@media screen and (max-width:1324px){.shower.list .slide{margin:0 -688px -400px 0;-webkit-transform:scale(.25);-ms-transform:scale(.25);transform:scale(.25)}}@media screen{.shower.list .slide:before{position:absolute;top:0;left:0;z-index:-1;width:512px;height:320px;box-shadow:0 0 30px rgba(0,0,0,.005),0 20px 50px rgba(42,43,45,.6);border-radius:2px;content:'';-webkit-transform-origin:0 0;-ms-transform-origin:0 0;transform-origin:0 0;-webkit-transform:scale(2);-ms-transform:scale(2);transform:scale(2)}}@media screen and (max-width:1324px){.shower.list .slide:before{width:256px;height:160px;-webkit-transform:scale(4);-ms-transform:scale(4);transform:scale(4)}}@media screen{.shower.list .slide:after{top:auto;right:auto;bottom:-80px;left:120px;padding:0;width:auto;height:auto;background:0 0;color:#3c3d40;text-shadow:0 1px 1px #8d8e90;font-weight:700;-webkit-transform-origin:0 0;-ms-transform-origin:0 0;transform-origin:0 0;-webkit-transform:scale(2);-ms-transform:scale(2);transform:scale(2)}}@media screen and (max-width:1324px){.shower.list .slide:after{bottom:-104px;-webkit-transform:scale(4);-ms-transform:scale(4);transform:scale(4)}}@media screen{.shower.list .slide:hover:before{box-shadow:0 0 0 10px rgba(42,43,45,.3),0 20px 50px rgba(42,43,45,.6)}.shower.list .slide:target:before{box-shadow:0 0 0 1px #376da3,0 0 0 10px #4b86c2,0 20px 50px rgba(42,43,45,.6)}}@media screen and (max-width:1324px){.shower.list .slide:target:before{box-shadow:0 0 0 1px #376da3,0 0 0 10px #4b86c2,0 20px 50px rgba(42,43,45,.6)}}@media screen{.shower.list .slide:target:after{text-shadow:0 1px 1px rgba(42,43,45,.6);color:#4b86c2}.shower.list .slide>div:before{position:absolute;top:0;right:0;bottom:0;left:0;z-index:2;content:''}.shower.list .slide.cover:after,.shower.list .slide.shout:after{visibility:visible}.shower.list .slide footer{display:block}.shower.full{position:absolute;top:50%;left:50%;overflow:hidden;margin:-320px 0 0 -512px;width:1024px;height:640px;background:#000}.shower.full.debug:after{position:absolute;top:0;right:0;bottom:0;left:0;z-index:2;background:url(../images/grid-16x10.svg) no-repeat;content:''}.shower.full .region{position:absolute;clip:rect(0 0 0 0);overflow:hidden;margin:-1px;padding:0;width:1px;height:1px;border:none;display:block}.shower.full .slide{position:absolute;top:0;left:0;margin-left:150%}.shower.full .slide .next{visibility:hidden}.shower.full .slide .next.active{visibility:visible}.shower.full .slide:target{margin:0}.shower.full .slide.shout.grow h2,.shower.full .slide.shout.shrink h2{opacity:0;-webkit-transition:all .4s ease-out;transition:all .4s ease-out}.shower.full .slide.shout.grow:target h2,.shower.full .slide.shout.shrink:target h2{opacity:1;-webkit-transform:scale(1) translateY(-50%);-ms-transform:scale(1) translateY(-50%);transform:scale(1) translateY(-50%)}.shower.full .slide.shout.grow h2{-webkit-transform:scale(.1) translateY(-50%);-ms-transform:scale(.1) translateY(-50%);transform:scale(.1) translateY(-50%)}.shower.full .slide.shout.shrink h2{-webkit-transform:scale(10) translateY(-50%);-ms-transform:scale(10) translateY(-50%);transform:scale(10) translateY(-50%)}.shower.full .progress{position:absolute;left:-20px;bottom:0;z-index:1;width:0;height:0;box-sizing:content-box;border:10px solid #4b86c2;border-right-color:transparent;-webkit-transition:width .2s linear;transition:width .2s linear;clip:rect(10px,1044px,20px,20px)}.shower.full .progress[style*='100%']{padding-left:10px}}@page{margin:0;size:1024px 640px}
</style>
<style>
#Cover h2 {
position:absolute;
top:50%;
right:-25%;
left:-25%;
margin:-1em 0 0;
padding:0.5em 0 0.55em;
background:rgba(255, 255, 234, 0.8);
color:#334445;
text-align:center;
font-size:100px;
}
#Cover .next {
opacity:0;
-webkit-transform-origin:50% 50%;
-webkit-transform:rotate(-20deg) scale(5);
    -webkit-transition:all 0.5s;
-moz-transform-origin:50% 50%;
-moz-transform:rotate(-20deg) scale(5);
    -moz-transition:all 0.5s;
-o-transform-origin:50% 50%;
-o-transform:rotate(-20deg) scale(5);
    -o-transition:all 0.5s;
transform-origin:50% 50%;
transform:rotate(-20deg) scale(5);
    transition:all 0.5s;
}
#Cover .next.active {
opacity:1;
-webkit-transform:rotate(-20deg) scale(1);
-moz-transform:rotate(-20deg) scale(1);
-o-transform:rotate(-20deg) scale(1);
transform:rotate(-20deg) scale(1);
}
#Check img {
width:115px;
vertical-align:-4%;
}
#Zoidberg {
background:#FFF url(pictures/zoidberg.png) 50% 100% no-repeat;
}
#Zoidberg h2 {
margin-top:-120px;
font-size:90px;
}
</style>
<link rel=\"stylesheet\" href=\"index.css\">
</head>
<body class=\"shower list\">
<header class=\"caption\">
<h1>Flexbox, теперь понятно</h1>
<p><a href=\"https://pepelsbey.net/\">Вадим Макеев</a>, <a href=\"https://opera.com\">Opera Software</a></p>
</header>
<section class=\"slide cover\" id=\"Cover\"><div>
<h2 class=\"next\">Flexbox, теперь понятно</h2>
<img src=\"pictures/specs.png\" alt=\"\">
</div></section>
<section class=\"slide shout\"><div>
<h2>Flexbox</h2>
</div></section>
<section class=\"slide shout\" id=\"Check\"><div>
<h2><img src=\"pictures/check.svg\" alt=\"\"> 68,51%</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2 style=\"font-size:90px\">Первая система раскладки, которая не хак</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2>prozrachniy.gif</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2>&lt;br clear=all&gt;</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2 style=\"font-size:130px\"><a href=\"https://www.w3.org/TR/2009/WD-css3-flexbox-20090723/\" target=\"_blank\">F09</a> ‣ <a href=\"https://www.w3.org/TR/2012/WD-css3-flexbox-20120322/\" target=\"_blank\">F11</a> ‣ <a href=\"https://www.w3.org/TR/css3-flexbox/\" target=\"_blank\">F12</a></h2>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/browsers-olympic.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox</h2>
<img src=\"pictures/browsers.jpg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox 09</h2>
<img src=\"pictures/browsers-09-desktop.jpg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox 09</h2>
<img src=\"pictures/browsers-09-mobile.jpg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox 11</h2>
<img src=\"pictures/browsers-11.jpg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox 12</h2>
<img src=\"pictures/browsers-12.jpg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<h2>Flexbox 12</h2>
<img src=\"pictures/browsers-12-up.jpg\" alt=\"\">
</div></section>
<section class=\"slide shout\"><div>
<h2>Собственно</h2>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-container.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row.svg\" alt=\"\">
</div></section>
<section class=\"slide shout\"><div>
<h2>Оси</h2>
</div></section>
<section class=\"slide\"><div>
<h2>Привычный CSS</h2>
<pre>
<code>E {</code>
<code>    <mark>top</mark>:0; <mark class=\"comment\">/* сверху */</mark></code>
<code>    <mark>bottom</mark>:0; <mark class=\"comment\">/* снизу */</mark></code>
<code>    <mark>text-align</mark>:center; <mark class=\"comment\">/* горизонтально */</mark></code>
<code>    <mark>vertical-align</mark>:middle; <mark class=\"comment\">/* вертикально */</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide shout\"><div>
<h2><span style=\"border-bottom:solid 0.13em\">Главная</span></h2>
</div></section>
<section class=\"slide shout\"><div>
<h2><span style=\"border-bottom:dotted 0.13em\">Поперечная</span></h2>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-arrow.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-bones.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-column.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-column-arrow.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-column-bones.svg\" alt=\"\">
</div></section>
<section class=\"slide shout\"><div>
<h2>Пушкин. Зимний вечер</h2>
</div></section>
<section class=\"slide\"><div>
<h2>Пушкин. Зимний вечер</h2>
<pre>
<code>&lt;div class=\"<mark>poem</mark>\"&gt;</code>
<code>    <mark>&lt;div&gt;</mark>буря мглою&lt;/div&gt;</code>
<code>    <mark>&lt;div&gt;</mark>небо кроет&lt;/div&gt;</code>
<code>    <mark>&lt;div&gt;</mark>вихри снежные&lt;/div&gt;</code>
<code>    <mark>&lt;div&gt;</mark>крутя&lt;/div&gt;</code>
<code>&lt;/div&gt;</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Пушкин. Зимний вечер</h2>
<pre>
<code><mark>.poem</mark> {</code>
<code>    overflow:hidden;</code>
<code>    height:<mark>640px</mark>;</code>
<code>    }</code>
<code>    .poem <mark>div</mark> {</code>
<code>        float:left;</code>
<code>        }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Пушкин. Зимний вечер</h2>
<pre>
<code>.poem div<mark>:first-child</mark> {</code>
<code>    background:<span style=\"color:#090\">#090</span>;</code>
<code>    }</code>
<code>.poem div<mark>:last-child</mark> {</code>
<code>    background:<span style=\"color:#C00\">#C00</span>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide shout\"><div>
<div class=\"poem\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Включаем Flexbox</h2>
<pre>
<code>.poem {</code>
<code>    <mark>display:flex;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex axis-right\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Меняем направление по оси</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    flex-direction:<mark>row</mark>; <mark class=\"comment\">/* по умолчанию */</mark></code>
<code>    flex-direction:<mark>row-reverse</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex row-reverse axis-left\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Поворачиваем саму ось</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    flex-direction:<mark>column</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex column axis-down\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Меняем направление по оси</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    flex-direction:<mark>column-reverse</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex column-reverse axis-up\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide shout\"><div>
<h2>Што?</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2>Вдоль</h2>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-bones.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-bones-reverse.svg\" alt=\"\">
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Вдоль направо</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    justify-content:<mark>flex-start</mark>; <mark class=\"comment\">/* по умолчанию */</mark></code>
<code>    justify-content:<mark>flex-end</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-end\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Вдоль посередине</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    <mark>justify-content:center;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-center\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Вдоль равномерно</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    <mark>justify-content:space-between;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Вдоль красиво</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    <mark>justify-content:space-around;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-around\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide shout\"><div>
<h2>Перестановка</h2>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between order\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Меняем порядок</h2>
<pre>
<code>.poem div:nth-child(<mark class=\"important\">2</mark>) {</code>
<code>    <mark>order:1;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between order order-2nd-1\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Меняем порядок</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>order:4;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between order order-all-4\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Меняем порядок</h2>
<pre>
<code>.poem div:nth-child(<mark class=\"important\">1</mark>) { <mark>order:2</mark> }</code>
<code>.poem div:nth-child(<mark class=\"important\">2</mark>) { <mark>order:1</mark> }</code>
<code>.poem div:nth-child(<mark class=\"important\">3</mark>) { <mark>order:4</mark> }</code>
<code>.poem div:nth-child(<mark class=\"important\">4</mark>) { <mark>order:3</mark> }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between order order-arranged\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide cover w\"><div>
<img src=\"pictures/welcome.jpg\" alt=\"\">
</div></section>
<section class=\"slide shout\"><div>
<h2>Поперёк</h2>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-bones.svg\" alt=\"\">
</div></section>
<section class=\"slide\"><div>
<h2>Даём высоту</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>height:250px;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between align-items-height\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Поперёк внизу</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    align-items:<mark>flex-start</mark>; <mark class=\"comment\">/* по умолчанию */</mark></code>
<code>    align-items:<mark>flex-end</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between align-items-height align-items-end\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Поперёк посередине</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    align-items:<mark>center</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between align-items-height align-items-center\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Поперёк индивидуально</h2>
<pre>
<code>.poem <mark>div</mark>:nth-child(<mark class=\"important\">1</mark>) {</code>
<code>    align-self:<mark>flex-start</mark>;</code>
<code>    }</code>
<code>.poem <mark>div</mark>:nth-child(<mark class=\"important\">4</mark>) {</code>
<code>    align-self:<mark>flex-end</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex justify-between align-items-height align-items-center align-items-start-end\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex margin\">
<div>буря мглою</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Центрирование</h2>
<pre>
<code>.poem {</code>
<code>    <mark>display:flex;</mark></code>
<code>    }</code>
<code>.poem div {</code>
<code>    <mark>margin:auto;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide shout\"><div>
<h2>Растягивание</h2>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex\">
<div>×</div>
<div>×</div>
<div>×</div>
<div>×</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Растягивание</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>flex-grow:1;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex grow width-play\">
<div>×</div>
<div>×</div>
<div>×</div>
<div>×</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Растягивание</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>flex-grow:1;</mark></code>
<code>    }</code>
<code>.poem div:nth-child(<mark class=\"important\">1</mark>) {</code>
<code>    <mark>flex-grow:4;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex grow grow-1st-4 width-play\">
<div>×</div>
<div>×</div>
<div>×</div>
<div>×</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Сжатие</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>width:25%;</mark></code>
<code>    }</code>
<code>.poem div:nth-child(1) {</code>
<code>    <mark>flex-shrink:4;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex shrink width-play\">
<div>×</div>
<div>×</div>
<div>×</div>
<div>×</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Запас</h2>
<pre>
<code>.poem div {</code>
<code>    <mark>flex-grow:1;</mark></code>
<code>    }</code>
<code>.poem div:nth-child(<mark class=\"important\">1</mark>) {</code>
<code>    <mark>flex-basis:250px;</mark></code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex grow basis width-play\">
<div>×</div>
<div>×</div>
<div>×</div>
<div>×</div>
</div>
</div></section>
<section class=\"slide shout\"><div>
<h2>Весь Пушкин</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2>Многострочный Flexbox</h2>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Перенос</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    flex-wrap:<mark>nowrap</mark>; <mark class=\"comment\">/* по умолчанию */</mark></code>
<code>    flex-wrap:<mark>wrap</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide\"><div>
<h2>Перенос наоборот</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    flex-wrap:<mark>wrap-reverse</mark>;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap-reverse\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap grow width-play\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<img src=\"pictures/axis-row-bones.svg\" alt=\"\">
</div></section>
<section class=\"slide\"><div>
<h2>Порядок поперёк</h2>
<pre>
<code>.poem {</code>
<code>    display:flex;</code>
<code>    align-content:<mark>stretch</mark>; <mark class=\"comment\">/* по умолчанию */</mark></code>
<code>    align-content:<mark>center</mark>;</code>
<code>    }</code>
</pre>
<p class=\"note\">Только для многострочных блоков!</p>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap grow align-content-center\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap grow align-content-between\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap grow align-content-start\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide cover\"><div>
<div class=\"poem flex wrap grow align-content-end\">
<div>буря мглою</div>
<div>небо кроет</div>
<div>вихри снежные</div>
<div>крутя</div>
<div>то</div>
<div>как зверь</div>
<div>она</div>
<div>завоет</div>
<div>то заплачет</div>
<div>как дитя</div>
<div>то по кровле</div>
<div>обветшалой</div>
<div>вдруг соломой</div>
<div>зашумит</div>
<div>то как</div>
<div>путник запоздалый</div>
<div>к нам в окошко</div>
<div>застучит</div>
</div>
</div></section>
<section class=\"slide shout\" id=\"Zoidberg\"><div>
<h2>Многострочный Flexbox в Firefox?</h2>
</div></section>
<section class=\"slide shout\"><div>
<h2 style=\"font-size:120px\">Фолбеки на старый Flexbox</h2>
</div></section>
<section class=\"slide\"><div>
<h2>Включение Flexbox</h2>
<pre>
<code>E {</code>
<code>    display:<mark>-webkit-box</mark>;</code>
<code>    display:-moz-box;</code>
<code>    display:<mark>-ms-flexbox</mark>;</code>
<code>    display:<mark>-webkit-flex</mark>;</code>
<code>    display:flex;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Растягивание блоков</h2>
<pre>
<code>E {</code>
<code>    <mark>-webkit-box-flex</mark>:1;</code>
<code>    -moz-box-flex:1;</code>
<code>    <mark>-ms-flex</mark>:1;</code>
<code>    <mark>-webkit-flex</mark>:1;</code>
<code>    flex:1;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Прямая колонка</h2>
<pre>
<code>E { -webkit-box-orient:<mark>vertical</mark>;</code>
<code>       -moz-box-orient:vertical;</code>
<code>        -ms-flex-direction:<mark>column</mark>;</code>
<code>    -webkit-flex-direction:<mark>column</mark>;</code>
<code>            flex-direction:column; }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Обратная колонка</h2>
<pre>
<code>E { -webkit-box-orient:<mark>vertical</mark>;</code>
<code>    -webkit-box-direction:<mark>reverse</mark>;</code>
<code>       -moz-box-orient:vertical;</code>
<code>       -moz-box-direction:reverse;</code>
<code>        -ms-flex-direction:<mark>column-reverse</mark>;</code>
<code>    -webkit-flex-direction:<mark>column-reverse</mark>;</code>
<code>            flex-direction:column-reverse; }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Обратный ряд</h2>
<pre>
<code>E { -webkit-box-orient:<mark>horizontal</mark>;</code>
<code>    -webkit-box-direction:<mark>reverse</mark>;</code>
<code>       -moz-box-orient:horizontal;</code>
<code>       -moz-box-direction:reverse;</code>
<code>        -ms-flex-direction:<mark>row-reverse</mark>;</code>
<code>    -webkit-flex-direction:<mark>row-reverse</mark>;</code>
<code>            flex-direction:row-reverse; }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Вдоль равномерно</h2>
<pre>
<code>E {</code>
<code>    <mark>-webkit-box-pack</mark>:justify;</code>
<code>    -moz-box-pack:justify;</code>
<code>    <mark>-ms-flex-pack</mark>:justify;</code>
<code>    <mark>-webkit-justify-content</mark>:space-between;</code>
<code>    justify-content:space-between;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Поперёк посередине</h2>
<pre>
<code>E {</code>
<code>    <mark>-webkit-box-align</mark>:center;</code>
<code>    -moz-box-align:center;</code>
<code>    <mark>-ms-flex-align</mark>:center;</code>
<code>    <mark>-webkit-align-items</mark>:center;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide\"><div>
<h2>Перестановка</h2>
<pre>
<code>E {</code>
<code>    <mark>-webkit-box-ordinal-group</mark>:1;</code>
<code>    -moz-box-ordinal-group:1;</code>
<code>    <mark>-ms-flex-order</mark>:1;</code>
<code>    <mark>-webkit-order</mark>:1;</code>
<code>    order:1;</code>
<code>    }</code>
</pre>
</div></section>
<section class=\"slide cover w\"><div>
<img src=\"pictures/gotcha.gif\" alt=\"\">
</div></section>
<section class=\"slide\"><div>
<h2>Читать</h2>
<ul>
<li><a href=\"https://caniuse.com/flexbox\">Поддержка Flexbox в браузерах</a></li>
<li><a href=\"https://wiki.csswg.org/spec/flexbox-2009-2011-spec-property-mapping\">Таблица соответствия F09 и F11</a></li>
<li><a href=\"https://zomigi.com/blog/flexbox-syntax-for-ie-10/\">Таблица соответствия F09 и F11 для IE10</a></li>
<li><a href=\"https://bennettfeely.com/flexplorer/\">CSS3 Flexplorer</a></li>
<li><a href=\"https://developer.mozilla.org/en-US/docs/CSS/Using_CSS_flexible_boxes\">Использование Flexbox от Mozilla</a></li>
<li><a href=\"https://msdn.microsoft.com/en-us/library/ie/hh673531(v=vs.85).aspx\">Руководство по Flexbox от Microsoft</a></li>
</ul>
</div></section>
<section class=\"slide\" id=\"ThankYou\"><div>
<h2>Flexbox, теперь понятно</h2>
<p>Вадим Макеев, Opera Software</p>
<ul>
<li><a href=\"https://twitter.com/pepelsbey\">@pepelsbey</a></li>
<li><a href=\"https://pepelsbey.net\">pepelsbey.net</a></li>
<li><a href=\"mailto:pepelsbey@gmail.com\">pepelsbey@gmail.com</a></li>
</ul>
<img src=\"pictures/flexo.png\" alt=\"\" class=\"place b r\" style=\"margin-right:70px\">
<p>Презентация: <a href=\"https://pepelsbey.net/pres/flexbox-gotcha/\">pepelsbey.net/pres/flexbox-gotcha</a></p>
</div></section>
<section class=\"slide shout\"><div>
<h2><a href=\"https://sokr.me/fbx\">sokr.me/fbx</a></h2>
</div></section>
<p class=\"badge\"><a href=\"https://github.com/shower/shower\">Powered by Shower</a></p>
<div class=\"progress\"></div>
<script src=\"../shower/shower.min.js\"></script>
<!-- Copyright © 2010–2014 Vadim Makeev — pepelsbey.net -->
<script>(function(b,c,a){(c[a]=c[a]||[]).push(function(){try{c.yaCounter155532=new Ya.Metrika({id:155532})}catch(a){}});var e=b.getElementsByTagName('script')[0],d=b.createElement('script'),a=function(){e.parentNode.insertBefore(d,e)};d.async=!0;d.src='//mc.yandex.ru/metrika/watch.js';'[object Opera]'==c.opera?b.addEventListener('DOMContentLoaded',a):a()})(document,window,'yandex_metrika_callbacks');</script><noscript><img src=\"//mc.yandex.ru/watch/155532\" alt=\"\"></noscript>
</body>
</html>"))
;; iface ends here
