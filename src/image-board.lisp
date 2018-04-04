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

(defun make-post-from-id (id)
  (let ((dbres (multiple-value-list (sqlite:execute-one-row-m-v *db* "SELECT * FROM Posts WHERE id=?;" id))))
    (apply #'make-post-boa dbres)))

(defun make-post-list-from-parent (id)
  (let ((thread-list (sqlite:execute-to-list *db* "SELECT * FROM Posts WHERE parent=? OR id=?;" id id)))
    (mapcar #'(lambda (l) (apply #'make-post-boa l)) thread-list)))

;; creating html
(defun generate-error-html (error-string)
  "Generate a HTML page signalling an error"
  (format nil "<h1>Error: ~A</h1>" error-string))

(defun generate-post-html-div (a-post)
  "Generate a HTML string from a post struct"
  (concatenate 'string
	       "<div>"
	       (format nil "<h3>~D ~A<br>~A</h3>" (post-id a-post) (post-name a-post) "PLACEHOLDER DATE")
	       (format nil "<p>~A</p>" (regex-replace-all "\\n" (post-message a-post) "<br>"))
	       "</div>"))

(defun generate-thread-html (id)
  "Generate a HTML page from a thread id" 
  (apply #'concatenate 'string (mapcar #'generate-post-html-div (make-post-list-from-parent id))))

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
