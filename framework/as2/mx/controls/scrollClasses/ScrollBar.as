//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

//** Recipe for a component  Search for //** in this file to see the things
//   you should think about
//** 0) import all necessary classes
import mx.controls.scrollClasses.ScrollThumb;
import mx.controls.SimpleButton;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.skins.SkinElement;

/**
* a window with a title bar, caption and optional close button
* The title bar can be used to drag the window to a new location.
*
* @helpid 3263
* @tiptext
*/
class mx.controls.scrollClasses.ScrollBar extends UIComponent
{
//** 1) define either your movie clip name if you have a symbol for this class,
//      or just a symbolOwner pointing to the owner of the symbol for your
//      base class if you are a code-only class
//	static var symbolName:String = "ScrollBar";
//	static var symbolOwner:Object = ScrollBar;

/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.core.UIComponent;

//** 2) define your class name.

/**
* name of this class
*/
	var className:String = "ScrollBar";

//** 3) stick in all your default member variables

/**
* @private
* minimum scroll position
*/
	var minPos:Number = 0;
/**
* @private
* maximum scroll position
*/
	var maxPos:Number = 0;
/**
* @private
* amount to move when track is pressed
*/
	var pageSize:Number = 0;
/**
* @private
* if > 0, used as an override to the pageSize
*/
	var largeScroll:Number = 0;
/**
* @private
* amount to move when arrow buttons are pressed
*/
	var smallScroll:Number = 1;
/**
* @private
* stored value of the current position
*/
	var _scrollPosition:Number = 0;

//** 4) create variables for every skin element/linkage used in the component
//       This allows someone to set a different skin element just
//		 by changing a parameter in the component

/**
* symbol name of skin element for the scroll track
*/
	var scrollTrackName:String = "ScrollTrack";
/**
* symbol name of skin element for the scroll track when mouse is over it
*/
	var scrollTrackOverName:String = "";
/**
* symbol name of skin element for the scroll track when pressed
*/
	var scrollTrackDownName:String = "";
/**
* symbol name of skin element for the disabled state of the upArrow button
*/
	var upArrowName:String = "BtnUpArrow";
/**
* symbol name of skin element for the up state of the upArrow button
*/
	var upArrowUpName:String = "ScrollUpArrowUp";
/**
* symbol name of skin element for the over state of the upArrow button
*/
	var upArrowOverName:String = "ScrollUpArrowOver";
/**
* symbol name of skin element for the down state of the upArrow button
*/
	var upArrowDownName:String = "ScrollUpArrowDown";
/**
* symbol name of skin element for the disabled state of the downArrow button
*/
	var downArrowName:String = "BtnDownArrow";
/**
* symbol name of skin element for the up state of the downArrow button
*/
	var downArrowUpName:String = "ScrollDownArrowUp";
/**
* symbol name of skin element for the over state of the downArrow button
*/
	var downArrowOverName:String = "ScrollDownArrowOver";
/**
* symbol name of skin element for the down state of the downArrow button
*/
	var downArrowDownName:String = "ScrollDownArrowDown";
/**
* symbol name of skin element for the top cap of the thumb in the up state
*/
	var thumbTopName:String = "ScrollThumbTopUp";
/**
* symbol name of skin element for the moddle piece of the thumb in the up state
*/
	var thumbMiddleName:String = "ScrollThumbMiddleUp";
/**
* symbol name of skin element for the bottom cap of the thumb in the up state
*/
	var thumbBottomName:String = "ScrollThumbBottomUp";
/**
* symbol name of skin element for the grip of the thumb in the up state
*/
	var thumbGripName:String = "ScrollThumbGripUp";
//** 5) stick in your class constants.  If you have more than one copy of
//       a particular subobject, you might want to create skinIDs to reference
//       them.

/**
* @private
* index of track
*/
	static var skinIDTrack:Number = 0;
/**
* @private
* index of track in over state
*/
	static var skinIDTrackOver:Number = 1;
/**
* @private
* index of track when pressed
*/
	static var skinIDTrackDown:Number = 2;
/**
* @private
* index of up arrow
*/
	static var skinIDUpArrow:Number = 3;
/**
* @private
* index of down arrow
*/
	static var skinIDDownArrow:Number = 4;
/**
* @private
* index of thumb
*/
	static var skinIDThumb:Number = 5;

//** 6) skinID constants go hand-in-hand with an idNames array of instance names for the skins

/**
* @private
* instance names for scrollbar skins
*/
	var idNames:Array = new Array("scrollTrack_mc", "scrollTrackOver_mc", "scrollTrackDown_mc", "upArrow_mc", "downArrow_mc");

//** 7) add a clip parameter entry for every variable that has a getter/setter, or is specially handled in the
//       init to map to a function call

/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters:Object = {minPos: 1, maxPos: 1, pageSize: 1, scrollPosition: 1,
								lineScrollSize: 1, pageScrollSize: 1,
								visible: 1, enabled: 1};
/**
* @private
* all components must use this mechanism to merge their clip parameters with their base class clip parameters
*/
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(ScrollBar.prototype.clipParameters, UIComponent.prototype.clipParameters);

/**
* @private
* true until the component has finished initializing
*/
	var initializing:Boolean = true;

//** 8) define uninitialized member variables.  There won't be a property slot on these at
//   runtime until someone assigns a property.

