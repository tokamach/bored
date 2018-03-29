(defpackage :com.tokamach.image-board
  (:use :common-lisp :sqlite))

(defvar *app* (make-instance 'ningle:<app>))

;; db interaction
(defun create-post (id parent title email message))
(defun get-thread-from-index (index))

;; creating html

;; Routes
(setf (ningle:route *app* "/")
      "Hello fegit")
