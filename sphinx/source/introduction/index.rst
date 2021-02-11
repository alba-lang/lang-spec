.. _Introduction:

************************************************************
Introduction
************************************************************

Goals of the Language
============================================================

Alba shall be an easy to learn functional programming language. Easy to learn
means that is easy to write simple web applications or simple console
applications, even for newcomers to programming.

However internally alba offers all the goodies of dependent types including the
possibility to write fully certified. Programs written in alba cannot produce
runtime errors. All errors are compile time errors.

A big challenge to reach the goal is to design the type system so that it does
not get in the way. Furthermore it is very important to print understandable
error messages.



Goals for Version 1
============================================================


Mandatory goals:

- Web applications in the elm style

- Playground for experimenting with dependent types

- Compilation to intermediate representation in human readable form (see chapter
  :ref:`Intermediate Representation`)


Nice to have goals:

- Simple node applications


Not necessary:

- Universe polymorphism

- Other backends (only javascript required in order to run on the browser)
