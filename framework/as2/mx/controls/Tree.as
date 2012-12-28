//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.List;
import mx.controls.treeclasses.TreeDataProvider;
import mx.effects.Tween;

[RequiresDataBinding(true)]
[IconFile("Tree.png")]
[InspectableList("multipleSelection", "rowHeight")]


/**
* @tiptext nodeOpen event
* @helpid 3419
*/
[Event("nodeOpen")]
/**
* @tiptext nodeClose event
* @helpid 3420
*/
[Event("nodeClose")]

/**
* Tree class
* - extends List
* @tiptext Tree provides a way to represent and manipulate hierarchical data
* @helpid 3200
*/

class mx.controls.Tree extends List
{


	static var symbolName : String = "Tree";
	static var symbolOwner : Object = Tree;
	var className : String = "Tree";
	//#include "../core/ComponentVersion.as"

	static var mixIt2 : Boolean = TreeDataProvider.Initialize(XMLNode);

	var isNewRowStyle = { depthColors:true, indentation:true, disclosureOpenIcon:true, disclosureClosedIcon:true,folderOpenIcon:true, folderClosedIcon:true, defaultLeafIcon:true };

	//::: Defaults
	var __rowRenderer : String = "TreeRow";
//	var __rowHeight : Number = 400;

	//::: Declarations
	var openNodes : Object;
	var nodeList : Array;
	var rowIndex : Number;
	var opening : Boolean;
	var tween : Object;
	var maskList : Array;
	var rowList : Array;
	var isOpening : Boolean = false;
	var treeDataProvider : Object;
	var nodeIndices : Object;
//	var openDuration : Number = 250;
	var branchNodes : Object;
	var nodeIcons : Object;
	var eventPending : Object;
	var eventAfterTween : Object;
	var minScrollInterval = 50; // slow down scrolling a little

	function Tree()
	{
	}


	// 	::: PUBLIC METHODS


/**
* @tiptext Sets the icon(s) for the specified node
* @param node the node to affect
* @param iconID the linkage ID for the closed (or leaf) icon
* @param iconID2 the linkage ID for the open (or leaf) icon
* @helpid 3201
*/
	function setIcon(node, iconID, iconID2)
	{
		if (nodeIcons==undefined) {
			nodeIcons = new Object();
		}
		if (iconID2==undefined)
			iconID2=iconID;
		var nI = nodeIcons[node.getID()] = {iconID:iconID, iconID2:iconID2};
		invUpdateControl = true;
		invalidate();
	}


/**
* @tiptext Asks the tree if the specified node is a branch
* @param node the node to inspect
* @return true if a branch, false if not
* @helpid 3411
*/
	function getIsBranch(node)
	{
		return (node.hasChildNodes() || branchNodes[node.getID()]!=undefined);
	}

/**
* @tiptext Sets the specified node to explicitly be a branch, even with no children
* @param node the node to affect
* @param branch true if branch, false if not
* @helpid 3412
*/
	function setIsBranch(node, branch)
	{
		if (branchNodes==undefined) {
			branchNodes = new Object();
		}
		if (!branch) {
			delete branchNodes[node.getID()];
		} else {
			branchNodes[node.getID()] = true;
		}
		if (isNodeVisible(node)) {
			invUpdateControl = true;
			invalidate();
		}
	}


