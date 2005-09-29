var EditRanges = new Array();

function SetEditRange(id, range)
{
	EditRanges[id] = range.split(":");
	EditRanges[id][2] = /[0-9]*\.[0-9]*/.test(range);
	EditRanges[id][3] = Math.round(Math.abs(EditRanges[id][1]-EditRanges[id][0])/20);
	if (EditRanges[id][3] < 0) EditRanges[id][3] = 1;
}

function EditUp(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	if (EditRanges[id][2])
	{
		val = parseFloat(ctrl.value);
		val += 1.0;
	}
	else {
		val = parseInt(ctrl.value);
		val++;
	}	
	if (isNaN(val)) val = 0;
	if (val > EditRanges[id][1]) val = EditRanges[id][1];
	ctrl.value = val;
}

function EditDown(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	if (EditRanges[id][2])
	{
		val = parseFloat(ctrl.value);
		val -= 1.0;
	}
	else {
		val = parseInt(ctrl.value);
		val--;
	}
	if (isNaN(val)) val = 0;
	if (val < EditRanges[id][0]) val = EditRanges[id][0];
	ctrl.value = val;
}

function EditPgUp(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	if (EditRanges[id][2])
	{
		val = parseFloat(ctrl.value);		
	}
	else {
		val = parseInt(ctrl.value);
	}
	val += EditRanges[id][3];
	if (isNaN(val)) val = 0;
	if (val > EditRanges[id][1]) val = EditRanges[id][1];
	ctrl.value = val;
}

function EditPgDown(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	if (EditRanges[id][2])
	{
		val = parseFloat(ctrl.value);
	}
	else {
		val = parseInt(ctrl.value);
	}
	val -= EditRanges[id][3];
	if (isNaN(val)) val = 0;
	if (val < EditRanges[id][0]) val = EditRanges[id][0];
	ctrl.value = val;
}

function EditHome(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	ctrl.value = EditRanges[id][1];
}

function EditEnd(id)
{
	ctrl = document.getElementById(id);
	if (!ctrl) return;
	ctrl.value = EditRanges[id][0];
}

function EditOnKeyDown(id, e)
{
	if(window.event) // IE
		keynum = e.keyCode
	else if(e.which) // Netscape/Firefox/Opera
		keynum = e.which

	if (keynum == 38) EditUp(id); //up
	else if (keynum == 40) EditDown(id); //down
	else if (keynum == 36) EditHome(id); // home
	else if (keynum == 35) EditEnd(id); // end
	else if (keynum == 33) EditPgUp(id); // home
	else if (keynum == 34) EditPgDown(id); // end
	return false;
}

function EditOnKeyPress(id, e)
{
	if(window.event) // IE
		keynum = e.keyCode
	else if(e.which) // Netscape/Firefox/Opera
		keynum = e.which

	if ((keynum >= 48) && (keynum <= 57)) return true;
	if (keynum < 32) return true;
	if (keynum == 127) return true;
	if ((keynum == 46) && (EditRanges[id][2]))
	{
		ctrl = document.getElementById(id);
		return !/^[^.]*\.[^.]*$/.test(ctrl.value);
	}
	return false;
}
