//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.events.EventDispatcher;

/* ============================================================================

	XMLNode Mix-in Methods (FTreeDataProvider methods)
	nig 05.22.03

	To get the functionality we want out of the XML object, a few methods need to be mixed
	directly onto XMLNode, since the XML object is composed
	of XMLNode objects. The methods will allow us to broadcast changes to the
	registered views, and provide the extra methods users will want to make XML construction
	easier.
=============================================================================*/

class mx.controls.treeclasses.TreeDataProvider extends Object
{



//::: BEGIN BLOCK : USED FOR MIXIN MANAGEMENT ONLY

	static var mixinProps : Array = ["addTreeNode", "addTreeNodeAt", "getTreeNodeAt", "removeTreeNodeAt",
							"getRootNode", "getDepth", "removeAll", "removeTreeNode", "updateViews"];


	//make sure we have a link to the package we depend on at static time
	static var evtDipatcher = mx.events.EventDispatcher;

	// Initialize is called to apply the mixinProps above to the given object's prototype.
	// Typical usage : TreeDataProvider.Initialize(XMLNode);
	static function Initialize(func:Function) : Boolean
	{
		var obj = func.prototype;
		if (obj.addTreeNode!=undefined) return false;
		var m = mixinProps;
		var l = m.length;


		for (var i=0; i<l; i++) {
			obj[m[i]] = mixins[m[i]];
			_global.ASSetPropFlags(obj, m[i],1);
		}

		// add ability to broadcast events
		EventDispatcher.initialize(obj);
		_global.ASSetPropFlags(obj, "addEventListener",1);
		_global.ASSetPropFlags(obj, "removeEventListener",1);
		_global.ASSetPropFlags(obj, "dispatchEvent",1);
		_global.ASSetPropFlags(obj, "dispatchQueue",1);
		_global.ASSetPropFlags(obj, "createEvent",1);

		return true;
	}


	static var mixins: TreeDataProvider = new TreeDataProvider();

	/*   dynamically adds Properties to the object passed,
	builds inline functions to be passed to addProperty	*/
	function createProp(obj : Object, propName:String, setter:Boolean) : Void
	{
		var p = propName.charAt(0).toUpperCase() + propName.substr(1);
		var s = null;
		var g = function(Void)
		{
			return this["get" + p]();
		};
		if (setter) {
			s = function(val)
			{
				this["set" + p](val);
			};
		}
		obj.addProperty(propName, g, s);

	}


//::: END MIXIN MANAGEMENT BLOCK. BEGIN ACTUAL CLASS CODE HERE.



	// Used for Node creation and other helper functions
	static var blankXML = new XML();
	// Keep track of the latest treenode ID (this will let us move from one tree to another).
	static var largestID = 0;

	/*::: STATIC Method ConvertToNode

		  Arguments :
		  tag (element tag name)
			label (string OR XML object)
			[data] (string)
		  returns :
			an XMLNode

		Note that in the case of xmlObj, the first childNode is copied
		out of the DOM
	*/
	static function convertToNode(tag, arg, data)
	{
		if (typeof(arg) == "string") {
			var tmpNode = TreeDataProvider.blankXML.createElement(tag);
			tmpNode.attributes.label = arg;
			if (data != undefined)
				tmpNode.attributes.data = data;
			return tmpNode;
		}
		//-!! not sure about this case below.
		else if (arg instanceof XML) {
			return arg.firstChild.cloneNode(true);
		}
		else if (arg instanceof XMLNode) {
			return arg;
		}
		else if (typeof(arg) == "object") {
			var tmpNode = TreeDataProvider.blankXML.createElement(tag);
			for (var i in arg) {
				tmpNode.attributes[i] = arg[i];
			}
			if (data != undefined)
				tmpNode.attributes.data = data;
			return tmpNode;
		}
	}


	//::: From XMLNode mixin
	var childNodes : Array;
	var attributes : Object;
	var parentNode : Object;
	var hasChildNodes : Function;
	var appendChild : Function;
	var removeNode : Function;
	var insertBefore : Function;

	//::: From EventDispatcher mixin
	var dispatchEvent : Function;


	function TreeDataProvider()
	{

	}


	// adds a single node  (arg can be a string or an XML object)
	function addTreeNode(arg, data)
	{
		return addTreeNodeAt(childNodes.length, arg, data);
	}


	// adds a single node  (arg can be a string or an XML object)
	function addTreeNodeAt(index, arg, data)
	{
		if (index > childNodes.length) return;

		var node;
		if (arg instanceof XMLNode) {
//			trace("an instance of XMLNODE");
			node = arg.removeTreeNode();
		} else {
			node = TreeDataProvider.convertToNode("node", arg, data);
		}
		if (index>=childNodes.length) {
			appendChild(node);
		} else {
			insertBefore(node, childNodes[index]);
		}
//		var r = getRootNode();
		updateViews( { eventName: "addNode", node: node,
				parentNode: this, index: index } );
		return node;
	}


	function getTreeNodeAt(index)
	{
		return childNodes[index];
	}


	function removeTreeNodeAt(index)
	{
		var target = childNodes[index];
		target.removeNode();
//		var rN = getRootNode();
		updateViews( { eventName: "removeNode", node: target,
				parentNode: this, index: index } );

		return target;
	}


	function removeTreeNode()
	{
		var p = parentNode;
		// Locate the node's within its parent
		var index;
		var i = 0;
		var sib = parentNode.firstChild;
		while (sib != undefined) {
			if (sib == this) {
				index = i;
				break;
			}
			i++;
			sib = sib.nextSibling;
		}

		// If index is undefined, then it must not have a parent!
		if(index != undefined) {
			var rN = getRootNode();
			this.removeNode();

			p.updateViews( { eventName: "removeNode", node: this,
					parentNode: p, index: index } );
		}
		return this;
	}


	function removeAll()
	{
		while(childNodes.length > 0) {
			removeTreeNodeAt(childNodes.length-1);
		}
		var rN = getRootNode();
		updateViews( { eventName: "updateTree" } );
	}


	function getRootNode()
	{
		var rootNode = this;

		while(rootNode.parentNode != undefined && rootNode.isTreeRoot==undefined) {
			rootNode = rootNode.parentNode;
		}

		return rootNode;
	}


	//::: PRIVATE METHODS / PROPERTIES


	function updateViews(eventObj)
	{
		var node = this;
		eventObj.target = this;
		eventObj.type = "modelChanged";
	//	trace("update views");
		while (node!=undefined) {
			if (node.isTreeRoot || node.parentNode==undefined) {
				node.dispatchEvent(eventObj);
			}
			node = node.parentNode;
		}
	}
}
