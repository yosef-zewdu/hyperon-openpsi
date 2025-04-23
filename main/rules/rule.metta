!(bind! &psiRules (new-space))

(= (PsiRules) &psiRules)

(: addLink (-> Symbol Symbol Expression Symbol Atom))
(= (addLink $handle $linkType $andLink $goal)
   (let*
     (
      ($rule (collapse (match &self (: $handle ($linkType $andLink $goal)) (: $handle ($linkType $andLink $goal)))))
      ($condition (== (len $rule) 0))
    )
      (if $condition 
            (
              let* (
                    ($newRule (: $handle ($linkType $andLink $goal)))
                    ($_ (add-atom &self $newRule))
                  )
                    $newRule
            )
            (car-atom $rule) 
      )
     )
)

(: existsIn Grounded Atom Atom)
(= (existsIn $space $atom)
   ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) )
)

(: addRule (-> Symbol Expression Symbol Expression Atom))
(= (addRule $ruleHandle $andLink $goal $tv)
    (let* (
              ($rule (addLink $ruleHandle IMPLICATION_LINK $andLink $goal))
              ($exists (existsIn (PsiRules) $rule))
            )
              (if $exists 
                  (: $ruleHandle (getRuleType $ruleHandle))
                  (
                    let* (
                          ($newRule (: $ruleHandle (IMPLICATION_LINK $andLink $goal)))
                          ($_ (add-atom (PsiRules) (: $ruleHandle $tv)))
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

