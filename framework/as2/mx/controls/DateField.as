//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.ComboBase;
import mx.controls.DateChooser;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.managers.PopUpManager;

/**
* @tiptext change event
* @helpid 3613
*/
[Event("change")]
/**
* @tiptext open event
* @helpid 3614
*/
[Event("open")]
/**
* @tiptext close event
* @helpid 3615
*/
[Event("close")]
/**
* @tiptext scroll event
* @helpid 3616
*/
[Event("scroll")]

[TagName("DateField")]
[RequiresDataBinding(true)]
[IconFile("DateField.png")]

/**
* DateField class
*
* @tiptext Pops up a DateChooser for date selection
* @helpid 3617
*/ 
[InspectableList("dayNames","disabledDays","monthNames","firstDayOfWeek","showToday")]
class mx.controls.DateField extends ComboBase
{
	/**
	* @private
	* SymbolName for DateField
	*/
	static var symbolName:String = "DateField";

	/**
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = DateField;

	/**
	* @private
	* Class name of this class
	*/
	var   className : String = "DateField";
//#include "../core/ComponentVersion.as"
	
	var	_showingPullDown:Boolean = false;
	var	__pullDown:MovieClip;
	var boundingBox:MovieClip;
	var initializing = true;
	var	__dateFormatter:Function;
	var	dispatchValueChangedEvent:Function;
	var __enabled:Boolean = true;
	var pullDownExists:Boolean = false;
	var isPressed:Boolean;
	var bInKeyDown:Boolean = false;
	var propTempStore:Object = undefined;
	var openPos:Number = 0;

	var clipParameters:Object = {showToday: 1, firstDayOfWeek: 1, monthNames: 1, dayNames: 1, disabledDays: 1}; 
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(mx.controls.DateField.prototype.clipParameters, UIComponent.prototype.clipParameters);

	var owner:Object;

	/**
	* Constructor
	*/
	function DateField()
	{
	}
	
	/**
	* @private
	* init variables.
	*
	*/
	function init() : Void
	{
		super.init();
		__height = 22;
		boundingBox._visible = false;

		downArrowUpName = "openDateUp";
		downArrowDownName = "openDateDown";
		downArrowOverName = "openDateOver";
		downArrowDisabledName = "openDateDisabled";

	}
	
	/**
	* @private
	* create subobjects in the component. 
	*
	*/
	function createChildren() : Void
	{
		super.createChildren();
		// Set our editable state to itself in order to force the onPress method to be set (if necessary).

		editable = editable;
		text_mc.text = "";
		tabEnabled = false;
		initializing = false;
	}
	
	function onKillFocus(n) : Void
	{	
		super.onKillFocus();
	}
	
	//-- Creation (PullDown) -----------------------------------
	function getPullDown() : Object
	{
		if (initializing || !__enabled)
			return undefined;
			
		if (!hasPullDown())
		{
			var o = new Object();
			o.styleName = this;
			o._visible = false;
			__pullDown = PopUpManager.createPopUp(this, DateChooser, false, o, true);
			__pullDown.owner = this;
			__pullDown.changeHandler = _changeHandler;
			__pullDown.scrollHandler = _scrollHandler;
			__pullDown.itemRollOverHandler = _itemRollOverHandler;
			__pullDown.itemRollOutHandler = _itemRollOutHandler;
			__pullDown.resizeHandler = _resizeHandler;
			__pullDown.mouseDownOutsideHandler = function(eventObj)
			{
 				o = this.owner;
 				var pt = new Object();
 				pt.x = o._root._xmouse;
 				pt.y = o._root._ymouse;
 				o._root.localToGlobal(pt);
 				if( o.hitTest(pt.x, pt.y, false) ) 
				{
					//do nothing
				}
				else if (this.owner.downArrow_mc.hitTest(pt.x, pt.y, false)) 
				{
					//do nothing
				}
				else 
				{

					this.owner.displayPullDown(false);
				}
			};
			for(var i in propTempStore)
			{
				__pullDown[i] = propTempStore[i];
			}
			delete propTempStore;
			pullDownExists = true;
			// Create the mask that keeps the pullDown listbox only visible below the textfield.
		}
		
		return __pullDown;
	}
	
	//  :::  PUBLIC METHODS
	
	//-- Size ------------------------------------------------
	function setSize(w:Number, h:Number, noEvent) : Void
	{
		super.setSize(w, __height, noEvent);
	}
	
	function getPropTempStore():Boolean
	{
		if(propTempStore == undefined)
		{
			propTempStore = new Object();
		}
		return true;
	}

	
	//-- DateFormatter Function -------------------------------------
	function getDateFormatter():Function
	{
		return __dateFormatter;
	}
	
/**
* user supplied function
* @tiptext A user-supplied function to compute the label of a Date item. 
* @helpid 3618
*/ 
	function get dateFormatter():Function
	{
		return getDateFormatter();
	}
	
