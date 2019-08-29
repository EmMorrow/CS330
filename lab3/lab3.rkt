#lang racket

(define (check-temps1 temps)
  (andmap (lambda (i) (and (> i 4) (< i 96))) temps))
 
(define (check-temps temps low high)
  (andmap (lambda (i) (and (> i (- low 1)) (< i (+ high 1)))) temps))

(define (duple lst)
  (map (lambda (i) (list i i)) lst))

(define (average lst)
  (/ (foldr + 0 lst) (length lst)))

(define (convertFC temps)
  (map (lambda (i) (* (- i 32) 5/9))
       temps))

(define (get-rid item lst)
  (if (empty? lst)
      true
      (if (> item (first lst))
          false
          (get-rid item (rest lst)))))

(define (convert digits)
  (define pow .1)
  (exact-round (foldl + 0 (map (lambda (i)
         (set! pow (* pow 10))
         (* i pow)) digits))))

(define (curry2 func)
  (lambda (x)
    (lambda (y)
      (func x y))))

      
(define (eliminate-larger lst)
  (foldr (lambda (x nums)
           (if (get-rid x nums)
               (append (list x) nums)
               nums))
         empty lst))





#|(convertFC (list 32 50 212))
(duple (list 1 2 3))
(average (list 1 2 3))
(check-temps1 (list 6 7 94))
(check-temps (list 5 7 96) 5 96)
((curry2 funcs) 1 2)
|#







  
      
  
 
  
  