	function getNodeDepth(node)
	{
		var count = 0;
		var curNode = node;
		while (curNode.parentNode!=undefined && curNode!=treeDataProvider) {
			count++;
			curNode = curNode.parentNode;
		}
		return count;
	}


/**
* @tiptext Asks the tree if the specified node is open or closed
* @param node the node to inspect
* @return true if open, false if not
* @helpid 3413
*/
	function getIsOpen(node)
	{
		//-!! could require a check for undefined
		return (openNodes[node.getID()] == true);
	}


/**
* @tiptext Tells the tree to open or close the specified node
* @param node the node to affect
* @param open true to open, false to close
* @param animate true to animate the transition, false to not.
* @helpid 3202
*/
	function setIsOpen(node, open, animate, fireEvent)
	{

		// if this can't be opened, or shouldn't be, don't!
		if (!getIsBranch(node) || (getIsOpen(node)==open) || isOpening) return;

		// write down if we're opening (do this later if closing)
		if (open) {
			openNodes[node.getID()]=open;
		}

		// will it affect the displayList?
		if (isNodeVisible(node)) {

			// get a list of the items that will be added / removed to display
			nodeList = getDisplayList(node, !open);

			// find row we'll start rendering at, if any
			rowIndex = getDisplayIndex(node) +1 - __vPosition;

			// only move as many rows as can be displayed
			var rowsToMove = Math.min(nodeList.length, __rowCount-rowIndex);
			var dur = getStyle("openDuration");
			if (animate && rowIndex<__rowCount && rowsToMove>0 && rowsToMove<20 && dur!=0) {
				// Kill any previous animation. tween is undefined if there is no Tween underway.
				tween.endTween();

				// animate the opening
				opening = open;
				isOpening = true;
				var dist = rowsToMove * __rowHeight;
				for (var i=rowIndex; i<__rowCount; i++) {
					rows[i].__lastY = rows[i]._y;
				}
				maskList = new Array();
				rowList = new Array();
				var bM = __viewMetrics;
				var dWidth = (__hScrollPolicy=="on" || __hScrollPolicy=="auto") ? __width + __maxHPosition : __width-bM.left-bM.right;


				for (var i=0; i<rowsToMove; i++) {
					var tmpMask = maskList[i] = attachMovie("BoundingBox", "openMask"+i, 2001+i);
					tmpMask._width = __width-bM.left - bM.right;
					tmpMask._x = bM.left;
					tmpMask._height = dist;
					tmpMask._y = rows[rowIndex]._y;

					var tmpRow = rowList[i] = listContent.createObject(__rowRenderer, "treeRow"+topRowZ++, topRowZ, {owner:this, styleName:this});
					tmpRow._x = bM.left;


					tmpRow.setSize(dWidth, __rowHeight);
					//! find selected
					if (open) {
						//! parametrize "normal"
						tmpRow.drawRow(nodeList[i], "normal");
						tmpRow._y = rows[rowIndex]._y - dist + __rowHeight*i;
						tmpRow.setMask(tmpMask);
					} else {
						var itemIndex = Math.max(__vPosition+__rowCount+i+nodeList.length-rowsToMove,rowIndex+nodeList.length);
						tmpRow.drawRow(__dataProvider.getItemAt(itemIndex), getStateAt(itemIndex));
						tmpRow._y = rows[__rowCount-1]._y + (i+1)*(__rowHeight);
						rows[rowIndex+i].setMask(tmpMask);
					}
					tmpRow.__lastY = tmpRow._y;
				}
				dur = dur* Math.max(rowsToMove / 5, 1);

				if (fireEvent)
					eventAfterTween = node;
				tween = new Tween(this, 0, (open) ? dist : -1*dist, dur, 5);
				var oE = getStyle("openEasing");
				if (oE!=undefined) {
					tween.easingEquation = oE;
				}

			} else {
				// not to be animated
				isOpening = false;
				if (open) {
					addItemsAt(getDisplayIndex(node)+1, nodeList);
				} else {
					__dataProvider.removeItemsAt(getDisplayIndex(node)+1, nodeList.length);
				}
				invScrollProps = true;
				if (fireEvent)
					eventPending = node;
				invalidate();
			}
		}
		if (!open) {
			openNodes[node.getID()]=open;
		}
		var i = getDisplayIndex(node);
		var r = rows[i-__vPosition];
		r.drawRow(r.item, getStateAt(i));

	}

