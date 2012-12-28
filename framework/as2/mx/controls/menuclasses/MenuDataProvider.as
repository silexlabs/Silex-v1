//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.treeclasses.TreeDataProvider;

/* ============================================================================

	XMLNode Mix-in Methods (MenuDataProvider methods)
	nig 05.26.03

	To get the functionality we want out of the XML object, a few methods need to be mixed
	directly onto XMLNode, since the XML object is composed
	of XMLNode objects. The methods will allow the user to create specialized XML for displaying
	popup menus
=============================================================================*/

class mx.controls.menuclasses.MenuDataProvider extends Object
{
	// **************************************************************************
	// Mixin support

	static var mixinProps : Array = ["addMenuItem", "addMenuItemAt",
				"getMenuItemAt", "removeMenuItem", "removeMenuItemAt",
				"normalize", "indexOf"];


	// Initialize is called to apply the mixinProps above to the given object's prototype.
	// Typical usage : MenuDataProvider.Initialize(XMLNode);
	static function Initialize(func:Function) : Boolean
	{
		var obj = func.prototype;
		var m = mixinProps;
		var l = m.length;


		for (var i=0; i<l; i++) {
			obj[m[i]] = mixins[m[i]];
			_global.ASSetPropFlags(obj, m[i], 1);
		}

		return true;
	}


	static var mixins: MenuDataProvider = new MenuDataProvider();


	// **************************************************************************
	// Mixin inheritance

	/**
	 * Accessible when mixed-in with XMLNode
	 */
	var attributes : Object;
	var parentNode : Object;
	var childNodes : Array;

	/**
	 * Accessible when mixed-in with TreeDataProvider
	 */
	var addTreeNode : Function;
	var addTreeNodeAt : Function;
	var getTreeNodeAt : Function;
	var removeTreeNode : Function;
	var removeTreeNodeAt : Function;


	function MenuDataProvider()
	{

	}

	// **************************************************************************
	// MenuDataProvider API

	/**
	 * Add an item to this item's submenu.  If this is the first item added,
	 * then the necessary structures will be created to support a submenu.
	 *
	 * @param arg may be either (1) an Object (whose properties will be copied
	 * into the resulting XMLNode's attributes), (2) an XMLNode (used directly),
	 * or (3) an XML instance whose firstChild will be cloned and used.
	 *
	 * @returns an XMLNode carrying a representation of the menu item's state
	 */
	function addMenuItem(arg : Object) : Object
	{
		return addTreeNode(TreeDataProvider.convertToNode("menuitem", arg));
	}


	/**
	 * Insert an item into this item's submenu.  If the index is invalid,
	 * then this call will be ignored.
	 *
	 * @param index the index where the item should be inserted
	 * @param arg may be either (1) an Object (whose properties will be copied
	 * into the resulting XMLNode's attributes), (2) an XMLNode (used directly),
	 * or (3) an XML instance whose firstChild will be cloned and used.
	 *
	 * @returns an XMLNode carrying a representation of the menu item's state
	 */
	function addMenuItemAt(index:Number, arg:Object) : Object
	{
		return addTreeNodeAt(index, TreeDataProvider.convertToNode("menuitem", arg));
	}


	/**
	 * Remove this item from it's parent.
	 *
	 * @returns a reference to the XMLNode that was removed
	 */
	function removeMenuItem(Void) : Object
	{
		return removeTreeNode();
	}


	/**
	 * Remove an item from this item's submenu.
	 *
	 * @param index the index of the item to be removed
	 * @returns a reference to the XMLNode that was removed
	 */
	function removeMenuItemAt(index:Number) : Object
	{
		return getTreeNodeAt(index).removeTreeNode();
	}


	/**
	 * Retrieve a menu item from this menu
	 *
	 * @param index the index of the item to be retrieved
	 * @returns a reference to the XMLNode that was removed
	 */
	function getMenuItemAt(index:Number) : Object
	{
		return getTreeNodeAt(index);
	}


	/**
	 * Return the index of the given item within this item's submenu.  If
	 * the target item does not belong to this item's submenu, then return
	 * undefined.
	 *
	 * @param item the target item
	 * @returns the index of the given item, or undefined
	 */
	function indexOf(item : Object) : Number
	{
		for(var i = 0; i < childNodes.length; i++) {
			if(childNodes[i] == item) {
				return i;
			}
		}
		return undefined;
	}


}