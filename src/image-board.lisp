(declaim (optimize (debug 3)))
(in-package :bored)

(defvar *db* (sqlite:connect "/Users/tom/code/lisp/bored/posts.db"))
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
  (sqlite:execute-non-query *db* "DELETE FROM Posts WHERE id=?;" id))

