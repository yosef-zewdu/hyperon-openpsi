(= (extractTvFromRule $rule)
    (let  (: $handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $rule 
        (STV $bel $conf)
    )
)

(: symmetricDifference (-> Expression Expression Expression))
(= (symmetricDifference $exp1 $exp2)
   (let* (
	  ($res1 (subtraction-atom $exp1 $exp2))
	  ($res2 (subtraction-atom $exp2 $exp1))
	)
     (union-atom $res1 $res2)
))

;;This function changes the truth value of a rule
(: changeTruthValue (-> Expression Expression Expression))
(= (changeTruthValue $rule (STV $x $y))
	(let (: $handle ((TTV $time (STV $bel $conf))  (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) $rule 
	  	(: $handle ((TTV $time (STV $x $y)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))))
)