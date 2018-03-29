(defpackage :com.tokamach.image-board
  (:use :ningle :sqlite))

(defvar *app* (make-instance 'ningle:<app>))
(defvar *db* (connect "posts.db"))

;; db interaction
(defun create-post (id parent title email message))
(defun delete-post (id))

(defun get-post-from-id (id))
(defun get-thread-from-id (id))

;; creating html
(defun generate-thread-html (id)
  (concatenate 'string "<h1>" id "<h1>"))

;; Routes
(setf (ningle:route *app* "/")
      "test")

(setf (ningle:route *app* "/thread/:id")
      #'(lambda (params)
	  (generate-thread-html (cdr (assoc :id params)))))
