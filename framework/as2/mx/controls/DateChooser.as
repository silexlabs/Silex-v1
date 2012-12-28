//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.CalendarLayout;
import mx.controls.SimpleButton;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.skins.ColoredSkinElement;

/**
* @tiptext scroll event
* @helpid 3600
*/
[Event("scroll")]
/**
* @tiptext change event
* @helpid 3601
*/
[Event("change")]

[TagName("DateChooser")]
[RequiresDataBinding(true)]
[IconFile("DateChooser.png")]

/**
* The class for handling DateChooser functionality.
*
* @helpid 3602
* @tiptext DateChooser enables a user to select a date
*/
class mx.controls.DateChooser extends UIComponent
{

	/**
	* @private
	* SymbolName for DateChooser
	*/
	static var symbolName:String = "DateChooser";

	/**
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = DateChooser;
	
	/**
	* name of this class
	*/
	var className:String = "DateChooser";

	//#include "../core/ComponentVersion.as"

	// Properties
	var __enabled:Boolean = true;
	var __monthNames:Array = [ "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ];
	
	// Children
	var boundingBox:MovieClip;
	var background_mc:MovieClip;
	var border_mc:MovieClip;
	var headerDisplay:MovieClip;
	var dateDisplay:TextField;
	var fwdMonthHit:MovieClip;
	var backMonthHit:MovieClip;

	var fwdMonthButton:SimpleButton;
	var backMonthButton:SimpleButton;
	var todayIndicator:MovieClip; 
	var dateGrid:CalendarLayout;
	var	sizeXRatio:Number;
	var	sizeYRatio:Number;
	var uninitializer:Object = undefined;

	var _color:Object = {headerColor:1,backgroundColor:1};
	var clipParameters:Object = {showToday: 1, firstDayOfWeek: 1, monthNames: 1, dayNames: 1, disabledDays: 1}; 
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(mx.controls.DateChooser.prototype.clipParameters, UIComponent.prototype.clipParameters);

	////////////////////////////////////////////////////////////////////////////
	//
	// Constants
	//
	////////////////////////////////////////////////////////////////////////////
	
	// Layout
	var distance:Number = 1;
	var gridY:Number = 41;
	var defaultWidth = 205;
	var defaultHeight = 214;

	//defining to compile
	var calHeader:MovieClip;

	// Depths in DateChooser
	var dateGridDepth:Number = 5;
	var backgroundDepth:Number = 1;
	var borderDepth:Number = 2; 
	var headerDepth:Number = 3;
	var headerDisplayDepth:Number = 4;
	var buttonHitAreaDepth:Number = 8;
		
	//skin buttons to now remain according to the new version of Royale
	// Skins for month forward button
	var fwdMonthButtonSkinID:Number = 6;
	var fwdMonthButtonUpSymbolName:String = "fwdMonthUp";
	var fwdMonthButtonDownSymbolName:String = "fwdMonthDown";
	var fwdMonthButtonDisabledSymbolName:String = "fwdMonthDisabled";
	
	// Skins for month backward button
	var backMonthButtonSkinID:Number = 7;
	var backMonthButtonUpSymbolName:String = "backMonthUp";
	var backMonthButtonDownSymbolName:String = "backMonthDown";
	var backMonthButtonDisabledSymbolName:String = "backMonthDisabled";

	// Other state information
	var previousSelectedCellIndex:Number = undefined;

	/**
	* Constructor
	*/
	function DateChooser()
	{
	}
	
	/**
	* @private
	* init variables.
	*
	*/
	function init():Void
	{
		super.init();
		tabEnabled = false;		
		// Hide the author-time bounding box
		boundingBox._visible = false;
		boundingBox._width = boundingBox._height = 0;
	}
	
	/**
	* @private
	* create subobjects in the component. This method creates textfields for 
	* dates in a month, month scroll buttons, header row, background and border.
	*
	*/
	function createChildren():Void
	{
		// Create the background.
		var w:Number = width; // Compiler workaround !!!
		var h:Number = height;
		
		createEmptyMovieClip("background_mc", backgroundDepth);
		var localBackground:MovieClip = background_mc;
		localBackground.onPress = function (){};
		localBackground.useHandCursor = false;
		

		createEmptyMovieClip("border_mc", borderDepth);
		var localBorder:MovieClip = border_mc;
		
		sizeXRatio = w/defaultWidth;
		sizeYRatio = h/defaultHeight;


		localBackground.beginFill(0xFFFFFF, 100);
		localBackground.lineTo(w, 0);
		localBackground.lineTo(w, h);
		localBackground.lineTo(0, h);
		localBackground.lineTo(0, 0);
		localBackground.endFill();
		
		localBackground.styleName = this;
		ColoredSkinElement.setColorStyle(localBackground, "backgroundColor");

		localBorder.lineStyle(0, 0x000000, 100);
		localBorder.lineTo(w, 0);
		localBorder.lineTo(w, h);
		localBorder.lineTo(0, h);
		localBorder.lineTo(0, 0);

		ColoredSkinElement.setColorStyle(localBorder, "borderColor");

		

		//create Grid: instance of CalendarLayout
	
		if (_global.styles.CalendarLayout !=undefined){ styleName = _global.styles.CalendarLayout;}
		createClassObject(CalendarLayout, "dateGrid", dateGridDepth,{styleName:this});
		for(var t in uninitializer)
		{
			dateGrid[t] = uninitializer[t];
		}


		dateGrid.move(0,41*sizeYRatio);


		//create the header

		createEmptyMovieClip("calHeader", headerDepth);
		var localHeader:MovieClip = calHeader;
		
		localHeader.beginFill(0x389683, 100);
		localHeader.moveTo(1, 1);
		localHeader.lineTo(w-1,1);
		localHeader.lineTo(w - 1,30*sizeYRatio);
		localHeader.lineTo(1,30*sizeYRatio);
		localHeader.lineTo(1, 1);
		localHeader.endFill();

		//dateHeaderColor
		localHeader.styleName = this;
		ColoredSkinElement.setColorStyle(localHeader, "headerColor");

	
		createLabel("dateDisplay",headerDisplayDepth);
		dateDisplay._width = 120*sizeXRatio;
		dateDisplay._height = 20*sizeYRatio;
		dateDisplay._x = 45*sizeXRatio;
		dateDisplay._y = 5*sizeYRatio;
		dateDisplay.readOnly = true;
		dateDisplay.selectable = false;
		dateDisplay.setStyle("styleName","HeaderDateText");
		dateDisplay.text = monthNames[displayedMonth]+" "+displayedYear;


		createClassObject(SimpleButton, "fwdMonthButton", fwdMonthButtonSkinID);
		var localFwdMonthButton:SimpleButton = fwdMonthButton;
		localFwdMonthButton.autoRepeat = false;
		localFwdMonthButton.tabEnabled = false;
		
		localFwdMonthButton.move((w - (12*sizeXRatio) - (6*sizeXRatio)), 8*sizeYRatio);
			
		localFwdMonthButton.falseUpSkin = fwdMonthButtonUpSymbolName;
		localFwdMonthButton.falseDownSkin = fwdMonthButtonDownSymbolName;
		localFwdMonthButton.falseDisabledSkin = fwdMonthButtonDisabledSymbolName;
			
		localFwdMonthButton.buttonDownHandler = fwdMonthButtonDownHandler;
		
		// Create the previous-month button.
		
		createClassObject(SimpleButton, "backMonthButton", backMonthButtonSkinID);
		var localBackMonthButton:SimpleButton = backMonthButton;
		localBackMonthButton.tabEnabled = false;
		localBackMonthButton.autoRepeat = false;
		localBackMonthButton.move(12*sizeXRatio, 8*sizeYRatio);
			
		localBackMonthButton.falseUpSkin = backMonthButtonUpSymbolName;
		localBackMonthButton.falseDownSkin = backMonthButtonDownSymbolName;
		localBackMonthButton.falseDisabledSkin = backMonthButtonDisabledSymbolName;
			
		localBackMonthButton.buttonDownHandler = backMonthButtonDownHandler;
		
		var pointX:Number = fwdMonthButton._x;
		var pointY:Number = fwdMonthButton._y;

		createEmptyMovieClip("fwdMonthHit", buttonHitAreaDepth);
		fwdMonthHit.beginFill(0xCC0000,50);
		fwdMonthHit.moveTo(pointX - (6.2*sizeXRatio), pointY - (2.3*sizeYRatio));
		fwdMonthHit.lineTo(pointX+(12*sizeXRatio), pointY - (2.3*sizeYRatio));
		fwdMonthHit.lineTo(pointX+(12*sizeXRatio), pointY+(16*sizeYRatio));
		fwdMonthHit.lineTo(pointX - (6.2*sizeXRatio), pointY+(16*sizeYRatio));
		fwdMonthHit.lineTo(pointX - (6.2*sizeXRatio), pointY - (2.3*sizeYRatio));
		fwdMonthHit.endFill();
		fwdMonthHit._visible = false;

		fwdMonthButton.hitArea = fwdMonthHit;
		
		pointX = backMonthButton._x;
		pointY = backMonthButton._y;

		createEmptyMovieClip("backMonthHit", buttonHitAreaDepth+1);
		backMonthHit.beginFill(0xCC0000,50);
		backMonthHit.lineTo(fwdMonthHit._width, 0);
		backMonthHit.lineTo(fwdMonthHit._width, fwdMonthHit._height);
		backMonthHit.lineTo(0, fwdMonthHit._height);
		backMonthHit.lineTo(0, 0);
		backMonthHit.endFill();
		backMonthHit._x = pointX - (6*sizeXRatio);
		backMonthHit._y = pointY - (2.3*sizeYRatio);
		backMonthHit._visible = false;

		backMonthButton.hitArea = backMonthHit;
		
	}
	

	function invalidateStyle():Void
	{
		dateGrid.invalidateStyle();
		calHeader.invalidateStyle();
		background_mc.invalidateStyle();
		border_mc.invalidateStyle();
	}
	
	function setStyle(n:String,val):Void
	{
		var v = (val == " ") ? undefined : val;
		dateDisplay[n] = v;
		dateGrid.setStyle(n,val);
		super.setStyle(n,val);
	}

	/**
	* @private
	* size the object.  Lays out the contents.  
	* The width and height properties are set to the
	* new desired size
	*
	*/
	function setSize(w:Number, h:Number, noEvent:Boolean):Void
	{
		if(w<=1 || h<=1)
			return;
		var oldW = this.width;
		var oldH = this.height;
		
		sizeXRatio = w/oldW;
		sizeYRatio = h/oldH;

		
		//change the background MC, headers, text Display and month Buttons
		background_mc._width = w;
		background_mc._height = h;

		border_mc._width = w;
		border_mc._height = h;

		
		//change the header movieClip
		calHeader._xscale = background_mc._xscale;;
		calHeader._yscale= background_mc._yscale;

		//change the buttons
		//TODO: verify correctness
		//var buttonWidth = buttonWidth._width*sizeXRatio;
		//var buttonHeight = buttonWidth._height*sizeYRatio;
		var buttonWidth = border_mc._width*sizeXRatio;
		var buttonHeight = border_mc._height*sizeYRatio;
		
		backMonthButton.setSize(buttonWidth, buttonHeight);
		fwdMonthButton.setSize(buttonWidth, buttonHeight);

		var bButtonX = backMonthButton._x*sizeXRatio;
		var bButtonY = backMonthButton._y*sizeYRatio;

		var fButtonX = fwdMonthButton._x*sizeXRatio;
		var fButtonY = fwdMonthButton._y*sizeYRatio;

		backMonthButton._x = bButtonX;
		backMonthButton._y = bButtonY;
		
		fwdMonthButton._x = fButtonX;
		fwdMonthButton._y = fButtonY;

		backMonthHit._x = backMonthHit._x*sizeXRatio;
		backMonthHit._y = backMonthHit._y*sizeYRatio;
		backMonthHit._width = backMonthHit._width*sizeXRatio;
		backMonthHit._height = backMonthHit._height*sizeYRatio;


		fwdMonthHit._x = fwdMonthHit._x*sizeXRatio;
		fwdMonthHit._y = fwdMonthHit._y*sizeYRatio;
		fwdMonthHit._width = fwdMonthHit._width*sizeXRatio;
		fwdMonthHit._height = fwdMonthHit._height*sizeYRatio;

		//change the text Display
		dateDisplay._width= dateDisplay._width*sizeXRatio;
		dateDisplay._height= dateDisplay._height*sizeYRatio;
		
		var displayX = dateDisplay._x*sizeXRatio;
		var displayY = dateDisplay._y*sizeYRatio;

		dateDisplay._x = displayX;
		dateDisplay._y = displayY;

		if(dateGrid.autoScale)
		{
			var gridX = dateGrid._x*sizeXRatio;
			dateGrid._x = gridX;
			var gridY = dateGrid._y*sizeYRatio;
			dateGrid._y = gridY;
		}

		dateGrid.setSize(w,h,noEvent);
		super.setSize(w, h, noEvent);

		__width = w;
		__height = h;
	}
	
	//a temp object which stores the values from PI till CalendarLayout it not there.
	function getInitializer():Boolean
	{
		if(uninitializer == undefined)
		{
			uninitializer = new Object();
		}
		return true;
	}

	/**
	* current day highlight
	* @helpid 3603
	* @tiptext The highlight on the current day of the month
	*/
	[Inspectable(defaultValue=true)]
	function get showToday() : Boolean
	{
		if(__enabled)
			return dateGrid.showToday;
	}

	function set showToday(n : Boolean)
	{
		if(!__enabled)
			return;

		if(dateGrid == undefined && getInitializer())
		{
			uninitializer.showToday = n;
		}
		else
		{
			dateGrid.showToday=n;
		}
	}


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
		fwdMonthButton.enabled = b;
		backMonthButton.enabled = b;
		dateDisplay.enabled = b;
		dateGrid.enabled = b;

	}

