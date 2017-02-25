;; [[file:doc.org::*Функции для кодогенерации сущностей][generators]]
;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
;; Licensed under the GNU AGPLv3

(setq org-confirm-babel-evaluate nil)

(defun outlist (lst ident fn)
  (let ((outlist-result '())
        (first  (car lst))
        (middle (butlast (cdr lst)))
        (last   (car (last lst))))
    (cond ((equal 0 (length lst))
           (push (concat ident "()") outlist-result))
          ((equal 1 (length lst))
           (push (funcall fn (concat ident "(%s)") first) outlist-result))
          ((< 1 (length lst))
           (push (funcall fn (concat ident "(%s") first) outlist-result)
           (mapcar #'(lambda (x)
                       (push (funcall fn (concat "\n" ident " %s") x) outlist-result))
                   middle)
           (push (funcall fn (concat "\n" ident " %s)") last) outlist-result)))
   outlist-result))

(defun split-name (s)
  (split-string
   (let ((case-fold-search nil))
     (downcase
      (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2" s)))
   "[^A-Za-z0-9]+"))

(defun camelcase  (s) (mapconcat 'capitalize (split-name s) ""))
(defun underscore (s) (mapconcat 'downcase   (split-name s) "_"))
(defun dasherize  (s) (mapconcat 'downcase   (split-name s) "-"))
(defun colonize   (s) (mapconcat 'capitalize (split-name s) "::"))

(defun camelscore (s)
  (cond ((string-match-p "\\(?:[a-z]+_\\)+[a-z]+" s)(dasherize  s))
        ((string-match-p "\\(?:[a-z]+-\\)+[a-z]+" s)(camelcase  s))
        ((string-match-p "\\(?:[A-Z][a-z]+\\)+$"  s)(colonize   s))
        (t(underscore s)) ))

(defun camelscore-word-at-point ()
  (interactive)
  (let* ((case-fold-search nil)
         (beg (and (skip-chars-backward "[:alnum:]:_-") (point)))
         (end (and (skip-chars-forward  "[:alnum:]:_-") (point)))
         (txt (buffer-substring beg end))
         (cml (camelscore txt)) )
    (if cml (progn (delete-region beg end) (insert cml)))))

(defun gen-fields (rows)
  (let ((fields) (primary) (foreign) (unique))
    (mapcar #'(lambda (val)
                (unless (string= "" (nth 3 val))
                  (mapcar #'(lambda (addon-key)
                              (let (meta-key)
                                (if (listp addon-key)
                                    (setq meta-key (car addon-key))
                                  (setq meta-key addon-key))
                                (cond
                                 ((string= meta-key 'primary)
                                  (push (car val) primary))
                                 ((string= meta-key 'one-to-many)
                                  (push (list 'one-to-many (car val) (nth 1 addon-key)) foreign))
                                 ((string= meta-key 'many-to-one)
                                  (push (list 'many-to-one (car val) (nth 1 addon-key)) foreign))
                                 ((string= meta-key 'unique)
                                  (push (car val) unique)))))
                          (read (nth 3 val)))))
            rows)
  (values
     (outlist rows "  "
              (function (lambda (tpl val)
                          (if (not (string= "" (nth 1 val)))
                               (if (string= "" (nth 2 val))
                                  (format tpl (subseq val 0 2))
                                  (format tpl (subseq val 0 3)))
                            (format tpl (list (car val)))))))
     primary
     (outlist (reverse foreign) "  "
              (function (lambda (tpl val)
                          (format tpl val))))
     unique)))

(defun gen-states (rows)
  (let ((result)
        (hash (make-hash-table :test #'equal))
        (states))
    (dolist (elt rows nil)
      (puthash (cadr elt) nil hash)
      (puthash (cadr (cdr elt))  nil hash))
    (maphash (lambda (k v)
               (push k states))
             hash)
    (push "\n" result)
    (push "  (" result)
    (dolist (elt (butlast states))
      (push (format ":%s " elt) result))
    (push (format ":%s)" (car (last states))) result)
    (mapconcat 'identity (reverse result) "")))

(defun gen-actions (rows)
  (let ((result))
    (push "\n" result)
    (let ((x (car rows)))
      (push (format "  ((:%s :%s :%s)" (cadr x) (cadr (cdr x)) (car x)) result))
    (if (equal 1 (length rows))
        (push ")" result)
      (progn
        (push "\n" result)
        (mapcar #'(lambda (x)
                    (push (format "   (:%s :%s :%s)\n" (cadr x) (cadr (cdr x)) (car x)) result))
                (cdr (butlast rows)))
        (let ((x (car (last rows))))
          (push (format "   (:%s :%s :%s))" (cadr x) (cadr (cdr x)) (car x)) result))))
    (mapconcat 'identity (reverse result) "")))

(defmacro define-entity (name desc slot-descriptions primary foreign unique &rest class-options)
  (let ((fields))
    ;; full initial hash with pair 'field-name' => 'slot-description'
    (mapcar #'(lambda(slot)
                (let ((base-data)
                      (name (car (subseq slot 0 1)))
                      (common-type)
                      (default)
                      (nullable)
                      (type)
                      (type-attrs)
                      (attrs))

                  (if (< 1 (length slot))
                      (setq common-type  (car (subseq slot 1 2))))

                  (if (< 2 (length slot))
                      (setq default (car (subseq slot 2 3))))

                  ;; преобразование типа из списка
                  (when (and (listp common-type) (string= "or" (car common-type)))
                    (setq type (car (last common-type)))
                    (setq type-attrs (cdr (last common-type)))
                    (setq nullable t))
                  (when (and (listp common-type) (not (string= "or" (car common-type))))
                    (setq type (car common-type))
                    (setq type-attrs (cdr common-type)))
                  (if (listp common-type)
                      (setq type (car common-type))
                    (setq type common-type))

                  (cond
                   ((string= "numeric" type)
                    (setq attrs (plist-put attrs :precision (nth 0 type-attrs)))
                    (setq attrs (plist-put attrs :scale (nth 1 type-attrs))))
                   ((string= "string" type)
                    (setq attrs (plist-put attrs :max (nth 0 type-attrs)))))

                  (setq fields
                        (plist-put fields (car slot)
                                   (list :name name
                                         :type type
                                         :attrs attrs
                                         :default default
                                         :nullable nullable)))))
            slot-descriptions)

    ;; let's parse type in more usable format

    ;;primary
    (mapcar #'(lambda (primary-field)
                (let ((field-value (plist-get fields primary-field)))
                  (when field-value
                    (plist-put fields primary-field (plist-put field-value :primary t)))))
            primary)

    ;;foreign
    (mapcar #'(lambda (foreign)
                (let ((foreign-field (nth 1 foreign))
                      (field-value (plist-get fields (nth 1 foreign))))
                  (when field-value
                    (plist-put fields foreign-field (plist-put field-value
                                                               (intern (concat ":" (symbol-name (nth 0 foreign))))
                                                               (nth 2 foreign)))))
                )
            foreign)

    ;;unique
    (mapcar #'(lambda (unique-field)
                (let ((field-value (plist-get fields unique-field)))
                  (when field-value
                    (plist-put fields unique-field (plist-put field-value :unique t)))))
            unique)

    ;; plist to normal list
    (setq fields (cl-loop for (key value) on fields by 'cddr
                          collect value
                          ))
    `',fields))

;; ;; пример
;; (define-entity message "Сущность сообщений"
;;   ((id serial)
;;    (type integer)
;;    (author integer)
;;    (target_user integer)
;;    (target_holder integer)
;;    (datetime datetime)
;;    (subject (string 127))
;;    (text text)
;;    (is_read boolean))
;;   (id)
;;   ((many-to-one type (message-type id))
;;    (many-to-one author (user id))
;;    (many-to-one target_user (user id))
;;    (many-to-one target_holder (holder id)))
;;   ())

(defmacro define-automat (name desc slot-descriptions primary foreign unique &rest class-options)
  (let
      ((fields))
    ;; full initial hash with pair 'field-name' => 'slot-description'
    (mapcar #'(lambda(slot)
                (let ((base-data)
                      (name (car (subseq slot 0 1)))
                      (common-type)
                      (default)
                      (nullable)
                      (type)
                      (type-attrs)
                      (attrs))

                  (if (< 1 (length slot))
                      (setq common-type (car (subseq slot 1 2))))
                  (if (< 2 (length slot))
                      (setq default (car (subseq slot 2 3))))

                  ;; преобразование типа из списка
                  (when (and (listp common-type) (string= "or" (car common-type)))
                    (setq type (car (last common-type)))
                    (setq type-attrs (cdr (last common-type)))
                    (setq nullable t))
                  (when (and (listp common-type) (not (string= "or" (car common-type))))
                    (setq type (car common-type))
                    (setq type-attrs (cdr common-type)))
                  (if (listp common-type)
                      (setq type (car common-type))
                    (setq type common-type))

                  (cond
                   ((string= "numeric" type)
                    (setq attrs (plist-put attrs :precision (nth 0 type-attrs)))
                    (setq attrs (plist-put attrs :scale (nth 1 type-attrs))))
                   ((string= "string" type)
                    (setq attrs (plist-put attrs :max (nth 0 type-attrs)))))

                  (setq fields
                        (plist-put fields (car slot)
                                   (list :name name
                                         :type type
                                         :attrs attrs
                                         :default default
                                         :nullable nullable)))))
            slot-descriptions)

    ;; let's parse type in more usable format

    ;;primary
    (mapcar #'(lambda (primary-field)
                (let ((field-value (plist-get fields primary-field)))
                  (when field-value
                    (plist-put fields primary-field (plist-put field-value :primary t)))))
            primary)

    ;;foreign
    (mapcar #'(lambda (foreign)
                (let ((foreign-field (nth 1 foreign))
                      (field-value (plist-get fields (nth 1 foreign))))
                  (when field-value
                    (plist-put fields foreign-field (plist-put field-value
                                                               (intern (concat ":" (symbol-name (nth 0 foreign))))
                                                               (nth 2 foreign)))))
                )
            foreign)

    ;;unique
    (mapcar #'(lambda (unique-field)
                (let ((field-value (plist-get fields unique-field)))
                  (when field-value
                    (plist-put fields unique-field (plist-put field-value :unique t)))))
            unique)

    ;; plist to normal list
    (setq fields (cl-loop for (key value) on fields by 'cddr
                          collect value
                          ))
    `',fields))

(defmacro with-entity (entity &optional fields)
  (let ((entity-data)
        (result-fields)
        (need-fields))
    ;; достаем сущность из сгенерированного файла
    (setq entity-data
          (eval (read
                 (with-temp-buffer
                   (insert-file-contents
                    (concat "./src/" (symbol-name entity) "-entity.lisp"))
                   (buffer-string)))))
    ;; фильтр по запрошенным полям
    (when fields
      (mapcar #'(lambda (field)
                  (if (listp field)
                      (setq need-fields (plist-put need-fields (car field) (cdr field)))
                    (setq need-fields (plist-put need-fields field nil))))
              fields))
    (if need-fields
        (setq result-fields
              (apply #'append
                     (mapcar #'(lambda (entity-field)
                                 (setq field-name (plist-get entity-field :name))
                                 (if (not (plist-member need-fields field-name))
                                     nil
                                   (setq result-field
                                         (if (plist-get need-fields field-name)
                                             (append entity-field
                                                     (plist-get need-fields field-name))
                                           entity-field))
                                   (setq result-field (plist-put result-field :entity entity))
                                   (list result-field)))
                             entity-data)))

      ;;[TODO:bgg] этот блок можно переписать лучше, избежав дублирования кода
      (setq result-fields
            (apply #'append
                   (mapcar #'(lambda (entity-field)
                               (setq result-field (plist-put entity-field :entity entity))
                               (list result-field))
                           entity-data))))
    `',result-fields))

;; ;; пример для message-entity без списка необходимых полей
;; (message "%s"
;;          (with-entity message))

;; ;; пример для message-entity со списком необходимых полей
;; (message "%s"
;;          (with-entity message
;;                       (id target_user target_holder)))

;; (print
;;  (pp
;;   (macroexpand-all
;;    '(with-entity message
;;                  (id
;;                   target_user
;;                   target_holder
;;                   (text :label "Your message"))))))

(defun gen-post (rows var)
  (flet ((rval (val var)
               (let ((match-result (string-match ":" val)))
                 (if (and (not (null match-result))
                          (= 0 (string-match ":" val)))
                     (concat "\"" (substring val 1) "\"")
                   (format ",(drakma:url-encode (%s %s) :utf-8)" val var)))))
    (let ((result))
      (push (format "`((\"%s\" . %s)"
                    (caar rows)
                    (rval (cadar rows) var)
                    var)
            result)
      (mapcar #'(lambda (x)
                  (push (format "\n  (\"%s\" . %s)"
                                (car x)
                                (rval (cadr x) var)
                                var)
                        result))
              (butlast (cdr rows)))
      (push (format "\n  (\"%s\" . %s))"
                    (caar (last rows))
                    (rval (cadar (last rows)) var)
                    var)
            result)
      (mapconcat 'identity (reverse result) ""))))
;; generators ends here
