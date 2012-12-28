//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.ScrollSelectList;
import mx.controls.menuclasses.MenuDataProvider;
import mx.controls.treeclasses.TreeDataProvider;
import mx.effects.Tween;
import mx.managers.PopUpManager;

[RequiresDataBinding(true)]
[IconFile("Menu.png")]
[InspectableList("rowHeight")]

/**
* @tiptext menuHide event
* @helpid 3034
*/
[Event("menuHide")]
/**
* @tiptext menuShow event
* @helpid 3035
*/
[Event("menuShow")]

/**
* Menu class
* - extends ScrollSelectList
* - gives the user the ability to select an option from a scrolling list
* @tiptext Provides the ability to select select an option from a scrolling list.
* @helpid 3433
*/
class mx.controls.Menu extends ScrollSelectList
{
	// **************************************************************************
	// System Infrastructure

	/*
	* @private
	* SymbolName for object
	*/
	static var symbolName:String = "Menu";
	/*
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = Menu;

	/*
	* @private
	* className for object
	*/
	var	className:String = "Menu";

		// Version string
//#include "../core/ComponentVersion.as"


	// **************************************************************************
	// Static initialization

	static var mixit : Boolean = TreeDataProvider.Initialize(XMLNode);
	static var mixit2 : Boolean = MenuDataProvider.Initialize(XMLNode);


	// **************************************************************************
	// Menu Factory

	/**
	 * Return the Menu instance described by the given MenuDataProvider, and
	 * place the instance in the given parent container.
	 *
	 * @param parent the container
	 * @param mdp a MenuDataProvider to base the menu on
	 * @returns a Menu instance, already placed inside the parent, but invisible
	 *
	 * @tiptext Static function to create a menu instance
	 * @helpid 3139
	 */
	public static function createMenu(parent, mdp, initObj)
	{
		if(parent == undefined) {
			parent = _root;
		}

 		var pt = new Object();
 		pt.x = parent._root._xmouse;
 		pt.y = parent._root._ymouse;
 		parent._root.localToGlobal(pt);

		if(mdp == undefined) {
			mdp = new XML();
		}
//		parent.trackAsMenu = true;

		var result = PopUpManager.createPopUp(parent, mx.controls.Menu, false, initObj, true);
		if(result == undefined) {
			trace("Failed to create a new menu, probably because there is no Menu in the Library");
		}
		else {
			result.isPressed = true;
			result.mouseDownOutsideHandler = function(event) : Void
			{
				if(!this.isMouseOverMenu() && !this.__activator.hitTest(pt.x, pt.y)) {
					this.hideAllMenus();
				}
			};

			result.dataProvider = mdp;
		}
		return result;
	}


	/**********************
	   utilities for querying an item's state
	********************/
	public static function isItemEnabled(itm : Object) : Boolean
	{
		var val = itm.attributes.enabled;
		return ((val==undefined || val==true || val.toLowerCase()=="true") && itm.attributes.type.toLowerCase()!="separator");
	}

	public static function isItemSelected(itm : Object) : Boolean
	{
		var val = itm.attributes.selected;
		return (val==true || val.toLowerCase()=="true");
	}

	// **************************************************************************
	// Instance fields

	// Pre-sets on ScrollSelectList fields
	var __hScrollPolicy : String = "off";
	var __vScrollPolicy : String = "off";
	var __rowRenderer : String = "MenuRow";
	var __rowHeight : Number = 19;


	// MDP will be used to hold the overall XML doc, but we'll still be
	// manipulating ScrollSelectList's __dataProvider as the "displayList" for
	// each individual submenu
	var __menuDataProvider : Object; // for now, its really XML
	var __wasVisible = false;
	var __menuBar;		// MenuBar (optional)
	var __activator;	// MenuBarItem (optional)
	var __parentMenu : Menu;
	var __menuCache : Object;
	var __namedItems : Object;
	var __radioGroups : Object;
	var __enabled:Boolean = true;

	var __openDelay : Number = 250; // default delayTime in mSec
	var __closeDelay : Number = 250; // default delayTime in mSec
	var __delayQueue : Array = new Array();
	var __timer; // container for setInterval delay
	var __timeOut; // container for setInterval delay

	var __anchor : Number; // reference to the ID of the last opened submenu within a menu level
	var __anchorIndex : Number; // reference to the rowIndex of a menu's anchor in the parent menu
	var __activeChildren : Object; // list of submenus within a menu level
	var anchorRow : Object; // temp variable for detecting if a row is "selected" as an anchor.

	var __lastRowRolledOver : Number; // used for re-entrant key navigation
	var menuBarIndex: Number;

	var popupTween : Tween;
	var popupMask : MovieClip;
	var __iconField = "icon";
	var invUpdateSize : Boolean;
	var supposedToLoseFocus : Boolean;
	var wasJustCreated:Boolean;
	var _selection:Object;
	var _members:Object;

