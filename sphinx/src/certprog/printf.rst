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
