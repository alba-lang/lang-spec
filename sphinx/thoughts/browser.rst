************************************************************
Browser
************************************************************


Modules
==================================================

.. code-block:: javascript

    /* module file 'm.js' */
    export function f (x,y) { return x + y }

    export {f, g, ... };  // all exported things


    /* using 'm.js' */
    import * as M from './m.js'

    const sum = M.f(3,4)


Document Access
==================================================


.. code-block:: javascript

    var e = document.createElement('div')
    var t = document.createTextNode('Hello, World!')

    e.appendChild(t)

    <node>.insertBefore (<new-child>, <cur-child>)
    <node>.appendChild(<child>)
    <node>.removeChild(<child>)
    <node>.replaceChild(<new-child>, <old-child>)

    <node>.setAttribute(<name>, <value>)    // both strings
    <node>.getAttribute(<name>)
    // setting an attribute updates the corresponding property
    // updating a property does not set the corresponding attribute!
    // attributes are always strings, properties are string or complex objects.


Note:

- Text nodes and elements are nodes. But elements can carry attributes. Nodes
  are event targets. Listeners can be added to event targets.


.. code-block:: none

    Hierarchy:

        Document                        Text node

        Element                         Character data

                        Node

                        Event Target



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

    handler {A}: String → Decoder (A,Bool,Bool) → Attribute A
        {: 'Decoder' decodes the event object into a message of type 'A'
           and two booleans. The first one indicates, whether propagation
           shall be stopped. The second one indicates, whether default
           behaviour shall be prevented ('stopPropagation' and
           'preventDefault'). :}


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
        -- Change the url, but do not trigger a page load
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

Need ``history``, ``popstate``, ``window.location``.


.. note::

    Subscription to events missing (timers etc.)





Handling of Subscriptions
============================================================

We can subscribe to various events which can happen in the system. The events
produced by the user doing something in the dom tree are already handled by
eventhandler attached to dom elements (dom elements are event targets).

The application might be interested to timer events (one shot timers or interval
timers). Navigation commands (back/forward button).

Events:

- Message from javascript
- Timer (one shot or interval)
- Keyboard (keypress, keyup, keydown)
- Mouse
- Window resize, visibility change
- Animation frame


How to handle subscriptions.

The elm way: The model determines all subscriptions. Any update of the model
might change the subscriptions. Each update requires to diff the subscriptions
and the previous subscriptions. This is like changes in the virtual dom. However
virtual dom changes have to be analyzed only at each animation frame.

Usually an application has only a couple of subscriptions. Therefore a check of
subscriptions each model update is not very bad.

However subscriptions change only rarely (or never). Therefore it is waste of
time diffing the subscriptions each model update.

Another way: Use commands to add subscriptions. This is the most performance
efficient method, because adding of event handlers only happens, when the state
of the model requires it. Disadvantage: How to cancel subscriptions? How to
update subscriptions? Possible solution: For each event type there can be only
one handler (for interval timers one for each interval). Creating a subscription
overwrites the previous subscription. Cancellation of event handlers is not
ambiguous, because there is at most one handler per event type.

An one shot timer is not a subscription. It is a command. At expiry it sends the
message to the application. If we want to be able to cancel a one shot timer, we
have to provide a timer number at creation time. Then cancellation can be done
with the timer number. I.e. we can handle it the same way as the other
subscriptions. At most one handler can be registered for a certain timer number.
Creation of the next one shot timer with the same timer number removes the old
handler.

Restriction in the other way: There is at most one handler and one message
associated with each subscription. In the elm way we could have zero or more
subscriptions to the same event.