	[Bindable(param1="writeonly",type="XML")]
	var	_inherited_dataProvider:Array;

	// **************************************************************************
	// Lifecycle

	/**
	 * Constructor
	 */
	public function Menu() {}


	// **************************************************************************
	// UIObject extensions

	/**
	 * Generic initializer
	 */
	function init(Void) : Void
	{
		super.init();
		visible = false;
	}


	/**
	 * Child construction
	 */
	function createChildren(Void) : Void
	{
		super.createChildren();

		listContent.setMask(MovieClip(mask_mc));
		mask_mc.removeMovieClip();

		border_mc.move(0, 0);
		border_mc.borderStyle = "menuBorder"; // Change to "outset" to return to default
	}

	function propagateToSubMenus(prop:String, value)
	{
		// note: only root menu will have a non-empty menuCache
		for (var i in __menuCache) {
			var m = __menuCache[i];
			if (m!=this) {
				m["set"+prop](value);
			}
		}
	}

	function setLabelField(lbl:String)
	{
		super.setLabelField(lbl);
		propagateToSubMenus("LabelField", lbl);
	}


	function setLabelFunction(lbl:Function)
	{
		super.setLabelFunction(lbl);
		propagateToSubMenus("LabelFunction", lbl);
	}


	function setCellRenderer(cR) : Void
	{
		super.setCellRenderer(cR);
		propagateToSubMenus("CellRenderer", cR);
	}


	function setRowHeight(v : Number) : Void
	{
		super.setRowHeight(v);
		propagateToSubMenus("RowHeight", v);
	}

	function setIconField(v : String) : Void
	{
		super.setIconField(v);
		propagateToSubMenus("IconField", v);
	}

	function setIconFunction(v : Function) : Void
	{
		super.setIconFunction(v);
		propagateToSubMenus("IconFunction", v);
	}

	function size(Void) : Void
	{
		super.size();
		var o = getViewMetrics();
		layoutContent(o.left, o.top, __width - o.left - o.right, __height - o.top - o.bottom);
	}


	function draw(Void) : Void
	{
		if (invRowHeight) {
			super.draw();
			listContent.setMask(MovieClip(mask_mc));
			invUpdateSize = true;
		}
		super.draw();
		if (invUpdateSize) {
			updateSize();
		}
	}

	function onSetFocus()
	{
		super.onSetFocus();
		getFocusManager().defaultPushButtonEnabled = false;
	}



	// **************************************************************************
	// Accessor support


	public function setDataProvider(dP) : Void
	{
		// Translate if necessary
		if (typeof(dP) == "string") {
			dP = (new XML(dP)).firstChild;
		}

		// Out with the old...
		__menuDataProvider.removeEventListener("modelChanged", this);

		// In with the new...
		__menuDataProvider = dP;
		if (!(__menuDataProvider instanceof XML))
			__menuDataProvider.isTreeRoot = true;
		__menuDataProvider.addEventListener("modelChanged", this);
		modelChanged({eventName:"updateTree"});
	}


	public function getDataProvider() : Object
	{
		return __menuDataProvider;
	}


	// **************************************************************************
	// Menu API

	/**
	 * Append a menu item at the end of this menu.
	 *
	 * @param arg may be either (1) a String (to be used as the item's label),
	 * (2) an Object (whose properties will be copied into the resulting XMLNode's
	 * attributes), (3) an XMLNode (used directly), or (4) an XML instance whose
	 * firstChild will be cloned and used.
	 *
	 * @returns an XMLNode carrying a representation of the menu item's state
	 *
	 * @tiptext Append a new menu item to the menu
	 * @helpid 3141
	 */
	public function addMenuItem(arg : Object) : Object
	{

		return __menuDataProvider.addMenuItem(arg);
	}


	/**
	 * Insert a menu item into this menu.
	 *
	 * @param index the index where the item should be inserted
	 * @param arg may be either (1) a String (to be used as the item's label),
	 * (2) an Object (whose properties will be copied into the resulting XMLNode's
	 * attributes), (3) an XMLNode (used directly), or (4) an XML instance whose
	 * firstChild will be cloned and used.
	 *
	 * @returns an XMLNode carrying a representation of the menu item's state
	 *
	 * @tiptext Insert a new menu item into the menu at the given index
	 * @helpid 3142
	 */
	public function addMenuItemAt(index:Number, arg:Object) : Object
	{
		return __menuDataProvider.addMenuItemAt(index, arg);
	}


	/**
	 * Remove the item at a given index from the menu.  If there's no item
	 * at the given index, then do nothing and return undefined.
	 *
	 * @param index the index of the item to be removed
	 * @returns a reference to the XMLNode that was removed (if any)
	 *
	 * @tiptext Remove the indicated menu item from the menu
	 * @helpid 3143
	 */
	public function removeMenuItemAt(index:Number) : Object
	{
		var item = getMenuItemAt(index);
		if((item != undefined) && (item != null)) {
			item.removeMenuItem();
		}

		return item;
	}


