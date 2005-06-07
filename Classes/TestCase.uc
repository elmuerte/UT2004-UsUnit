/*******************************************************************************
	TestCase
	Base test class for the UsUnit unit testing framework. Subclass this class
	to implement your own testcases. Implement the function run() to perform
	your checks. When you're done you much call the function 'done()'

	For example:
		function run()
		{
			Check(1+1 = 2, "Basic math test");
			Check(IsA(class'TestCase'), "Self check");
			done();
		}

	Written by: Michiel "El Muerte" Hendriks <elmuerte@drunksnipers.com>

	UsUnit Testing Framework
	Copyright (C) 2005, Michiel "El Muerte" Hendriks

	This program is free software; you can redistribute and/or modify
	it under the terms of the Lesser Open Unreal Mod License.
	<!-- $Id: TestCase.uc,v 1.3 2005/06/07 21:31:19 elmuerte Exp $ -->
*******************************************************************************/

class TestCase extends TestBase abstract;

/**
	Perform a test, expression should contain the expression to evaluate. When
	it results in false the test failed.
*/
protected final function Check(bool expression, coerce string message, optional bool bFatal)
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