	function set dateFormatter(f:Function):Void
	{
		__dateFormatter = f;
	}
	
	//-- pullDown  ---------------------------------------------
/**
* reference of pulldown
* @tiptext Returns a reference to the DateChooser component contained by the DateField.
* @helpid 3619
*/ 
	function get pullDown() : Object
	{
		return getPullDown();
	}
	

	//-- Open -----------------------------------------------
	/**
	* @tiptext Opens the pullDown DateChooser.
	* @helpid 3620
	*/ 
	function open() : Void
	{
		displayPullDown(true);
	}

	//-- Close -----------------------------------------------
	/**
	* @tiptext Closes the pullDown DateChooser.
	* @helpid 3621
	*/ 
	function close() : Void
	{
		displayPullDown(false);
	}

//  :::  PROTECTED METHODS
	
		
	//-- Has pullDown ---------------------------------------
	function hasPullDown() : Boolean
	{
		return (__pullDown != undefined && __pullDown.valueOf() != undefined);
	}
	
	//-- Display PullDown ------------------------------------
	function displayPullDown(show:Boolean) : Void
	{
		
		if (show == _showingPullDown)
			return;
		
		// subclasses may extend to do pre-processing before the pullDown is displayed
		// or override to implement special display behavior
		var point = new Object();
		var todaysDate = new Date();
		//point x will exactly appear on the icon. Leaving 1 pixel for the border to appear.
		point.x = width - downArrow_mc.width;
		point.y = 0;
		localToGlobal(point);
		var o = this;
		o._root.globalToLocal(point);
		if (show) 
		{
			getPullDown();
			var dd = __pullDown;
			var dfDate = (__pullDown.selectedDate!=undefined) ? __pullDown.selectedDate : undefined;
			

			if(dfDate!=undefined)
			{
				__pullDown.displayedMonth = dfDate.getMonth();
				__pullDown.displayedYear = dfDate.getFullYear();
			}
			else
			{
				__pullDown.displayedMonth = todaysDate.getMonth();
				__pullDown.displayedYear = todaysDate.getFullYear();
			}

			dd.isPressed = true;
			dd.visible = show;
			var	xVal = point.x;
			var yVal = point.y;
			//handling of pullDown position
			// A. Bottom Left Placment
			// B. Bottom Right Placement
			// C. Top Right Placement

			if ((Stage.width > (dd.width + point.x)) && (Stage.height < (dd.height + point.y)))
			{
				xVal = point.x;
				yVal = point.y - dd.height + height;
				openPos = 1;
			}
			else if((Stage.width < (dd.width + point.x)) && (Stage.height < (dd.height + point.y)))
			{
				xVal = point.x - dd.width + downArrow_mc.width;
				yVal = point.y - dd.height;
				openPos = 2;
			}
			else if((Stage.width < (dd.width + point.x)) && (Stage.height > (dd.height + point.y)))
			{
				xVal = point.x - dd.width + downArrow_mc.width;
				yVal = point.y + height;
				openPos = 3;
			}
			else
			{
				downArrow_mc.enabled = false;
				openPos = 0;
			}

			dd.move(xVal, yVal);
		}
		else 
		{
			if(downArrow_mc.hitTest(_root._xmouse, _root._ymouse, false) && openPos!=0) 
			{
				__pullDown.visible = false;
			}
			else 
			{
				__pullDown.visible = false;
				downArrow_mc.enabled = true;
			}
		
		}

		_showingPullDown = show;
		
		dispatchEvent({type:(show ? "open" : "close"), target:this});
	}

//-------- Date Chooser Properties ------------------------
//height scaling not allowed
function get scaleY():Number
{
	return null;
}


function set scaleY(n:Number):Void
{
	//return;
}

// -------------------------------------------------------------------------
// showToday
// -------------------------------------------------------------------------

	/**
	* current day highlight
	* @helpid 3622
	* @tiptext The highlight on the current day of the month
	*/
	[Inspectable(defaultValue=true)]
	function get showToday() : Boolean
	{
		if(__enabled)
		{		
			if(!pullDownExists && getPropTempStore())
			{
				return propTempStore.showToday;
			}
			else
			{
				return __pullDown.showToday;
			}
		}
	}

	function set showToday(n : Boolean)
	{
		if(!__enabled)
			return;

		if(!pullDownExists && getPropTempStore())
		{
			propTempStore.showToday = n;
		}
		else
		{
			__pullDown.showToday=n;
		}
	}

	// -------------------------------------------------------------------------
	// enabled, will handle enabled at the last
	// -------------------------------------------------------------------------