	/**
	 * Remove an item from the menu.  If it doesn't belong to this Menu,
	 * then do nothing and return undefined.
	 *
	 * @param item the item to be removed
	 * @returns a reference to the XMLNode that was removed, or undefined
	 * if the given item does not belong to this Menu instance.
	 *
	 * @tiptext Remove the given menu item from the menu
	 * @helpid 3144
	 */
	public function removeMenuItem(item:Object) : Object
	{
		return removeMenuItemAt(indexOf(item));
	}


	/**
	 * Remove all items from the menu.
	 *
	 * @tiptext Remove all menu items from the menu
	 * @helpid 3145
	 */
	public function removeAll(Void) : Object // returns XML node
	{
		return __menuDataProvider.removeAll();
	}


	/**
	 * Retrieve a menu item from this menu
	 *
	 * @param index the index of the item to be retrieved
	 * @returns a reference to the XMLNode that was removed
	 *
	 * @tiptext Return the menu item at a specific index
	 * @helpid 3146
	 */
	public function getMenuItemAt(index:Number) : Object
	{
		return __menuDataProvider.getMenuItemAt(index);
	}


	/**
	 * Mark a menu item as 'selected' (or not), and notify listeners.
	 *
	 * @param item the target item
	 * @param select a boolean indicating whether the item is selected or not
	 *
	 * @tiptext Select or deselect a menu item
	 * @helpid 3147
	 */
	public function setMenuItemSelected(item:Object, select:Boolean) : Void
	{
		if (item.attributes.type=="radio") {
			var r = getRootMenu();
			groupName = item.attributes.groupName;
			r[groupName].setGroupSelection(item);
			return;
		}
		if(select != item.attributes.selected) {
//			var r = item.getRootNode();
			item.attributes.selected = select;
			item.updateViews( { eventName:"selectionChanged", node:item } );
		}
	}


	/**
	 * Mark a menu item as 'enabled' (or not), and notify listeners.
	 *
	 * @param item the target item
	 * @param enable a boolean indicating whether the item is enabled or not
	 *
	 * @tiptext Enable/disable a menu item
	 * @helpid 3148
	 */
	public function setMenuItemEnabled(item:Object, enable:Boolean) : Void
	{
		if(enable != item.attributes.enabled) {
			item.attributes.enabled = enable;
//			var r = item.getRootNode();
			item.updateViews( { eventName:"enabledChanged", node:item } );
		}
	}


	/**
	 * Return the index of the given item within this menu.  If
	 * the target item does not belong to this menu, then return
	 * undefined.
	 *
	 * @param item the target item
	 * @returns the index of the given item, or undefined
	 *
	 * @tiptext Return the index of the given menu item within the menu
	 * @helpid 3149
	 */
	public function indexOf(item : Object) : Number
	{
		return __menuDataProvider.indexOf(item);
	}


	/**
	 * If the Menu isn't presently visible, place the top-left corner
	 * at the given coordinates within the parent, resize the menu as
	 * needed, and make it visible.  This method also fires a "show"
	 * event to all listeners.
	 *
	 * @param x (optional) the horizontal location of the top-left corner
	 * @param y (optional) the vertical location of the top-left corner
	 *
	 * @tiptext Make the menu visible
	 * @helpid 3150
	 */
	public function show(x:Number, y:Number) : Void
	{
		if(!visible) {
			// Fire an event
			var r = getRootMenu();
			r.dispatchEvent({type:"menuShow", menuBar:__menuBar, menu:this, menuItem:__menuDataProvider});

			// Position it
			if(x != undefined)
			{
				_x = x;

				if(y != undefined)
				{
					_y = y;
				}
			}

			// Adjust for menus that extend out of bounds
			if(this != r){
				var shift = (_x + _width) - Stage.width;
				if(shift > 0) {
					_x = _x - shift;
					if(_x < 0) {
						_x = 0;
					}
				}
			}

			// Make it visible
			popupMask = attachMovie("BoundingBox", "pMask_mc", 6000);
			this.setMask(popupMask);
			var pW = width;
			if (pW < 50)
				pW = 100;
			popupMask._width = pW;
			popupMask._height = height;
			popupMask._x = 0 - popupMask._width;
			popupMask._y = 0 - popupMask._height;
			var pD = getStyle("popupDuration");
			if (this.wasJustCreated && pD<200) {
				pD = 200;
				delete this.wasJustCreated;
			}
			popupTween = new Tween(this, [popupMask._x,popupMask._y], [0,0], pD);

			visible = true;
			isPressed = true;
			if(!__menuBar && r==this){
				Selection.setFocus(this);
			}
		}
	}

