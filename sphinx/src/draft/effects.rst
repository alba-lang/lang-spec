********************************************************************************
Effects (Idris)
********************************************************************************


Some types:

.. code::

    Effect: Any :=
        all (T: Any): Any -> (T -> Any) -> Any


    type State: Effect :=
        get {A: Any}: State A A (\ _ := A)
        put {A B: Any}: B -> State Unit A (\ _ := B)



.. code::

    abstract type Handler (E: Effect) (M: Any -> Any) :=
        handle {T R A: Any} {P: T -> Any}:
            R -> E T R P -> (all x: P x -> M A) -> M A



.. code::

    type Mode := [read, write]

    type FileIO: Effect :=
        open (name: String) (m: Mode):
            FileIO Bool Unit (case  \ true := OpenFile m
                                    \ false := ())


        close {m} : FileIO Unit (OpenFile m) (\ _ := Unit)

        readLine: FileIO String (OpenFile read) (\ _ := OpenFile read)

        writeLine:
            String -> FileIO Unit (OpenFile write) (\ _ := OpenFile write)

        eof: FileIO Bool (OpenFile read) (\ _ := OpenFile read)
