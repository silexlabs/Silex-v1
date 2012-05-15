//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/*
		EXTENDS View (formerly UIComponent)
		IMPLEMENTS Scroller

		Base class for components with scrollbars and a mask. This component
		implements the Scroller interface, which is the API that defines any
		control meant for scrolling Scrollable content. Any content
		to be scrolled by such a control must implement Scrollable, the
		complementary interface that speaks with Scroller

 		Scroller INTERFACE
		===================

		METHODS
		-------
		setSize(x,y) 	- lays out the scroll controls and a mask
		setScrollProperties(numberOfCols, columnWidth, rowCount, rowHeight) - adjusts scroll controls
						  to represent the content

		PROPERTIES
		----------
		scrollContent	- property which sets the content of the pane. this usually sets a mask,
					   	  positions content, and sets the scrollProperties of the scroll controls
		hPosition		- the horizontal scroll position
		vPosition		- the vertical scroll position

		hScrollPolicy 	- defines whether the Scroller will layout a horizontal control. Values
						  are "on", "off", "auto"
		vScrollPolicy	- ditto, but for vertical scrolling
		hScroller		- a reference to the horizontal scroll control
		vScroller		- a reference to the vertical scroll control

		EVENTS
		------
		Emits the scroll event, as documented in the listBox spec.

*/

import mx.core.View;
import mx.controls.scrollClasses.ScrollBar;

/**
* @tiptext scroll event
* @helpid 3269
*/
[Event("scroll")]
/**
* @helpid 3270
* @tiptext base class for views/containers that support scrolling
*/
class mx.core.ScrollView extends View
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "ScrollView";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = ScrollView;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "ScrollView";

/*
* @private
* the horizontal scrollbar
*/
	var hScroller:ScrollBar;
/*
* @private
* the vertical scrollbar
*/
	var vScroller:ScrollBar;
/*
* @private
* the mask
*/
	var mask_mc:MovieClip;

	// default values of the getter/setter properties
	var __vScrollPolicy:String = "auto";
	var __hScrollPolicy:String = "off";
	var __vPosition:Number = 0;
	var __hPosition:Number = 0;

	// cached values of the content parameters
	var numberOfCols:Number = 0;
	var rowC:Number = 0;
	var columnWidth:Number = 1;
	var rowH:Number = 0;
	var heightPadding:Number = 0;
	var widthPadding:Number = 0;
	var oldRndUp : Number;
	var __maxHPosition : Number;
	var viewableRows:Number;
	var viewableColumns:Number;
	var propsInited:Boolean;
	var scrollAreaChanged:Boolean;
	var invLayout:Boolean;
	var specialHScrollCase:Boolean;

	// offsets including borders and scrollbars
	var __viewMetrics:Object;

	// mask is placed up high and then made invisible
	var MASK_DEPTH:Number = 10000;

	// pointer to us when we get called in another scope
	var owner : MovieClip;


	function getHScrollPolicy(Void)
	{
		return __hScrollPolicy;
	}

	function setHScrollPolicy(policy) : Void
	{
		__hScrollPolicy = policy.toLowerCase();
		if (__width==undefined) return; // from parameters
		setScrollProperties(numberOfCols, columnWidth, rowC, rowH, heightPadding, widthPadding);
	}


/**
* @tiptext whether the horizontal scrollbar is always on, always off or automatically changes
* @helpid 3271
*/
	function get hScrollPolicy() : String
	{
		return getHScrollPolicy();
	}

	function set hScrollPolicy(policy:String)
	{
		setHScrollPolicy(policy);
	}


	function getVScrollPolicy(Void)
	{
		return __vScrollPolicy;
	}

	function setVScrollPolicy(policy) : Void
	{
		__vScrollPolicy = policy.toLowerCase();
		if (__width==undefined) return; // from parameters
		setScrollProperties(numberOfCols, columnWidth, rowC, rowH, heightPadding, widthPadding);
	}

/**
* @tiptext Whether the vertical scrollbar is always on, always off or automatically changes.
* @helpid 3272
*/
	function get vScrollPolicy(): String
	{
		return getVScrollPolicy();
	}
	function set vScrollPolicy(policy:Object)
	{
		setVScrollPolicy(policy);
	}