	function onTweenUpdate(val : Array) : Void
	{
		popupMask._width = width;
		popupMask._x = val[0];
		popupMask._y = val[1];
	}

	function onTweenEnd(val : Array) : Void
	{
		popupMask._x = val[0];
		popupMask._y = val[1];
		this.setMask(undefined);
		popupMask.removeMovieClip();
	}

	/**
	 * If the Menu is visible, hide it and any visible submenus.
	 *
	 * @tiptext Make the menu invisible.
	 * @helpid 3151
	 */
	public function hide(Void) : Void
	{
		if(visible) {
			// Hide the children
			for (var i in __activeChildren) {
				__activeChildren[i].hide();
			}

			__lastRowRolledOver = undefined;

			clearSelected();
			if (anchorRow!=undefined)
				anchorRow.highlight._visible = false;

			visible = false;
			isPressed = false;
			__wasVisible = false;

			// Fire an event
			var r = getRootMenu();
			r.dispatchEvent({type:"menuHide", menuBar:__menuBar, menu:this, menuItem:__menuDataProvider});
		}
	}

	function onKillFocus()
	{
		super.onKillFocus();
		getFocusManager().defaultPushButtonEnabled = true;
		if (supposedToLoseFocus==undefined) {
			hideAllMenus();
		}
		delete supposedToLoseFocus;
	}

	// **************************************************************************
	// Event handlers

	public function modelChanged(eventObj)
	{
		var eventName = eventObj.eventName;

		if (eventName == "updateTree") {
//			trace("updateTree BEFORE:  " + __menuDataProvider);
			// Detach the old
			__dataProvider.removeAll();

			// Rebuild the DataProvider

			__dataProvider.addItemsAt(0, __menuDataProvider.childNodes);
			invUpdateSize = true;
			invalidate();
			super.modelChanged({eventName : "updateAll"});

			// Keep track of named items & radiogroups...
			deinstallAllItems();
			installItem(__menuDataProvider);

			// Cache the root menu, too
			if(__menuCache == undefined) {
				__menuCache = new Object();
			}
			__menuCache[__menuDataProvider.getID()] = this;

		}
		else if (eventName == "addNode" || eventName=="removeNode") {
			var menuItem = eventObj.node;
			var parentNode = eventObj.parentNode;


			// Add the item to the parent Menu instance
			var parentMenu = __menuCache[parentNode.getID()];
			if (eventName=="removeNode") {
				deleteDependentSubMenus(menuItem);
				parentMenu.removeItemAt(eventObj.index);
				deinstallItem(menuItem);
			} else {
				parentMenu.addItemAt(eventObj.index, menuItem);
				installItem(menuItem);
			}
			parentMenu.invUpdateSize = true;
			parentMenu.invalidate();
			var gPMenu = __menuCache[parentNode.parentNode.getID()];
			gPMenu.invUpdateControl = true;
			gPMenu.invalidate();

			// Add implied named items & radiogroups...

		}
		else if (eventName == "selectionChanged" || eventName == "enabledChanged") {
			// Update the parent Menu instance
			var parentMenu = __menuCache[eventObj.node.parentNode.getID()];
			parentMenu.invUpdateControl = true;
			parentMenu.invalidate();
		}
		else {
			super.modelChanged(eventObj);
		}
	}


	// **************************************************************************
	// Display support

	// Update the overall size in response to an item being added or removed
	private function updateSize():Void
	{
		delete invUpdateSize;
		var cH = calcHeight();
		if (getLength()!=__rowCount) {
			setSize(0,cH);
		}
		setSize(calcWidth(), cH);
	}


	private function calcWidth() : Number
	{
		var result = -1;
		var w;
		for(var i = 0; i < rows.length; i++) {
			w = rows[i].getIdealWidth();
			if(w > result) {
				result = w;
			}
		}
		var tI = getStyle("textIndent");
		if (tI==undefined) tI=0;
		return result+tI;
	}


	private function calcHeight() : Number
	{
		var m = getViewMetrics();
		return __dataProvider.length * __rowHeight + m.top + m.bottom;
	}


	// **************************************************************************
	// Theme support


	function invalidateStyle(propName : String) : Void
	{
		super.invalidateStyle(propName);
		for(var j in __activeChildren){
			__activeChildren[j].invalidateStyle(propName);
		}
	}

	function notifyStyleChangeInChildren(sheetName, styleProp, newValue) :Void
	{

		super.notifyStyleChangeInChildren(sheetName, styleProp, newValue);
		for(var j in __activeChildren){
			__activeChildren[j].notifyStyleChangeInChildren(sheetName, styleProp, newValue);
		}
	}


	// **************************************************************************
	// Internal operations

