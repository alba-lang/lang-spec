************************************************************
Browser
************************************************************



Virtual Dom
==================================================

::

    Attribute: Any → Any

    style {A}: String → String → Attribute A
        {: style "background-color" "red" :}

    attribute {A}: String → String → Attribute A
        {: like domNode.setAttribute('class', 'greeting') in JS :}

    property {A}: String → JSValue → Attribute A
        {: property "className" (Encode.string "myclass") :}

    on {A}: String → Decoder A → Attribute A
        {: 'Decoder' decodes event into an object of type 'A'.
            More general version for 'preventDefault' and 'stopPropagation'
            needed.
        :}


    Html: Any → Any

    text {A}: String → Html A

    node {A}: String → List (Attribute A) → List (Html A) → Html A
        {: node "div" [] [text "Hello"] :}




Application
==================================================

Initially an application gets some:

- configuration data

- initial url: The application might show different content depending on the url


::

    Command: Any → Any

    none {A}: Command A

    batch {A}: List (Command A) → Command A


    Task: Any → Any → Any

    attempt {E A M}: (Result E A → M) → Task E A → Command M

    succeed {E A}: A → Task E A
        -- return a := succeed a
    fail {E A}: E → Task E A
    (>>=) {E A B}: Task E A → (A → Task E B) → Task E B


    Key: Any                -- received at the start of the application

    pushUrl {A}: Key → String → Command A
        -- Change the ulr, but do not trigger a page load
        -- New entry in browser history

    replaceUrl {A}: Key → String → Command A
        -- Change the ulr, but do not trigger a page load
        -- No new entry in browser history

    back {A}: Key → Int → Command A

    load {A}: String → Command A
        -- load "https://alba-lang.github.io

    reload {A}: String → Command A


::

    -- Application

    application
        {M A}
        (init: Flags → Url → Key → (M, Command A))
        (view: M → Document A)              -- Document is title + list of Html
        (update: A → M → (M, Command A))
        (onUrlRequest: UrlRequest → A)
        (onUrlChange: Url → A)
    : Program Flags M A


``preventDefault`` has to be added to links to make the browser not reload the
page.

Need ``history`` and ``popstate``.


.. note::

    Subscription to events missing (timers etc.)
