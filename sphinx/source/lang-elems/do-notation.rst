.. _Do Notation:

************************************************************
Do Notation
************************************************************

Do notation can be used as a syntactic sugar for all types or type formers (i.e.
type constructors) ``M`` with a bind operation named ``>>=`` of the following
form::

    (>>=): all {A B C ...: Any):  M ... → (X → M C D ...) → M C D ...
    --                                         ^^^^^^^^^    ^^^^^^^^^
    --                                               same type!

Usually ``M`` is a type former and the bind operation looks like ::

    (>>=):  all {A B: Any}: M A → (A → M B) → M B   -- bind operation

    -- Examples:
    (>>=): Int → (String → Int) → Int               -- silly, but possible

    (>>=) {A B}: List A → (A → List B) → List B     -- usual list monadic bind

    (>>=) {A B}: Maybe A → (A → Maybe B) → Maybe B  -- usual maybe monadic bind


Do notation is meant to make expressions like the following more readable:
::

    e₀
    >>=
    (λ (x₁: A) :=
        e₁              -- expression of type 'M B'
        >>=
        (λ (x₂: B) :=
            e₂          -- expression of type 'M C'
            >>=
            (λ _ :=
                e₃
                >>=
                (λ x₄ := e₄))))

This expression describes a computation which does the following steps:

- Compute ``e₀`` and bind the result to the variable ``x₁``

- Compute ``e₁`` using ``x₁`` and bind the result to ``x₂``

- Compute ``e₂`` using ``x₁`` and ``x₂`` and ignoring its result

- Compute ``e₃`` using ``x₁`` and ``x₂`` and bind the result to ``x₄``

- Compute ``e₄`` using ``x₁``, ``x₂`` and ``x₄``


The same expression with do notation expresses that more concisely ::

    do
        x₁ := e₀
        x₂ := e₁
        e₂              -- result of 'e₂' ignored
        x₄ := e₃
        e₄

But note that this is only syntactic sugar. The nested bind expression and the
do notation are equivalent.
