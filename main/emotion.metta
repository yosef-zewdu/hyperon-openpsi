
!(bind! &emotion-space (new-space))
(= (create-emotion $emotion)
    (add-atom &emotion-space $emotion)

)

(= (get-emotions)
    (collapse (get-atoms &emotion-space))
)