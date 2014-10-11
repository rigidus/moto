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
  :components ((:file "package")
               (:file "prepare")
               (:file "util")
               (:file "globals")
               (:file "entity")
               (:file "moto")))