	private function deleteDependentSubMenus(menuItem:Object)
	{
		var subs = menuItem.childNodes;
		for(var i in subs) {
			deleteDependentSubMenus(subs[i]);
		}

		var subMenu = __menuCache[menuItem.getID()];
		if(subMenu != undefined) {
			subMenu.hide();
			delete __menuCache[menuItem.getID()];
		}
	}


	/**
	 * Install support structures for named items and radio-groups.
	 * For named items, add properties to the root Menu object that
	 * refer to them.  For radio items, add them to the implied
	 * radio-group.  Do the same for sub-items.
	 */
	private function installItem(item:Object) : Void
	{
		// Add information associated with the item

		// If it's an named item, then add it
		if(item.attributes.instanceName != undefined) {
			var id = item.attributes.instanceName;

			if(this[id] != undefined) {
				trace("WARNING:  Duplicate menu item instanceNames - " + id);
			}

			// Keep track of the items' names, so they can be cleared
			if(__namedItems == undefined) {
				__namedItems = new Object();
			}
			__namedItems[id] = item;

			// Attach the named item to the root menu object
			this[id] = item;
		}

		// If it's in a radio-group, then add it
		if((item.attributes.type == "radio") &&
				(item.attributes.groupName != undefined))
		{
			// Get the group object
			var groupName = item.attributes.groupName;
			var group = this[groupName];
			if(group == undefined)
			{
				// Create a group object
				group = new Object();
				group.name = groupName;
				group._rootMenu = this;
				group._members = new Object();
				group._memberCount = 0;
				group.getGroupSelection = getGroupSelection;
				group.setGroupSelection = setGroupSelection;
				group.addProperty("selection", group.getGroupSelection , group.setGroupSelection);

				// Keep track of groups
				if(__radioGroups == undefined) {
					__radioGroups = new Object();
				}
				__radioGroups[groupName] = group;

				// Attach the group to the root menu object
				this[groupName] = group;
			}

			// Add the item to the group
			group._members[item.getID()] = item;
			group._memberCount++;

			// If the item is selected, then it's the group's selected item
			if(isItemSelected(item)) {
				group.selection = item;
			}
		}

		// Add information associated with the item's children
		var subs = item.childNodes;
		for(var i in subs) {
			installItem(subs[i]);
		}
	}


	/**
	 * Scan the given Object (an XMLNode) for sub-elements containing named
	 * items and radio items.  For named items, remove the previously-added
	 * properties from the root Menu object that refer to them.  For radio
	 * items, remove them from the implied radio-group.
	 */
	private function deinstallItem(item:Object) : Void
	{
		// Remove anything associated with the item's children

		var subs = item.childNodes;
		for(var i in subs) {
			deinstallItem(subs[i]);
		}

		// Remove anything associated with the item

		// If it's a named item...
		if(item.attributes.instanceName != undefined) {
			var name = item.attributes.instanceName;
			delete this[name];
			delete __namedItems[name];
		}

		// If it's in a radio-group...
		if((item.attributes.type == "radio") &&
				(item.attributes.groupName != undefined))
		{
			// ...then find the group...
			var groupName = item.attributes.groupName;
			var group = this[groupName];
			if(group == undefined) return;

			// ...and delete the member from the group.
			delete group._members[item.getID()];
			group._memberCount--;

			// If the group is empty now...
			if(group._memberCount == 0) {
				// ...then delete the group
				delete this[groupName];
				delete __radioGroups[groupName];
			}
			else if(group.selection == item) {
				delete group._selection;	// Selected item was deleted
			}
		}
	}


	/**
	 * Clear out the named and radio-group items from this context
	 */
	private function deinstallAllItems(Void) : Void
	{
		// Zap named items
		for(var i in __namedItems) {
			delete this[i];
		}
		delete __namedItems;

		// Zap radio groups
		for(var i in __radioGroups) {
			delete this[i];
		}
		delete __radioGroups;
	}


	// **************************************************************************
	// Group accessors

	// Getter for group.selection
	function getGroupSelection() {
		return this._selection;
	}


	// Setter for group.selection
	function setGroupSelection(item)
	{
		this._selection = item;
		for(var i in this._members) {
			var member = this._members[i];
			member.attributes.selected = (member==item);
		}
//		var r = item.getRootNode();
		item.updateViews( { eventName:"selectionChanged", node:item } );

	}


	// **************************************************************************
	// Mouse-action handlers

