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
!(bind! &psiCache (new-space))

;a function that accepts an operator and a list of operands and performs
;the operand on them.

(= (addLink $handle $linkType $link)
   (let*
     (
      ($rule (collapse (match &psiRules (: $handle ($linkType $link)) ($linkType $link) )))
      ($condition (== (len $rule) 0))
    )
      (if $condition 
            (
              let* (
                    ($newRule (: $handle ($linkType $link)))
                    ($_ (add-atom &psiRules $newRule))
                  )
                    $newRule
            )
            (car-atom $rule) 
      )
     )
)

(= (existsIn $space $atom)
   (let $res (collapse (match $space $atom $atom)) (not (== (len $res) 0))) 
)

(= (addAndLink $handle $contextTuple $action)
   (
    let* (
            ($andLink (: $handle (AND_LINK (concatTuple ($action) $contextTuple ))))
            ($_ (add-atom &psiRules $andLink))
          )
          (get-type-space &psiRules $andLink)
    )
)

(= (addRule $ruleHandle $andLink $goal $tv)
    (let* (
              ($rule (addLink $ruleHandle IMPLICATION_LINK ((get-type-space &psiRules $andLink) $goal)))
              ($exists (existsIn &psiRules $rule));check if rule exists in cache
            )
              (if $exists 
                  $rule
                  (
                    let* (
                          ($newRule (: $ruleHandle ($rule $tv)))
                          (() (update-atom &psiRules $rule $newRule))
                        )
                        $newRule
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
        (((IMPLICATION_LINK (AND_LINK ($context $action)) goal) (TTV $timestamp $stv)) $action)
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
        (((IMPLICATION_LINK (AND_LINK ($context $action)) goal) (TTV $timestamp $stv)) $context)
        ($_ default-context)
      )

    )
)


(: getRuleType (-> Atom Atom))
(= (getRuleType $id) (collapse (get-type-space &psiRules $id)))

(= (mkRule $id $andLink $goal) 
   (
      let $output (collapse (get-type-space &psiRules $id)) 
      (
        if(== $output (%Undefined%))
          (let $_ (add-atom &psiRules (: $id (IMPLICATION_LINK $andLink $goal))) (atom with id -> $id added))
          (
            case $output 
              (
                (((TTV $timestamp $stv)) (add-atom &psiRules (: $id (IMPLICATION_LINK $andLink $goal))))
                (((IMPLICATION_LINK $prevAndLink $prevGoal)) (update-atom &psiRules (: $id (IMPLICATION_LINK $prevAndLink $prevGoal)) (: $id (IMPLICATION_LINK $andLink $goal))))
                (((TTV $timestamp $stv) (IMPLICATION_LINK $prevAndLink $prevGoal)) (update-atom &psiRules (: $id (IMPLICATION_LINK $prevAndLink $prevGoal)) (: $id ((IMPLICATION_LINK $andLink $goal) (TTV $timestamp $stv)))))
                (((IMPLICATION_LINK $prevAndLink $prevGoal)(TTV $timestamp $stv)) (update-atom &psiRules (: $id (IMPLICATION_LINK $prevAndLink $prevGoal)) (: $id ((IMPLICATION_LINK $andLink $goal) (TTV $timestamp $stv)))))
              )
          )
      )
    )
)

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

(= (setTV $id $timestamp $tv)
   (
    let $output (getRuleType $id)
    (
     if(== $output (%Undefined%))
      (let $_ (: $id (TTV $timestamp $tv)))
      (
       case $output 
        (
          (((TTV $prevTimestamp $prevTV)) (update-atom &psiRules (: $id (TTV $prevTimestamp $prevTV)) (: $id (TTV $timestamp $tv))))
          (((IMPLICATION_LINK $prevAndLink $prevGoal)) (add-atom &psiRules (: $id (TTV $timestamp $tv))))
          (((TTV $prevTimestamp $prevTV) (IMPLICATION_LINK $prevAndLink $prevGoal)) (update-atom &psiRules (: $id (TTV $prevTimestamp $prevTV)) (: $id (TTV $timestamp $tv))))
          (((IMPLICATION_LINK $prevAndLink $prevGoal)(TTV $prevTimestamp $prevTV)) (update-atom &psiRules (: $id (IMPLICATION_LINK $prevAndLink $prevGoal)) (: $id ((IMPLICATION_LINK $andLink $goal) (TTV $timestamp $stv)))))
        )
       )
     )
    )
)

;;; tests

;!(addAndLink and1 (c1 c2) workout)
;!(addRule rule1 (addAndLink and1 (c1 c2) workout) bulk (TTV 1 (STV 1.0 1.0)))
!(add-atom &psiRules (: Rule1 (TTV 1 (STV 0.0 0.0))))
!(mkRule rule1 (AND_LINK ((c1 c2) action)) bulk)
!(mkRule Rule1 (AND_LINK ((c1 c2) action)) bulk)
!(getRuleType Rule1)

!(getTV Rule1)
!(getTV rule1)

!(getGoal Rule1)
!(getGoal rule1)

!(getAction Rule1)
!(getAction rule1)

!(getContext Rule1)
!(getContext rule1)
