;; Mutable variable
(define-data-var data uint u0)

;; A function that returns an input number
(define-public (print-data)
    (ok (print (var-get data)))
)


(define-public (initialize (param1 uint) (param2 uint))
 (begin
    ;; Initialization logic here
    (var-set data u5000)
    (ok true)
 )
)