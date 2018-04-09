(asdf:defsystem bored
  :depends-on (:ningle
	       :clack
	       :sqlite)
  :serial t
  :components ((:module :src
			:components
			((:file "html")
			 (:file "image-board")
			 (:file "main"))))
  :description "Image board software")
