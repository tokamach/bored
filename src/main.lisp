(declaim (optimize (debug 3)))
(in-package :bored)

(defvar *app* (make-instance 'ningle:<app>))
(defvar *server*)

(defun start ()
  (setf *server*
	(clack:clackup
	 (lack:builder
	  (:static
	   :path "/asset/"
	   :root (make-pathname :directory "/Users/tom/code/lisp/bored/asset/"))
	  *app*))))

(defun stop ()
  (clack:stop *server*))

;; Routes
(setf (ningle:route *app* "/")
      #'(lambda (params)
	  (generate-catalog-html)))

(setf (ningle:route *app* "/thread/:id" :method :GET)
      #'(lambda (params)
	  (generate-thread-html
	   (make-post-list-from-parent (parse-integer (cdr (assoc :id params)))))))

(setf (ningle:route *app* "/thread/:id" :method :POST)
      #'(lambda (params)
	  (let ((id      (cdr (assoc :id params)))
		(name    (cdr (assoc "name" params :test #'equalp)))
		(message (cdr (assoc "message" params :test #'equalp))))
	    (create-post (make-post-boa *next-post-id* id name (get-universal-time) message))
	    `(302 (:location ,(format nil "/thread/~D" id))))))

(setf (ningle:route *app* "/delete/:id" :method :GET)
      #'(lambda (params)
	  (let ((parent (post-parent (make-post-from-id (cdr (assoc :id params)))))
		(id (cdr (assoc :id params))))
	    (unless (equalp parent nil)
	      (delete-post id))
	    `(302 (:location ,(format nil "/thread/~D" parent))))))
