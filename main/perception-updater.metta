!(bind! &envSpace (new-space))
!(bind! &percepta (new-space))
!(bind! &cache (new-space))
;; what does the agent perceive ?
;; inspired by rocca it is going to receive time-stamped observations.
(: Perception Type)
(: EnvObject Type)
(: envOject (-> Expression EnvObject))
(: perception (-> Number Expression Perception))

;; adds perceptions in the percepta space after 
;; checking defensively if the perceptions are empty
(= (addPerceptions $space $perceptions)
    (if (== $perceptions ())
        ()
        (add-reduct $space (superpose $perceptions))
    )
)

(= (fetchMaxCycle' $expressions $min)
    (if (== $expressions ())
        $min
    
        (let* (
            (($head $tail) (decons-atom $expressions))
            ((perception $timeCycle $observation) $head)
            ($isHeadSmaller (< $timeCycle $min))
        )
            (if $isHeadSmaller (fetchMaxCycle' $tail $timeCycle) (fetchMaxCycle' $tail $min))
        )
    )

)
(= (fetchMaxCycle $space)
    (let $expressions (collapse (get-atoms $space))
        (fetchMaxCycle' $expressions -1) ;; the -1 here is below the lower bound for timecycles. Since
                                        ;; they are positive values.
    )
)


(= (perceptionUpdater $envSpace $percepta $maxCycles)
    (if (> $maxCycles 0)
        (let* (

            

        )
        )
    )


)