	// true if servicing a scroll event
	var isScrolling:Boolean;

/**
* @private
* instance name of the scroll track
*/
	var scrollTrack_mc:SkinElement;
/**
* @private
* instance name of the scroll thumb
*/
	var scrollThumb_mc:ScrollThumb;
/**
* @private
* instance name of the up arrow button
*/
	var upArrow_mc:SimpleButton;
/**
* @private
* instance name of the down arrow button
*/
	var downArrow_mc:SimpleButton;
/**
* @private
* instance name of bounding box that gets destroyed at init time
*/
	var boundingBox_mc:MovieClip;

	// strings used to build up the name of the detail property of the event object
	var minMode:String;
	var maxMode:String;
	var minusMode:String;
	var plusMode:String;

	// setInterval reference
	var scrolling; // interval reference

	// see mx.events.EventDispatcher
	var scrollHandler:Function;

//** 9) define your getters and setters here

/**
* the current scroll position
*
* @tiptext
* @helpid 3264
*/
	function get scrollPosition():Number
	{
		return _scrollPosition;
	}

	function set scrollPosition(pos:Number)
	{
		_scrollPosition = pos;
		if (isScrolling != true)
		{
			// update thumb
			pos = Math.min(pos, maxPos);
			pos = Math.max(pos, minPos);
			var y:Number = ((pos-minPos) * (scrollTrack_mc.height-scrollThumb_mc._height) / (maxPos - minPos)) + scrollTrack_mc.top;
			scrollThumb_mc.move(0,y);
		}
	}

/**
* the amount to move when the track is pressed
*
* @tiptext
* @helpid 3265
*/
	function get pageScrollSize():Number
	{
		return largeScroll;
	}
	function set pageScrollSize(lScroll:Number)
	{
		largeScroll = lScroll;
	}

/**
* the amount to move when an arrow button is pressed
*
* @tiptext
* @helpid 3266
*/
	function set lineScrollSize(sScroll:Number)
	{
		smallScroll = sScroll;
	}
	function get lineScrollSize():Number
	{
		return smallScroll;
	}

	// for internal use only.  Used by horizontal bar to deal with rotation
	function get virtualHeight():Number
	{
		return __height;
	}


//** 10) write a constructor.  It should generally be empty

	function ScrollBar()
	{
	}

//** 11) put in your init function.  Init is called when the class is created
//      CreateChildren is called when the after all of the objects in the inheritance
//      chain have been initialized.  You also have the option to not call
//      super.createChildren, where you must call super.init();

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
	function init(Void):Void
	{
	//** 11a) call super.init().  This adds your StyleDeclaration (if nobody gave you one
	//       and sets initial values for width and height
		super.init();

	//** 11b) finish other initialization of variables.
		_scrollPosition = 0;

		// most components are focusable, but the scrollbar isn't
		tabEnabled = false;
		focusEnabled = false;

		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;

	}