/**
* @tiptext	The offset into the content from the left edge.
* @helpid 3273
*/
	function get hPosition():Number
	{
		return getHPosition();
	}
	//this only moves the scrollBars -- assumes the call emanated from the scrollable content
	function set hPosition(pos:Number)
	{
		setHPosition(pos);
	}


	function getHPosition(Void) : Number
	{
		return __hPosition;
	}

	function setHPosition(pos:Number) : Void
	{
		hScroller.scrollPosition = pos;
		__hPosition = pos;
		//EXTEND this method in ScrollPane to move the content.
	}

/**
* @tiptext the offset into the content from the top edge, usually in pixels or lines
* @helpid 3274
*/
	function get vPosition():Number
	{
		return getVPosition();
	}
	function set vPosition(pos:Number)
	{
		setVPosition(pos);
	}

	function getVPosition(Void) : Number
	{
		return __vPosition;
	}

	function setVPosition(pos:Number) : Void
	{
		vScroller.scrollPosition = pos;
		__vPosition = pos;
		//EXTEND this method in ScrollPane to move the content.
	}

/**
* @tiptext the maximum offset into the content from the top edge, not the bottom of content
* @helpid 3275
*/
	function get maxVPosition():Number
	{
		var m:Number = vScroller.maxPos;
		return (m==undefined) ? 0 : m;
	}



/**
* @tiptext the maximum offset into the content from the left edge, not the right edge of content
* @helpid 3276
*/
	function get maxHPosition():Number
	{
		return getMaxHPosition();
	}
	function set maxHPosition(pos:Number)
	{
		setMaxHPosition(pos);
	}

	function getMaxHPosition(Void) : Number
	{
		if (__maxHPosition!=undefined) {
			return __maxHPosition;
		}
		var m:Number = hScroller.maxPos;
		return (m==undefined) ? 0 : m;
	}

	function setMaxHPosition(pos:Number) : Void
	{
		__maxHPosition = pos;
	}

	function ScrollView()
	{
	}

	//   setScrollProperties
	// the problem here : if it is (discrete) scrolling list content, content's "virtual dimensions" needs
	// to represent the number of rows / columns.
	// in the case of list content :
	//			numberOfCols = number of (model) data fields (in the case of grid content)
	//			columnWidth = pixel width of (view) columns (grid content)
	//			(column params only works for fixed-size columns)
	// 			rowCount = number of (model) items
	//			rowHeight = pixel height of one (view) row
	//
	// in the case of analog content (swfs, jpgs, anything being scrolled strictly based on "physical" size) :
	//			numberOfCols = number of pixels wide the content is
	//			columnWidth = 1 (each column is typically 1 pixel)
	//			rowCount = number of pixels wide
	//			rowHeight = 1 (each row is typically 1 pixel)
	// note that for better scrolling experience w/ analog content, you should set the lineScrollSize
	// of .hScroller and .vScroller, so they scroll in more than 1-pixel increments with each arrow button click
	//
	// The padding params are optional, and are meant to allow the scrollPane to contain fixed content,
	// non-scrollable in one or both dimensions. An example is the column/row headers of a dataGrid, which
	// only scroll in one dimension, and shouldn't be taken as part of the scrollBars' calculations of position.

