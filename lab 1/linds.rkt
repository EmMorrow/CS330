#lang slideshow
(define c (circle 10))
(define r (rectangle 10 20))
(define (sum-coins pennies nickels dimes quarters)
  (define nAmount (* nickels 5))
  (define dAmount (* dimes 10))
  (define qAmount (* quarters 25))
  (+ pennies nAmount dAmount qAmount))
(define (degrees-to-radians angle)
  (define conversion (/ pi 180))
  (* angle conversion))
(define (sign x)
  (cond
    [(positive? x) 1]
    [(zero? x) 0]
    [(negative? x) -1]))
(define (new-sin angle type)
  (if (symbol=? type 'degrees) (sin (degrees-to-radians angle)) (sin angle)))