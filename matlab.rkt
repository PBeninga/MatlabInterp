#lang typed/racket
(require typed/rackunit)

; Value definition
(define-type Value (U Number Null Boolean Symbol String Matrix))
(define-type-alias Matrix (Listof (Listof Number)))
; ExprM definition
(define-type ExprM (U ValM SetM))
(struct ValM ([v : Value]) #:transparent)
(struct IDM ([id : Symbol]) #:transparent)
(struct SetM ([id : Symbol] [fresh : ExprM]) #:transparent)
(struct MatOpM ([matA : Matrix] [matB : Matrix]) #:transparent)
; Environment definition
(define-type-alias Environment (Listof Binding))
(struct Binding ([id : Symbol] [v : Value]) #:transparent)


; top-env function
; creates a fresh top-env every call
(define (top-env) : Environment
  (list (Binding 'true #t) (Binding 'false #f) (Binding 'null '())))


; lookup function
; get the value of a symbol from the environment
(define (lookup [id : Symbol] [env : Environment]) : Value
  (begin (define curbind (first env))
         (if (empty? env)
             (error "Matterp: No value found for this identifier.")
             (if (equal? (Binding-id curbind) id)
                 (Binding-v curbind)
                 (lookup id (rest env))))))


; interp function
; takes in an AST for a MatLab program
; returns a value for the interpreted program
(define (interp [exp : ExprM] [env : Environment]) : Value
  (match exp
    [(ValM v) v]
    [(IDM id) (lookup id env)]
    [(SetM id fresh) ()]
    [(MatOpM m) ]))