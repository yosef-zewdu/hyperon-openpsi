 
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


;How are goal and demand are related?
  ;Demand -> Ubergoal (higher level goal) -> Goal
  ;Ubergoal values are derived from tv of their correspoding Demand
  ;Ubergoals are automatically goals, they are related to Goals with STI

  ;motive selection steps:
  ; 1. choose the most dominant demand
  ; 2. choose the most important uberGoal, based on a higher STI
  ; 3. choose the goal that has the strongest connection to the dominant uberGoal as the goal
  ;planning steps:
  ; 4. prepare a list of actions that will lead to the demand being satisfied, choosing an inital goal randomly.
  ; 5. update demand values using demandUpdaterAgent.
  ;modulator and emotion computation steps:
  ; 6. compute modulator values from the demand values.
  ; 7. compute emotion states from the modulator values.

!(bind! np (py-atom numpy))
!(bind! &testedActions (new-space))

(= (TestedActions) &testedActions)

(= (hill_climbing_planner $initialState $goal $testedActions $plan $ruleSpace)
   (if (== $initialState $goal) ;if the current state is the goal, return the plan.
     $plan
     (let* (
            ($tested (getTestedActions $initialState $testedActions)) ;query tested actions for initialState.
            ($applicableActions (collapse (match $ruleSpace 
                                                 (: $handle (IMPLICATION_LINK (AND_LINK (($initialState) $action)) $g))
                                                 $action))) ;get applicable actions and.
            ($untriedActions (filterUntriedRules $applicableActions $tested () )) ;Filter out the ones that already have been tested.
            ;(() (println! ( tested --> $tested untried --> $untriedActions applicable --> $applicableActions plan --> $plan)))
          )
       (if (== $untriedActions ()) ;No untested actions, return ()
         ()
         (let* (
                ($newStates (applyActions $untriedActions $initialState () $ruleSpace)) ;Apply all actions to get new states.
                (($minDistance $bestPair) (findMinDistance $newStates $goal 1000 () $ruleSpace)) ;find the least distance among the new states.
                ($currentDistance (distance $initialState $goal $ruleSpace))
                ($bestAction (car-atom $bestPair))
                ($bestState (cadr-atom $bestPair))
                (() (println! (new-stateus (bestAction $bestAction) (appActions $newStates) (currState $initialState) (plan $plan) (currDistance $currentDistance) (minDis $minDistance))))
              )
           (if (>= $currentDistance $minDistance)
            (let () (update-atom $testedActions ($initialState $bestAction) ($bestState $bestAction)) 
              (hill_climbing_planner $bestState $goal $testedActions (cons-atom $bestAction $plan) $ruleSpace) ;recursively explore the best state
              )
              ;No improvement, mark all untried actions as tested
             (let $res (markAllTested $untriedActions $tested) ()
                  ;(println! (markAll $res))
              )
            )
          )
         )
      )
    )
   )

(= (distance $current $goal $ruleSpace)
   (- 1 (S_d (goal-value $current $ruleSpace) 
             (goal-value $goal $ruleSpace) (desired-goal-value $goal $ruleSpace) 1)) ;TODO: calculate over every demand, if necessary
   )

(= (applyActions $actions $goal $acc $ruleSpace)
   (if (== $actions ())
     $acc
     (let* (
            (($head $tail) (decons-atom $actions))
            ($res (collapse (match $ruleSpace (: $handle (IMPLICATION_LINK (AND_LINK (($goal) $head)) $g) ) ($head $g))))
            ($rest (applyActions $tail $goal (concatTuple $res $acc) $ruleSpace))
            (() (println! (appAc $res $rest)))
          )
       (if (== $head ())
         (concatTuple $acc $res)
         $rest
         )
      )
     )
   )

(= (fuzzy_equal $x $t $a)
    (/ 1
        (+ 1
            (* $a (*(- $x $t) (- $x $t)))
        )  
    )     
)

(= (S_d $current $min_l $max_l $alpha)
   (if(< $current $min_l)
     (fuzzy_equal $current $min_l $alpha)
     (if (> $current $max_l)
      (+ 0.9 (* ((py-dot np random.random)) 0.1))
      (+ 0.8 (* ((py-dot np random.random)) 0.2))
       )
     )
    )
   
(= (filterUntriedRules $actions $tested $acc)
     (if (== $actions ())
      $acc
      (let ($head $tail) (decons-atom $actions)
        (if (isMember $head $tested)
          (filterUntriedRules $tail $tested $acc)
          (filterUntriedRules $tail $tested (cons-atom $head $acc))
          )
       )
    )
   )

(= (findMinDistance $newStates $goal $minDistance $bestPair $ruleSpace)
   (if (== $newStates ())
     ($minDistance $bestPair)
     (let* (
            ((($action $state) $tail) (decons-atom $newStates))
            ($dist (distance $state $goal $ruleSpace))
            )
          (if (< $dist $minDistance)
            (findMinDistance $tail $goal $dist ($action $state) $ruleSpace)
            (findMinDistance $tail $goal $minDistance $bestPair $ruleSpace)
            )
      )
    )
   )

(= (markAllTested $actions $tested)
   (if (== $actions ())
     $tested
     (let ($head $tail) (decons-atom $actions)
       (if (isMember $head $tested)
         (markAllTested $tail $tested)
         (markAllTested $tail (cons-atom $head $tested))
         )
      )
     )
   )

(= (getTestedActions $key $space)
   (collapse (match $space ($key $action) $action))
   )