	function onTweenUpdate(val)
	{
		for (var i=rowIndex; i<__rowCount; i++) {
			rows[i]._y = rows[i].__lastY + val;
		}
		for (var i=0; i<rowList.length; i++) {
			rowList[i]._y = rowList[i].__lastY + val;
		}

	}

	function onTweenEnd(val)
	{
		for (var i=rowIndex; i<__rowCount; i++) {
			rows[i]._y = rows[i].__lastY + val;
			delete rows[i].__lastY;
			if (i>=__rowCount-rowList.length && opening) {
				rows[i].removeMovieClip();
			}
		}
		for (var i=0; i<rowList.length; i++) {
			rowList[i]._y = rowList[i].__lastY + val;
			if (opening) {
				rowList[i].setMask(undefined);
			} else {
				rows[rowIndex+i].removeMovieClip();
			}
			maskList[i].removeMovieClip();
		}
		isOpening = false;
		vScroller.scrollPosition = __vPosition;
		if (opening) {
			var firstShiftedRow = rowIndex+rowList.length;
			for (var i=__rowCount-1; i>=firstShiftedRow; i--) {
				rows[i] = rows[i-rowList.length];
	//			trace("shifting row " + (i-rowList.length) + " into space " + i);
				rows[i].rowIndex = i;
			}
			for (var i=rowIndex; i<firstShiftedRow; i++) {
				rows[i] = rowList[i-rowIndex];
	//			trace("shifting row " + (i-rowIndex) + " into space " + i);
				rows[i].rowIndex = i;
			}

			addItemsAt(rowIndex+__vPosition, nodeList);
		} else {
			var lastShiftedRow = __rowCount-rowList.length;
			for (var i=rowIndex; i<lastShiftedRow; i++) {
				rows[i] = rows[i+rowList.length];
				rows[i].rowIndex = i;
			}
			for (var i=lastShiftedRow; i<__rowCount; i++) {
				rows[i] = rowList[i-lastShiftedRow];
				rows[i].rowIndex = i;
			}
			__dataProvider.removeItemsAt(rowIndex+__vPosition, nodeList.length);
		}
		if (eventAfterTween!=undefined) {
			eventPending = eventAfterTween;
			invalidate();
			delete eventAfterTween;
		}

		// Get rid of the tween, so this onTweenEnd doesn't get called more than once.
		delete tween;
		delete invUpdateControl;
	}

	function size(Void) : Void
	{
		// Kill any animation before resizing. tween is undefined if there is no Tween underway.
		tween.endTween();
		super.size();
	}

	function setVPosition(pos:Number)
	{
		if (isOpening) return;
		super.setVPosition(pos);
	}

	function onScroll(evt:Object):Void
	{
		if (isOpening) return;
		super.onScroll(evt);
	}

	function addItemsAt(index, arr)
	{
		var s1 = __dataProvider.slice(0,index);
		var s2 = __dataProvider.slice(index);
		__dataProvider = s1.concat( arr, s2 );
		__dataProvider.addEventListener("modelChanged", this);
		modelChanged({eventName : "addItems", firstItem : index, lastItem : index+arr.length-1});

	}

	function setDataProvider(dP)
	{
		if (treeDataProvider!=undefined) {
			// clear the association with the old dP
			treeDataProvider.removeEventListener(this);
		}

		if (typeof(dP)=="string") {
			dP = new XML(dP);
		}

		treeDataProvider = dP;
		treeDataProvider.isTreeRoot = true;
//		treeDataProvider.isBranch = true;
		setIsBranch(treeDataProvider, true);
		setIsOpen(treeDataProvider, true);
		setDisplayIndex(treeDataProvider, -1);
		treeDataProvider.addEventListener("modelChanged", this);
		modelChanged({eventName:"updateTree"});

	}

