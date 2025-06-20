!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)

!(import! &self hyperon-openpsi:main:mind-agents:action-planner:action-planner-v2)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

!(bind! sleep (py-atom time.sleep))

(= (ping) (let $t (sleep 1)  (println! (Just ball is pinged))))


(= (pong) 
    (let*
    
        (
            ($t (sleep 1))
            ($du (decrease-urge (ball is ponged) 1 &self))
            ; ($txt (ball is ponged))
        ) 
            (println! (Just ball is ponged))
    )
)

(= (pong-step) 
    (let*
    
        (
            ($t (sleep 1))
            ($urge (urge-value (ball is ponged) &self))
        ) 

        (if (< $urge 0.7)
            (let $p (println! (Not yet feeling like ponging the ball. Urge = $urge))
            (increase-urge (ball is ponged) 0.2 &self))
            
            (let* 
                (
                ($p (println! (Feeling like ponging the ball. Urge = $urge)))
                ($inc (increase-urge (ball is ponged) 0.2 &self))
                )
                (pong)
                
            )
        )
    )
)

(= (pong-step-loop)
    (let $urge (urge-value (ball is ponged) &self)
        
        (if (< $urge 0.7)
            (let $ps (pong-step) (pong-step-loop)) ; recursively call until urge >= 0.7
            (pong-step) ;  call to trigger pong when urge >= 0.7
        )
    )
)


!(addGoal (ball is neutral) 0.0 1.0 &self)
!(addGoal (ball is pinged) 0.0 1.0 &self)
!(addGoal (ball is ponged) 1.0 1.0 &self)


;; One cycle 
; !(addRule r1 ((ball is neutral)) (ping) (ball is pinged) (TTV 0 (STV 1.0 1.0)))
; !(addRule r2 ((ball is pinged)) (pong-step-loop) (ball is ponged) (TTV 0 (STV 1.0 1.0)))
; !(addRule r3 ((ball is ponged)) (ping) (ball is pinged) (TTV 0 (STV 1.0 1.0)))

;; To continously play ping pong without stop 
; (= (loop)
;     (let*
;     (
;        ($r1 (addRule r1 ((ball is neutral)) (ping) (ball is pinged) (TTV 0 (STV 1.0 1.0))))
;        ($r2 (addRule r2 ((ball is pinged)) (pong-step-loop) (ball is ponged) (TTV 0 (STV 1.0 1.0))))
;     )
;         (loop)
;     )
; )

; !(loop)

; qoute the actions for the planner
!(addRule r1 ((ball is neutral))  (quote (ping)) (ball is pinged) (TTV 0 (STV 1.0 1.0)))
!(addRule r2 ((ball is pinged))  (quote (pong-step-loop)) (ball is ponged) (TTV 0 (STV 1.0 1.0)))
!(addRule r3 ((ball is ponged))  (quote (ping)) (ball is pinged) (TTV 0 (STV 1.0 1.0)))


!(planner: (hillClimbingPlanner  (ball is neutral) (ball is ponged) (TestedActions) () &self))


; to see the actions step
!(ping)
!(pong-step-loop)





