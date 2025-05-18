!(bind! &envSpace (new-space))
!(bind! &percepta (new-space))
!(bind! &cache (new-space))
;; what does the agent perceive ?
;; inspired by rocca it is going to receive time-stamped observations.
(: Perception Type)
;; (: perception (-> Number Expression Perception))


(= (remove-atoms' $space $expression)
    (if (== $expression ())
        ()
        (let* (
            (($head $tail) (decons-atom $expression))
            ($_ (remove-atom $space $head))
        )
            (remove-atoms' $space $tail)
        )
    )
)
(= (remove-atoms $space)
    (let $atoms (collapse (get-atoms $space))
        (remove-atoms' $space $atoms)
    )
)

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
            ($isHeadLarger (> $timeCycle $min))
        )
            (if $isHeadLarger (fetchMaxCycle' $tail $timeCycle) (fetchMaxCycle' $tail $min))
        )
    )

)
(= (fetchMaxCycle $space)
    (let $expressions (collapse (get-atoms $space))
        (fetchMaxCycle' $expressions 0) ;; the -1 here is below the lower bound for timecycles. Since
                                        ;; they are positive values.
    )
)

(= (changeToPercepta $data $timeStamp)
    (collapse (perception $timeStamp (superpose $data)))
)

(= (perceptionUpdater $cacheSpace $percepta  $max-recur)
    (if (and (> $max-recur 0) (not (== (collapse (get-atoms $cacheSpace)) ())))
        (let* (
            ($newData (collapse (get-atoms $cacheSpace)))
            ($_ (remove-atoms $cacheSpace))
            ($maxCycle (fetchMaxCycle $percepta))
            ($newPercepta ((if (== $newData ())
                                ()
                                (changeToPercepta $newData (+ $maxCycle 1))
                            ))
            )
            ($_ (addPerceptions $percepta $newPercepta))
            

        )
            (perceptionUpdater $cacheSpace $percepta (- $max-recur 1))

        )
        ()
    )


)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;          tests for perception-updater ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!(add-atom &envSpace (a b c d))
!(add-atom &envSpace (dat))
!(get-atoms &envSpace)
!(remove-atoms &envSpace)
!(get-atoms &envSpace)
!(fetchMaxCycle &percepta)

