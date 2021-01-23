.. _Javascript:

****************************************
Javascript
****************************************


.. highlight:: javascript


General
============================================================

Names
--------------------------------------------------

The names used in the source language might interfere with the javascript
keywords and operators. Since javascript does not allow to define functions with
an operator name, operators of the source language have to be represented by
valid javascript identifiers.



**DETAILS MISSING!!**



Algebraic Types
--------------------------------------------------

Objects of algebraic types can be implemeneted by arrays. For each constructor
we use an :math:`n+1`\ ary array where :math:`n` is the number of runtime
arguments the constructor takes. The first element of the array is tag i.e. a
number :math:`i` which says that the :math:`i`\ th constructor has been used to
construct the object. The other array elements are arguments to construct the
object.

E.g. to encode a list we use::

    [0]                         // empty list

    [1, 'a', [1, 'b', [0]]]     // the list ["a", "b"]







Pattern Match
--------------------------------------------------

The most straightforward way is to use a ``switch/case`` expression.

Example: List append and reverse

.. code-block:: alba

    append {α: Any}: List α → List α → List α :=
        λ []            ys  := b
        λ (x :: xs)     ys  := x :: (append xs ys)

    reverse {α: Any}: List α → List α :=
        λ []        :=  []
        λ (x :: xs) :=  append (reverse xs) [x]

.. code-block::

    function append (xs, ys) {
        switch(xs[0]) {
        case 0:
            return ys
        default:
            return [1, xs[1], append (xs[2], ys)]
        }
    }

    function reverse (xs) {
        switch (xs[0]) {
        case 0:
            return xs
        default:
            return append (reverse (xs[2]), [1, xs[1], [0]])
        }
    }







Tail Recursion
--------------------------------------------------

The javascript engines in the browser and node cannot handle deep recursion
well. Therefore compiling recursive Alba functions to recursive javascript
functions is not efficient and might frequently cause stack overflows.

Therefore we have to avoid deep recursion.

If a function is tail recursive, it can be easily implemented by a ``while``
loop. Look at the tail recursive function ``foldLeft``.

.. code-block:: alba

    foldLeft {α β: Any} (f: α → β → β): β → List α → β := case
        λ b     []          :=  b
        λ b     (x :: xs)   :=  foldLeft (f x b) xs


Instead of recursively calling ``foldLeft`` we just overwrite the original
arguments with the arguments of the recursive call and do the next iteration in
a while loop.  In any pattern clause which does not have a recursive call, the
final result of the function can be returned.


.. code-block::

    function foldLeft (f, b, xs) {
        while (true) {
            switch (xs[0]) {
            case 0:
                return b
            default:
                b  = f(xs[1], b)        // updates must be done in parallel!
                xs = xs[2]
            }
        }
    }

.. note::

    In the branches representing the recursive calls the updates of the original
    arguments must be done in parallel. I.e. the left hand sides of the
    assignments have to *see* the original values on the right hand side.
    Temporary variables have to be used, if the sequential assignments are not
    semantically equivalent to a parallel assignment.

.. warning::

    This does not work if one of the arguments is a function closure and in the
    update of the function closure the function is used. This creates an
    infinite recursion and stack overflow.




Eliminate Recursion
--------------------------------------------------

.. note::
    DRAFT


.. code-block:: alba

    append {α: Any} (xs ys: List α): List α :=
        app xs identity where
            app: List α → (List α → List α) → List α := case
                λ [] k :=
                    k ys
                λ (x :: xs) k :=
                    app xs (λ r := k (x :: r))

    reverse {α: Any} (xs: List α): List α :=
        rev xs identity where
            rev: List α → (List α → List α) → List α := case
                λ []        k :=    k []
                λ (x :: xs) k :=    rev xs (λ r := k (append r [x]))



.. code-block::

    function identity (x) { return x }

    function append (xs, ys) {
        var k =
            (x) => {return x}
        function nextK (xs, k) {
            return (r) => {return k([1, xs[1], r])}
        }
        while(true){
            switch (xs[0]){
                case 0:
                    return k(ys)
                default:
                    k  = nextK(xs,k)
                    xs = xs[2]
            }
        }
    }

    function reverse (xs) {
        var k = identity
        function nextK (xs, k) {
            return (r) => {return k (append(r, cons (xs[1],nil)))}
        }
        while(true) {
            switch (xs[0]){
                case 0:
                    return k ([0])
                default:
                    k = nextK(xs,k)
                    xs = xs[2]
            }
        }
    }



Browser
============================================================


Node
============================================================
