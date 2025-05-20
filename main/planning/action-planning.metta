 
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
!(bind! &ruleSpace (new-space))
(= (weightRule $rule)
    (random-float 0 1)
)

(= (addRulesToSpace $space)
    (add-reduct $space (superpose (
            ;;  ((: x ((TTV 1 (STV 0.7 0.6)) (IMPLICATION_LINK (AND_LINK ((Goal init 0.9 0.6) act1)) (Goal g 1.0 1.0)))) 3)
            ;;  ((: y ((TTV 1 (STV 0.6 0.5)) (IMPLICATION_LINK (AND_LINK ((Goal g 0.9 0.6) act1)) (Goal g1 1.0 1.0)))) 4)
            ;;  ((: r1 ((TTV 1 (STV 0.8 0.7)) 
            ;;         (IMPLICATION_LINK 
            ;;         (AND_LINK ((Goal init 0.9 0.6) explore)) 
            ;;         (Goal found_target 1.0 1.0)))) 2)
            ;; ((: r2 ((TTV 1 (STV 0.75 0.65)) 
            ;;     (IMPLICATION_LINK 
            ;;     (AND_LINK ((Goal found_target 0.95 0.7) approach)) 
            ;;     (Goal near_target 1.0 1.0)))) 3)
            ;; ((: r3 ((TTV 1 (STV 0.7 0.6)) 
            ;;     (IMPLICATION_LINK 
            ;;     (AND_LINK ((Goal near_target 0.9 0.7) interact)) 
            ;;     (Goal task_done 1.0 1.0)))) 2)
            ;; ((: r4 ((TTV 1 (STV 0.65 0.6)) 
            ;;     (IMPLICATION_LINK 
            ;;     (AND_LINK ((Goal task_done 0.9 0.8) report)) 
            ;;     (Goal mission_complete 1.0 1.0)))) 10)
            ;; ((: r5 ((TTV 1 (STV 0.5 0.5)) 
            ;;     (IMPLICATION_LINK 
            ;;     (AND_LINK ((Goal init 0.8 0.5) idle)) 
            ;;     (Goal low_energy 1.0 1.0)))) 1)
                ;; r1: Start exploring
((: r1 ((TTV 1 (STV 0.8 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))) 2)

;; r2: Approach after finding target
((: r2 ((TTV 1 (STV 0.75 0.65)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal found_target 1.0 1.0) approach)) 
          (Goal near_target 1.0 1.0)))) 3)

;; r3: Interact when near
((: r3 ((TTV 1 (STV 0.7 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal near_target 1.0 1.0) interact)) 
          (Goal task_done 1.0 1.0)))) 2)

;; r4: Report task done
((: r4 ((TTV 1 (STV 0.65 0.6)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal task_done 1.0 1.0) report)) 
          (Goal mission_complete 1.0 1.0)))) 10)

;; r5: Do nothing and become low energy
((: r5 ((TTV 1 (STV 0.5 0.5)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.8 0.5) idle)) 
          (Goal low_energy 1.0 1.0)))) 1)

;; r6: Analyze after mission complete
((: r6 ((TTV 1 (STV 0.75 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal mission_complete 0.9 0.7) analyze)) 
          (Goal analyze_data 1.0 1.0)))) 4)

;; r7: Upload results after analysis
((: r7 ((TTV 1 (STV 0.7 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal analyze_data 0.85 0.7) upload)) 
          (Goal upload_results 1.0 1.0)))) 2)

;; r8: Reboot after upload
((: r8 ((TTV 1 (STV 0.9 0.8)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal upload_results 0.95 0.75) reboot)) 
          (Goal reset_system 1.0 1.0)))) 1)

            )
        )
    )

)

(= (getWeightFromRule $rule)
    (let ($schema $weight) $rule $weight)
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
        (let $handleWithAction (findRulesWithAction &ruleSpace $currAction) ;; a temporary solution
            ((car-atom $handleWithAction) $currAction)

        )
        (let* (
            ($currRule (car-atom $rulesWithWeight))
            ($tail (cdr-atom $rulesWithWeight))
            ($weight (getWeightFromRule $currRule))
            ($ruleAction (selectActionFromRule $currRule))
            ($range (- $targetValue $weight))
        )
            (if (< $range (- $targetValue $minValue))
                (selectSingleActionHelper $tail $weight $ruleAction $targetValue)
                (selectSingleActionHelper $tail $minValue $currAction $targetValue)
            )
        )

    )
    
)