	/**
	* first day of week
	* @helpid 3604
	* @tiptext Sets the first day of week for DateChooser
	*/
	[Inspectable(defaultValue=0)]
	function get firstDayOfWeek() : Number
	{
		if(__enabled)
			return dateGrid.firstDayOfWeek;
	}

	function set firstDayOfWeek(n : Number)
	{
		if(!__enabled)
			return;

		if(dateGrid==undefined && getInitializer())
		{
			uninitializer.firstDayOfWeek = n;
		}
		else
		{
			dateGrid.firstDayOfWeek = n;
		}
	}

	// -------------------------------------------------------------------------
	// displayed month
	// -------------------------------------------------------------------------

	/**
	* current displayed month
	* @helpid 3605
	* @tiptext The currently displayed month in the DateChooser
	*/
  	[ChangeEvent("scroll")]
	[Bindable]
	function get displayedMonth():Number
	{
		if(__enabled)
			return dateGrid.displayedMonth;
	}

	function set displayedMonth(m:Number)
	{
		if(!__enabled)
			return;

		dateGrid.displayedMonth = m;
		dateDisplay.text = monthNames[dateGrid.displayedMonth]+" "+displayedYear;
	}

	
	/**
	* displayed Year
	* @helpid 3606
	* @tiptext The currently displayed year in DateChooser
	*/
  	[ChangeEvent("scroll")]
	[Bindable]
	function get displayedYear():Number
	{
		if(__enabled)
			return dateGrid.displayedYear;
	}

