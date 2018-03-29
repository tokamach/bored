(defpackage :com.tokamach.image-board
  (:use :common-lisp))

(defvar *app* (make-instance 'ningle:<app>))

(setf (ningle:route *app* "/"))
