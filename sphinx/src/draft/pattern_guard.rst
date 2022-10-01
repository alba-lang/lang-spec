********************************************************************************
Pattern Guard
********************************************************************************



.. code::

    unzip {A B: Any}: List (A, B) -> (List A, List B)
    := case
        \ [] :=
            ([], [])

        \ (x, y) :: xys :=
            match unzip xys case
                \ (xs, ys) := (x :: xs, y :: ys)

    -- with a pattern guard

        \ (x, y) :: yxs with
            unzip xys
            \ (xs, xy) := (x :: xs, y :: ys)

Just syntactic sugar. Easier to read, less indentation.

Question: How to make it parseable. Is it really worthwile, the original code
already is well readable.
