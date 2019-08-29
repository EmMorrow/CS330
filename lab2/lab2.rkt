#lang racket

(define (get-rid num lst)
  (if (null? lst)
      false
      (if (> num (first lst))
          true
          (get-rid num (rest lst)))))

(define (trav-list index newlst lst)
  (if (null? lst)
      newlst
      (if (get-rid (first lst) (rest lst))
          (trav-list (+ index 1) newlst (rest lst))
          (trav-list (+ index 1) (append newlst (list (first lst))) (rest lst)))))
      
      
(define (eliminate-larger lst)
  (trav-list 0 (list) lst))

(define (check-temps1 temps)
  (if (null? temps)
      #t
      (if (> (first temps) 95)
          #f
          (if(< (first temps) 5)
             #f
             (check-temps1 (rest temps))))))


  
(define (check-temps temps low high)
  (if (null? temps)
      #t
      (if (> (first temps) high)
          #f
          (if(< (first temps) low)
             #f
             (check-temps1 (rest temps))))))

(define (help list factor num)
  (if (null? list)
      num
      (help (rest list) (* factor 10) (+ num (* factor (first list))))))

(define (convert digits)
  (help digits 1 0))


(define (duple-help result lst)
  (if (null? lst)
      result
      (duple-help (append result (list (list (first lst) (first lst)))) (rest lst))))

(define (duple lst)
  (duple-help (list) lst))

(define (avg-help num size lst)
  (if (null? lst)
      (/ num size)
      (avg-help (+ num (first lst)) (+ size 1) (rest lst))))
  
(define (average lst)
  (avg-help 0 0 lst))
  
(define (help-convert tempc temps)
  (if (null? temps)
      tempc
      (help-convert (append tempc (list (* (- (first temps) 32) 5/9))) (rest temps))))

(define (convertFC temps)
  (help-convert (list) temps))

(define (help-find lst target index)
  (if (null? lst)
      -1
      (if (equal? (first lst) target)
          index
          (help-find (rest lst) target (+ index 1)))))
  
(define (find-item lst target)
  (help-find lst target 0))

(define (get-help lst n index)
  (if (equal? n index)
      (first lst)
      (get-help (rest lst) n (+ index 1))))

(define (get-nth lst n)
  (get-help lst n 0))


(find-item (list 1 2 3 4) 3)
  
      
  
 
  
  