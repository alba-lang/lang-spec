.. _Implicit Arguments:

************************************************************
Implicit Arguments
************************************************************






A :ref:`function type <Types>` in fully elaborated form has the structure::

    all <telescope>: <simple type>

    all (x₁: A₁) (x₂: A₂) ... : R


Variables which do occur in the subsequent types or in the result type are
**potentially implicit** arguments.

A potentially implicit argument can be made implicit by using braces instead of
parentheses. I.e. in ::

    all {x₁: A₁} ... : R

    all {x₁} ... : R

the argument ``x₁`` is declared as an implicit argument.

Many potentially implicit arguments are **mandatory implicit**. A potentially
implicit argument ``x: A`` is mandatory implicit in the following cases:

- ``A`` in head normal form is a kind i.e. it is a sort or ``all <telescope>:
  Sort``.

- The function type in which ``x: A`` occurs is a proposition.

Only in the case that the function type is not a proposition and ``A`` is not a
kind, then the user can choose to make a potentially implicit argument implicit
or not.

Rule:
    Mandatory implicit arguments have to be declared within braces.
