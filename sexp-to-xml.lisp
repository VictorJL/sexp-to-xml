(defvar *output*)
(defvar *indent*)

(defun format-tag (symbol &optional arg)
  (cond
    ((equal arg 'begin)
     (format nil "~{~a~}<~(~a~)>~%" *indent* symbol))
    ((equal arg 'end)
     (format nil "~{~a~}<~(/~a~)>~%" *indent* symbol))
    (t
     (format nil "~{~a~}~a~%" *indent* symbol))))

(defun sexp-to-xml--inside-tag (sexp)
  (if sexp
      (if (listp (car sexp))
          (progn
            (sexp-to-xml--new-tag (car sexp))
            (sexp-to-xml--inside-tag (cdr sexp)))
          (progn
            (push (format-tag
                   (string (car sexp)))
                  *output*)
            (sexp-to-xml--inside-tag (cdr sexp))))))

(defun sexp-to-xml--new-tag (sexp)
  (push (format-tag (car sexp) 'begin)
        *output*)
  (let ((*indent* (cons "  " *indent*)))
   (sexp-to-xml--inside-tag (cdr sexp)))
  (push (format-tag (car sexp) 'end)
        *output*))

(defun sexp-to-xml (&rest sexps)
  (apply #'concatenate 'string
         (apply #'concatenate 'list
                         (loop for sexp in sexps collecting
                              (let ((*output* nil)
                                    (*indent* nil))
                                (reverse (sexp-to-xml--new-tag sexp)))))))


(defmacro sexp-to-xml! (&rest sexps)
  `(sexp-to-xml ,@(loop for sexp in sexps collecting
                       `(quote ,sexp))))