	function getDataProvider()
	{
		return treeDataProvider;
	}


/**
* @tiptext Refreshes the tree's list of displayed nodes
* @helpid 3203
*/
	function refresh()
	{
		updateControl();
	}

/**
* @tiptext Appends a child node at the end of the tree node
* @param label the text for the node
* @param data the data for the node
* @return the new node
* @helpid 3414
*/
	function addTreeNode(label, data)
	{
		if (treeDataProvider == undefined)
			setDataProvider(new XML());

		return treeDataProvider.addTreeNode(label, data);
	}

/**
* @tiptext Adds a child node at the specified index on the tree node
* @param label the position (in the tree's root node's children) for the node
* @param label the text for the node
* @param data the data for the node
* @return the new node
* @helpid 3204
*/
	function addTreeNodeAt(index, label, data)
	{
		if (treeDataProvider == undefined)
			setDataProvider(new XML());

		return treeDataProvider.addTreeNodeAt(index, label, data);
	}

/**
* @tiptext Returns the child node at the specified index of the tree node
* @param index the position of the node in the tree's dp's children
* @return the node
* @helpid 3205
*/
	function getTreeNodeAt(index)
	{
		return treeDataProvider.getTreeNodeAt(index);
	}

/**
* @tiptext Removes the child node at the specified index of the tree node
* @param index the position of the node in the tree's root
* @return the node
* @helpid 3415
*/
	function removeTreeNodeAt(index)
	{
		return treeDataProvider.removeTreeNodeAt(index);
	}


/**
* @tiptext Removes all nodes from the tree
* @helpid 3416
*/
	function removeAll()
	{
		return treeDataProvider.removeAll();
	}



/**
* @tiptext Returns the node specified on the tree's list of displayed nodes
* @param index the position of the node in the tree's list of displayed nodes
* @return the node
* @helpid 3417
*/
	function getNodeDisplayedAt(index)
	{
		return __dataProvider.getItemAt(index);
	}

	function modelChanged(eventObj)
	{
		var event = eventObj.eventName;
		if (event == "updateTree") {
	//! update views here
			__dataProvider = getDisplayList(treeDataProvider);
			__dataProvider.addEventListener("modelChanged", this);
			super.modelChanged({eventName : "updateAll"});
		} else if (event == "addNode") {
			var node = eventObj.node;
			if (isNodeVisible(node)) {
				// When a node has been added, it needs to find its
				// node UID in our tree. It's assumed node is visible.
				if (node.nextSibling!=undefined) {
					// if there's a next sibling, it's easy - our node replaces it
					setDisplayIndex(node, getDisplayIndex(node.nextSibling));
				} else if (node.previousSibling!=undefined) {
					// if there's a previous sibling, it's a bit harder. Find the last
					// displayed descendant of that sibling, our node is right after that.
					var a = getDisplayList(node.previousSibling);
					if (a.length>0) {
						setDisplayIndex(node, getDisplayIndex(a.pop())+1);
					} else {
						// if the prev sib has no children, we're right after it
						setDisplayIndex(node, getDisplayIndex(node.previousSibling)+1);
					}
				} else {
					// if the node has no siblings, it's right after the parent
					setDisplayIndex(node, getDisplayIndex(node.parentNode)+1);
				}
				// if our node happens to have open descendants, prep them for display
				//-!! NOTE : do I have to deal with cases of being removed from elsewhere in the tree?
				var newItems = getDisplayList(node);
				newItems.unshift(node);
				addItemsAt(getDisplayIndex(node), newItems);
			} else {
				// in case the folder needs updating
				invUpdateControl=true;
				invalidate();
			}
		} else if (event == "removeNode") {
			var node = eventObj.node;
			var index = getDisplayIndex(node);
			if (index!=undefined) {
				var displayArray = getDisplayList(node);
				__dataProvider.removeItemsAt(index, displayArray.length+1);
			}

		} else if (event == "addItems") {
			super.modelChanged(eventObj);
			var items = __dataProvider;
			for (var i=eventObj.firstItem; i<items.length; i++) {
				setDisplayIndex(items[i], i);
			}
		} else if (event == "removeItems") {
			var items = __dataProvider;
			for (var i=eventObj.firstItem; i<items.length; i++) {
				setDisplayIndex(items[i], i);
			}
			super.modelChanged(eventObj);
/*			var f = eventObj.firstItem;
			var l = eventObj.lastItem;
			for (var i in selected) {
				if (selected[i]>=f && selected[i]<=l) {
					delete selected[i];
				}
			}
*/			//-!! check this
		} else {
			super.modelChanged(eventObj);
		}
	}



