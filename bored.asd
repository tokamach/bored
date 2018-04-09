(asdf:defsystem bored
  :depends-on (:ningle
	       :lack
	       :clack
	       :sqlite)
  :pathname "src"
  :serial t
  :components ((:file "package")
	       (:file "image-board")
	       (:file "html")
	       (:file "main"))
  :description "Image board software")