;; This functions selects a single action from a list of rules
;; That are going to be implemented in relation to a target value.
(= (selectSingleAction $rulesWithWeight $targetValue)
    (if (or (== $rulesWithWeight ()) (== $rulesWithWeight (())))
        (() ())
        (let* (
            ($head (car-atom $rulesWithWeight))
            ($action (selectActionFromRule $head))
            ($weight (getWeightFromRule $head))
        )
            (selectSingleActionHelper $rulesWithWeight $weight $action $targetValue)
        )
    )
)

;; This function might require further modification later.
(= (findRulesWithContext $space $context)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) 
    ))

)
(= (findRulesWithGoalAsContext $space $goal)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($goal $action)) $nextGoal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($goal $action)) $nextGoal))) $weight) 
    ))

)

(= (findRulesWithAction $space $action)
    (collapse (match $space ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight)
        
    ))

)
;; This function fetches rules for multiple goals given as an s-expression. 
(= (findRulesForMultipleGoals $space $goals $accum)
    (if (== $goals ())
        $accum
        (let* (
            (($head $tail) (decons-atom $goals))
            ($rules (findRulesWithGoalAsContext $space $goal))
            ($newAccum (union-atom $accum $rules))
        )  
            (findRulesForMultipleGoals $space $tail $newAccum)
        )
    )
)

(= (getDgv $goal)
    (let (Goal $name $x $y) $goal $y)
)

(= (extractGoalName $goal)
    (let (Goal $name $x $y) $goal $name)
)

(= (extractGoalFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $goal)

)

(= (extractContextFromRule $rule)
    (let ((: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $weight) $rule $context)
)
;; an implementation inspired that greedily selects 
;; an action at each step.
(= (planner $ruleSpace $initState $goal $accum)
    (if (== $initState $goal)
        (let* (
            ($initRules (findRulesWtihContext $ruleSpace $initState))
            (($initRule $initAction) (selectSingleAction $initRules (getDgv $goal)))
            ($accum' (union-atom $accum ($initAction)))    
        ) 
            $accum'
        ) ;; contains all the actions in the action selection criterion
        (let* (
            ($target (getDgv $goal))
            ($goalName (extractGoalName $goal))
            ($relatedRules (findRulesWithContext $ruleSpace $initState))
            (($rule $currAction) (selectSingleAction $relatedRules $target))
            ($accum' (if (== $currAction ()) $accum (union-atom $accum ($currAction))))
            ($goals (collapse (extractGoalFromRule (superpose $relatedRules))))
            ($_ (println! (goals $goals)))
            ($nextRules (findRulesForMultipleGoals $ruleSpace $goals ()))

            ($_ (println! (currentState $initState)))
            ($_ (println! (next Rules $nextRules)))
            ($_ (println! (goal name $goalName)))
            ($_ (println! (accumulator $accum)))
            ($_ (println! (target $target)))
            (($currRule $action) (selectSingleAction $nextRules $target))
            ($_ (println! (currRule $currRule action $action)))
            
        )
            (if (== $action ())
                (let* (
                    ($_ (println! (No more action found)))
                )
                    $accum'
                )
                (let* (
                    ($_ (println! (non-empty action)))
                    ($newAccum (union-atom $accum' ($action))) ;; accumulating actions in the action accumulator.
                    ($newState (extractGoalFromRule $currRule))         
                )
                    (planner $ruleSpace $newState $goal $newAccum)
                )
            )

        )
        



        
    )
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Tests for action Planner                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 
!(getWeightFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2))
!(getWeightFromRule ((: r2 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 3))

!(addRulesToSpace &ruleSpace)
!(selectActionFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2))
!(extractContextFromRule ((: r1 ((TTV 1 (STV 0.8 0.7)) 
                    (IMPLICATION_LINK 
                    (AND_LINK ((Goal init 0.9 0.6) explore)) 
                    (Goal found_target 1.0 1.0)))) 2))
!(getDgv (Goal first 1.0 0.3))
!(selectSingleAction (collapse (get-atoms &ruleSpace)) 10.0)
!(findRulesWithGoalAsContext &ruleSpace (Goal low_energy 1 1))
!(planner &ruleSpace (Goal init 0.9 0.6) (Goal reset_system 1.0 1.0) ())
;; !(selectSingleAction (()) 1.0)