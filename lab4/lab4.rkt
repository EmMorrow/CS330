#lang racket
(define (default-parms f values)
  (lambda args
    (apply f (append args
                     (list-tail values
                                (length args))))))

(define (correct-types types values)
  (if (and (empty? types) (empty? values))
      #t
      (if (not ((first types) (first values)))
          #f
          (correct-types (rest types) (rest values)))))
      
(define (type-parms f types)
  (lambda args
    (if (correct-types types args)
        (apply f args)
        (error "ERROR MSG"))))

(define (degrees-to-radians angle)
  (* angle
     (/  pi 180)))

(define (new-sin angle type)
  (if (symbol=? type 'degrees)
      (sin (degrees-to-radians angle))
      (sin angle)))


(define new-sin2 (default-parms
                   (type-parms
                    new-sin
                    (list number? symbol?))
                   (list 0 'radians)))
  
