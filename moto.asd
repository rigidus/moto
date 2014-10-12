
;;;; moto.asd

(asdf:defsystem #:moto
  :serial t
  :pathname "src"
  :depends-on (#:closer-mop
               #:postmodern
               #:anaphora
               #:cl-ppcre
               #:restas
               #:restas-directory-publisher
               #:closure-template
               #:cl-json
               #:cl-base64
               #:drakma
               #:split-sequence)
  :description "site for bikers"
  :author "rigidus"
  :version "0.0.3"
  :license "GPLv3"
  :components ((:file "package")    ;; файл пакетов
               (:static-file "templates.htm")
               (:file "prepare")    ;; подготовка к старту
               (:file "util")       ;; файл с утилитами
               (:file "globals")    ;; файл с глобальными определеями
               ;; Модуль сущностей, автоматов и их тестов
               (:module "entity"
                        :serial t
                        :pathname "mod"
                        :components ((:file "entity")))
               ;; Модуль авторизации
               (:module "auth"
                        :serial t
                        :pathname "mod/auth"
                        :components ((:static-file "auth-tpl.htm")
                                     (:file "auth")))
               (:file "moto")       ;; стартовый файл
               (:file "events")     ;; события системы
               (:file "iface")      ;; файл веб-интерфейса
               ))
