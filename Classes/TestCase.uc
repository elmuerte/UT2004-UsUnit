/*******************************************************************************
    TestCase
<p>
    Base test class for the UsUnit unit testing framework. Subclass this class
    to implement your own testcases. Implement the function run() to perform
    your checks. When you're done you much call the function 'done()'
</p>
<p>
    For example:
<pre>
        function run()
        {
            Check(1+1 = 2, "Basic math test");
            Check(IsA(class'TestCase'), "Self check");
            done();
        }
</pre>
</p>
<p>
    Written by: Michiel "El Muerte" Hendriks &lt;elmuerte@drunksnipers.com&gt;
</p>
<p>
    UsUnit Testing Framework -
    Copyright (C) 2005, Michiel "El Muerte" Hendriks
</p>

    This program is free software; you can redistribute and/or modify
    it under the terms of the Lesser Open Unreal Mod License.
    <!-- $Id: TestCase.uc,v 1.7 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class TestCase extends TestBase abstract;

// Using UCPP grants you some feature to make the usage of check() easier
// Including the following macro in your class will include special definitions
// that will include the source file and line of the called check, it can also
// automatically make a comment of the contents of the expression
// If you use it you will need to precompile it with UCPP:
//     http://wiki.beyondunreal.com/wiki/UCPP

//#pragma ucpp include ../../UsUnit/macros.inc

/**
    Perform a test, expression should contain the expression to evaluate. When
    it results in false the test failed.
*/
protected final function Check(bool expression, coerce string message)
{
    ++Checks;
    Reporter.reportCheck(Checks, message);
    if (!expression)
    {
        ++Failed;
        Reporter.reportFail(Checks, Failed);
    }
    else {
       Reporter.reportPass(Checks);
    }
}

/** short-hand for signaling the test is done */
protected final function Done()
{
    TestComplete(self);
}