	function set displayedYear(y:Number)
	{
		if(!__enabled)
			return;

		dateGrid.displayedYear = y;
		dateDisplay.text = monthNames[displayedMonth]+" "+displayedYear;
	}
	
	/**
	* names of days of week
	* @helpid 3607
	* @tiptext The names of days of week in a DateChooser
	*/
	[Inspectable(defaultValue="S,M,T,W,T,F,S")]
	function get dayNames() : Array
	{
		if(__enabled)
		{
			if(dateGrid == undefined && getInitializer())
			{
				return uninitializer.dayNames;
			}
			else
			{
				return dateGrid.dayNames;
			}
		}
	}

	function set dayNames(d : Array)
	{
		if(!__enabled)
			return;

		if(dateGrid == undefined && getInitializer())
		{
			uninitializer.dayNames = d;
		}
		else
		{
			dateGrid.dayNames = d;
		}
	}
	
	/**
	* disabled Days
	* @helpid 3608
	* @tiptext The disabled days in a week
	*/
	[Inspectable(defaultValue="")]
	function get disabledDays() : Array
	{
		if(__enabled)
		{
			if(dateGrid == undefined && getInitializer())
			{
				return uninitializer.disabledDays;
			}
			else
			{
				return dateGrid.disabledDays;
			}
		}
	}

