(asdf:defsystem image-board
  :depends-on (:ningle
	       :clack
	       :sqlite)
  :components ((:module :src
		:components
		((:file "image-board"
			:depends-on ("html"))
		 (:file "html"))))
  :description "Image board software")
