/*******************************************************************************
    Output_WebAdmin
<p>
    Output module for the webadmin interface
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
    <!-- $Id: Output_WebAdmin.uc,v 1.3 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/
class Output_WebAdmin extends Output_HTMLBase;

var array<string> lines;
var string timestamp;

function Logf(coerce string line)
{
    lines[lines.length] = line;
}

function start()
{
    lines.length = 0;
    timestamp = Level.Year$"-"$Right("0"$Level.Month, 2)$"-"$Right("0"$Level.Day, 2)@Right("0"$Level.Hour, 2)$":"$Right("0"$Level.Minute, 2)$":"$Right("0"$Level.Second, 2);
    super.start();
}

function _head()
{
    _style();
}

function _footer()
{
    _stats();
}

/** returns required closing tags */
function string closure()
{
    local string res;
    if (Stack.length == 0) return "<p><em>Tests still running...</em></p>";
    if (Stack[0].IsA('TestCase')) res = "</table>";
    res = res$StrRepeat("</td></tr></table>", Stack.length);
    return res$"<p><em>Tests still running...</em></p>";
}

defaultProperties
{

}