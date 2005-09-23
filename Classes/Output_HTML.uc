/*******************************************************************************
    Output_HTML
<p>
    Writes the test results to an HTML file.
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
    <!-- $Id: Output_HTML.uc,v 1.8 2005/09/23 09:23:41 elmuerte Exp $ -->
*******************************************************************************/

class Output_HTML extends Output_HTMLBase config(UsUnit);

var protected FileLog html;

var config string FilenameFormat;

event Created()
{
    html = spawn(class'FileLog');
}

function Logf(coerce string line)
{
    html.Logf(line);
}

/**
    return the filename to use for the log file. The following formatting rules are accepted:
    %P      server port
    %N      server name
    %L      level name
    %Y      year
    %M      month
    %D      day
    %H      hour
    %I      minute
    %S      second
    %W      day of the week
*/
function string GetLogFilename()
{
  local string result;
  result = FilenameFormat;
  ReplaceText(result, "%P", string(Level.Game.GetServerPort()));
  ReplaceText(result, "%N", Level.Game.GameReplicationInfo.ServerName);
  ReplaceText(result, "%L", Left(string(Level), InStr(string(Level), ".")));
  ReplaceText(result, "%Y", string(Level.Year));
  ReplaceText(result, "%M", Right("0"$string(Level.Month), 2));
  ReplaceText(result, "%D", Right("0"$string(Level.Day), 2));
  ReplaceText(result, "%H", Right("0"$string(Level.Hour), 2));
  ReplaceText(result, "%I", Right("0"$string(Level.Minute), 2));
  ReplaceText(result, "%W", string(Level.DayOfWeek));
  ReplaceText(result, "%S", Right("0"$string(Level.Second), 2));
  return result;
}

function start()
{
    html.OpenLog(GetLogFilename(), "html", true);
    super.start();
}

function end()
{
    super.end();
    html.CloseLog();
}

defaultproperties
{
    FilenameFormat="UsUnit_report"
}