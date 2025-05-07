;; !(register-module! ../../utilities-module)
;; !(register-module! ../../../hyperon-openpsi)
;; !(import! &self utilities-module:utils)
;; !(import! &self hyperon-openpsi:main:rules:rule)
!(bind! &satisfiabilityCache (new-space))

;; This function fetches queries based on handles
;; it returns the handle and the query as one being the type of the other.
;; The template return type is (: handle $query)
(= (getQueryByHandle $handle $space)
    (match $space (: $handle $query) (: $handle $query))
)

;; changes the rule to the query that can match to the rule
;; hence every rule is going to be unique since the handle for 
;; every rule is going to be different.
(= (changeRuleToQuery $rule)
    (let* (
            ($handle (cadr-atom $rule))
            ($queryTTV (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            ($queryTV (: $handle ((STV $bel $conf) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
            
        )
        (unify (quote $rule) (quote $queryTTV)
            (: $handle ((TTV $time' (STV $bel' $conf')) (IMPLICATION_LINK (AND_LINK ($context' $action')) $goal')))
            (unify (quote $rule) (quote $queryTV)
                (: $handle ((STV $bel' $conf') (IMPLICATION_LINK (AND_LINK ($context' $action')) $goal')))
                (ERROR The rule doesn't exist)

            )
        )
    )
)


;;This function is a function that can be used as a helper for 
;; one instance which is used as a helper function for checkSatisfier
;; which works with a list.
(= (checkSatisfier' $rule $cacheInstance)
    (unify $rule $cacheInstance True False)
)

;;checks if the rules pattern exists in the satisfiability cache
;;The satisfiability cache is a space to cache already grounded satisfiable code.
(= (checkSatisfier $rule $satisfiabilityCache)
    (let* (
        ($caches (collapse (get-atoms $satisfiabilityCache)))
        ($_ (println! (caches $caches)))
        ($truthValues (collapse (checkSatisfier' $rule (superpose $caches))))
        (() (println! (truthValues $truthValues)))
    ) 
        (any $truthValues)
    )

)

;;Implements a simple grounding mechanism for metta
(= (satisfy $satisfiabilityCache $rule)
    (let* ( 
        ($query (changeRuleToQuery $rule))
        ($handle (cadr-atom $rule))
        ($exists (checkSatisfier $rule $satisfiabilityCache))
    
    )
        (if $exists
            ()
            (add-atom $satisfiabilityCache $query)
        )
    )
)
;;This is a helper function to assist the recursion process.
(=(removeBasedOnPattern $pattern $space-pattern $space)
    (unify $pattern $space-pattern
        (remove-atom $space $space-pattern) 
        (empty)
    )
)

(=(removeBasedOnPatternList $pattern $patternList $space)
    (if (== () $patternList)
        ()
        (let* (
            (($head $tail) (decons-atom $patternList))
            ($_ (println! (headonRemove $head)))
            ($_ (collapse (removeBasedOnPattern $pattern $head $space)))
        )
            (removeBasedOnPatternList $pattern $tail $space)
        )
    )
)

;; checks if a rule is grounded using the satisfy function.
(= (checkSatisfiability $handle $satisfiabilityCache)
    (let* ( 
        ($rule (getQueryByHandle $handle $satisfiabilityCache))
        ($query (changeRuleToQuery $rule))
        ($_ (println! (query $query)))
        ($caches (collapse (get-atoms $satisfiabilityCache)))
        ($handle (cadr-atom $rule))
        ($_ (println! (handle $handle)))
    )
       (if (== (car-atom $query) ERROR)
            (FALSE_TV)
            (let* (
                ($_ (removeBasedOnPatternList  $query $caches $satisfiabilityCache))
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
;; !(satisfy &satisfiabilityCache (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y)))))
;; !(checkSatisfiability (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y)))) &satisfiabilityCache)
;; !(get-atoms &satisfiabilityCache)
;; !(changeRuleToQuery (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y)))))