	/**
	 * @private
	 * Handle mouse release on an item.
	 *
	 * For separators or items with sub-menu, do nothing.
	 * For check & radio items, toggle state, then fire change event.
	 * For normal items, fire change event.
	 */
	function onRowRelease(rowIndex : Number) : Void
	{
		if (!enabled || !selectable || !visible) return;

		var row = rows[rowIndex];
		var item = row.item;
		if ((item != undefined) && isItemEnabled(item)) {
			var type = item.attributes.type;
			var isChange = (!item.hasChildNodes() && (type != "separator"));

			// If it's a change event, then hide the menus
			if(isChange) {
				// Hide all of the menus
				hideAllMenus();
			}

			// If it's a check item, then toggle it
			var groupName;
			var r = getRootMenu();

			if(type == "check" || type=="radio") {
				setMenuItemSelected(item, !isItemSelected(item));
			}

			if(isChange) {
				r.dispatchEvent({type:"change", menuBar:__menuBar, menu:r,
						menuItem:item, groupName:item.attributes.groupName});
			}
		}
	}


	/**
	 * @private
	 * Extend the behavior from ScrollSelectList to handle row presses over
	 * separators, branch items, and disabled row items.
	 */
	function onRowPress(rowIndex : Number) : Void
	{
		var item = rows[rowIndex].item;

		// only allow action on items that are enabled which are not branches
		if (isItemEnabled(item) && !item.hasChildNodes()){
			super.onRowPress(rowIndex);
		}
	}


	/**
	 * @private
	 * Notify listeners when the mouse leaves
	 */
	function onRowRollOut(rowIndex : Number) : Void
	{
		if (!enabled || !selectable || !visible) return;

		super.onRowRollOut(rowIndex);

		// Fire the appropriate rollout event
		var item = rows[rowIndex].item;
		if (item != undefined) {
			var r = getRootMenu();
			r.dispatchEvent({type:"rollOut", menuBar:__menuBar, menu:this, menuItem:item});
		}

		var menu = __activeChildren[item.getID()];

		// handle submenus and row highlight on exit
		if (item.hasChildNodes()>0) {
			if(menu.isOpening || menu.isOpening == undefined){
				cancelMenuDelay();
				menu.isOpening = false;
			}
			if(menu.visible){
				rows[rowIndex].drawRow(item, "selected", false);
			}
		}else{
			if(menu.isClosing || menu.isClosing == undefined){
				cancelMenuDelay();
				menu.isClosing = false;
			}
		}

		// Check for mouse movement outside menu
		setTimeOut(__closeDelay, item.getID());
	}


	/**
	 * @private
	 * Extend the behavior from ScrollSelectList to pop up submenus
	 */
	function onRowRollOver(rowIndex : Number) : Void
	{
		if (!enabled || !selectable || !visible) return;

		var row = rows[rowIndex];
		var item = row.item;
		var __id = item.getID();
		var prevmenu = __activeChildren[__anchor];
		var menu = __activeChildren[__id];

		clearSelected(); // clear staggered selection from key nav
		clearTimeOut(); // cancel timeout check

		__lastRowRolledOver = rowIndex;

		if (anchorRow!=undefined) {
			anchorRow.drawRow(anchorRow.item, "normal", false);
			delete anchorRow;
		}

		// Anchor row on the parent menu must appear selected
		if(__parentMenu){
			var parentRow = __parentMenu.rows[__anchorIndex];
			parentRow.drawRow(parentRow.item, "selected", false);
			__parentMenu.anchorRow = parentRow;
		}

		// Close grandchild submenus - only children are allowed to be open
		if(menu.__activeChildren[menu.__anchor].visible){
			menu.__activeChildren[menu.__anchor].hide();
		}

		// Close unrelated submenus within this level
		if(prevmenu.visible && (__anchor != __id)){
			prevmenu.isClosing = true;
			setMenuDelay(__closeDelay, "closeSubMenu", {id:__anchor});
		}

		// Send event and update view
		if ((item != undefined) && isItemEnabled(item)) {

			// Fire the appropriate rollover event
			var r = getRootMenu();
			r.dispatchEvent({type:"rollOver", menuBar:__menuBar, menu:this, menuItem:item});

			// Update the view
			if(item.hasChildNodes()>0) {
				anchorRow = row;
				row.drawRow(item, "selected", false);

				if(!menu.visible){
					menu.isOpening = true;
					setMenuDelay(__openDelay, "openSubMenu", {item:item, rowIndex:rowIndex});
				}
			}else{
				row.drawRow(item, "highlighted", false);
			}
		}
	}


	function onRowDragOver(rowIndex : Number) : Void
	{
		var item = __dataProvider.getItemAt(rowIndex + __vPosition);

		// only allow dragover action on items that are enabled
		if (isItemEnabled(item)){
			super.onRowDragOver(rowIndex);
			onRowRollOver(rowIndex);
		}
	}


	// **************************************************************************
	// Menu visibility management

	function __onMouseUp() {
		// >>> COPIED FROM ScrollSelectList
		clearInterval(dragScrolling);
		delete dragScrolling;
		delete isPressed;
		if (!selectable) return;

		if(__wasVisible) {
			hide();
		}

		__wasVisible = false;
	}