/**
* set the parameters for scrolling
* @param colCount number of units to scroll horizontally
* @param colWidth width in pixels of each of those units
* @param rwCount number of untis to scroll vertically
* @param rwHeight height in pixels of each of those units
* @param hPadding pixels on the left edge that are not scrolled (for row headers)
* @param wpadding pixels on the top edge that are not scrolled (for column headers)
*/
	function setScrollProperties(colCount:Number, colWidth:Number, rwCount:Number, rwHeight:Number, hPadding:Number, wPadding:Number):Void
	{
		var vM = getViewMetrics();
		if (hPadding == undefined) hPadding = 0;
		if (wPadding == undefined) wPadding = 0;
		propsInited = true;
		delete scrollAreaChanged;
		heightPadding = hPadding;
		widthPadding = wPadding;
		if(colWidth==0) colWidth=1;
		if(rwHeight==0) rwHeight=1;

		var viewableCols:Number = Math.ceil( (__width-vM.left-vM.right-widthPadding)/colWidth );
//		trace("SSP : " + viewableCols + " " + colCount + " " + colWidth);
		if ( __hScrollPolicy=="on" || (viewableCols < colCount && (__hScrollPolicy=="auto")) ) {
			// we need a horizontal	scrollBar.
			if (hScroller==undefined || specialHScrollCase) {
				delete specialHScrollCase;
				// nope, need to add it
				hScroller = ScrollBar(createObject("HScrollBar", "hSB", 1001));
				hScroller.lineScrollSize = 20;
				hScroller.scrollHandler = scrollProxy;
				hScroller.scrollPosition = __hPosition;
				scrollAreaChanged = true;
			}
			if (numberOfCols!=colCount || columnWidth!=colWidth || viewableColumns!=viewableCols || scrollAreaChanged) {

				hScroller.setScrollProperties(viewableCols, 0, colCount-viewableCols);
				viewableColumns = viewableCols;
				numberOfCols = colCount;
				columnWidth = colWidth;
			}

		} else if ( (__hScrollPolicy=="auto" || __hScrollPolicy=="off") && hScroller!=undefined) {
			// we need to remove this scroller
			hScroller.removeMovieClip();
			delete hScroller;
			scrollAreaChanged = true;
		}
		if (heightPadding==undefined) heightPadding=0;
		var viewableRws:Number = Math.ceil( (__height-vM.top-vM.bottom-heightPadding)/rwHeight );
		var rndUp = ( (__height-vM.top-vM.bottom)%rwHeight != 0 );
//		trace("SSP : " + viewableRws + " " + rwCount + " ");
		if ( __vScrollPolicy=="on" || (viewableRws < rwCount+rndUp && (__vScrollPolicy=="auto")) ) {
			// we need a vertical scroller. Does it exist?
			if (vScroller==undefined) {
				// no it doesn't, and we're allowed to add it.
				vScroller = ScrollBar(createObject("VScrollBar", "vSB", 1002));
				vScroller.scrollHandler = scrollProxy;
				vScroller.scrollPosition = __vPosition;
				scrollAreaChanged = true;
				rowH = 0;
			}
			if (rowC!=rwCount || rowH!=rwHeight || ((viewableRows+rndUp)!=(viewableRws+oldRndUp)) || scrollAreaChanged) {
				vScroller.setScrollProperties(viewableRws, 0, rwCount-viewableRws + rndUp);
				viewableRows = viewableRws;
				rowC = rwCount;
				rowH = rwHeight;
				oldRndUp = rndUp;
			}

		} else if ( (__vScrollPolicy=="auto" || __vScrollPolicy=="off") && vScroller!=undefined) {
			vScroller.removeMovieClip();
			delete vScroller;
			scrollAreaChanged = true;
		}
		numberOfCols = colCount;
		columnWidth = colWidth;

		// now, if any scroller came into or left existence, it's possible that the content
		// is occluded or revealed enough that the other scroller needs to appear or go away
		if (scrollAreaChanged) {

			doLayout();


			// this is for content that conforms to the (discrete) scrollable interface. It just falls through
			// on analog content (I hope)
			var o:Object = __viewMetrics;
			var ownr:MovieClip = (owner!=undefined) ? owner : this;
			ownr.layoutContent(o.left, o.top, columnWidth*numberOfCols-o.left-o.right, rowC*rowH,
								__width-o.left-o.right, __height-o.top-o.bottom);
		}
		//EXTEND this method in ScrollPane to setLineScrollSize on .hScroller and .vScroller.
		// As well, if scrollAreaChanged is true, the ScrollPane will need to run another setScrollProps to see
		// if the change might force a change in the other scrollBar.
		if (!enabled)
			setEnabled(false);
	}

