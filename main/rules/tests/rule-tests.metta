!(register-module! ../../../../hyperon-openpsi)
!(import! &self hyperon-openpsi:main:rules:rule)

!(addRule x (AND_LINK ((x1 x2) y)) z (TTV 1 (STV 11.0 11.0)))
!(assertEqual (getContext x) (x1 x2))
!(assertEqual (getAction x) y)
!(assertEqual (getGoal x) z)
!(assertEqual (getTV x) (TTV 1 (STV 11.0 11.0)))

!(addRule x (AND_LINK ((x1 x2) y)) z (TTV 1 (STV 11.0 11.0)))