	function set disabledDays(dd : Array)
	{
		if(!__enabled)
			return;
		if(dateGrid == undefined && getInitializer())
		{
			uninitializer.disabledDays = dd;
		}
		else
		{
			dateGrid.disabledDays = dd;
		}
	}
	
	
	/**
	* selectable range
	* @helpid 3609
	* @tiptext The start and end dates between which a date can be selected
	*/
	function get selectableRange()
	{
		if(__enabled)
			return dateGrid.selectableRange;
	}

	function set selectableRange(sRange)
	{
		if(!__enabled)
			return;
			
		dateGrid.selectableRange = sRange;
	}
	
	/**
	* disabled ranges
	* @helpid 3610
	* @tiptext The disabled dates inside the selectableRange
	*/
	function get disabledRanges():Array
	{
		if(__enabled)
			return dateGrid.disabledRanges;
	}

	function set disabledRanges(r:Array)
	{
		if(!__enabled)
			return;

		dateGrid.disabledRanges = r.slice(0);
	}
	
	/**
	* selected date
	* @helpid 3611
	* @tiptext The selected date in DateChooser
	*/
  	[ChangeEvent("change")]
	[Bindable]
	function get selectedDate():Date
	{
		if(__enabled)
			return dateGrid.selectedDate;
	}

