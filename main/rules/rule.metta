!(bind! &psiRules (new-space))

(= (FALSE_TV) (False (STV 0.0 1.0))) ;False, with Maximum confidence
(= (TRUE_TV) (True (STV 1.0 1.0))) ;True, with Maximum confidence

(= (PsiRules) &psiRules)

(: addAndLink (-> Atom Symbol Atom))
(= (addAndLink $context $action)
   (let $res 
        (collapse (match &self (AND_LINK ($context $action)) (AND_LINK ($context $action))))
        (if (not (== $res ()))
          (car-atom $res)
          (let () (add-atom &self (AND_LINK ($context $action))) (AND_LINK ($context $action)))
        )
     )
)

(: addRuleLink (-> Symbol Expression Symbol Symbol Expression))
(= (addRuleLink $handle $context $action $goal)
   (let*
     (
      ($andLink (addAndLink $context $action))
      ($rule (collapse (match &self (: $handle (IMPLICATION_LINK $andLink $goal)) (: $handle (IMPLICATION_LINK $andLink $goal)))))
    )
      (if (not (== $rule ())) 
            ($andLink (car-atom $rule)) 
            (
              let* (
                    ($newRule (: $handle (IMPLICATION_LINK $andLink $goal)))
                    ($_ (add-atom &self $newRule))
                  )
                    ($andLink $rule)
            )
      )
     )
)

(: existsIn Grounded Atom Bool)
(= (existsIn $space $atom)
   ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) )
)

(: addRule (-> Symbol Atom Symbol Symbol Atom Atom))
(= (addRule $ruleHandle $context $action $goal $tv)
    (let* (
              (($andLink $rule) (addRuleLink $ruleHandle $context $action $goal))
              ($exists (existsIn (PsiRules) $rule))
            )
              (if $exists 
                  (: $ruleHandle (getRuleType $ruleHandle))
                  (
                    let* (
                          ($newRule (: $ruleHandle (IMPLICATION_LINK $andLink $goal)))
                          ($_ (let $res (getRuleType $ruleHandle) (if (not (== (len $res) 2)) ; Important to avoid adding another $tv to $ruleHandle as type.
                                                                    (add-atom (PsiRules) (: $ruleHandle $tv))
                                                                    ;(println! (tv already added)) ;TODO: decide what happens in this case.
                                                                    ()
                                                                   )))
                          ($_ (add-atom &self (isExecuted $ruleHandle (FALSE_TV))))
                          (() (update-atom (PsiRules) $rule $newRule))
                        )
                        (: $ruleHandle (getRuleType $ruleHandle))
                  )
                )
    )
)
 
(: getAction (-> Atom Atom))
(= (getAction $rule) 
   (
    case (getRuleType $rule) 
      (
        (((TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $action)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal) (TTV $timestamp $stv)) $action)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $action )
        ($_ %Undefined%)
      )
   )
)

(: getGoal (-> Atom Atom))
(= (getGoal $rule)  
  ( 
   case (getRuleType $rule) 
    (
      (((TTV $timestamp $stv) (IMPLICATION_LINK $andLink $goal)) $goal)
      (((IMPLICATION_LINK $andLink $goal) (TTV $timestamp $stv)) $goal)
      (((IMPLICATION_LINK $andLink $goal)) $goal )
      ($_ %Undefined%)
    )
   )
)

(: getContext (-> Atom Atom))
(= (getContext $rule)
   (
    case (getRuleType $rule) 
      (
        (((TTV $timestamp $stv) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $context)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal) (TTV $timestamp $stv)) $context)
        (((IMPLICATION_LINK (AND_LINK ($context $action)) $goal)) $context )
        ($_ %Undefined%)
      )

    )
)


(: getRuleType (-> Atom Atom))
(= (getRuleType $id) (collapse (get-type-space &psiRules $id)))

(: getTV (-> Atom Atom))
(= (getTV $id) 
   (
    case (getRuleType $id)
    (
      (((TTV $timestamp $stv) $link) (TTV $timestamp $stv))
      (($link (TTV $timestamp $stv)) (TTV $timestamp $stv))
      ($_ (TTV 0 (STV 0.0 0.0))) ;default case
    )
  )
)


;(: x (Goal $value $dgv))
(: addGoalHelper (-> Symbol Number Number Atom))
(= (addGoalHelper $name $value $dgv)
   (if (and (isGvValid $value) (isGvValid $dgv)) 
      (if (not (existsIn &self $name))
          (let () 
              (add-atom &self (: $name (Goal $value $dgv))) 
              $name
          )
          (Goal With Id $name Already Exists)
        )
      (Invalid goal/dgv Value) 
    )
)

(: isGvValid (-> Number Bool))
(= (isGvValid $value)
   (and (>= $value 0.0) (<= $value 1.0))
   )

;This function accepts an optional third argument,
;dgv(desiredGoalValue), if () is passed then a default value of 1.0 is used.
;Returns the symbol representing the added goal.
(: addGoal (-> Atom Number Atom Atom))
(= (addGoal $name $value $dgv)
   (if (== () $dgv) 
      (addGoalHelper $name $value 1.0) 
      (addGoalHelper $name $value $dgv)
    )
   )

(: setGv (-> Symbol Number (->)))
(= (setGv $goal $value)
   (if (not (existsIn &self $goal))
          (Invalid Goal Id)
          (let (Goal $oldGv $oldDgv) (get-type $goal) 
              (update-atom &self (: $goal (Goal $oldGv $oldDgv)) (: $goal (Goal $value $oldDgv)))
              )
    )
   )

(: setDgv (-> Symbol Number (->)))
(= (setDgv $goal $value)
   (if (not (existsIn &self $goal))
          (Invalid Goal Id)
          (let (Goal $oldGv $oldDgv) (get-type $goal) 
              (update-atom &self (: $goal (Goal $oldGv $oldDgv)) (: $goal (Goal $oldGv $value)))
              )
    )
   )

