(declaim (optimize (debug 3)))
(defpackage :image-board
  (:use :cl :ningle :sqlite :cl-ppcre)
  (:export :*app*))
(in-package :image-board)

(defconstant +HTML-STRING+
"<html>
    <head>
	<meta charset=\"UTF-8\"> 
	<title>Image Board</title>
	<style>
	 @import url('https://fonts.googleapis.com/css?family=PT+Mono');
	 body {
	     /*background: url('file:///Users/tom/code/lisp/image-board/html/bg.png');*/
             background: grey;
	 }
	 div {
	     max-width: 400px;
	     background: white;
	     padding: 10px;
	     margin-bottom: 10px;
	 }

	 h3 {
	     font-family: 'PT Mono', monospace;
	     font-size: 17;
	     margin-top: 0px;
	     margin-bottom: 0px;
	 }

	 p {
	     margin-top: 5px;
	     font-family: 'PT Mono', monospace;
	     font-size: 13;
	 }

         a {
	     font-family: 'PT Mono', monospace;
             text-decoration: none;
             color: black;
         }

	 form {
	     margin-bottom: 0px;
	 }

	 input.message-box {
	     font-family: 'PT Mono', monospace;
	     font-size: 13;
	     width: 400px;
	 }

	 input.submit-button {
	     background: white;
	     border: 5px;
	     border-color: black;
	     text-align: center;
	     font-family: 'PT Mono', monospace;
	     font-size: 13;
	 }

	</style>
    </head>
    <body>
        ~A
        <div>
	<form class=\"postbox\" method=\"post\">
	    <input type=\"textarea\" name=\"name\" class=\"name-box\" autocomplete=\"off\" />
	    <input type=\"submit\" class=\"submit-button\" value=\"Post\" />
	    <input type=\"textarea\" name=\"message\" class=\"message-box\" autocomplete=\"off\" />
	</form>
        </div>
    </body>
</html>")

;; creating html
(defun surround-with-html-preamble (str)
  (format nil +HTML-STRING+ str))

(defun generate-error-html (error-string)
  "Generate a HTML page signalling an error"
  (format nil "<h1>Error: ~A</h1>" error-string))

(defun generate-post-html-div (a-post)
  "Generate a HTML string from a post struct"
  (concatenate 'string
	       "<div>"
	       (format nil "<h3>~D ~A<br>~A</h3>" (post-id a-post) (post-name a-post) (post-time a-post))
	       (format nil "<p>~A</p>" (regex-replace-all "\\n" (post-message a-post) "<br>"))
	       (format nil "<u><a href=\"/delete/~D\">delete</a></u> " (post-id a-post))
	       (if (equalp nil (post-parent a-post)) (format nil "<u><a href=/thread/~A>view thread</a></u>" (post-id a-post)))
	       "</div>"))

(defun generate-thread-html (list-of-posts)
  "Generate a HTML page from a list of posts" 
  (surround-with-html-preamble (apply #'concatenate 'string (mapcar #'generate-post-html-div list-of-posts))))

;; todo generate proper catalog
(defun generate-catalog-html ()
  (surround-with-html-preamble
   (generate-thread-html (make-catalog-list))))
