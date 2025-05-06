!(register-module! ../../../utilities-module)
!(register-module! ../../../../hyperon-openpsi)
!(import! &self utilities-module:utils)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self hyperon-openpsi:main:rules:implicator)


!(bind! &test-space (new-space)) ;; a mock space used to test my functions.
;; A helper function that serves as a testing mechanism.
(= (patternTester $pattern) 
    (unify $pattern ($handle ((TTV $time (STV $bel $conf)) (IMPLICATION_LINK (AND_LINK ($context $action)) $goal))) True False)
)
!(assertEqual (patternTester (changeRuleToQuery (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_LINK (AND_LINK ((x y) act)) (y)))))) True)
!(assertEqual (patternTester (changeRuleToQuery (x y z))) False)
!(assertEqual (checkSatisfiability (x ((TTV 1 (STV 0.5 0.6)) (IMPLICATION_(LINK (AND_LINK ((x y) act)) (y))))) &test-space) (False (STV 0.0 1.0)))