	function get enabled():Boolean
	{
		return getEnabled();
	}
	
	function getEnabled():Boolean
	{
		return __enabled;
	}
		
	function set enabled(b:Boolean):Void
	{
		setEnabled(b);
	}
	
	function setEnabled(b:Boolean):Void
	{
		if (b == __enabled)
			return;
		__enabled = b;
		super.setEnabled(b);

	}

	// -------------------------------------------------------------------------
	// first Day of Week
	// -------------------------------------------------------------------------
	/**
	* first day of week
	* @helpid 3623
	* @tiptext Sets the first day of week for DateField
	*/
	[Inspectable(defaultValue=0)]
	function get firstDayOfWeek() : Number
	{
		if(__enabled)
		
		if(!pullDownExists && getPropTempStore())
		{
			return propTempStore.firstDayOfWeek;
		}
		else
		{
			return __pullDown.firstDayOfWeek;
		}
	}

	function set firstDayOfWeek(n : Number)
	{
		if(!__enabled)
			return;

		if(!pullDownExists && getPropTempStore())
		{
			propTempStore.firstDayOfWeek = n;
		}
		else
		{
			__pullDown.firstDayOfWeek = n;
		}
	}

	// -------------------------------------------------------------------------
	// displayed month
	// -------------------------------------------------------------------------
	/**
	* current displayed month
	* @helpid 3624
	* @tiptext The currently displayed month in the pullDown of DateField
	*/
	function get displayedMonth():Number
	{
		if(__enabled)
			return pullDown.displayedMonth;
	}

	function set displayedMonth(m:Number)
	{
		if(!__enabled)
			return;
		
		if(!pullDownExists)
		{
			propTempStore.displayedMonth = m;
		}
		else
		{
			if(pullDown.selectedDate == undefined)
				pullDown.displayedMonth = m;
		}

	}

	// -------------------------------------------------------------------------
	// displayed Year
	// -------------------------------------------------------------------------
	/**
	* displayed Year
	* @helpid 3625
	* @tiptext The currently displayed year in the pullDown of DateField
	*/
	function get displayedYear():Number
	{
		if(__enabled)
			return pullDown.displayedYear;
	}

	function set displayedYear(y:Number)
	{
		if(!__enabled)
			return;
		
		if(!pullDownExists)
		{
			propTempStore.displayedYear = y;
		}
		else
		{
			if(pullDown.selectedDate == undefined)
				pullDown.displayedYear = y;
		}
	}
	
	// -------------------------------------------------------------------------
	// Day Names
	// -------------------------------------------------------------------------
	/**
	* names of days of week
	* @helpid 3626
	* @tiptext The names of days of week in a pullDown of DateField
	*/
	[Inspectable(defaultValue="S,M,T,W,T,F,S")]
	function get dayNames() : Array
	{
		if(__enabled)
		{
			if(!pullDownExists && getPropTempStore())
			{
				return propTempStore.dayNames;
			}
			else
			{
				return __pullDown.dayNames;
			}
		}
	}

	function set dayNames(d : Array)
	{
		if(!__enabled)
			return;

		if(!pullDownExists && getPropTempStore())
		{
			propTempStore.dayNames = d;
		}
		else
		{
			__pullDown.dayNames = d;
		}
	}
	
	// -------------------------------------------------------------------------
	// disabled Days
	// -------------------------------------------------------------------------
	/**
	* disabled Days
	* @helpid 3627
	* @tiptext The disabled days in a week
	*/
	[Inspectable(defaultValue="")]
	function get disabledDays() : Array
	{
		if(__enabled)
		{
			if(!pullDownExists && getPropTempStore())
			{
				return propTempStore.disabledDays;
			}
			else
			{
				return __pullDown.disabledDays;
			}
		}
	}

	function set disabledDays(dd : Array)
	{
		if(!__enabled)
			return;

		if(!pullDownExists && getPropTempStore())
		{
			propTempStore.disabledDays = dd;
		}
		else
		{
			__pullDown.disabledDays = dd;
			checkSelectedDate();
		}
	}
	
	// -------------------------------------------------------------------------
	// selectable Range
	// Param: Object/Date Object
	// -------------------------------------------------------------------------

	/**
	* selectable range
	* @helpid 3628
	* @tiptext The start and end dates between which a date can be selected
	*/
	function get selectableRange()
	{
		if(__enabled)
			return pullDown.selectableRange;
	}

	function set selectableRange(sRange)
	{
		if(!__enabled)
			return;
		
		if(!pullDownExists)
		{
			propTempStore.selectableRange = sRange;
		}	
		else
		{
			pullDown.selectableRange = sRange;
			checkSelectedDate();			
		}
	}
	
