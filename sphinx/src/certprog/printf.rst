********************************************************************************
Printf like Functions
********************************************************************************


.. code::

    type Ast :=
        leaf:   Ast
        char:   Char -> Ast -> Ast
        int:    Ast -> Ast
        string: Ast -> Ast


    parse: String -> Ast := case
        \ []              :=  leaf
        \ '%' :: 'd' :: s :=  int (parse s)
        \ '%' :: 's' :: s :=  string (parse s)
        \ c :: s          :=  char c (parse s)


    typeAst: Ast -> Any := case
        \ leaf        := String
        \ char _ ast  := typeAst ast
        \ int ast     := Int -> typeAst ast
        \ string ast  := String -> typeAst ast


    toFun: all (ast: Ast): String -> typeAst ast := case
        \ leaf,         s   := s
        \ char c ast,   s   := toFun ast (s + toString c)
        \ int ast,      s   := \ i  := toFun ast (s + toString i)
        \ string ast,   s   := \ s2 := toFun ast (s + s2)


    printf (s: String): typeAst (parse s) :=
        toFun (parse s) ""
