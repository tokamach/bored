;; (declaim (optimize (debug 3)))
(in-package :bored)

(defparameter +HTML-STRING+
"<html>
    <head>
	<meta charset=\"UTF-8\"> 
	<title>Bored</title>
	<style>
	 @import url('https://fonts.googleapis.com/css?family=PT+Mono');
	 body {
	     background: url('/asset/bg.png');
             /*background: grey;*/
	 }
	 div.post-container {
	     max-width: 400px;
	     background: white;
	     padding: 10px;
             margin: auto;
	     margin-bottom: 10px;
          /* height: -moz-fit-content */
             display: flow-root;
	 }

	 img.post-image {
	     float: left;
	     max-height: 255px;
	     max-width: 255px;
	     margin-right: 15px; 
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

	 textarea.message-box {
	     font-family: 'PT Mono', monospace;
	     font-size: 13;
	     width: 400px;
	     max-width: 400px;
             resize: vertical;
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
        <div>
        ~A
        </div>
    </body>
</html>")

(defun convert-universal-to-timestamp (time)
  (multiple-value-bind
	(second minute hour day month year)
      (decode-universal-time time)
    (format nil "~A-~A-~D ~A:~A:~A" year month day hour minute second)))

;; creating html
(defun surround-with-html-preamble (str)
  (format nil +HTML-STRING+ str))

(defun generate-error-html (error-string)
  "Generate a HTML page signalling an error"
  (format nil "<h1>Error: ~A</h1>" error-string))

(defun generate-post-html (a-post)
  "Generate a HTML string from a post struct"
  (concatenate 'string
	       "<div class=\"post-container\">"
	       (format nil "<h3>~D ~A<br>~A</h3>"
		       (post-id a-post)
		       (post-name a-post)
		       (convert-universal-to-timestamp (parse-integer (post-time a-post))))
	       (format nil "<p>~A</p>" (regex-replace-all "\\n" (post-message a-post) "<br>"))
	       (format nil "<u><a href=\"/delete/~D\">delete</a></u> " (post-id a-post))
	       (if (equalp nil (post-parent a-post)) (format nil "<u><a href=/thread/~A>view thread</a></u>" (post-id a-post)))
	       "</div>"))

(defun generate-thread-html (list-of-posts)
  "Generate a HTML page from a list of posts" 
  (surround-with-html-preamble
   (concatenate 'string
		(apply #'concatenate 'string (mapcar #'generate-post-html list-of-posts))
                "<div class=\"post-container\">
                     <form class=\"postbox\" method=\"post\">
                         <input type=\"textarea\" name=\"name\" class=\"name-box\" autocomplete=\"off\" />
                         <input type=\"submit\" class=\"submit-button\" value=\"Post\" />
                         <textarea rows=\"10\" name=\"message\" class=\"message-box\" autocomplete=\"off\"></textarea>
                     </form>
                 </div>")))

;; todo generate proper catalog
(defun generate-catalog-html ()
  (surround-with-html-preamble 
   (let ((catl (make-catalog-list)))
     (concatenate 'string
		  (apply #'concatenate 'string (mapcar #'generate-post-html catl))
		  "<div class=\"post-container\">
                       <form class=\"postbox\" method=\"post\" action=\"/create/\">
                           <input type=\"textarea\" name=\"name\" class=\"name-box\" autocomplete=\"off\" />
                           <input type=\"submit\" class=\"submit-button\" value=\"make new thread\" />
                           <textarea rows=\"10\" name=\"message\" class=\"message-box\" autocomplete=\"off\"></textarea>
                       </form>
                   </div>"))))
