(asdf:defsystem image-board
  :depends-on (:ningle
	       :clack
	       :sqlite)
  :components ((:module :src
		:components
		((:file "image-board"))))
  :description "Image board software")
