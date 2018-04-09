(declaim (optimize (debug 3)))
(defpackage :image-board
  (:use :cl :ningle :sqlite :cl-ppcre)
  (:export :*app*))
(in-package :image-board)

(defvar *app* (make-instance 'ningle:<app>))
(defvar *db* (sqlite:connect "/Users/tom/code/lisp/image-board/posts.db"))

(defvar *next-post-id* (1+ (sqlite:execute-single *db* "SELECT MAX(id) FROM Posts;")))

;; One post, if parent=nil then this is a thread
(defstruct (post (:constructor make-post-boa (id parent name time message)))
  id parent name time message)

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
   "INSERT INTO Posts (id, parent, name, time, message) VALUES (?, ?, ?, ?, ?);"
   (post-id a-post)
   (post-parent a-post)
   (post-name a-post)
   (post-time a-post)
   (post-message a-post))
  (incf *next-post-id*))

(defun delete-post (id)
  (sqlite:execute-non-query *db*
   "DELETE FROM Posts WHERE id=?;" id))

;; Routes
(setf (ningle:route *app* "/")
      #'(lambda (params)
	  (generate-catalog-html)))

(setf (ningle:route *app* "/" :method :POST)
      "FUCK")

(setf (ningle:route *app* "/thread/:id" :method :GET)
      #'(lambda (params)
	  (generate-thread-html (make-post-list-from-parent (parse-integer (cdr (assoc :id params)))))))

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
