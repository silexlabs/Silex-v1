//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.Menu;
import mx.core.UIComponent;

[TagName("MenuBar")]
[RequiresDataBinding(true)]
[IconFile("MenuBar.png")]

[Event("menuShow")]
[Event("menuHide")]
[Event("rollOver")]
[Event("rollOut")]
[Event("change")]
 
/**
* MenuBar class
* - extends UIComponent
* - gives the user the ability to select an option from a menu within a series of menus
* @tiptext Provides the ability to select an option from a menu within a series of menus.
* @helpid 3441
*/
class mx.controls.MenuBar extends UIComponent
{
	// **************************************************************************
	// System Infrastructure

	/**
	* @private
	* SymbolName for object
	*/
	static var symbolName:String = "MenuBar";

	/**
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = MenuBar;


	// Version string
//#include "../core/ComponentVersion.as"

	/**
	* @private
	* className for object
	*/
	var className:String = "MenuBar";

	// **************************************************************************
	// Private statics

	static var _s_MenuIndex = 0;


	// **************************************************************************
	// Local properties

	// Live Preview support
	var __labels:Array;

	// Runtime operations
	var __menuBarItems:Array;
	var __menus : Object;
	var __menuDataProvider : Object;
	var topItemDepth:Number = 200;
	var openMenuIndex:Number;
	var isDown;

	var boundingBox_mc:MovieClip;
	var background_mc:MovieClip;
	var mask_mc:MovieClip;

	var menuBarBackLeftName:String = "MenuBarBackLeft";
	var menuBarBackRightName:String = "MenuBarBackRight";
	var menuBarBackMiddleName:String = "MenuBarBackMiddle";

	var __selectFirstItem;

	var __backgroundWidth = 550;
	var __marginWidth = 10;
	var __menuEventHandler : Object;
	var invUpdateDisplay : Boolean;
	var invUpdateSize : Boolean;
	var tabChildren :Boolean= false;
	var enableByPass : Boolean;
	var supposedToLoseFocus : Boolean;
	var labelField : String = "label";
	var labelFunction : Function;
	var clipParameters:Object = { enabled:1, visible:1, labels:1, minWidth:1, minHeight:1};
 	var rebroadcastEvents : Object = { menuHide:1, menuShow:1, rollOver:1, rollOut:1, change:1 };

	// **************************************************************************
	// Lifecycle

	function MenuBar() {}


	/**
	* Generic initializer
	*/
	function init(Void) : Void
	{
		super.init();
		__menus = new Object();
		__menuBarItems = new Array();

		for(var i = 0; i < __labels.length; i++) {
		addMenu(__labels[i]);
		}
		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;
	}

	function draw(Void) : Void
	{
		super.draw();
		if (invUpdateDisplay)
			updateDisplay(invUpdateSize);
	}

 	function handleEvent(event)
   	{
 		var t = event.type;
 		if (t=="menuHide") {
 				//    trace("hide:  event.menuBar=" + event.menuBar + "; event.menu=" + event.menu);
 			if (event.menu.menuBarIndex == openMenuIndex) {
 				__menuBarItems[openMenuIndex].setLabelBorder("none");
 				delete openMenuIndex;
 	//			Selection.setFocus(this);
 			}
 		}
 		if (rebroadcastEvents[t]) {
 			event.target = this;
 			dispatchEvent(event);
   		}
 
   	}

	function onSetFocus()
	{
		super.onSetFocus();
		getFocusManager().defaultPushButtonEnabled = false;
	}

	function onKillFocus()
	{
		super.onKillFocus();
		getFocusManager().defaultPushButtonEnabled = true;
		if (supposedToLoseFocus==undefined) {
			getMenuAt(openMenuIndex).hide();
		}
		delete supposedToLoseFocus;
	}

	function createChildren(Void) : Void
	{
		super.createChildren();
		// Add the menubar background and children
		if(background_mc == undefined){
			createEmptyMovieClip("background_mc", 0);
			background_mc.createObject(menuBarBackLeftName, "bckLeft", 1);
			background_mc.createObject(menuBarBackRightName, "bckRight", 2);
			background_mc.createObject(menuBarBackMiddleName, "bckCenter", 3);
		}
		if(!_global.isLivePreview)
		{
			var mask_mc =  createObject("BoundingBox","mask_mc",10);
			this.setMask(mask_mc);
		}
		updateBackgroundDisplay();
	}

	function size(Void):Void
	{
		super.size();

		updateDisplay(true);
		updateBackgroundDisplay();
	}