	function isNodeVisible(node)
	{
		// if it's on the displayList, or its parent is and is open, it's visible all right
		return (getDisplayIndex(node)!=undefined || (getDisplayIndex(node.parentNode)!=undefined && getIsOpen(node.parentNode)) );
	}

	function getFirstVisibleNode()
	{
		return __dataProvider.getItemAt(__vPosition);
	}

	function setFirstVisibleNode(node)
	{
		var pos = getDisplayIndex(node);
		if (pos==undefined) return;

		setVPosition(pos);
	}


	function set firstVisibleNode(node)
	{
		setFirstVisibleNode(node);
	}

/**
* @tiptext Gets or sets the first node at the top of the view pane
* @helpid 3206
*/
	function get firstVisibleNode()
	{
		return getFirstVisibleNode();
	}

	function set selectedNode(node)
	{
		var ind = getDisplayIndex(node);
		if (ind >= 0)
			setSelectedIndex(ind);
	}

/**
* @tiptext Specifies the selected node in the tree
* @helpid 3207
*/
	function get selectedNode()
	{
		return getSelectedItem();
	}

	function set selectedNodes(nodeArray)
	{
		var indArray = new Array();
		var ind;
		for (var i=0; i<nodeArray.length; i++) {
			ind = getDisplayIndex(nodeArray[i]);
			if (ind!=undefined)
				indArray.push(ind);
		}
		setSelectedIndices(indArray);
	}

/**
* @tiptext Specifies the selected nodes in the tree
* @helpid 3208
*/
	function get selectedNodes()
	{
		return getSelectedItems();
	}


	// starts at a specific node and builds a display list starting from there
	// to be used in rendering the whole tree and after opening / adding, or closing / removing branches
	function getDisplayList(node, removed)
	{
		var dList = new Array();
		if (!isNodeVisible(node) || !getIsOpen(node)) return dList;
		var n = getDisplayIndex(node);
		var stack = new Array();
		var curNode = node.firstChild;
		var done = (curNode==undefined);
		while (!done) {
			if (removed) {
				setDisplayIndex(curNode, undefined);
			} else {
				setDisplayIndex(curNode, ++n);
			}
			dList.push(curNode);
			if (curNode.childNodes.length>0 && getIsOpen(curNode)) {
			// the node has open children, "recurse" down to them
				if (curNode.nextSibling!=undefined) {
				// leave a pointer to the next place to go, if it exists
					stack.push(curNode.nextSibling);
				}
				curNode = curNode.firstChild;
			} else {
			// node has no children, try its sibling
				if (curNode.nextSibling!=undefined) {
					curNode = curNode.nextSibling;
				} else if (stack.length==0) {
				// if there is no child, sibling, or next parent level node, that's the end of the puppet show
					done = true;
				} else {
				// there are still parents to explore, pop back up to the next parent level node
					curNode = stack.pop();
				}
			}
		}
//		trace(dList);
		return dList;
	}


/**
* @tiptext Returns the index of the node specified on the tree's list of displayed nodes
* @param node the node to query
* @return the index on the tree's display list
* @helpid 3418
*/
	function getDisplayIndex(node)
	{
		return nodeIndices[node.getID()];
	}

	function setDisplayIndex(node, UID)
	{
		nodeIndices[node.getID()] = UID;
	}

