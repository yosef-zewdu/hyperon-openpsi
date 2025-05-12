 
;; so what are the things that are known in prior
;; 1. An agent knows the current context it is in.
;; 2. An agent knows the goal it shall achieve. Should involve in some kind of searching mechanism
;; 3. There is a rule space that contains all the necessary cognitive schema. This is expected 
;; to be mined by the pattern miner.
;; 4. Since the agent knows its initial state, it will start 
;; from there and search rules that begins with the initial state.
;; 5. Hence, the agent selects the rule with the best metric.
;; 6. Then it selects the action from the rule and adds it to an accumulator.
;; 7. Then it starts from the goal as a context from the rule that is selected.
(= (weightRule $rule)
    (random-float 0 1)
)

(= (getWeightFromRule $rule)
    (let ($schema $weight) $weight)
)
;; The below function extracts an action from a cognitive schema.
;; The input will be a scalar weighted rule and returns an action. 
(= (selectActionFromRule $rule)
    (let* (
        (($schema $weight) $rule)
        ($schema (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
    )
        $action
    )
)
;; select single action from available rules. 
(= (selectSingleActionHelper $rulesWithWeight $minValue $currAction $targetValue)
    (if (== $rulesWithWeight ())
        $currAction
        (let* (
            ($currRule (car-atom $rulesWithWeight))
            ($tail (cdr-atom $rulesWithWeight))
            ($weight (getWeightFromRule $currRule))
            ($ruleAction (selectActionFromRule $rule))
            ($range (- $targetValue $weight))
        )
            (if (< $range (- $targetValue $minValue))
                (selectSingleActionHelper $tail $weight $ruleAction $targetValue)
                (selectSingleActionHelper $tail $minValue $currAction $targetValue)
            )
        )

    )
    
)

(= (planner $actionSpace $initState $goal $accum)
    (if (== $initState $goal)
        $accum ;; contains all the actions in the action selection criterion
        
    )
)
 
