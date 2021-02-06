************************************************************
Browser
************************************************************


Window
============================================================

A browser window is represented by a window object. The window object is an
event target which receives events like ``load``, ``resize``, ``popstate``.

The methods ``setTimeout`` and ``setInterval`` are window methods.

The most important properties are ``document``, ``history`` and ``location``.


Many objects in the browser inherit from ``EventTarget``. An event target has
the methods ``addEventListener``, ``removeEventListener`` and ``dispatchEvent``.



Document
============================================================

A document represents the web page loaded into the browser. A documents consists
of elements, text nodes and nodes.

.. code-block:: none

    Hierarchy:

        Document                        Text node

        Element                         Character data

                        Node

                        Event Target


A document is the root node of the document tree. Each document has a ``body``
property. The body is the body node, a frameset or null.

A document has methods to create text nodes and elements.

.. code-block:: javascript

    document.createTextNode('Hello, World!')
    document.createElement('div')



Nodes have methods to manipulate the document tree.

.. code-block:: javascript

    node.insertBefore(new_child, child)
    node.appendChild(child)     /* if 'child' is a document fragment, all
                                   children of the fragment are moved into
                                   'node' */
    node.removeChild(child)     // exception, if 'child' is not a child.
    node.replaceChild(new_child, child)
    node.firstChild()           // 'null' if there are no children
    node.parentNode()           // 'null' if there is no parent node

    // ATTENTION: documents and document fragments can never have parents.
    // Question: What happens if I insert the document into a node?


Elements of the document can have attributes. An attribute has a name and a
value. Both are strings.

.. code-block:: javascript

        element.setAttribute(name, value)
        element.getAttribute(name)          // null or "" if not present

Like all objects in javascript, elements can have arbitrary properties. A
``setAttribute`` sets the property of the same name. Updating a property does
**not** update the attribute.



Location
============================================================

General form of a uri:

