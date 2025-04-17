(: ActivationHelper (-> Number Number Number Number))
(= (ActivationHelper $competence $energy $stimulus)
    (+  (* 2 $stimulus)
             (* (/ $competence (+ $competence 0.5) )
                (/ $energy (+ 0.05 $energy) )
             )
         )
)

(: SecuringThresholdHelper (-> Number Number Number))
(= (SecuringThresholdHelper  $integrity $stimulus)
     (+  (* 2 $stimulus)
             (pow-math 
             $integrity 3)
         
        )

)
(: SelectionThresholdHelper (-> Number Number Number))
(= (SelectionThresholdHelper $competence $stimulus)
     (+  (* 2 $stimulus)
             (fuzzy_equal $competence 1 15)
         )
)