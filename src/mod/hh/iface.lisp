;; [[file:hh-iface.org::*Interface][iface]]
;;;; iface.lisp

(in-package #:moto)

;; Страницы
(in-package #:moto)

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

(in-package #:moto)

(defmacro html-page (&rest in-body)
  `(concatenate
   'string
   ,(format nil "<!DOCTYPE html>~%")
   (tree-to-html
    `(("html" (("lang" "en"))
              ("head" ()
                      ("meta" (("charset" "utf-8")))
                      ("meta" (("name" "viewport")
                               ("content" "width=device-width, initial-scale=1, shrink-to-fit=no"))))
              ("body" ()
                      ,@(link-css "bootstrap.min" "b" "s")
                      ,@(script-js "jquery-v-1.10.2" "jquery-ui-v-1.10.3" "modernizr"
                                   "jquery.sortable.original" "frp" "bootstrap.min" "b")
                      ("div" (("class" "container-fluid"))
                             ,@,@in-body)))))))

(in-package #:moto)

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

(in-package #:moto)

(defun graph ()
  (tgb "graph" "graph-on" "graph-off"
       `(("div" (("style" "text-align: center; overflow: auto;"))
                ("img" (("src" "/img/vacancy-state.png")))))))

(in-package #:moto)

(defun tgb (name on off &rest in)
  `(("button" (("type" "button") ("class" ,(format nil "btn btn-primary btn-~A" name))
               ("onclick" ,(format nil "tggl('~A', '~A', '.~A', '.btn-~A');"
                                   on off name name)))
              ,on)
    ("div" (("class" ,name)) ,@(mapcan #'identity in))))

`(,(car (tgb "col-uninteresting" "uninteresting-on" "uninteresting-off")))


;; (tgb "col-uninteresting" "uninteresting-on" "uninteresting-off"
;;      '(("div" (("class" "somecontent")) "content")))

;; =>
;; (("button"
;;   (("type" "button") ("class" "btn btn-primary btn-col-uninteresting")
;;    ("onclick"
;;     "tggl('uninteresting-on', 'uninteresting-off', '.col-uninteresting', '.btn-col-uninteresting');"))
;;   "uninteresting-on")
;;  ("div" (("class" "col-uninteresting"))
;;         ("div" (("class" "somecontent")) "content")))


;; (tree-to-html
;;  (tgb "col-uninteresting" "uninteresting-on" "uninteresting-off"
;;       '(("div" (("class" "somecontent")) "content"))))

;; =>
;; <button type="button"
;;         class="btn btn-primary btn-col-uninteresting"
;;         onclick="tggl('uninteresting-on', 'uninteresting-off', '.col-uninteresting', '.btn-col-uninteresting');">
;;    uninteresting-on
;; </button>
;; <div class="col-uninteresting">
;;    <div class="somecontent">
;;       content
;;    </div>
;; </div>

(defmacro col-btn (name)
  `(list (car (tgb ,(format nil "col-~A" name)
                   ,(format nil "~A-on" name)
                   ,(format nil "~A-off" name)))))

;; (macroexpand-1 '(col-btn "uninteresting"))

;; => (LIST (CAR (TGB "col-uninteresting" "uninteresting-on" "uninteresting-off"))),

(in-package #:moto)

(defun link-css (&rest rest)
  (mapcar #'(lambda (x)
              `("link" (("rel" "stylesheet") ("href" ,(format nil "/css/~A.css" x)))))
          rest))

(defun script-js (&rest rest)
  (mapcar #'(lambda (x)
              `("script" (("type" "text/javascript") ("src" ,(format nil "/js/~A.js" x)))))
          rest))

(in-package #:moto)

(defun in-page-script ()
  `("script"
    (("type" "text/javascript"))
    ,(ps
      (defun get-child-ids (selector)
        ((@ ((@ ((@ ($ selector) children)) map) (lambda (i elt) (array ((@ ((@ $) elt) attr) "id")))) get)))
      (defun save ()
        ((@ $ post) "#" (create :act "SAVE"
                                :unsort ((@ (get-child-ids "#unsort") join))
                                :uninteresting ((@ (get-child-ids "#uninteresting") join))
                                :interesting ((@ (get-child-ids "#interesting") join)))
         (lambda (data status)
           (if (not (equal status "success"))
               (alert (concatenate 'string "err-ajax-fail: " status))
               (eval data))))
        false))))

(in-package #:moto)

(defun vac-elt (id class title noteclass notes name)
  `(("li"
     (("id" ,(format nil "~A" id)) ("class" ,class) ("title" ,title) ("draggable" "true")
      ("style" "display: list-item;"))
     ("span" (("class" ,noteclass)) ,notes)
     ("a" (("href" ,(format nil "/hh/vac/~A" id))) ,name))))

;; (vac-elt 22604660 "unsort" "NULL" "emptynotes" "NILNULL" "DYMMY")

;; => (("li"
;;      (("id" "22604660") ("class" "unsort") ("title" "NULL")
;;       ("draggable" "true") ("style" "display: list-item;"))
;;      ("span" (("class" "emptynotes")) "NILNULL")
;;      ("a" (("href" "/hh/vac/22604660")) "DYMMY")))

(in-package #:moto)

(defun vac-elt-list (vacs vac-type)
  (if vacs
      (mapcar #'(lambda (vac)
                  (vac-elt (src-id vac) vac-type "" "emptynotes" (pretty-salary vac) (name vac)))
              vacs)
      (list (vac-elt -1 vac-type "" " " " " " "))))

;; (vac-elt-list (last (all-vacancy) 2) "unsort")

;; => ((("li"
;;       (("id" "18251915") ("class" "unsort") ("title" "") ("draggable" "true")
;;        ("style" "display: list-item;"))
;;       ("span" (("class" "emptynotes")) "0 NIL")
;;       ("a" (("href" "/hh/vac/18251915"))
;;            "Начальник отдела информационных технологий")))
;;     (("li"
;;       (("id" "23567086") ("class" "unsort") ("title" "") ("draggable" "true")
;;        ("style" "display: list-item;"))
;;       ("span" (("class" "emptynotes")) "150000 ₽")
;;       ("a" (("href" "/hh/vac/23567086")) "Project manager"))))

(in-package #:moto)

(defun vac-col (col-class name id &rest rest)
  `(("div" (("class" ,(format nil "col ~A" col-class)))
           ("div" (("style" "text-align: center")) ,name)
           ("ul"  (("class" "connected handles list no2") ("id" ,id)) ;; error here
                  ,@(mapcar #'car rest)))))

;; (vac-col "col-interesting" "interesting" "yep"
;;          (vac-elt 22604660 "unsort" "NULL" "emptynotes" "NILNULL" "DYMMY")
;;          (vac-elt 22604660 "unsort" "NULL" "emptynotes" "NILNULL" "DYMMY"))

;; => (("div" (("class" "col col-interesting"))
;;            ("div" (("style" "text-align: center")) "interesting")
;;            ("ul" (("class" "connected handles list no2") ("id" "yep"))
;;                  ("li"
;;                   (("id" "22604660") ("class" "unsort") ("title" "NULL")
;;                    ("draggable" "true") ("style" "display: list-item;"))
;;                   ("span" (("class" "emptynotes")) "NILNULL")
;;                   ("a" (("href" "/hh/vac/22604660")) "DYMMY"))
;;                  ("li"
;;                   (("id" "22604660") ("class" "unsort") ("title" "NULL")
;;                    ("draggable" "true") ("style" "display: list-item;"))
;;                   ("span" (("class" "emptynotes")) "NILNULL")
;;                   ("a" (("href" "/hh/vac/22604660")) "DYMMY")))))

(in-package #:moto)

(defun vac-elt-list-col (vacs vac-type)
  (apply #'vac-col (append (list (format nil "col-~A" vac-type) vac-type vac-type)
                           (vac-elt-list vacs vac-type))))

(in-package #:moto)

(restas:define-route hh-vacs ("/hh/vacs")
  (let* ((vacs (aif (all-vacancy) it (err "null vacancy")))
         (sorted-vacs (sort vacs #'sort-vacancy-by-salary))
         (uninteresting-vacs (remove-if-not #'(lambda (vac)
                                                (equal (state vac) ":UNINTERESTING"))
                                            sorted-vacs))
         (interesting-vacs (remove-if-not #'(lambda (vac)
                                              (equal (state vac) ":INTERESTING"))
                                          sorted-vacs))
         (unsort-vacs (remove-if-not #'(lambda (vac)
                                         (equal (state vac) ":UNSORT"))
                                     sorted-vacs)))
    (html-page
     `(,(in-page-script)
        ,@(legend)
        ,@(graph)
        ,@(col-btn "uninteresting")
        ,@(col-btn "unsort")
        ,@(col-btn "interesting")
        ("div" (("class" ""))
               ("button"
                (("type" "submit") ("class" "button") ("onclick" "save();return false;"))
                "SAVE"))
        ("div" (("class" "row no-gutters"))
               ,@(vac-elt-list-col uninteresting-vacs "uninteresting")
               ,@(vac-elt-list-col unsort-vacs "unsort")
               ,@(vac-elt-list-col interesting-vacs "interesting"))))))

(in-package #:moto)

(restas:define-route hh-vacs/post ("/hh/vacs" :method :post)
  (let* ((lists (remove-if #'(lambda (x) (and (equal "act" (car x)) (equal "SAVE" (cdr x))))
                           (hunchentoot:post-parameters*)))
         (split (mapcar #'(lambda (lst)
                            (cons (intern (string-upcase (car lst)) :keyword)
                                  (list (split-sequence:split-sequence #\, (cdr lst)))))
                        lists))
         (filter (mapcar #'(lambda (lst)
                             (cons (car lst)
                                   (list (remove-if #'(lambda (x)
                                                        (or (equal "" x)
                                                            (equal "-1" x)))
                                                    (cadr lst)))))
                         split))
         (toint (mapcar #'(lambda (lst)
                            (cons (car lst)
                                  (list (mapcar #'parse-integer (cadr lst)))))
                        filter))
         (res))
    (loop :for (key val) :in toint :collect
       (mapcar #'(lambda (x)
                   (let ((vac (car (find-vacancy :src-id x))))
                     (unless (equal (state vac) (format nil ":~A" key))
                       (format t "~A |~A>~A| ~A~%"
                               (src-id vac)
                               (state vac)
                               (bprint key)
                               (bprint (name vac)))
                       (takt vac key)
                       ;; (upd-vacancy vac (list :state (format nil ":~A" key)))
                       (push (list (src-id vac) key) res)
                       )))
               val))
    (format nil "/* ~A */" (bprint res))))

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

(defun vac-attr-tr (rest)
  `(("tr" NIL ,@(mapcar #'(lambda (x) `("td" () ,x))
                       rest))))

(vac-attr-tr `("a" "b" "c"))
;; => (("tr" NIL ("td" NIL "a") ("td" NIL "b") ("td" NIL "c")))


(defun vac-attr-tbl (vac)
  `("table"
    (("border" 0) ("style" "font-size: small;"))
    ,@(vac-attr-tr `("id:" ,(id vac) "&nbsp;&nbsp;&nbsp;" "src-id:"
                           ("a" (("href" ,(format nil "https://hh.ru/vacancy/~A" (src-id vac))))
                                ,(src-id vac))
                           "&nbsp;&nbsp;&nbsp;" "archive:" ,(archive vac) "&nbsp;&nbsp;&nbsp;"))
    ,@(vac-attr-tr `("emp-id:" ,(emp-id vac) "&nbsp;&nbsp;&nbsp;" "emp-name:"
                               ("span" (("style" "color:red")) ,(emp-name vac))
                               "&nbsp;&nbsp;&nbsp;" "state:" ,(state vac) "&nbsp;&nbsp;&nbsp;"))
    ,@(vac-attr-tr `("city:" ,(city vac) "&nbsp;&nbsp;&nbsp;" "metro:" ,(metro vac)
                             "&nbsp;&nbsp;&nbsp;" "state:"
                             ,(vac-state-selector vac) "&nbsp;&nbsp;&nbsp;"))
    ,@(vac-attr-tr `("experience:" ,(experience vac) "&nbsp;&nbsp;&nbsp;"
                                   "date:" ,(date vac) "&nbsp;&nbsp;&nbsp;"
                                   "state:" "%CHSTATE%" "&nbsp;&nbsp;&nbsp;"))))

;; (print
;;  (tree-to-html
;;   (vac-attr-tbl (car (all-vacancy)))))

(defun vac-state-selector (vac)
  (fieldset ""
    (eval
     (macroexpand
      (append `(select ("newstate" "" :default ,(subseq (state vac) 1)))
              (list
               (mapcar #'(lambda (x)
                           (cons (symbol-name x) (symbol-name x)))
                       (possible-trans vac))))))))
(in-package #:moto)

(defmacro form ((name title &rest rest &key action method class &allow-other-keys) &body body)
  (let ((result-class ""))
    (unless action (setf action "#"))
    (unless method (setf method "POST"))
    (when class
      (setf result-class (concatenate 'string result-class " " class)))
    ;; (remf rest :title)
    (remf rest :action)
    (remf rest :method)
    (remf rest :class)
    (setf rest (loop :for key :in rest :by #'cddr :collect
                  `(list ',(string-downcase (symbol-name key))
                         ,(getf rest key))))
    ``("form" (("action" ,,action)
                ("method" ,,method)
                ("id" ,,name)
                ("class" ,,result-class)
                ,,@rest)
               ("input" (("type" "hidden")
                         ("name" ,,(format nil "CSRF-~A" name) :value "todo")))
               ,,@body)))

;; (tree-to-html
;;  `(,(form ("chvacstateform" "" :alfa "beta" :gamma "teta")
;;           `("p" (("class" "b")) "aaa"))))

;; =>
;; "<form action=\"#\" method=\"POST\" id=\"chvacstateform\" class=\"\" alfa=\"beta\" gamma=\"teta\">
;;    <input type=\"hidden\" name=\"CSRF-chvacstateform\">
;;    </input>
;;    <p class=\"b\">
;;       aaa
;;    </p>
;; </form>
;; "


;; (print
;;  (tree-to-html
;;   (form ("chvacstateform" "")
;;     (car (vac-attr-tbl (car (all-vacancy)))))))

(restas:define-route hh/vac3/src-id ("/hh/vac3/:src-id")
  (tree-to-html
   `(,(form ("chvacstateform" "")
            (vac-attr-tbl (car (all-vacancy)))))))


(defun heading (name salary-text heading-text)
  `("div" (("class" "heading"))
          ("div" (("class" "heading__inner"))
                 ("div" (("class" "heading__headline"))
                        ("h1" (("class" "heading__headline--h1"))
                              ,name
                              ("span" (("style" "color:red"))
                                      ,salary-text))))
          ("div" (("class" "heading__text"))
                 ,heading-text)))

(defun content-box (class body)
  `("div" (("class" ,(format nil "content-box ~A" class)))
          ,body))

(tree-to-html
 `(,(content-box ""
                 (form ("tagform" nil :class "form-section-container")
                   `(("div" (("class" "form-section"))
                            "wfweff"
                            ;; ,(fieldset "Тэги"
                            ;;           (textarea ("tags" "Тэги") (tags vac))
                            ;;           (ps-html ((:span :class "clear"))))
                            ))))
    ,(content-box ""
                  (form ("tagform" nil :class "form-section-container")
                    `(("div" (("class" "form-section"))
                             "wfweff"
                             ;; ,(fieldset "Тэги"
                             ;;           (textarea ("tags" "Тэги") (tags vac))
                             ;;           (ps-html ((:span :class "clear"))))
                             ))))))

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
        (tree-to-html
         `(,(content-box ""
                         (heading (name vac)
                                   (salary-text vac)
                                   (form ("chvacstateform" "")
                                     (vac-attr-tbl (car (all-vacancy))))))
            ,(content-box ""
                          `("div" (("class" "vacancy-desc"))
                                  ,(format nil "~{~A~}" text)))
            ,(content-box ""
                          (form ("tagform" nil :class "form-section-container")
                            `("div" (("class" "form-section"))
                                     ,(fieldset "Тэги"
                                               (textarea ("tags" "Тэги") (tags vac))
                                               (ps-html ((:span :class "clear"))))
                                     )))
            ,(content-box ""
                          (form ("vacform" nil :class "form-section-container")
                            `("div" (("class" "form-section"))
                                    ,(fieldset "Заметки"
                                               (textarea ("notes" "Заметки") (notes vac))
                                               (textarea ("response" "Сопроводительное письмо") (response vac))
                                               (ps-html ((:span :class "clear"))))
                                    %RESPOND% %SAVE%)))
            ;; )
            ))
        ;; (content-box ()
        ;;   (form ("vacform" nil :class "form-section-container")
        ;;     ((:div :class "form-section")
        ;;      (fieldset "Заметки"
        ;;        (textarea ("notes" "Заметки") (notes vac))
        ;;        (textarea ("response" "Сопроводительное письмо") (response vac))
        ;;        (ps-html ((:span :class "clear")))))
        ;;     %RESPOND% %SAVE%))
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
              ;; (dbg (send-respond
              ;;       src-id
              ;;       (res-id (get-resume (parse-integer (getf p :resume))))
              ;;       (getf p :response)))
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
;; iface ends here
