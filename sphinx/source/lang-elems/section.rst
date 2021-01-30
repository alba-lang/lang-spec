.. _Sections:

************************************************************
Sections
************************************************************

It often happens that a couple of declarations need the same arguments. Then
these declarations can be put into a section.

Syntax::

    section <telescope> :=
        <declaration₁>
        <declaration₂>
        ...

The :ref:`telescope <Telescopes>` defines the common arguments for the
declarations. If a declaration does not need an argument, that argument is not
included in the final declaration.

Example::

    section {A: Any} :=
        (+): List A → List A → List A := case
            \ [] b :=
                b
            \ (h :: t) b :=
                h :: t + b

        reverse: List A → List A := case
            \ [] :=
                []
            \ (h :: t) :=
                reverse t + [h]
