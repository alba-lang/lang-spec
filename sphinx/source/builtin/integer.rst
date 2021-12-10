********************************************************************************
Module: alba.core.integer
********************************************************************************

.. code-block::

    -- Integer Numbers
    class Integer: Any :=
        positive:  Natural -> Integer
        negative1: Natural -> Integer    -- 'negative1 n' represents '- (succ n)'

    Integer.(+): Integer -> Integer -> Integer := ...
    Integer.(*): Integer -> Integer -> Integer := ...

    ...         -- details left out here


.. note::

    Missing: We have to include definitions of all arithmetic operators and
    decision procedures (equality, order relation) which have an efficient
    builtin representation.
