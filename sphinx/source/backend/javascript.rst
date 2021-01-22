.. _Javascript:

****************************************
Javascript
****************************************


.. highlight:: javascript


General
============================================================


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
        switch(xs[0] === 0) {
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



Browser
============================================================


Node
============================================================
