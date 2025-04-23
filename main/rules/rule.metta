(= (len $expr)
    (if (== $expr ())
        0
        (let $tail (cdr-atom $expr)
            (+ 1 (len $tail))
        )
    )
)

(: update-atom (-> Grounded Atom Atom (->)))
(= (update-atom $space $oatom $natom) (let $_ (remove-atom $space $oatom) (add-atom $space $natom)))

(= (concatTuple $xs $ys)
    (if (== $xs ())
        $ys
        (let* ( 
                ($head (car-atom $xs))
                ($tail (cdr-atom $xs))
                ($tailNew (concatTuple $tail $ys))
              )
            (cons-atom $head $tailNew)
        )
    )
)

!(bind! &psiRules (new-space))

(= (PsiRules) &psiRules)

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

(= (existsIn $space $atom)
   ( let $res (collapse (get-type-space $space $atom)) (not (== (%Undefined%) $res)) )
)

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
        ($_ default-action)
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
      ($_ default-goal)
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
        ($_ default-context)
      )

    )
)


(: getRuleType (-> Atom Atom))
(= (getRuleType $id) (collapse (get-type-space &psiRules $id)))

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

;;; tests

!(addRule x (AND_LINK ((x1 x2) y)) z (TTV 1 (STV 11.0 11.0)))
!(getContext x)
!(getAction x)
!(getGoal x)
!(getTV x)

!(addRule x (AND_LINK ((x1 x2) y)) z (TTV 1 (STV 11.0 11.0)))