	// -------------------------------------------------------------------------
	// Disabled Ranges
	// -------------------------------------------------------------------------

	/**
	* disabled ranges
	* @helpid 3629
	* @tiptext The disabled dates inside the selectableRange
	*/
	function get disabledRanges():Array
	{
		if(__enabled)
			return pullDown.disabledRanges;
	}

	function set disabledRanges(r:Array)
	{
		if(!__enabled)
			return;

		if(!pullDownExists)
		{
			propTempStore.disabledRanges = r.slice(0);
		}
		else
		{
			pullDown.disabledRanges = r.slice(0);
			checkSelectedDate();
		}
	}

	// -------------------------------------------------------------------------
	// selected Date
	// -------------------------------------------------------------------------

	/**
	* selected date
	* @helpid 3630
	* @tiptext The selected date in DateField
	*/
  	[ChangeEvent("change")]
	[Bindable]
	function get selectedDate():Date
	{
		if(__enabled)
			return pullDown.selectedDate;
	}

	function set selectedDate(s:Date)
	{
		if(!__enabled)
			return;

			pullDown.selectedDate = s;
			dateFiller(pullDown.selectedDate);
	}

	// -------------------------------------------------------------------------
	// monthNames
	// -------------------------------------------------------------------------
	/**
	* month names
	* @helpid 3631
	* @tiptext The name of the months displayed in the pullDown of DateField
	*/
	[Inspectable(defaultValue="January,February,March,April,May,June,July,August,September,October,November,December")]
	function get monthNames() : Array
	{
		if(__enabled)
		{
			if(!pullDownExists && getPropTempStore())
			{
				return propTempStore.monthNames;
			}
			else
			{
				return __pullDown.monthNames;
			}
		}
	}
	
	function set monthNames(a : Array) : Void
	{
		if(!__enabled)
			return;

		if(!pullDownExists && getPropTempStore())
		{
			propTempStore.monthNames = a.slice(0);
		}
		else
		{
			__pullDown.monthNames = a.slice(0);
		}
	}


	
	//  :::  PRIVATE METHODS
	
	//-- On Down Arrow -------------------------------------
	function onDownArrow() : Void
	{
		// the down arrow should always toggle the visibility of the pullDown
		_parent.displayPullDown(!_parent._showingPullDown);
	}
	
	function setStyle(n:String, val):Void
	{
		super.setStyle(n,val);
		pullDown.setStyle(n,val);
	}
	
	//-- Destructor ------------------------------------------
	function onUnload() : Void
	{
		__pullDown.removeMovieClip();
	}
	
	//PRIVATE EVENT HANDLERS
	
	//-- Resize Handler -------------------------------------
	function _resizeHandler() : Void
	{
		var o = this.owner;
	}
	
	//-- Change Handler ------------------------------------
	function _changeHandler(obj) : Void
	{
		var o = this.owner; // 'this' is the pullDown; 'o' is the DateField
		obj.target = o;
		var tempDate = o.pullDown.selectedDate;

		// This assignment will also assign the label to the text field. See setSelectedIndex().

		// If this was generated by the pullDown as a result of a keystroke, it is
		// likely a Page-Up or Page-Down, or Arrow-Up or Arrow-Down. If the selection
		// changes due to a keystroke, we leave the pullDown displayed. If it changes
		// as a result of a mouse selection, we close the pullDown.

		if (!o.bInKeyDown)
			o.displayPullDown(false);
			
		o.dispatchEvent(obj);

		o.dateFiller(tempDate);

//		var d =	o.pullDown.selectedDate;
//		o.text_mc.text = d.getDate()+"/"+(d.getMonth()+1)+"/"+d.getFullYear();

	}
	
	//this is the default date format which will be displayed if dateFormatter is not defined
	function dateFiller(d:Date):Void
	{
		if(dateFormatter==undefined)
		{
			if(d!=undefined)
			{
				text_mc.text = d.getDate()+" "+(monthNames[d.getMonth()]).substr(0, 3)+" "+d.getFullYear();
			}
			else
			{
				text_mc.text = "";
			}
		}
		else
		{
			text_mc.text = (d==undefined) ? "" : dateFormatter(d);
		}
	}

	function checkSelectedDate() : Void
	{
		if(pullDown.selectedDate!=undefined)
		{
			dateFiller(pullDown.selectedDate);
		}
		else
		{
			dateFiller();
		}
	}
	//-- Scroll Handler --------------------------------------
	function _scrollHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}
	
	//-- Item Roll Over Handler -----------------------------
	function _itemRollOverHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}
	
	//-- Item Roll Out Handler ------------------------------
	function _itemRollOutHandler(obj) : Void
	{
		var o = this.owner;
		obj.target = o;
		o.dispatchEvent(obj);
	}


}