.. code-block:: none

    uri:        scheme:[//authority]path[?query][#fragment]

    authority:  [userinfo@]host[:port]

    query:      key1=value1&key2=value2&...

    Example:

        http://www.example.com:8080/bla/blue?name=bla&color=blue#chapter1


The location object has properties and methods.

.. code-block:: javascript

    location.href
    location.hostname
    location.port
    location.pathname
    location.protocol
    location.assign(url)    // loads new web page




History
============================================================

.. code-block:: javascript

    history.back()
    history.forward()
    history.go(n)

    history.pushState(state, title, url)        // no page load
    history.replaceState(state, title, url)     // no page load




Alba Browser Application
============================================================

A compiled alba browser application is a javascript module with two exported
functions:

- init

    - element: The element below which the view shall be displayed
    - data: javascript object which the application can decode to get its init
      data
    - callback: To receive messages from the application
    - history access flag: Application is allowed to access the history and
      subscribe to popstate

- postMessage: A method to send messages to the application

The init method can throw an exception

- No element given or the element does not belong to the document.

- The application type is *document* or *application* and the element is not
  body. Reason: Only *sandbox*  and *element* can work below the body.
  *document* and *application* must takeover the body, i.e. must have exclusive
  rights on the page.

On success the init method does the following steps:

- Calls the internal init function with the data object to get the initial state
  and the initial commands.

  If the application type is *application* then call the internal init function
  with the url and an opaque navigation key. This is the method to allow the
  application to use navigation functions.

- Registers a requestAnimationFrame to display views of the state. The state
  object has a *modified* flag which is initially *true* and set to true on each
  update. The animation callback resets the *modified* flag after displaying the
  state.

The generated javascript module looks like

.. code-block:: javascript

    const code = {
        type: 'application'
        , init: function (data, key, url) { ... }
        , view: function (model) { ... }
        , update: function (msg, model) { ... }
        , onUrlRequest: function (urlreq) { ... }
    }

    var state                   // initialized by 'init'

    var element

    var callback = null         // initialized by 'init' or null

    function decode_message (m) { ... }

    function find_element (e) { ... }

    function do_command (cmd) { ... }

    export function init (conf) { ... }

    export function postMessage (m) {
        var m = decode_message(m)
        if (m === undefined) {
            return false
        } else {
            var res = code.update(m, state)
            state = res[0]
            cmd = res[1]
            do_command (cmd)
        }
    }



The compiler generates:

- The type of the application (*sandbox*, *element*, *document*, *application*).

- *init* function: maps arguments and optionally a key and the url into a state
  and a command and the permanent subscriptions.

- *update* function: maps message and state to a new state and a command.

- *view* function: maps the state to a dom update function

- *subscription* function: maps the state into the dynamic subscriptions

- an optional function pair mapping an url request (click on an anchor) to a
  message and an url (back/forward button of the browser) to a message.

The optional function pair is generated only in case of an application. For
sandbox, element and document these functions are not necessary.

The runtime environment is generic. It has the following dynamic data:

- The state with a *modified* flag.

- The current document: pointers to the elements of the document plus
  information to make diffing and updating possible.

- The current dynamic subscriptions. Contains all handler and information to
  remove the handlers. At each update we have to compare the new subscriptions
  with old subscriptions. Even if some subscriptions are the same, we have to
  update the handler, because there is no way to compare the handler functions
  (which map an event object into a message) for equality (only pointer
  equality).



Document Update
============================================================


In the alba code we have the builtins to create document nodes ::

    Html: Any → Any

    text {A}: String → Html A

    node {A} (tag: String)
    : List (Attribute A) → List (Html A) → Html A

    nodeKey {A}: (tag: String)
    : List (Attribute A) → List (String, Html A) → Html A



There are builtins for the attributes ::

    Attribute: Any → Any

    style {A}: String → String → Attribute A
        {: style "background-color" "red" :}

    attribute {A}: String → String → Attribute A
        {: like domNode.setAttribute('class', 'greeting') in JS :}

    property {A}: String → JSValue → Attribute A
        {: property "className" (Encode.string "myclass") :}

    handler {A}: String → Decoder (A,Bool,Bool) → Attribute A
        {: 'Decoder' decodes the event object into a message of type 'A'
           and two booleans. The first one indicates, whether propagation
           shall be stopped. The second one indicates, whether default
           behaviour shall be prevented ('stopPropagation' and
           'preventDefault'). :}

There are certain subtleties with attributes:

- Each element has a style property. The style property is an object with a set
  of properties like *color*, *backgroundColor*, ... The function ``style`` let
  us set one property within the style property like it is done in css files.

- Attributes have a name and a string value. Setting an attribute sets the
  corresponding property. A property change does not affect the attribute.

- Properties are javascript properties of the element. They are implicitly
  changed by changing attributes. Setting the style property can overide the
  effect of the *style* function and vice versa.

- Handlers are not attributes. Since elements and nodes are event targets, the
  javascript functions *addEventListener* and *removeEventListener* are used to
  attach and remove event handlers.

Update the styles:
    Create a new style object and updated the style property of the element
    object.

Update the attributes:
    We have to update existing attributes if their values has changed and remove
    attributes which no longer exist.

    Have an old and a new attribute object.

    .. code-block:: javascript

        for (const [name, value] of Object.entries(new_attrs)) {
            const old_value = old_attrs[name]
            if (old_value === undefined || !(old_value == value)) {
                element.setAttribute(name,value)
            }
        }
        for (const [name, value] of Object.entries(old_attrs)) {
            const new_value = old_attrs[name]
            if (old_attrs[name] === undefined) {
                element.removeAttribute(name)
            }
        }

Update the properties:
    Same as with the attributes. We need an old and a new object with the same
    properties as the element. We cannot use the element, because it can have
    much more properties than controlled by the application.

    Do not compare the values, just overwrite the old properties by the new
    properties and delete the properties which are no longer in use by ``delete
    element.property``.

    Never update the style property. This is done exclusively by ``style``.

    Update the properties before the attributes. Reason: Setting of attributes
    might overwrite the properties.

Update the handlers:
    We have to remove all old handlers and add the new ones. This is neccessary,
    because it is not possible to compare handler for equality (they are
    functions).
