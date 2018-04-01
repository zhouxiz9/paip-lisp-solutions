(load "auxfns.lisp")
(load "tests.lisp")
(load "ops.lisp")

(defvar *visited* nil)

(defun GPS (start-state-actions goals ops)
  (let ((start-state (first start-state-actions))
        (start-actions (second start-state-actions)))
    (cond ((visited-p start-state) nil)
        ((achieve-all start-state goals) start-actions)
        (t (progn (setf *visited* (union *visited* (list start-state)))
                  (let ((next-state-list (apply-op start-state start-actions ops)))
                    (if (null next-state-list) nil
                        (some #'(lambda (state) (GPS state goals ops)) next-state-list))))))))   
  

(defun visited-p (state)
  (some #'(lambda (visited-state) (equal-sets visited-state state)) *visited*))

(defun achieve-all (state goals)
  (every #'(lambda (goal) (member goal state)) goals))

(defun equal-sets (x y)
  (and (every #'(lambda (item) (member item y)) x)
       (every #'(lambda (item) (member item x)) y)))

;; return a list of state that results from applying operation on the given state
(defun apply-op (state actions ops)
  (cond ((null ops) nil)
        
        ((every #'(lambda (precond) (member precond state)) (op-preconds (first ops)))
         
         (let* ((op (first ops))
                (next-state (union (op-add-list op) (set-difference state (op-del-list op))))
                (next-actions (append actions (list (op-action op)))))
           (append (list (list next-state next-actions))
                   (apply-op state actions (rest ops)))))
        
        (t (apply-op state actions (rest ops)))))


(run-tests #'GPS *ops*)