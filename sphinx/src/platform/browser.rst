********************************************************************************
Browser
********************************************************************************


Modules
================================================================================



Html
--------------------------------------------------------------------------------


An object of type ``Html M`` describes a dom tree which the user sees in his
browser window. Any interactions with the user (clicking on an element, moving
the mouse, entering text, ...) creates an object of type ``M``.

A dom element consists of a node name, a list of attributes and a list of
children. The elementary nodes are text nodes.



.. code::

    Html: Any -> Any


    text {M: Any}: String -> Html M
    node {M: Any}: String -> List (Attribute M) -> List (Html M) -> Html M

    div {M: Any} (attrs: List Attribute) (children: List (Html M)): Html M :=
        node "div" attrs children

    ...





Attribute
--------------------------------------------------------------------------------

An object of type ``Attribute M`` is an attribute of a dom node which can create
a message of type ``M``.


.. code::

    Attribute: Any -> Any

    style {M}: String -> String -> Attribute M
        -- style "background-color" "red"

    attribute {M}: String -> String -> Attribute M
        -- like domNode.setAttribute('class', 'greeting') in JS

    property {M}: String -> JSValue -> Attribute M
        -- property className (string "myclass")


    handler {M}: String -> Decoder (M * Bool * Bool) -> Attribute M
        {: 'Decoder' decodes the event object into a message of type 'A'
           and two booleans. The first one indicates, whether propagation
           shall be stopped. The second one indicates, whether default
           behaviour shall be prevented ('stopPropagation' and
           'preventDefault').
        :}


    onClick {M} (m: M): Attribute M :=
        handler "onClick" (return m)




Command
--------------------------------------------------------------------------------

.. code::

    Command: Any -> Any

    pushUrl {M}: Key -> String -> Command M    -- Tasks?



Subscription
--------------------------------------------------------------------------------

.. code::

    Subscription: Any -> Any

    receiveMessage {M}: Decoder M -> Subscription M





Encoder
--------------------------------------------------------------------------------

.. code::

    JSValue: Any


    undefined: JSValue

    null:   JSValue

    int:    JSValue

    float:  JSValue

    string: JSValue

    bool:   JSValue

    object: List (String * JSValue) -> JSValue
        -- with duplicate keys the last wins.

    list:  List JSValue -> JSValue




Decoder
--------------------------------------------------------------------------------

An object of type ``Decoder A`` decodes a javascript object into and object of
type ``Maybe A``.


.. code::

    Decoder (A: Any): Any :=
        JSValue -> Maybe A

    return {A}: A -> Decoder A

    fail {A}: Decoder A

    (>>=) {A B}: Decoder A -> (A -> Decoder B) -> Decoder B

    string: Decoder String

    int:    Decoder Int

    float:  Decoder Float

    field {A}: String -> Decoder A -> Decoder A

    list {A}: Decoder A -> Decoder (List A)

    array {A}: Decoder A -> Decoder (Array A)


This definition has the disadvantage that it cannot handle arbitrarily deep
javascript objects. In order to do that we need a parser like object.

.. code::

    Parser (A: Any) (i: Progress): Any :=
        JSValue -> Maybe A * JSValue

    run {A i} (d: Parser A i) (v: JSValue): Maybe A :=
        match d v case
            \ (nothing, _) :=
                nothing
            \ (just a, _) :=
                just a


    return {A}: A -> Parser A no

    fail {A}:   Parser A no

    (>>=) {A B} (m: Parser A i) (f: A -> Parser B j): Parser B (i or j) :=
        \ v :=
            match m v case
                \ (just a, v2) :=
                    f a v2
                \ (nothing, v2) :=
                    (nothing, v2)

    string: Parser String no
    int:    Parser Int    no

    field: String -> Parser Unit yes        -- enters the field of an object

    arrayLength: Parser Nat no

    get: Nat -> Parser Unit yet             -- enters an element of an array

    list {A i}: Parser A i -> Parser (List A) no



Browser Programs
================================================================================



Sandbox
--------------------------------------------------------------------------------


A sandbox program occupies the whole browser window (i.e. it is rendered
directly below the ``body`` node). The user can interact with the program by
clicking of element, moving the mouse, entering text etc. The only effect of the
user interaction is changing the dom.

A sandbox program cannot interact with the outside world. There are no http
requests, no sending and receiving of messages from and to the outer javascript
code.


.. code::

    Html: Any -> Any

    Browser: Any                -- type for browser programs

    sandbox {S M: Any}: S -> (M -> S -> S) -> (S -> Html M) -> Browser
        -- sandbox init update view



An example of a sandbox program:

.. code::

    use
        alba.core.int
        alba.core.string
        alba.browser.browser

    type Message := [increment, decrement]

    update: Mesage -> Int -> Int := case
        \ increment, i :=
            i + 1
        \ decrement, i :=
            i - 1

    view: (i: Int): Html Message :=
        div []
            [   button [onClick decrement] [text "-"]
                , div [] [text (toString i)]
                , button [onClick increment] [text "+"]
            ]



Element
--------------------------------------------------------------------------------


An element program manages only the dom subtree of an existing node of the dom.
No dom elements outside the root element are neither accessible nor changeable.

An element program can interact with the surrounding javascript code by sending
and receiving messages. It can make http requests. It can subscribe to external
events like timers etc.


.. code::

    element {S M: Any}:
        Decoder (S * Command M)     -- initialisation
        ->
        (M -> S -> S * Command M)   -- update
        ->
        (S -> Html M)               -- view
        ->
        (S -> Subscription M)       -- subscriptions
        ->
        Browser



Document
--------------------------------------------------------------------------------

A document application occupies the whole browser page and its title.

.. code::

    document {S M: Any}:
        Decoder (S * Command M)         -- initialisation
        ->
        (M -> S -> S * Command M)       -- update
        ->
        (S -> String * List (Html M))   -- view with title
        ->
        (S -> Subscription M)           -- subscriptions
        ->
        Browser



Single Page Application
--------------------------------------------------------------------------------

.. code::

    application {S M: Any}:
        Decoder (Key -> Url -> S * Command M)       -- initialisation
        ->
        (M -> S -> S * Command M)                   -- update
        ->
        (S -> String * List (Html M))               -- view with title
        ->
        (S -> Subscription M)                       -- subscriptions
        ->
        (UrlRequest -> M)                           {: The user has clicked on a
                                                       link :}
        ->
        (Url -> M)                                  {: Forward or backward
                                                       movement in the history
                                                       without changing the main
                                                       page :}
        ->
        Browser
