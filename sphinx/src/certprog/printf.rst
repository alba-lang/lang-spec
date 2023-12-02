********************************************************************************
Printf like Functions
********************************************************************************


.. code::

    type Ast :=
            -- Syntax tree of a format string.
        leaf:   Ast
        char:   Char -> Ast -> Ast
        int:    Ast -> Ast
        string: Ast -> Ast
        any:    Ast -> Ast


    parse: String -> Ast
        -- Convert a format string into a syntax tree.
    := case
        \ []              :=  leaf
        \ '%' :: 'd' :: s :=  int    (parse s)
        \ '%' :: 's' :: s :=  string (parse s)
        \ '%' :: 'a' :: s :=  any    (parse s)
        \ c :: s          :=  char c (parse s)


    TypeAst: Ast -> Any
        -- Convert a syntax tree of a format string into a type.
    := case
        \ leaf        := String
        \ char _ ast  := TypeAst ast
        \ int ast     := Int -> TypeAst ast
        \ string ast  := String -> TypeAst ast
        \ any ast     := all {A: Any}: (A -> String) -> A -> TypeAst ast


    toFun: String -> all (ast: Ast): TypeAst ast
        -- 'toFun s ast': Append to the string 's' the string
        -- corresponding to the sytanx tree 'ast' of the format
        -- string.
    := case
        \ s,  leaf         := s
        \ s,  char c ast   := toFun (s + toString c) ast
        \ s,  int ast      := \ i   := toFun (s + toString i) ast
        \ s,  string ast   := \ s2  := toFun (s + s2) ast
        \ s,  any ast      := \ f a := toFun (s + f a) ast


    printf (s: String): TypeAst (parse s)
        -- E.g. 'printf "name %s, value %d" "diameter" 5'
    :=
        toFun "" (parse s)



Without syntax tree:

.. code::

    TypeFmt: String -> Any
    := case
        \ []                 := String
        \ '%' :: 'd' :: fmt  := Int    -> TypeFmt fmt
        \ '%' :: 's' :: fmt  := String -> TypeFmt fmt
        \ '%' :: 'a' :: fmt  := all {A: Any}: (A -> String) -> A -> TypeFmt fmt
        \ _   :: fmt         := TypeFmt fmt


    printf (fmt: String): TypeFmt fmt :=
        let
            aux: List String -> all (fmt: String): TypeFmt fmt
            := case
                \ l,  []                 := foldLeft (\ accu s := s + accu) "" l
                \ l,  '%' :: 'd' :: fmt  := \ i   := aux (toString i :: l) fmt
                \ l,  '%' :: 'd' :: fmt  := \ s2  := aux (s2 :: l) fmt
                \ l,  '%' :: 'a' :: fmt  := \ f a := aux (f a :: l) fmt
                \ l,  c   :: fmt         := aux (toString c :: l) fmt
        :=
            aux [] fmt


The version without using a syntax tree is shorter and in my opinion more
understandable. Maybe it can be further improved in efficiency by using a
difference list.


.. code::

    printf (fmt: String): TypeFmt fmt :=
        let
            aux: (String -> String) -> all (fmt: String): TypeFmt fmt
            := case
                \ ds,  []                 := ds ""
                \ ds,  '%' :: 'd' :: fmt  := \ i   := aux ((+) (toString i) << ds) fmt
                \ ds,  '%' :: 'd' :: fmt  := \ s2  := aux ((+) s2 << ds) fmt
                \ ds,  '%' :: 'a' :: fmt  := \ f a := aux ((+) (f a) << ds) fmt
                \ ds,  c   :: fmt         := aux ((+) (toString c) << ds) fmt
        :=
            aux (\ s := s) fmt