	/**
	 * Interval functions used to delay submenu tasks
	 *
	 * setMenuDelay - sets the interval timer or defers to queue
	 * callMenuDelay - calls the delayed function and signals to clear the interval
	 * clearMenuDelay - clears the interval and checks the queue for more tasks
	 * cancelMenuRequest - cancels last request and removes it from the queue
	 * runDelayQueue - cycles through delayed tasks
	 * setTimeOut - sets a timer to test for out of bounds cursor movement
	 * clearTimeOut - clears timeout interval
	 * callTimeOut - checks if cursor is out of bounds from branch item
	 *
	 * openSubMenu - opens a submenu after the specified delay time
	 * closeSubMenu - closes a submenu(s) after the specified delay time
	 */

	function setMenuDelay(delay:Number, request:String, args:Object):Void
	{
		if(__timer == null){
			__timer = setInterval(this, "callMenuDelay", delay, request, args);
		}else{
			__delayQueue.push({delay:delay, request:request, args:args});
		}
	}

	function callMenuDelay(request:String, args:Object):Void
	{
		this[request](args); // call delayed function
		clearMenuDelay();
	}

	function clearMenuDelay(Void):Void
	{
		clearInterval(__timer); // clear the oneshot interval
		__timer = null;
		runDelayQueue(); // check to see if another task is in the queue
	}

	function cancelMenuDelay(Void):Void
	{
		var cancel = __delayQueue.pop(); // cancel last request
		clearMenuDelay();
	}

	function runDelayQueue(Void):Void
	{
		if(__delayQueue.length == 0) return;

		var runTask = __delayQueue.shift();
		var delay = runTask.delay;
		var request = runTask.request;
		var args = runTask.args;

		setMenuDelay(delay, request, args);
	}

	function setTimeOut(delay:Number, id:Number):Void
	{
		clearTimeOut();
		__timeOut = setInterval(this, "callTimeOut", delay, id);
	}

	function clearTimeOut(Void) : Void
	{
		clearInterval(__timeOut);
		__timeOut = null;
	}

	function callTimeOut(Void):Void
	{
		var submenu = __activeChildren[__anchor];
		clearTimeOut();
		if(!isMouseOverMenu() && submenu){
			var rowIndex = submenu.__anchorIndex;
			var item = __dataProvider.getItemAt(rowIndex + __vPosition);
			var row = rows[rowIndex];
			row.drawRow(item, "normal", false);
			submenu.hide();
			__delayQueue.length = 0;
		}
	}

	// open submenu

	function openSubMenu(o:Object) : Void
	{
		var r = getRootMenu();
		var row = rows[o.rowIndex];
		var mdp = o.item;

		var __id = __anchor = mdp.getID();
		var menu = r.__menuCache[__id];

		// check to see if the menu exists, if not create it
		if (menu == undefined) {
			menu = PopUpManager.createPopUp(r, mx.controls.Menu, false, {__parentMenu:this, __anchorIndex:o.rowIndex, styleName:r}, true);
			menu.labelField = r.__labelField;
			menu.labelFunction = r.__labelFunction;
			menu.iconField = r.__iconField;
			menu.iconFunction = r.__iconFunction;
//			menu.popupDuration = 200;
			menu.wasJustCreated = true;
			menu.cellRenderer = r.__cellRenderer;
			menu.rowHeight = r.__rowHeight;
			if (r.__menuCache == undefined) {
				r.__menuCache = new Object();
				r.__menuCache[r.__menuDataProvider.getID()] = r;
			}
			if (__activeChildren == undefined) __activeChildren = new Object();

			r.__menuCache[__id] = menu; // store a root reference to this menu
			__activeChildren[__id] = menu; // store a local reference to active submenus

			// addItems to it
			menu.__dataProvider.addItemsAt(0, mdp.childNodes);
			menu.invUpdateSize = true;
			menu.invalidate();
		}
		menu.__menuBar = __menuBar;
		var pt = {x:0,y:0};
		row.localToGlobal(pt);
		row._root.globalToLocal(pt);
		menu.focusManager.lastFocus = undefined;
		menu.show(pt.x + row.__width, pt.y);
		focusManager.lastFocus = undefined;
		menu.isOpening = false;
	}


	// close submenu

	function closeSubMenu(o:Object) : Void
	{
		var menu = __activeChildren[o.id];
		menu.hide();
		menu.isClosing = false;
	}


	// **************************************************************************
	// Handle Key Events

	// overwrite super's moveSelBy for altered functionality
	// - need to include setVPosition calls if scolling is added

