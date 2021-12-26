Theorem succInjective
    {a b: nat}
    (eq: S a = S b)
    : a = b.
Proof
    let f n :=
        match n with
        | O => a
        | S n => n
        end
    in
    let g (i j: nat) (eq: i = j): f i = f j :=
        match eq in (_ = x) return f i = f x with
        | eq_refl =>  eq_refl
        end
    in
    g (S a) (S b) eq.
