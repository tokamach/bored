(asdf:defsystem image-board
  :depends-on (:ningle
	       :clack
	       :sqlite)
  :serial t
  :components ((:module :src
			:components
			((:file "html")
			 (:file "image-board"))))
  :description "Image board software")