	/**
	 * Append a menu and activator at the end of this menubar.
	 *
	 * @param arg1 may be either (1) a String (to be used as the item's label), (2) or an xmlNode
 	 * @param arg2 may be either (1) undefined, (2) a menu, (3) or an xml/xmlNode
	 *
	 * @returns Return the reference to the new Menu.
	 *
	 * @tiptext Append a new menu item into the menubar
	 * @helpid 3442
	 */
	function addMenu(arg1, arg2) : Menu
	{
		var ind = __menuDataProvider.childNodes.length;
		if (ind==undefined) ind = 0;
		return addMenuAt(ind, arg1, arg2);

	}

	/**
	 * Insert a menu and activator into the menubar.
	 *
	 * @param index the index where the menu should be inserted
	 * @param arg1 may be either (1) a String (to be used as the item's label), (2) or an xmlNode
 	 * @param arg2 may be either (1) undefined, (2) a menu, (3) or an xml/xmlNode
	 *
	 * @returns Return the reference to the new Menu.
	 *
	 * @tiptext Insert a new menu item into the menubar at the given index
	 * @helpid 3443
	 */
	function addMenuAt(index, arg1, arg2)
	{
		if (__menuDataProvider==undefined) {
			__menuDataProvider = new XML();
			__menuDataProvider.addEventListener("modelChanged", this);
		}
		var newMenu : Menu;
		var mdp;
		var newItem = arg1;

		if (arg2!=undefined) {
			if (arg2 instanceof XML) {
				mdp = __menuDataProvider.addMenuItemAt(index, arg1);
				var c=arg2.childNodes;
				while (c.length!=0) {
					mdp.addMenuItem(c[0]);
				}
				newItem=undefined;
			} else {
				arg2.attributes.label = arg1;
				newItem = arg2;
			}
		}
		if (newItem!=undefined) {
			mdp = __menuDataProvider.addMenuItemAt(index, newItem);
		}


		return insertMenuBarItem(index, mdp);

	}

	// **************************************************************************
	// Activator list management


	private function insertMenuBarItem(index, mdp)
	{
		var newMenu = Menu.createMenu(_parent._root, mdp, {styleName:this, menuBarIndex:index});

		__menus[mdp.getID()] = newMenu;

		newMenu.__menuBar = this;
		newMenu.addEventListener("menuHide", this);
		newMenu.addEventListener("rollOver", this);
		newMenu.addEventListener("rollOut", this);
		newMenu.addEventListener("menuShow", this);
		newMenu.addEventListener("change", this);
		newMenu.border_mc.borderStyle = "menuBorder";
		newMenu.labelField = labelField;
		newMenu.labelFunction = labelFunction;
		var tmp = labelFunction(mdp);
		if (tmp==undefined) tmp = mdp.attributes[labelField];
		// Create a MenuBarItem as the activator
		var item = createObject("MenuBarItem", "mbItem"+topItemDepth++, topItemDepth, {owner:this, __initText:tmp, styleName:this, _visible:false});
		item.enabled = enabled;
		item.setSize(item.getPreferredWidth(), __height);

		newMenu.__activator = item; // menu needs this for a hitTest when clicking outside menu area

		// trace("insertMenuBarItem:: " + index + "    " + item);
		__menuBarItems.splice(index, 0, item);

		invUpdateDisplay=true;
		invalidate();

		return newMenu;
	}


	/**
	 * Return the menu at the given index
	 *
	 * @param index the index of the menu instance to return
	 *
	 * @returns a reference to the menu at that specified index
	 *
	 * @tiptext Return the menu item at a specific index.
	 * @helpid 3444
	 */
	function getMenuAt(index) : Menu
	{
		return __menus[__menuDataProvider.childNodes[index].getID()];
	}


	/**
	 * Remove the menu at the given index
	 *
	 * @param index the index of the menu instance to remove
	 *
	 * @returns a reference to the menu that was removed
	 *
	 * @tiptext Remove the menu item at a specific index.
	 * @helpid 3445
	 */
	function removeMenuAt(index)
	{
		var m = __menuDataProvider.removeMenuItemAt(index);
		var a = __menuBarItems[index];
		__menuBarItems.splice(index,1);
		a.removeMovieClip();
		var tmp = __menus[m.getID()];
		delete __menus[m.getID()];
		invUpdateDisplay = true;
		invalidate();
		return tmp;
	}


	function setEnabled(b:Boolean) : Void
	{
		super.setEnabled(b);
		var l = __menuBarItems.length;
		enableByPass = true;
		for (var i=0; i<l; i++) {
			__menuBarItems[i].enabled = b;
		}
		delete enableByPass;
	}


	/**
	 * Enable/disable a menu
	 *
	 * @param index the index of the menu instance to enable
	 * @param menu the Menu instance to remove
	 *
	 * @tiptext Enable/disable the menu item at a specific index.
	 * @helpid 3446
	 */
	function setMenuEnabledAt(index, enable)
	{
		if (!enabled && enableByPass==undefined) return;
		__menuBarItems[index].enabled = enable;
	}


