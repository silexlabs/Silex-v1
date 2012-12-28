//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.SelectableRow;
import mx.effects.Tween;

class mx.controls.treeclasses.TreeRow extends SelectableRow
{

	//::: Defaults
	var indentAdjust : Number = 3;

	//::: Declarations
	var node : Object;
	var disclosure : MovieClip;
	var nodeIcon : MovieClip;
	var open : Boolean;
	var rotationTween : Tween;


	function setValue(item, state)
	{
		node = item;
		var branch = owner.getIsBranch(node);
		super.setValue(node, state);
	//	cell._width = cell.textWidth+10;
		if (node==undefined) {
			disclosure._visible = nodeIcon._visible = false;
			return;
		}
		nodeIcon._visible = true;

		open = owner.getIsOpen(node);
		var indent = (owner.getNodeDepth(node)-1) * getStyle("indentation");

		var dI = owner.getStyle( (open) ? "disclosureOpenIcon" : "disclosureClosedIcon");
		disclosure = createObject(dI, "disclosure", 3);
		disclosure.onPress = disclosurePress;
		disclosure.useHandCursor = false;

		disclosure._visible = branch;

		disclosure._x = indent + 4;
		var nI = owner.nodeIcons[node.getID()][(open) ? "iconID2" : "iconID"];
		if (nI==undefined) {
			nI = owner.__iconFunction(node);
		}

		if (branch) {
			if (nI==undefined) {
				nI = owner.getStyle( (open) ? "folderOpenIcon" : "folderClosedIcon");
			}
		} else {
			if (nI==undefined) {
				nI = node.attributes[owner.iconField];
			}
			if (nI==undefined) {
				nI = owner.getStyle("defaultLeafIcon");
			}
		}
		nodeIcon.removeMovieClip();
		nodeIcon = createObject(nI, "nodeIcon", 20);


		nodeIcon._x = disclosure._x + disclosure._width + 2;
		cell._x = nodeIcon._x + nodeIcon._width + 2;
		//indent + (indentAdjust*3) + owner.disclosureWidth + 16;

		// Make sure we size our height and our cell-width.
		size();
	}



	function getNormalColor()
	{
		node = item;
		var c = super.getNormalColor();
		var itemIndex = rowIndex + owner.__vPosition;
		var col = owner.getColorAt(itemIndex);
		if (col==undefined) {
			var colArray = owner.getStyle("depthColors");
			if (colArray == undefined) {
				return c;
			} else {
				var d = owner.getNodeDepth(node);
				if (d==undefined) d = 1;
				col = colArray[(d-1)%colArray.length];
			}
		}
		return col;
	}


	// ::: PRIVATE METHODS

	function createChildren()
	{
		super.createChildren();
		if (disclosure==undefined) {
			createObject("Disclosure", "disclosure", 3, {_visible:false} );
			disclosure.onPress = disclosurePress;
			disclosure.useHandCursor = false;
		}
	}

	function size()
	{
		super.size();
		disclosure._y = (__height - disclosure._height) / 2;
		nodeIcon._y = (height - nodeIcon._height) / 2;
		cell.setSize(__width - cell._x, __height);
	}


	// this is scoped to the disclosure icon. _parent is the row.
	function disclosurePress()
	{
		var p = _parent;
		var c = p.owner;
		if (c.isOpening || !c.enabled) return;
		var o = (p.open) ? 90 : 0;
		p.open = !_parent.open;
		c.pressFocus();
		c.releaseFocus();

		c.setIsOpen(p.node, p.open, true, true);
	}
}