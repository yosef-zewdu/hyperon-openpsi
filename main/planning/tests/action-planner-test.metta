!(register-module! ../../../../hyperon-openpsi)
!(register-module! ../../../utilities-module)

!(import! &self hyperon-openpsi:main:planning:action-planner)
!(import! &self hyperon-openpsi:main:types)
!(import! &self hyperon-openpsi:main:rules:rule)
!(import! &self utilities-module:utils)

!(addGoal (S1 is off) 0.0 () &self)
!(addGoal (S2 is off) 0.0 () &self)
!(addGoal (S3 is off) 0.0 () &self)
!(addGoal (S4 is off) 0.0 () &self)

!(addGoal (S1 is on) 0.5 1 &self)
!(addGoal (S2 is on) 0.75 1 &self)
!(addGoal (S3 is on) 1.0 1.0 &self)
!(addGoal (S4 is on) 0.0 () &self)

!(addRule r1 ((S1 is off)) (Turn on S1) (S1 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r2 ((S1 is on)) (Turn on S2) (S2 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r3 ((S2 is on)) (Turn on S3) (S3 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r3' ((S3 is off)) (Turn on S3) (S3 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r4 ((S3 is on)) (Turn on S4) (S4 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r4' ((S4 is off)) (Turn on S4) (S4 is on) (TTV 0 (STV 1.0 1.0)))
!(addRule r5 ((S1 is on)) (Turn off S1) (S1 is off) (TTV 0 (STV 1.0 1.0)))

!(hillClimbingPlanner (S1 is off) (S3 is on) (TestedActions) () &self)
