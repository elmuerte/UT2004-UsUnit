
                             UsUnit v1.1.??
                  UnrealScript Unit Testing Framework
                      ??

--{ About }---------------------------------------------------------------------

UsUnit is a unit testing framework for UnrealScript. It will make is easier to
perform so called unit tests in UnrealScript.

--{ Usage }---------------------------------------------------------------------

For information about how to use UsUnit please visit the following UnrealWiki
page:
        http://wiki.beyondunreal.com/wiki/UsUnit

--{ Compiling }-----------------------------------------------------------------

In order to compile the UsUnit source you will need the UCPP precompiler. You 
can get the compiler and more information here:
        http://wiki.beyondunreal.com/wiki/UCPP

By default the precompiled source files are made for UnrealEngine2.5. If you 
want to recompile the .puc files you must define UE25 for the precompiler.
If you want to compile it for an UnrealEngine2 game you must define UE2.

e.g.
        ucpp.exe -DUE25 ...
or
        ucpp.exe -DUE2 ...

--{ Changelog }-----------------------------------------------------------------

Changes since v1.0.11
- TestSuiteBase.bBreakOnFail defaults to false
- Removed redundant argument bFatal from TestCase.Check
- Added output reporter for the webadmin interface

-------------------------------------------{ Copyright 2005 Michiel Hendriks }--
