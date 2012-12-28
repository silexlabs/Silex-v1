//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.UIComponent;

class mx.controls.cells.CheckCellRenderer extends UIComponent
{

	var check : MovieClip;
	var listOwner : MovieClip; // the reference we receive to the list
	var getCellIndex : Function; // the function we receive from the list
	var	getDataLabel : Function; // the function we receive from the list

	function CheckCellRenderer()
	{
	}

	function createChildren(Void) : Void
	{
		check = createObject("CheckBox", "check", 1, {styleName:this, owner:this});
		check.addEventListener("click", this);
		size();
	}

	// note that setSize is implemented by UIComponent and calls size(), after setting
	// __width and __height
	function size(Void) : Void
	{
		check.setSize(20, __height);
		check._x = (__width-20)/2;
		check._y = (__height-16)/2;
	}

	function setValue(str:String, item:Object, sel:Boolean) : Void
	{

		check._visible = (item!=undefined);
		check.selected = item[getDataLabel()];
	}

	function getPreferredHeight(Void) : Number
	{
		return 16;
	}

	function getPreferredWidth(Void) : Number
	{
		return 20;
	}

	function click()
	{
		listOwner.dataProvider.editField(getCellIndex().itemIndex, getDataLabel(), check.selected);
	}

}