/**
* get the thickness of the edges of the object taking into account the border and scrollbars if visible
* @return object with left, right, top and bottom edge thickness in pixels
*/
	function getViewMetrics(Void):Object
	{
		var o:Object = __viewMetrics;
		var m:Object = border_mc.borderMetrics;
		o.left = m.left;
		o.right = m.right;
		if (vScroller != undefined)
			o.right += vScroller.minWidth;
		o.top = m.top;
		if (hScroller==undefined && (__hScrollPolicy=="on" || __hScrollPolicy==true)) {
			hScroller = ScrollBar(createObject("FHScrollBar", "hSB", 1001));
			specialHScrollCase = true;
		}
		o.bottom = m.bottom;
		if (hScroller != undefined)
			o.bottom += hScroller.minHeight;
		return o;
	}

/**
* @private
* layout the scrollbars and adjust the mask
*/
	function doLayout(Void):Void
	{
		var w = width;
		var h = height;
		delete invLayout;
		var o:Object = __viewMetrics = getViewMetrics();
		var lo = o.left;
		var ro = o.right;
		var to = o.top;
		var bo = o.bottom;
		var hsb = hScroller;
		var vsb = vScroller;

		hsb.setSize(w-lo-ro, hsb.minHeight + 0);
		hsb.move(lo, h-bo);
		vsb.setSize(vsb.minWidth + 0, h-to-bo);
		vsb.move(w-ro, to);
		var mask = mask_mc;
		mask._width = w-lo-ro;
		mask._height = h-to-bo;
		mask._x = lo;
		mask._y = to;
	}
/**
* @see mx.core.View
*/
	// the id is not typed so that a ref can be passed
	function createChild(id, name:String, props:Object):MovieClip
	{
		var newObj:MovieClip = super.createChild(id, name, props);
		return newObj;
	}

	// init variables and create internal objects
	function init(Void):Void
	{
		super.init();
		__viewMetrics = new Object();
		if (_global.__SVMouseWheelManager==undefined) {
			var s = _global.__SVMouseWheelManager = new Object();
			s.onMouseWheel = this.__onMouseWheel;
			Mouse.addListener(s);
		}
	}

	function __onMouseWheel(delta:Number, scrollTarget:MovieClip) : Void
	{
		var i = scrollTarget;
		var sT;
		while(i!=undefined) {
			if (i instanceof mx.core.ScrollView) {
				sT = i;
				delete i;
			}
			i = i._parent;
		}
		if (sT!=undefined) {
			var i = (delta<=0) ? 1 : -1;
			var l = sT.vScroller.lineScrollSize;
			if (l==undefined) l=0;
			l = Math.max(Math.abs(delta), l);
 			var nPos = sT.vPosition + l*i;
 			sT.vPosition = Math.max(0, Math.min(nPos, sT.maxVPosition));
			sT.dispatchEvent({type:"scroll", direction:"vertical", position:sT.vPosition });
		}
	}


	// create the mask and make it invisible
	function createChildren(Void):Void
	{
		super.createChildren();
		if (mask_mc == undefined)
			mask_mc = createObject("BoundingBox", "mask_mc", MASK_DEPTH);
		mask_mc._visible = false;
	}

	// if we get invalidated just call super
	function invalidate(Void):Void
	{
		super.invalidate();
	}

	// redraw by re-laying out
	function draw(Void):Void
	{
		size();
	}

	// respond to size changes
	function size(Void):Void
	{
		super.size();
	}

	// handle scroll events from the scrollbar
	// 'this' is actually the scrollbar so we just
	// pass it to the parent
	function scrollProxy(docObj:Object):Void
	{
		_parent.onScroll(docObj);
	}

	// process the scroll event
	function onScroll(docObj:Object):Void
	{
		var scroller:MovieClip = docObj.target;
		var pos:Number = scroller.scrollPosition;
		if (scroller==vScroller) {
			var d:String = "vertical";
			var prop:String = "__vPosition";
		} else {
			var d:String = "horizontal";
			var prop:String = "__hPosition";
		}
		this[prop] = pos;
		dispatchEvent({type:"scroll", direction:d, position:pos });
	}

	// scrollbars must be enabled/disabled when we are
	function setEnabled(v:Boolean):Void
	{
		vScroller.enabled = hScroller.enabled = v;
	}

/**
* @private
* this gets called when the child is finished loading
* @param obj the loaded child
*/
	function childLoaded(obj:MovieClip):Void
	{
		super.childLoaded(obj);
		obj.setMask(mask_mc);
	}
}