	/**
	 * Return the enabled status of a menu
	 *
	 * @param index the index of the menu instance
	 *
	 * @returns a Boolean of the enabled state of the specified menu
	 *
	 * @tiptext Return the enabled state of the menu item at a specific index.
	 * @helpid 3447
	 */
	function getMenuEnabledAt(index)
	{
		return __menuBarItems[index].enabled;
	}


	/**
	* Load the state from the given XMLNode object
	*/
	function setDataProvider(dp)
	{
		removeAll();
		__menuDataProvider = dp;
		dp.isTreeRoot = true;
		var c = dp.childNodes;
		var l = c.length;
		for (var i=0; i<l; i++) {
			insertMenuBarItem(i,c[i]);
		}
	}

	[Bindable(param1="writeonly",type="XML")]
	function get dataProvider() : Object
	{
		return __menuDataProvider;
	}

	function set dataProvider(dp:Object) : Void
	{
		setDataProvider(dp);
	}




	// **************************************************************************
	// Live Preview support MR

	[Inspectable(defaultValue="")]
	function get labels():Array
	{
		return __labels;
	}

	function set labels(lbls:Array):Void
	{
		__labels = lbls;

		var mL = __menuBarItems.length;
		var lL = __labels.length;

		for(var i = 0; i < mL ; i++) {
			removeMenuAt(0);
		}

		for(var i = 0; i < lL; i++) {
			addMenu(__labels[i]);
		}
		redraw(true);
	}


	// **************************************************************************
	// Theme support

	function invalidateStyle(propName : String) : Void
	{
		super.invalidateStyle(propName);
		if (propName=="fontFamily" || propName=="fontSize" || propName=="fontWeight" || propName=="styleName") {
			invUpdateDisplay = true;
			invUpdateSize = true;
			invalidate();
		}
		for(var i = 0; i < __menuBarItems.length; i++) {
			getMenuAt(i).invalidateStyle(propName);
		}
	}

	function changeColorStyleInChildren(sheet, styleProp:String, newValue) : Void
	{
		super.changeColorStyleInChildren(sheet, styleProp, newValue);
		for(var i = 0; i < __menuBarItems.length; i++) {
			getMenuAt(i).changeColorStyleInChildren(sheet, styleProp, newValue);
		}

	}

	function notifyStyleChangeInChildren(sheet, styleProp:String, newValue)
	{
		super.notifyStyleChangeInChildren(sheet, styleProp, newValue);
		for(var i = 0; i < __menuBarItems.length; i++) {
			getMenuAt(i).notifyStyleChangeInChildren(sheet, styleProp, newValue);
		}
	}


	// **************************************************************************
	// Display support

	// Layout current representation of items

	function updateDisplay(resize:Boolean) : Void
	{
		delete invUpdateDisplay;
		delete invUpdateSize;
		var lastX : Number = __marginWidth;
		var lastW:Number = 0;
		var len : Number = __menuBarItems.length;

		for(var i=0; i<len; i++) {

			var item = __menuBarItems[i];
			item._visible = true;
			item.menuBarIndex = i;
			getMenuAt(i).menuBarIndex = i;
			if (resize)
				item.setSize(item.getPreferredWidth(), __height);

			lastX = item._x = lastX+lastW;
			lastW = item.__width;
		}
	}


	// Update the width and placement of the background graphic

	function updateBackgroundDisplay()
	{
		mask_mc._width = width;
		mask_mc._height = height;
		var b = background_mc;
		b._height = __height;

		b.bckLeft._x = 0;
		var bLeftW = b.bckLeft._width;
		b.bckCenter._width = __width - (bLeftW + b.bckRight._width);
		b.bckCenter._x = bLeftW;
		b.bckRight._x = bLeftW + b.bckCenter._width;
	}



	// Show a menuBarItem's menu

	function showMenu(index:Number) : Void
	{
		openMenuIndex = index;
		var item = __menuBarItems[index];
 		var mdp = item.dP;
 		if (__menus[mdp.getID()]==undefined) {
 
 			var newMenu = Menu.createMenu(_parent._root, mdp, {styleName:this, menuBarIndex:index});
 
 			__menus[mdp.getID()] = newMenu;
 
 			newMenu.__menuBar = this;
 			newMenu.addEventListener("menuHide", this);
 			newMenu.addEventListener("rollOver", this);
 			newMenu.addEventListener("rollOut", this);
 			newMenu.addEventListener("menuShow", this);
 			newMenu.addEventListener("change", this);
 			newMenu.border_mc.borderStyle = "menuBorder";
 			newMenu.labelField = labelField;
 			newMenu.labelFunction = labelFunction;
 
 
 			newMenu.__activator = item; // menu needs this for a hitTest when clicking outside menu area
 
 		}
 
		var pt = {x:0, y:0};
		item.setLabelBorder("falsedown");
		item.localToGlobal(pt);
		var menu = getMenuAt(index);
 		// popups go on the root of the swf which if loaded, is not
 		// necessarily at 0,0 in global coordinates
 		menu._root.globalToLocal(pt);
		menu.focusManager.lastFocus = undefined;
		menu.show(pt.x, pt.y + (item._height+1));
	}