	function set selectedDate(s:Date)
	{
		if(!__enabled)
			return;

		dateGrid.selectedDate = s;
		dateDisplay.text = monthNames[displayedMonth]+" "+displayedYear;
	}

	/**
	* month names
	* @helpid 3612
	* @tiptext The name of the months displayed in the DateChooser
	*/
	[Inspectable(defaultValue="January,February,March,April,May,June,July,August,September,October,November,December")]
	function get monthNames() : Array
	{
		if(__enabled)
			return getMonthNames();
	}
	
	function getMonthNames() : Array
	{
		return __monthNames;
	}
	
	function set monthNames(a : Array) : Void
	{
		if(!__enabled)
			return;
		setMonthNames(a);
	}
	
	function setMonthNames(a : Array) : Void
	{
 		// If we just set the values of __monthNames array, they will be picked up
 		// by all other DateChooser components. Instead, we'll create a new array
 		// and set the values into that.
 		__monthNames = new Array();
		for (var i:Number = 0; i < a.length; i++)
		{
			__monthNames[i] = a[i];
		}
		if(dateGrid!=undefined)
		{
			dateDisplay.text = __monthNames[displayedMonth]+" "+displayedYear;
		}

	}
	
	// -------------------------------------------------------------------------
	// Event handling
	// -------------------------------------------------------------------------

	function fwdMonthButtonDownHandler():Void
	{
		var owner = _parent;
		var testDate = new Date(owner.displayedYear, owner.displayedMonth, owner.selectableRange.rangeEnd.getDate());
		if((owner.selectableRange != undefined) && (owner.dateGrid.selRangeMode == 1 || owner.dateGrid.selRangeMode == 3))
		{
			if(owner.selectableRange.rangeEnd > testDate)
			{
				owner.dateGrid.stepDate(0, 1);
				owner.dateDisplay.text = owner.monthNames[owner.displayedMonth]+" "+owner.displayedYear;
			}
			
		}
		else if(owner.dateGrid.selRangeMode != 4 || owner.selectableRange == undefined)
		{
			owner.dateGrid.stepDate(0, 1);
			owner.dateDisplay.text = owner.monthNames[owner.displayedMonth]+" "+owner.displayedYear;
		}
	} 
	
	function backMonthButtonDownHandler():Void
	{

		var owner = _parent;
		var testDate = new Date(owner.displayedYear, owner.displayedMonth, owner.selectableRange.rangeStart.getDate());
		if((owner.selectableRange != undefined) && (owner.dateGrid.selRangeMode == 1 || owner.dateGrid.selRangeMode == 2))
		{
			if(owner.selectableRange.rangeStart < testDate)
			{
				owner.dateGrid.stepDate(0, -1);
				owner.dateDisplay.text = owner.monthNames[owner.displayedMonth]+" "+owner.displayedYear;
			}
			
		}
		else if(owner.dateGrid.selRangeMode != 4 || owner.selectableRange == undefined)
		{
			owner.dateGrid.stepDate(0, -1);
			owner.dateDisplay.text = owner.monthNames[owner.displayedMonth]+" "+owner.displayedYear;
		}
	} 

	function dispatchScrollEvent(detail:String):Void
	{
		// don't type this as a UIEvent so we can overload the detail type
		dispatchEvent({type: "scroll", detail: detail});
	}

	function dispatchChangeEvent():Void
	{
		// don't type this as a UIEvent so we can overload the detail type
		dispatchEvent(({type:"change"}));
	}

}
