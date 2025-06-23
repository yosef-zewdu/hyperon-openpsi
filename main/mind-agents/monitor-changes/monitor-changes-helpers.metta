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
;;This function filps the truth-value of a rule and updates the atomspace.
(: flipTruthValue (-> hyperon::space::DynSpace Expression Expression))
(= (flipTruthValue &space $atom)
   	(let* (
		($_ (remove-atom $space $atom))
		($newAtom (changeTruthValue $atom (STV 1 1)))

	)
	  	(add-atom $space $newAtom)
	  )
)
!(extractTvFromRule (: r1 ((TTV 1 (STV 0.8 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))))
!(changeTruthValue (: r1 ((TTV 1 (STV 0.8 0.7)) 
        (IMPLICATION_LINK 
          (AND_LINK ((Goal init 0.9 0.6) explore)) 
          (Goal found_target 1.0 1.0)))) (STV 1.0 1.0))