	//** 12) load your graphics and sub objects in createChildren.  Subclasses
	//      will have had a chance to override the creation of your children
	//      so check to see what isn't defined and create it now
	//      It is recommended that you make things invisible at first so there
	//      isn't flicker as the object is created.

/**
* @private
* create child objects.
*/
	function createChildren(Void):Void
	{
		// get the scroll tracking area
		if (scrollTrack_mc == undefined)
		{
			setSkin(skinIDTrack, scrollTrackName);
		}
		scrollTrack_mc.visible = false;

		// now that the track is loaded, setup the scrollbar track listener
		// even though the buttons aren't created yet.  As an optimization,
		// we will set up the buttons in the correct enabled/disabled state
		// in their initialization routines
	//	setScrollProperties(pageSize, minPos, maxPos);

		var o:Object = new Object();
		o.enabled = false; //enabled && (maxPos - minPos > 0);
		o.preset = SimpleButton.falseDisabled; // o.enabled ? SimpleButton.falseUp : SimpleButton.falseDisabled;
		o.initProperties = 0;	// make sure it doesn't go through clip parameter processing
		o.autoRepeat = true;
		o.tabEnabled = false;

		var b;
		// get the arrow buttons
		if (upArrow_mc == undefined)
		{
			b = createButton(upArrowName, "upArrow_mc", skinIDUpArrow, o);
		}
		b.buttonDownHandler = onUpArrow;
		b.clickHandler = onScrollChanged;
		_minHeight = b.height;
		_minWidth = b.width;

		// get the arrow buttons
		if (downArrow_mc == undefined)
		{
			b = createButton(downArrowName, "downArrow_mc", skinIDDownArrow, o);
		}
		b.buttonDownHandler = onDownArrow;
		b.clickHandler = onScrollChanged;
		_minHeight += b.height;

	//** 12b) the base class will automatically call invalidate to get things to display
	}

	// helper function to create the arrow buttons
	function createButton(linkageName:String, id:String, skinID:Number, o:Object):Object
	{

		// here's a situation where using a skinID saves os from a string compare
		if (skinID == skinIDUpArrow)
		{
			o.falseUpSkin = upArrowUpName;
			o.falseDownSkin = upArrowDownName;
			o.falseOverSkin = upArrowOverName;

		}
		else
		{
			o.falseUpSkin = downArrowUpName;
			o.falseDownSkin = downArrowDownName;
			o.falseOverSkin = downArrowOverName;
		}

		var b = createObject(linkageName, id, skinID, o);
		this[id].visible = false;
		this[id].useHandCursor = false;

		return b;
	}

/**
* @private
* create the thumb
*/
	function createThumb(Void):Void
	{
		//mr
		var o:Object = new Object();
		o.validateNow = true;
		o.tabEnabled = false;
		o.leftSkin = thumbTopName;
		o.middleSkin = thumbMiddleName;
		o.rightSkin = thumbBottomName;
		o.gripSkin = thumbGripName;

		createClassObject(ScrollThumb, "scrollThumb_mc", skinIDThumb, o);
	}

	//** 13) add methods on your object.  If you are converting an old
	//      component, review it to see if anything needs
	//      to change.  Most things stay the same unless they involve
	//      broadcasting events, or things that are now getter/setter
	//      properties

