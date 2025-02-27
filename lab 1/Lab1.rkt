#lang racket
(define (sum-coins pennies nickels dimes quarters)
  (+ pennies
     (* 5 nickels)
     (* 10 dimes)
     (* 25 quarters)))

(define (degrees-to-radians angle)
  (* angle
     (/  pi 180)))

(define (sign x)
  (if (> x 0)
      1
      (if (equal? x 0)
          0
          -1)))

(define (new-sin angle type)
  (if (symbol=? type 'degrees)
      (sin (degrees-to-radians angle))
      (sin angle)))







