!(register-module! ../utilities-module)
!(import! &self utilities-module:utils)

!(bind! &emotion-space (new-space))
(: Emotion Type)

(: emotion (-> Atom Number Emotion))

(= (getEmotionString $list)
  (let (emotion $x $_) (superpose $list) $x)
)

(= (isAvailable?  $emotion-space $emotion)
    (let* (
        ((emotion $x $y) $emotion)
        ($emotions (get-emotions)) 
        ($emotStrings (collapse (getEmotionString $emotions)))
    )
        (isMember $x $emotStrings)  
    )
)
(= (create-emotion $emotion-space $emotion)
    (unify $emotion (emotion $y $x)
            (if (isAvailable? $emotion-space $emotion)
                (Error is Available)
                (add-atom &emotion-space $emotion) 
            )
            (Error Wrong Format)
    )
    
)

(= (get-emotions)
    (collapse (match &emotion-space $x $x))
)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;              Tests For emotion.metta                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!(create-emotion &emotion-space (emotion anger 0))
!(create-emotion &emotion-space (emotion data 0))
!(create-emotion &emotion-space (emotion anger 0))
!(isAvailable? &emotion-space (emotion anger 0))
!(match &emotion-space $x $x)
!(create-emotion &emotion-space data)
!(get-emotions)
!(getEmotionString (get-emotions))
!(get-atoms &emotion-space)