	function removeMenuBarItemAt(index)
	{
		var item = __menuBarItems[index];
		var menu = item.__menu;
		if(item != undefined) {
			menu.removeMovieClip();
			item.removeMovieClip();

			__menuBarItems.splice(index, 1);

			updateDisplay(false);
		}
	}


	private function removeAll()
	{
		// trace("removeAllMenuBarItems::  menuBarItems.length" + __menuBarItems.length);
		while(__menuBarItems.length > 0) {
			var item = __menuBarItems[0];
			var menu = item.__menu;

			menu.removeMovieClip();
			item.removeMovieClip();

			__menuBarItems.splice(0, 1);
		}

		updateDisplay(false);
	}


	// **************************************************************************
	// Mouse Event Handlers


	function onItemRollOver(index:Number) : Void
	{
		//    trace(" **** onItemRollOver **** ");
		var newItem = __menuBarItems[index];
		if(openMenuIndex!=undefined){
			var oldIndex = openMenuIndex;
			if(oldIndex != index) {
				// Deactivate the old
				isDown = false;
				var oldItem = __menuBarItems[oldIndex];
				onItemRelease(oldIndex);
				oldItem.setLabelBorder("none");
				// Activate the new
				showMenu(index);
				isDown = true;
			}
		}
		else {
			newItem.setLabelBorder("falserollover");
			isDown = false;
		}
	}


	function onItemPress(index : Number) : Void
	{

		//    trace(" **** onItemPress **** ");
		var item = __menuBarItems[index];
		if(!isDown) {
			showMenu(index);
			isDown = true;
		}else{
			item.setLabelBorder("falsedown");
			isDown = false;
		}
		pressFocus();
	}


	function onItemRelease(index : Number)
	{
		//    trace(" **** onItemRelease **** ");
		var item = __menuBarItems[index];
		if (!isDown) {
			getMenuAt(index).hide();
			item.setLabelBorder("falserollover");
		}
		releaseFocus();
	}


	function onItemRollOut(index : Number)
	{
		//    trace(" **** onItemRollOut **** ");
		if(openMenuIndex != index) {
			__menuBarItems[index].setLabelBorder("none");
		}
	}


	function onItemDragOver(index : Number)
	{

		var item = __menuBarItems[index];
		if(openMenuIndex!=undefined) {
			var oldIndex = openMenuIndex;
			if(oldIndex != index) {
				isDown = false;
				var oldItem = __menuBarItems[oldIndex];
				onItemRelease(oldIndex);
				oldItem.setLabelBorder("none");
			}
		}
		else{
			isDown = true;
		}

		onItemPress(index);
	}


	function onItemDragOut(index : Number)
	{
		//    trace(" **** onItemDragOut **** ");
		onItemRollOut(index);
	}

	// **************************************************************************
	// Keyboard Navigation Handlers

	function keyDown(e:Object) : Void
	{

		var barLen = __menuBarItems.length;
		var mbItem;

		if (e.code == Key.RIGHT || e.code == Key.LEFT) {
			if (openMenuIndex==undefined) openMenuIndex = -1;
			var nextIndex = openMenuIndex;

			var found=false;
			var count=0;
			while(!found && count<barLen) {
				count++;
				nextIndex =  (e.code==Key.RIGHT) ? nextIndex+1 : nextIndex-1;

				if (nextIndex>=barLen) {
					nextIndex = 0;
				} else if (nextIndex<0) {
					nextIndex = barLen-1;
				}
				if (__menuBarItems[nextIndex].enabled)
					found=true;
			}
			if (count<=barLen)
				onItemRollOver(nextIndex); // trigger next item in the bar
		}

		// Handle Key.DOWN Navigation

		if (Key.isDown(Key.DOWN)) {

			if (openMenuIndex!=undefined) {
				var menu = getMenuAt(openMenuIndex);
				menu.focusEnabled = true; // enabled selection
				menu.moveSelBy(1);
				supposedToLoseFocus = true;
				Selection.setFocus(menu);
	//			drawFocus(true);
			}
		}

		// Handle Key.ENTER/ESCAPE Commands

		if (Key.isDown(Key.ENTER) || Key.isDown(Key.ESCAPE)) {
			getMenuAt(openMenuIndex).hide();
		}
	}
	
	private static var MenuBarItemDependency = mx.controls.menuclasses.MenuBarItem;
	private static var MenuRowDependency = mx.controls.menuclasses.MenuRow;
	
}