	function keyDown(e:Object) : Void
	{
		if (isOpening) return;
		// Keyboard handling is consistent with Windows Explorer.
		var	node = selectedNode;
		if (e.ctrlKey)
		{
			// Ctrl keys always get sent to the List.
			super.keyDown(e);
		}
		else if (e.code == Key.SPACE)
		{
			// Spacebar toggles the current open/closed status. No effect for leaf nodes.
			if (getIsBranch(node)) {
				var o = !getIsOpen(node);
				setIsOpen(node, o, true, true);
			}

		}
		else if (e.code == Key.LEFT)
		{
			// Left Arrow closes an open node. Otherwise selects the parent node.
			if (getIsOpen(node)) {
				setIsOpen(node, false, true, true);
			} else {
				selectedNode = node.parentNode;
				dispatchEvent({type:"change"});
				var dI = getDisplayIndex(selectedNode);
				if (dI<__vPosition) {
					setVPosition(dI);
				}
			}
		}
		else if (e.code == Key.RIGHT)
		{
			// Right Arrow has no effect on leaf nodes. Closed branch nodes are opened. Opened branch nodes select the first child.
			if (getIsBranch(node))
			{
				if (getIsOpen(node)) {
					selectedNode = node.firstChild;
					dispatchEvent({type:"change"});
				} else {
					setIsOpen(node, true, true, true);
				}
			}
		}
		else
		{
			// Nothing that we know or care about. Send it off to the List.
			super.keyDown(e);
		}
	}

	function init()
	{
		super.init();
		// if a node's ID is within the openNodes table, it's open
		openNodes = new Object();
		// if a node's ID is within the nodeUID table, it's on the displayList
		nodeIndices = new Object();
	}

	function invalidateStyle(propName : String) : Void
	{
		if (isNewRowStyle[propName]) {
			invUpdateControl = true;
			invalidate();
		}
		super.invalidateStyle(propName);
	}

	function layoutContent(x : Number,y : Number,tW : Number,tH : Number,dW : Number,dH : Number) : Void
	{
		var	highestDepth=0;
		var highestIndex=0;

		// ScrollSelectList (which this extends) assumes that list row depths are monotonically increasing.
		// Unfortunately, Tree inserts rows of a higher depth whenever a closed node opens.
		// Before going into ScrollSelectList's layoutContent, make calculate an ideal topRowZ based on the
		// highest depth of any of the rows. The ideal topRowZ must be set up so that whatever the hightest
		// depth is, each subsequent row in the list *could* have a depth increased by one, resulting in
		// a topRowZ just greater than what the depth of the last item in the list would be if all were
		// monotonically increasing as set up by ScrollSelectList.

		// First, find the row at the greatest depth, and what the depth is.
		for (var i=0; i < rows.length; i++)
		{
			var	depth = rows[i].getDepth();

			if (depth > highestDepth)
			{
				highestDepth = depth;
				highestIndex = i;
			}
		}

		// Now that we have the highest depth, calculate the ideal topRowZ, which would increase
		// the depth number for each subsequent row in the list.
		var	idealRowZ = highestDepth + rows.length - highestIndex;

		// Now set the actual topRowZ according to the ideal RowZ.
		if (topRowZ < idealRowZ)
			topRowZ = idealRowZ;

		// Now it is safe for ScrollSelectList to layout the rows.
		super.layoutContent(x,y, tW, tH, dW, dH);
		// EXTEND here for dataGrid, re-set scrollProps.
	}

	function draw(Void) : Void
	{
		super.draw();
		if (eventPending!=undefined) {
			dispatchEvent( {type: ((getIsOpen(eventPending)) ? "nodeOpen" : "nodeClose"), node:eventPending } );
			delete eventPending;
		}
	}

[Bindable(type="XML")]
var _inherited_dataProvider:Object;

	private static var TreeRowDependency = mx.controls.treeclasses.TreeRow;
}

