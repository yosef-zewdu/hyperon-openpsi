
!(bind! &emotion-space (new-space))
(: Emotion Type)
(: emotion (-> Atom Emotion))
(= (create-emotion $emotion)
    (unify $emotion (emotion $x) (add-atom &emotion-space $emotion) (Error Wrong Format))
    
)

(= (get-emotions)
    (collapse (get-atoms &emotion-space))
)