;!(import! &self py_ops)
!(register-module! ../../../hyperon-openpsi)
!(register-module! ../../utilities-module)

!(import! &self hyperon-openpsi:main:planning:action-planning)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

!(addGoal g1 0.1 0.2 &self)
!(addGoal g2 0.1 0.2 &self)
!(addGoal g3 0.1 0.2 &self)

!(addRule r1 (initContext) a1 g1 (TTV 1 (STV 1.0 1.0)))
!(assertEqual (getAction r1) a1)
!(assertEqual (getContext r1) (initContext))
!(assertEqual (getGoal r1) g1)

!(addRule r2 (g1) (goNear (self Bob)) g2 (TTV 1 (STV 1.0 1.0)))
;!(assertEqual (getContext r2) (g1))
;!(assertEqual (getAction r2) a2)
;!(assertEqual (getGoal r2) g2)

;!(addRule r3 (g3) a3 finalGoal (TTV 1 (STV 1.0 1.0)))
;!(assertEqual (getContext r3) (g2))
;!(assertEqual (getAction r3) a3)
;!(assertEqual (getGoal r3) finalGoal)

!(addRule r3 (g2) (ask (Bob "What's your name?")) externalNovelty (TTV 1 (STV 1.0 1.0)))
!(addGoal finalGoal 0.1 0.2 &self)
!(addGoal externalNovelty 0.9 1 &self)

!(hillClimbingPlanner g1 externalNovelty (TestedActions) () &self)
