//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIComponent;
import mx.skins.RectBorder;


class mx.controls.menuclasses.MenuBarItem extends UIComponent
{
	// **************************************************************************
	// Local properties

	var __menu;
	var cell;
	var __enabled;
	var __initText;
	var owner : MovieClip;
	var border_mc : RectBorder;
	var __cellHeightBuffer:Number = 3;
	var __cellWidthBuffer:Number = 20;
	var __isDown:Boolean = false;
	var __isClosing:Boolean = false;
	var menuBarIndex:Number;

	// **************************************************************************

	function MenuBarItem() {
	}


	function createChildren(Void):Void
	{
		super.createChildren();
		createLabel("cell",20);
		cell.setValue(__initText);	//set text again

		createClassObject(mx.skins.halo.ActivatorSkin, "border_mc", 0, {styleName:this.owner, borderStyle:"none"});
		useHandCursor = false;
		trackAsMenu = true;
	}


	// **************************************************************************
	// Internal functions

	function size(Void):Void
	{
		super.size();
		border_mc.setSize(__width, __height);
		cell.setSize(__width-__cellWidthBuffer, cell.getPreferredHeight());

		cell._x = __cellWidthBuffer / 2;
		cell._y = (__height - cell._height)  / 2;
	}

	function getPreferredWidth(Void) : Number
	{
		return cell.getPreferredWidth() + __cellWidthBuffer;
	}

	function setLabelBorder (style:String) : Void
	{
		border_mc.borderStyle = style;
		border_mc.draw();
	}

	function setEnabled(state:Boolean) : Void
	{
		cell.enabled = state;
		if (!enabled)
			setLabelBorder("none");
	}


	// **************************************************************************
	// Mouse Event Handlers


	function onPress(Void) {
		owner.onItemPress(menuBarIndex);
	}


	function onRelease(Void) {
		owner.onItemRelease(menuBarIndex);
	}


	function onRollOver(Void) {
		owner.onItemRollOver(menuBarIndex);
	}


	function onRollOut(Void) {
		owner.onItemRollOut(menuBarIndex);
	}


	function onDragOver(Void) {
		owner.onItemDragOver(menuBarIndex);
	}


	function onDragOut(Void) {
		owner.onItemDragOut(menuBarIndex);
	}

}