	function moveSelBy(incr : Number) : Void
	{
		var curIndex = getSelectedIndex();
		if (curIndex == undefined) {
			curIndex = -1;
		}

		var newIndex = curIndex + incr;

		if(newIndex > (__dataProvider.length-1)){
			newIndex = 0;
		}
		else if(newIndex < 0){
			newIndex = __dataProvider.length-1;
		}

		wasKeySelected = true;
 		selectRow(newIndex-__vPosition, false, false);

		var item = __dataProvider.getItemAt(newIndex + __vPosition);

		if(item.attributes.type == "separator"){
			moveSelBy(incr);
		}
	}


	function keyDown(e:Object) : Void
	{
		// Pick up with key navigation where the cursor rollOver left off
		if(__lastRowRolledOver != undefined){
			selectedIndex = __lastRowRolledOver;
			__lastRowRolledOver = undefined;
		}
		//super.keyDown(e);

		var s = selectedItem; // selected rows mdp

		// Handle Key.UP Navigation
		if (Key.isDown(Key.UP)) {

			var r = getRootMenu();
			var menu = r.__menuCache[s.getID()];

			if(s.hasChildNodes() && menu.visible){
				supposedToLoseFocus = true;
				Selection.setFocus(menu);
//				__menuBar.drawFocus(true);
				menu.selectedIndex = menu.rows.length-1;
			}else{
				moveSelBy(-1);
			}
		}


		// Handle Key.DOWN Navigation
		if (Key.isDown(Key.DOWN)) {

			var r = getRootMenu();
			var menu = r.__menuCache[s.getID()];

			if(s.hasChildNodes() && menu.visible){
				supposedToLoseFocus = true;
				Selection.setFocus(menu);
//				__menuBar.drawFocus(true);
				menu.selectedIndex = 0;
			}else{
				moveSelBy(1);
			}
		}


		// Handle Key.RIGHT Navigation
		if (Key.isDown(Key.RIGHT)) {
			if(isItemEnabled(s) && s.hasChildNodes()){
//				focusEnabled = false; // must disable focus in parent menu
				openSubMenu({item:s, rowIndex:selectedIndex});
				var r = getRootMenu();
				var menu = r.__menuCache[s.getID()];
//				menu.focusEnabled = true;
				supposedToLoseFocus = true;
				Selection.setFocus(menu);
//				__menuBar.drawFocus(true);
				menu.selectedIndex = 0;
			}
			else{
				// jump to next sibling in the menubar
				if(__menuBar){
					supposedToLoseFocus = true;
					Selection.setFocus(__menuBar);
					__menuBar.keyDown(e);
				}
			}
		}


		// Handle Key.LEFT Navigation
		if (Key.isDown(Key.LEFT)) {
			if( __parentMenu ){
//				__parentMenu.focusEnabled = true;
				supposedToLoseFocus = true;
				hide(); // hide this menu
				Selection.setFocus(__parentMenu);
//				__menuBar.drawFocus(true);
			}
			else{
				// jump to previous sibling in the menubar
				if(__menuBar){
					supposedToLoseFocus = true;
					Selection.setFocus(__menuBar);
					__menuBar.keyDown(e);
				}
			}
		}


		// Handle Key.ENTER Commands
		if (Key.isDown(Key.ENTER) || Key.isDown(Key.SPACE)) {
			if(isItemEnabled(s) && s.hasChildNodes()){
				openSubMenu({item:s, rowIndex:selectedIndex});
				var r = getRootMenu();
				var menu = r.__menuCache[s.getID()];
 				supposedToLoseFocus = true;
 				Selection.setFocus(menu);
				menu.selectedIndex = 0;
			}
			else{
				onRowRelease(selectedIndex);
			}
		}


		// Handle Key.ESCAPE commands
		if (Key.isDown(Key.ESCAPE) || Key.isDown(Key.TAB)) {
			hideAllMenus();
		}
	}



	// **************************************************************************
	// Internal utilities

	function hideAllMenus(Void)
	{
		getRootMenu().hide();
	}


	function isMouseOverMenu(Void)
	{
 		var pt = new Object();
 		pt.x = _root._xmouse;
 		pt.y = _root._ymouse;
 		_root.localToGlobal(pt);
 		if (border_mc.hitTest(pt.x,pt.y)) {
			return true;
		}

		var r = getRootMenu();
		for (var i in r.__menuCache) {
			var sM = r.__menuCache[i];
			if (sM.visible && sM.border_mc.hitTest(pt.x,pt.y)) {
				return true;
			}
		}
		return false;
	}


	/**
	 * Climb up and find the root menu
	 */
	function getRootMenu(Void) : Menu
	{
		var target = this;
		while (target.__parentMenu != undefined) {
			target = target.__parentMenu;
		}
		return target;
	}


	// Dump the current state of __dataProvider
	/*
	function dumpDataProviderState() {
		for(var i = 0; i < __dataProvider.length; i++) {
			trace("[" + i + "]:  " + __dataProvider[i]);
		}
	}
	*/
	
	private static var MenuRowDependency = mx.controls.menuclasses.MenuRow;
}
