;; [[file:doc.org::*Каркас проекта][defsystem]]
;;;; Copyright © 2014-2015 Glukhov Mikhail. All rights reserved.
     ;;;; Licensed under the GNU AGPLv3
     ;;;; moto.asd

(asdf:defsystem #:moto
  :serial t
  :pathname "src"
  :depends-on (#:closer-mop
               #:postmodern
               ;; #:cl-mysql
               #:anaphora
               #:cl-ppcre
               #:restas
               #:restas-directory-publisher
               #:closure-template
               #:cl-json
               #:cl-base64
               #:drakma
               #:split-sequence
               #:cl-html5-parser
               #:cl-who
               #:parenscript
               #:cl-fad
               #:optima
               #:fare-quasiquote-extras
               #:fare-quasiquote-optima
               )
  :description "site for bikers"
  :author "rigidus"
  :version "0.0.3"
  :license "GNU AGPLv3"
  :components ((:file "package")    ;; файл пакетов
               (:static-file "templates.htm")
               (:file "prepare")    ;; подготовка к старту
               (:file "util")       ;; файл с утилитами
               (:file "globals")    ;; файл с глобальными определеями
               (:file "bricks")     ;; компоненты для создания интерфейсов
               ;; Модуль сущностей, автоматов и их тестов
               (:module "entity"
                        :serial t
                        :pathname "mod"
                        :components ((:file "entity")))
               (:file "entityes")   ;; Сущности и автоматы
               (:file "moto")       ;; стартовый файл
               ;; Модуль авторизации (зависит от определения сущностей в стартовом файле)
               (:module "auth"
                        :serial t
                        :pathname "mod/auth"
                        :components ((:static-file "auth-tpl.htm")
                                     (:file "auth")))
               ;; Модуль очередей
               ;; (:module "que"
               ;;          :serial t
               ;;          :pathname "mod/que"
               ;;          :components ((:file "que")))
               ;; Модуль сообщений
               (:module "msg"
                        :serial t
                        :pathname "mod/msg"
                        :components ((:file "msg")))
               ;; Модуль trend
               ;; (:module "trend"
               ;;          :serial t
               ;;          :pathname "mod/trend"
               ;;          :components ((:static-file "trend-tpl.htm")
               ;;                       (:file "trend-prepare")
               ;;                       (:file "entityes")
               ;;                       (:file "loader")
               ;;                       (:file "trend")
               ;;                       (:file "iface")))
               ;; Модуль мотобратан
               ;; ;; (:module "bratan"
               ;; ;;          :serial t
               ;; ;;          :pathname "mod/bratan"
               ;; ;;          :components ((:file "bratan")))
               ;; Модуль HeadHunter
               (:module "hh"
                        :serial t
                        :pathname "mod/hh"
                        :components ((:file "m-util")
                                     (:file "f-util")
                                     (:file "util")
                                     (:file "globals")
                                     (:file "entityes")
                                     (:file "hh")
                                     (:file "vacancy")
                                     (:file "resume")
                                     (:file "response")
                                     (:file "iface")))
               (:file "events")     ;; события системы
               (:file "iface")      ;; файл веб-интерфейса
               ))
;; defsystem ends here
