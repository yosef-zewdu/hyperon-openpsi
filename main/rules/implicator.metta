!(register-module! ../../utilities-module)
!(register-module! ../../../hyperon-openpsi)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:rules:rule)
!(bind! &satisfiabilityCache (new-space))


;; changes the rule to the query that can match to the rule
;; hence every rule is going to be unique since the handle for 
;; every rule is going to be different.
(= (changeRuleToQuery $rule)
    (let* (
            ($handle (car-atom $rule))
            ($queryTTV ($handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            ($queryTV ($handle ((STV $bel $conf) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            
        )
        (unify (quote $rule) (quote $queryTTV)
            ($handle ((TTV $time' (STV $bel' $conf')) (IMPLICATION_LINK (AND_LINK ($context' $action')) $goal')))
            (unify (quote $rule) (quote $queryTV)
                ($handle ((STV $bel' $conf') (IMPLICATION_LINK (AND_LINK ($context' $action')) $goal')))
                (ERROR The rule doesn't exist)

            )
        )
    )
)

;;checks if the rules pattern exists in the satisfiability cache
;;The satisfiability cache is a space to cache already grounded satisfiable code.
(= (checkSatisfier $rule $satisfiabilityCache)
    (let* (
        ($caches (collapse (get-atoms $satisfiabilityCache)))
        ($truthValues (collapse (unify $rule (superpose $caches) True False)))
        
    ) 
        (any $truthValues)
    )

)
;;Implements a simple grounding mechanism for metta
(= (satisfy $satisfiabilityCache $rule)
    (let* ( 
        ($query (changeRuleToQuery $rule))
        ($handle (car-atom $rule))
        ($exists (checkSatisfier $rule $satisfiabilityCache))
    
    )
        (if $exists
            (empty)
            (add-atom $satisfiabilityCache ($handle $query))
        )
    )
)


;; checks if a rule is grounded.
(= (checkSatisfiability $rule $satisfiabilityCache)
    (let* ( 
        ($query (changeRuleToQuery $rule))
        ($handle (cadr-atom $rule))

    )
       (if (== (car-atom $query) ERROR)
            (FALSE_TV)
            (let* (
                ($_ (remove-atom $satisfiabilityCache ($handle $query)))
                ($_ (satisfy $satisfiabilityCache $rule))

            )
                (if (checkSatisfier $rule $satisfiabilityCache)
                    (TRUE_TV)
                    (FALSE_TV)
                )
            )

        )
    )
)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;         Tests for implicator    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!(satisfy &satisfiabilityCache (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y)))))
(((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y))) (ERROR The rule doesn't exist))
!(get-atoms &satisfiabilityCache)

