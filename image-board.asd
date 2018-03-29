(in-package :cl-user)
(defpackage :com.tokamach.image-board-asd
  (:use :cl :asdf))
(in-package :com.tokamach.image-board-asd)

(defsystem image-board
  :depends-on (:ningle
	       :clack
	       :sqlite)
  :components ((:module "src"
		:components
		((:file "image-board"))))
  :description "Image board software")
