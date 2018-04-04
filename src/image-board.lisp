(declaim (optimize (debug 3)))
(defpackage :image-board
  (:use :cl :ningle :sqlite :cl-ppcre)
  (:export :*app*))
(in-package :image-board)

(defvar *app* (make-instance 'ningle:<app>))
(defvar *db* (sqlite:connect "/Users/tom/code/lisp/image-board/posts.db"))

;; One post, if parent=nil then this is a thread
(defstruct (post (:constructor make-post-boa (id parent name message)))
  id parent name message)

(defun make-post-from-id (id)
  (let ((dbres (multiple-value-list (sqlite:execute-one-row-m-v *db* "SELECT * FROM Posts WHERE id=?;" id))))
    (apply #'make-post-boa dbres)))

(defun make-catalog-list ()
  (let ((thread-list (sqlite:execute-to-list *db* "SELECT * FROM Posts WHERE parent IS NULL;")))
    (mapcar #'(lambda (l) (apply #'make-post-boa l)) thread-list)))

(defun make-post-list-from-parent (id)
  (let ((thread-list (sqlite:execute-to-list *db* "SELECT * FROM Posts WHERE parent=? OR id=?;" id id)))
    (mapcar #'(lambda (l) (apply #'make-post-boa l)) thread-list)))

;; db interaction
(defun create-post (a-post)
  (sqlite:execute-non-query
   *db*
   "INSERT INTO Posts (id, parent, name, message) VALUES (?, ?, ?, ?);"
   (post-id a-post)
   (post-parent a-post)
   (post-name a-post)
   (post-message a-post)))

(defun delete-post (id)
  (sqlite:execute-non-query *db*
   "DELETE FROM Posts WHERE id=?;" id))

;; Routes
(setf (ningle:route *app* "/")
      (generate-catalog-html))

(setf (ningle:route *app* "/thread/:id" :method :GET)
      #'(lambda (params)
	  (generate-thread-html (make-post-list-from-parent (parse-integer (cdr (assoc :id params)))))))
#|
(setf (ningle:route *app* "/thread/:id" :method :POST)
      #'(lambda (params)
	  (let ((req (lack.request:request-query-parameters ningle:*request*))
		(id (cdr (assoc :id params))))
	    (create-post id (assoc :parent req) (assoc :title req) (assoc :email req) (assoc :message req)))
	  (create-post ((cdr (assoc :id params))))))
|#