	//  ::: PUBLIC METHODS

/**
* resizes the thumb, enables/disables arrows if there is stuff to scroll
*
* @tiptext
* @helpid 3267
*/
	function setScrollProperties(pSize:Number, mnPos:Number, mxPos:Number, ls:Number):Void
	{
		var thumbHeight:Number;
		var o:SkinElement = scrollTrack_mc;

		pageSize = pSize;
		largeScroll = (ls != undefined && ls > 0) ? ls : pSize;
		minPos = Math.max(mnPos, 0);
		maxPos = Math.max(mxPos,0);
		_scrollPosition = Math.max(minPos, _scrollPosition);
		_scrollPosition = Math.min(maxPos, _scrollPosition);
		if ((maxPos-minPos > 0) && enabled) {
			var tmp:Number = _scrollPosition;
			if (!initializing)
			{
				upArrow_mc.enabled = true;
				downArrow_mc.enabled = true;
			}
			o.onPress = o.onDragOver = startTrackScroller;
			o.onRelease = releaseScrolling;
			o.onDragOut = o["stopScrolling"] = stopScrolling;
			o.onReleaseOutside = releaseScrolling;
			o.useHandCursor = false;
			if (scrollThumb_mc == undefined)
			{
				createThumb();
			}
			var st:ScrollThumb = scrollThumb_mc;
			if (scrollTrackOverName.length > 0)
			{
				o.onRollOver = trackOver;
				o.onRollOut = trackOut;
			}
			thumbHeight = pageSize / (maxPos-minPos+pageSize) * o.height;
			if (thumbHeight < st.minHeight)
			{
				if (o.height < st.minHeight)
				{
					st.visible = false;
				}
				else
				{
					thumbHeight = st.minHeight;
					st.visible = true;
					st.setSize(_minWidth, st.minHeight + 0);
				}
			}
			else
			{
				st.visible = true;
				st.setSize(_minWidth, thumbHeight);
			}
			st.setRange(upArrow_mc.height + 0, virtualHeight - downArrow_mc.height - st.height,
										 minPos, maxPos);
			tmp = Math.min(tmp, maxPos);
			scrollPosition = Math.max(tmp, minPos);
		} else {
			scrollThumb_mc.visible = false;
			if (!initializing)
			{
				upArrow_mc.enabled = false;
				downArrow_mc.enabled = false;
			}
			delete o.onPress;
			delete o.onDragOver;
			delete o.onRelease;
			delete o.onDragOut;
			delete o.onRollOver;
			delete o.onRollOut;
			delete o.onReleaseOutside;
		}
		if (initializing)
		{
			scrollThumb_mc.visible = false;
		}
	}

	// turn off buttons, or turn on buttons and resync thumb
	function setEnabled(enabledFlag:Boolean):Void
	{
		super.setEnabled(enabledFlag);
		setScrollProperties(pageSize, minPos, maxPos, largeScroll);
	}

	//** 14) create a draw method.  Most of the time, all you'll need to do
	//		is force a layout of your objects, and make things visible if it
	//      is the first time you are being drawn

	// draw by making everything visible, then laying out
	function draw(Void):Void
	{
		if (initializing)
		{
			initializing = false;
			scrollTrack_mc.visible = true;
			upArrow_mc.visible = true;
			downArrow_mc.visible = true;
		}

		// call size to get everything to display itself in the right place
		size();
	}

	//** 15) create a size method or replace your old setSize with an size()
	// stretches the track, creates + positions arrows

/**
* @private
* size changed to re-position everything
*/
	function size(Void):Void
	{
		if (_height==1) return;

		if (upArrow_mc == undefined) return;

		var y1:Number = upArrow_mc.height;
		var y2:Number = downArrow_mc.height;
		upArrow_mc.move(0, 0);
		var st:SkinElement = scrollTrack_mc;
		st._y = y1;
		st._height = virtualHeight - y1 - y2;
		downArrow_mc.move(0, virtualHeight - y2);
		setScrollProperties(pageSize, minPos, maxPos, largeScroll);
	}

/**
* @private
* create and dispatch a scroll event
*/
	function dispatchScrollEvent(detail:String):Void
	{
		// don't type this as a UIEvent so we can overload the detail type
		dispatchEvent({type: "scroll", detail: detail});
	}

/**
* @private
* returns true if it is a scrollbar key.  It will execute the equivalent code for that key as well
*/
	function isScrollBarKey(k:Number):Boolean
	{
		if (k == Key.HOME)
		{
			if (scrollPosition != 0)
			{
				scrollPosition = 0;
				dispatchScrollEvent(minMode);
			}
			return true;
		}
		else if (k == Key.END)
		{
			if (scrollPosition < maxPos)
			{
				scrollPosition = maxPos;
				dispatchScrollEvent(maxMode);
			}
			return true;
		}
		return false;

	}

