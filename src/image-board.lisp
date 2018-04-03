(declaim (optimize (debug 3)))
(defpackage :com.tokamach.image-board
  (:use :ningle :sqlite))

(defvar *app* (make-instance 'ningle:<app>))
(defvar *db* (sqlite:connect "posts.db"))

;; One post, if parent=nil then this is a thread
(defstruct (post (:constructor make-post-boa (id parent title email message)))
  id parent title email message)

;; db interaction
(defun create-post (id parent title email message)
  (sqlite:execute-non-query *db*
   "INSERT INTO Posts (id, parent, title, email, message) VALUES (?, ?, ?, ?, ?);"
   id parent title email message))
(defun delete-post (id)
  (sqlite:execute-non-query *db*
   "DELETE FROM Posts WHERE id=?;" id))

(defun get-post-from-id (id)
  (let ((dbres (multiple-value-list (sqlite:execute-one-row-m-v *db* "SELECT * FROM Posts WHERE id=?;" id))))
    (apply #'make-post-boa dbres)))

;; creating html
(defun generate-thread-html (id)
  (concatenate 'string
   (format nil "<h1>~D</h1>" id)
   (format nil "<p>~A</p>" (post-message (get-post-from-id id)))))

;; Routes
(setf (ningle:route *app* "/")
      "test")

(setf (ningle:route *app* "/thread/:id" :method :GET)
      #'(lambda (params)
	  (generate-thread-html (parse-integer (cdr (assoc :id params))))))
#|
(setf (ningle:route *app* "/thread/:id" :method :POST)
      #'(lambda (params)
	  (let ((req (lack.request:request-query-parameters ningle:*request*))
		(id (cdr (assoc :id params))))
	    (create-post id (assoc :parent req) (assoc :title req) (assoc :email req) (assoc :message req)))
	  (create-post ((cdr (assoc :id params))))))
|#
