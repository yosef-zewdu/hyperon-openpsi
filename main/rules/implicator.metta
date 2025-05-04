!(bind! &satisfiabilityCache (new-space))

(= (changeRuleToQuery $rule)
    (let* (
            ($handle (cadr-atom $rule))
            ($queryTTV (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            ($queryTV (: $handle ((STV $bel $conf) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            
        )
        (unify $rule $queryTTV 
            $queryTTV
            (unify $rule $queryTV
                $queryTV
                (ERROR The rule doesn't exist)

            )
        )
    )
)

(= (checkSatisfier $rule $satisfiabilityCache)
    (let* (
        ($caches (collapse (get-atoms $satisfiabilityCache)))
        ($truthValues (collapse (unify $rule (superpose $caches) True False)))
        
    ) 
        (any $truthValues)
    )

)

(= (satisfy $satisfiabilityCache $rule)
    (let* ( 
        ($query (changeRuleToQuery $rule))
        ($handle (cadr-atom $rule))
    
    )
        (add-atom $satisfiabilityCache (: $handle $query))
    )
)



(= (checkSatisfiability $rule $satisfiabilityCache $ruleSpace)
    (let* ( 
        ($query (changeRuleToQuery $rule))
        ($handle (cadr-atom $rule))

    )
       (if (== (car-atom $query) ERROR)
            (FALSE_TV)
            (let* (
                ($_ (remove-atom $satisfiabilityCache (: $handle $query)))
                ($_ (satisfy $satisfiabilityCache $rule))

            )

            )

        )
    )
)

