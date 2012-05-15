//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.listclasses.ScrollSelectList;

[TagName("List")]
[IconFile("List.png")]
[InspectableList("labels", "data", "multipleSelection", "rowHeight")]
[DataBindingInfo("acceptedTypes","{dataProvider: {label: &quot;String&quot;}}")]

/**
* List class
* - extends ScrollSelectList
* - gives the user the ability to select one or many options from a scrolling list
* @tiptext List provides the ability to select one or many options from a scrolling list
* @helpid 3127
*/

class mx.controls.List extends ScrollSelectList
{

	static var symbolOwner : Object = List;
	static var symbolName : String = "List";

	var className : String = "List";
	//#include "../core/ComponentVersion.as"

	//::: DEFAULT VALUES
	var clipParameters:Object = { rowHeight: 1, enabled:1, visible:1, labels:1 };

	var scrollDepth : Number = 1;
	var __vScrollPolicy : String = "on";

	//::: Declarations

	var __labels : Array;


        [Inspectable(defaultValue="")]
	var data : Array;


	var __selectedIndex : Number;
	var boundingBox_mc : MovieClip;
	var oldVWidth : Number;
	var autoHScrollAble : Boolean = false;

	var totalWidth : Number;
	var totalHeight : Number;
	var displayWidth : Number;

	var calcPreferredWidthFromData : Function;
	var calcPreferredHeightFromData : Function;


	var invScrollProps : Boolean;
	var invScrollSize : Boolean;

	function List()
	{

	}


	//::: PUBLIC METHODS

	function setEnabled(v : Boolean) : Void
	{
		super.setEnabled(v);
		border_mc.backgroundColorName = v ? "backgroundColor" : "backgroundDisabledColor";
		border_mc.invalidate();
	}



        [Inspectable(defaultValue="")]
	function get labels() : Array
	{
		// for live preview only
		return __labels;
	}
	function set labels(lbls : Array)
	{
		__labels = lbls;
		setDataProvider(lbls);
	}


	//::: SCROLL METHODS

	function setVPosition(pos:Number) : Void
	{
		pos = Math.min(__dataProvider.length-rowCount + roundUp, pos);
		pos = Math.max(0,pos);
		super.setVPosition(pos);
	}



	function setHPosition(pos : Number) : Void
	{
		pos = Math.max(Math.min(__maxHPosition, pos), 0);
		super.setHPosition(pos);
		hScroll(pos);
	}


	function setMaxHPosition(pos:Number) : Void
	{
		__maxHPosition = pos;
		invScrollProps = true;
		invalidate();
	}


	function setHScrollPolicy(policy : String) : Void
	{
		if (policy.toLowerCase()=="auto" && !autoHScrollAble) return;
		super.setHScrollPolicy(policy);
		if (policy=="off") {
			setHPosition(0);
			setVPosition(Math.min(__dataProvider.length-rowCount+roundUp, __vPosition));
		}
	}


	//::: LAYOUT METHODS


	function setRowCount(rC : Number) : Void
	{
		if (isNaN(rC)) return;
		var o = getViewMetrics();
		setSize(__width, __rowHeight*rC + o.top + o.bottom);

	}

	function layoutContent(x : Number,y : Number,tW : Number,tH : Number,dW : Number,dH : Number) : Void
	{
	//	trace("List.layoutContent - x:" + x + " y:" + y + " tW:" + tW + " tH:" + tH + " dW:" + dW + " dH:" + dH);
		totalWidth = tW;
		totalHeight = tH;
		displayWidth = dW;
		var w = (__hScrollPolicy=="on" || __hScrollPolicy=="auto") ? Math.max(tW, dW) : dW;
		super.layoutContent(x,y,w,dH);
		// EXTEND here for dataGrid, re-set scrollProps.
	}


	//::: PRIVATE METHODS
	// event handling

	function modelChanged(eventObj : Object) : Void
	{
		super.modelChanged(eventObj);
		var event = eventObj.eventName;
		if (event == "addItems" || event == "removeItems" || event=="updateAll" || event=="filterModel") {
			invScrollProps = true;
			invalidate("invScrollProps");
		}
	}


	function onScroll(eventObj : Object) : Void
	{
		var scroller = eventObj.target;
		if (scroller==vScroller) {
			setVPosition(scroller.scrollPosition);
		} else {
			hScroll(scroller.scrollPosition);
		}
		super.onScroll(eventObj);
	}

	function hScroll(pos:Number) : Void
	{
		__hPosition = pos;
		listContent._x = -pos;
	}


	//::: PRIVATE CONSTRUCTION


	function init(Void) : Void
	{
		super.init();
		if (labels.length>0) {
			var dp = new Array();
			for (var i=0; i<labels.length;i++) {
				dp.addItem( {label:labels[i], data:data[i]} );
			}
			setDataProvider(dp);
		}
		__maxHPosition = 0;
	}

	function createChildren(Void) : Void
	{
		super.createChildren();

		listContent.setMask(MovieClip(mask_mc));
		border_mc.move(0, 0);
		border_mc.setSize(__width, __height);
	}


	function getRowCount(Void) : Number
	{
		var vM = getViewMetrics();
		return (__rowCount==0) ? Math.ceil((__height - vM.top - vM.bottom) / __rowHeight) : __rowCount;

	}


	function size(Void) : Void
	{
		super.size();

		configureScrolling();

		var o = getViewMetrics();
		layoutContent(o.left, o.top, __width + __maxHPosition, totalHeight, __width - o.left - o.right, __height - o.top - o.bottom);
	}



	function draw(Void) : Void
	{
		if (invRowHeight) {
			invScrollProps = true;
			super.draw();
			listContent.setMask(MovieClip(mask_mc));
			invLayoutContent = true;
		}

		if (invScrollProps) {
			configureScrolling();
			delete invScrollProps;
		}
		if (invLayoutContent) {
			var o = getViewMetrics();
			layoutContent(o.left, o.top, __width + __maxHPosition, totalHeight, __width - o.left - o.right, __height - o.top - o.bottom);
		}
		super.draw();
	}


	function configureScrolling(Void) : Void
	{

		var len = __dataProvider.length;
		if (__vPosition>Math.max(0,len-getRowCount()+roundUp)) {
			setVPosition( Math.max(0,Math.min(len-getRowCount()+roundUp, __vPosition)) );
		}
		var o = getViewMetrics();
		var vWidth = ( __hScrollPolicy!="off" ) ? __maxHPosition + __width - o.left - o.right : __width - o.left - o.right;
		if (len==undefined) len = 0;
		setScrollProperties(vWidth, 1, len, __rowHeight);
		if (oldVWidth!=vWidth)  {
			invLayoutContent = true;
		}
		oldVWidth = vWidth;


	}

	[Bindable(param1="writeonly",type="DataProvider")]
	var	_inherited_dataProvider:Array;

	[Bindable("readonly")]
	[ChangeEvent("change")]
	var	_inherited_selectedItem:Object;

	[Bindable("readonly")]
	[ChangeEvent("change")]
	var	_inherited_selectedItems:Array;

	[Bindable]
	[ChangeEvent("change")]
	var	_inherited_selectedIndex:Number;

	[Bindable]
	[ChangeEvent("change")]
	var	_inherited_selectedIndices:Array;

}

