//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.SelectableRow;
import mx.controls.Menu;

class mx.controls.menuclasses.MenuRow extends SelectableRow
{
  	// declarations
	var icon_branch : MovieClip;
	var icon_sep    : MovieClip;


	var icon_mc : MovieClip; // anything that goes in the left gutter
	var branch : Boolean;
	var iconID : String;
	var isEnabled : Boolean = true;
	var selected : Boolean = false;
	var type : String; // the kind of row this is.

	var idealWidth  : Number; // needs to be this width or wider

	var lBuffer     : Number = 18; // left side margin
	var rBuffer     : Number = 15; // right side margin

	function MenuRow()
	{
	}

	// assemble assets - super will handle text color and background enabling

	function setValue(itemObj:Object, sel:String)
	{
		var c = cell;
		var tmpText = itemToString(itemObj);
		if (c.getValue()!=tmpText) {
			c.setValue(tmpText, itemObj, state);
		}


		var newBranch = itemObj.hasChildNodes();
		var newEnabled = Menu.isItemEnabled(itemObj);
		var newType = itemObj.attributes.type;
		if (newType==undefined) newType = "normal";
		var newSelected = Menu.isItemSelected(itemObj);

		var newIconID = owner.__iconFunction(itemObj);
		if (newIconID==undefined)
			newIconID = itemObj.attributes[owner.__iconField];
		if (newIconID==undefined)
			newIconID = owner.getStyle("defaultIcon");


		if(icon_branch && (newBranch!=branch || newEnabled!=isEnabled || type=="separator")) {
			icon_branch.removeMovieClip();
			delete icon_branch;
		}

		if (newSelected!=selected || newIconID!=iconID || newType!=type || (newEnabled!=isEnabled && newType!="normal")) {
			icon_mc.removeMovieClip();
			icon_sep.removeMovieClip();
			delete icon_sep;
			delete icon_mc;
		}

		branch = newBranch;
		isEnabled = newEnabled;
		type = newType;
		selected = newSelected;
		iconID = newIconID;

		cell.__enabled = isEnabled;
		cell.setColor((isEnabled) ? owner.getStyle("color") : owner.getStyle("disabledColor"));

		if(sel == "highlighted"){
			if(isEnabled) cell.setColor(owner.getStyle("textRollOverColor"));
		}
		else if(sel == "selected"){
			if(isEnabled) cell.setColor(owner.getStyle("textSelectedColor"));
		}

		if (branch && icon_branch==undefined) {
			// render arrow icon
			icon_branch = createObject("MenuBranch"+ ((isEnabled) ? "Enabled" : "Disabled") , "icon_branch", 20);
		}


		if (type == "separator") {
			//render separator icon
			if(icon_sep==undefined){
				var sep = createObject("MenuSeparator", "icon_sep", 21);
			}
		} else if (icon_mc==undefined) {

			if (type!="normal") {
				if (selected)
					iconID = ((type=="check") ? "MenuCheck" : "MenuRadio") + ((isEnabled) ? "Enabled" : "Disabled");
				else
					iconID = undefined;
			}
			if (iconID!=undefined) {
				icon_mc = createObject(iconID, "icon_mc", 21);
			}
		}

		size(); // reset icon placement
	}


	// parses the item to return a display string
	function itemToString(itmObj : Object) : String
	{
		if(itmObj.attributes.type == "separator") {
			return " ";
		}
		else {
			return super.itemToString(itmObj);
		}
	}


	// set the properties of the row assets

	function size(Void) : Void
	{
		super.size();

		cell._x = lBuffer; // create the left margin
		cell.setSize(__width-rBuffer-lBuffer, Math.min(__height, cell.getPreferredHeight()));

		// determine icon placement

		if(icon_branch){

			icon_branch._x = (__width - (rBuffer / 2));
			icon_branch._y = (__height - icon_branch._height) / 2;

		}

		if(icon_sep){

			icon_sep._x = 4;
			icon_sep._y = (__height - icon_sep._height) / 2;
			icon_sep._width = (__width - 8);

		}
		else if(icon_mc){
			icon_mc._x = Math.max(0, (lBuffer  - icon_mc._width) / 2);
			icon_mc._y = (__height - icon_mc._height) / 2;
		}
	}



	// return the ideal width for this row item

	function getIdealWidth(Void): Number
	{
		cell.draw();
		idealWidth = cell.getPreferredWidth() + 4 + lBuffer + rBuffer;
		return idealWidth;
	}
}