	//   ::: PRIVATE METHODS

/**
* @private
* figure out how much to move
*/
	function scrollIt(inc:String, mode:Number):Void
	{
		var delt:Number = smallScroll;
		if (inc != "Line") {
			delt = (largeScroll==0) ? pageSize : largeScroll;
		}
		var newPos:Number = _scrollPosition + (mode*delt);
		if (newPos>maxPos) {
			newPos = maxPos;
		} else if (newPos<minPos) {
			newPos = minPos;
		}
		if (scrollPosition != newPos)
		{
			scrollPosition = newPos;
			var move:String = (mode < 0) ? minusMode : plusMode;
			dispatchScrollEvent(inc + move);
		}
	}

/**
* @private
* set up the repeating events when pressing on the track
*/
	function startTrackScroller(Void):Void
	{
		_parent.pressFocus();

		if (_parent.scrollTrackDownName.length > 0)
		{
			if (_parent.scrollTrackDown_mc == undefined)
			{
				_parent.setSkin(skinIDTrackDown, scrollTrackDownName);
			}
			else
			{
				_parent.scrollTrackDown_mc.visible = true;
			}
		}
		_parent.trackScroller();
		_parent.scrolling = setInterval(_parent, "scrollInterval", getStyle("repeatDelay"), "Page", -1);
	}

/**
* @private
* this gets called at certain intervals to repeat the scroll event when pressing the track
*/
	function scrollInterval(inc:String,mode:Number):Void
	{
		clearInterval(scrolling);
		if (inc=="Page") {
			trackScroller();
		} else {
			scrollIt(inc,mode);
		}
		scrolling = setInterval(this, "scrollInterval", getStyle("repeatInterval"), inc, mode);
	}

/**
* @private
* figure out which direction we're moving
*/
	function trackScroller(Void):Void
	{
		if (scrollThumb_mc._y+scrollThumb_mc.height < _ymouse) {
			scrollIt("Page",1);
		} else if (scrollThumb_mc._y>_ymouse) {
			scrollIt("Page",-1);
		}
	}

/**
* @private
* this event is used by scrollview contents so they know they can reset selection
* after the user has clicked on the scroll bars
*/
	function dispatchScrollChangedEvent(Void):Void
	{
		dispatchEvent({type:"scrollChanged"});
	}

/**
* @private
* stop repeating events because the track is no longer pressed
*/
	function stopScrolling(Void):Void
	{
		clearInterval(_parent.scrolling);
		_parent.scrollTrackDown_mc.visible = false;
	}

/**
* @private
* stop repeating events because the track is no longer pressed
* special case to restore focus when we've released the mouse
*/
	function releaseScrolling(Void):Void
	{
		_parent.releaseFocus();
		stopScrolling();
		_parent.dispatchScrollChangedEvent();
	}

/**
* @private
* switch to the over state of the track
*/
	function trackOver(Void):Void
	{
		if (_parent.scrollTrackOverName.length > 0)
		{
			if (_parent.scrollTrackOver_mc == undefined)
			{
				_parent.setSkin(skinIDTrackOver, scrollTrackOverName);
			}
			else
			{
				_parent.scrollTrackOver_mc.visible = true;
			}
		}
	}

/**
* @private
* the mouse has left the track
*/
	function trackOut(Void):Void
	{
		_parent.scrollTrackOver_mc.visible = false;
	}

/**
* @private
* callback when the uparrow is pressed
*/
	function onUpArrow(Void):Void
	{
		_parent.scrollIt("Line",-1);
	}

/**
* @private
* callback when the downarrow is pressed
*/
	function onDownArrow(Void):Void
	{
		_parent.scrollIt("Line",1);
	}

/**
* @private
* callback when the arrow is released
*/
	function onScrollChanged(Void):Void
	{
		_parent.dispatchScrollChangedEvent();
	}
	
	private static var ButtonDependency = mx.controls.Button;
}
