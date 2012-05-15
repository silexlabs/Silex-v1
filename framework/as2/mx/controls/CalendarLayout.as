//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.UIComponent;
import mx.skins.ColoredSkinElement;


//class declaration for calendar layout
/**************************************************************
This class would handle the layout of the date grid in a month.
CalendarLayout can be extended to develop DateControls with either
single month display control or side-by-side month displays.
**************************************************************/


class mx.controls.CalendarLayout extends UIComponent
{

	////////////////////////////////////////////////////////////////////////////
	//
	// Standard UIObject variables
	//
	////////////////////////////////////////////////////////////////////////////

	static var symbolName:String = "CalendarLayout";
	static var symbolOwner:Object = CalendarLayout;
	var className:String = "CalendarLayout";

	////////////////////////////////////////////////////////////////////////////
	//
	// Variables
	//
	////////////////////////////////////////////////////////////////////////////

	//variables
	var defaultWidth = 205;
	var defaultHeight = 165;

	// Depths in CalendarLayout
	var dayBlockBaseDepth:Number = 2; // 2 - 7 for dayBlock0 - dayBlock6
	var showTodayDepth:Number = 200;
	var selectedDateDepth:Number = 198;
	var rollOverDateDepth:Number = 199;
	var labelBaseDepth:Number = 900;// Depths within each DayBlock
	var backgroundDepth:Number = 1;

	// Other variables
	var selRangeMode:Number = 1;
	var disRangeMode:Array = [];
	var selCell:TextField;
	var selectedCell:String;
	var todaysLabelReference:TextField;

	//styles
	var _color:Object = {themeColor:1,rollOverColor:1,selectionColor:1,todayColor:1};


	//scroll details
	var nextMonth:String;
	var previousMonth:String;
	var nextYear:String;
	var previousYear:String;
	var selectedLabel:TextField;

	// modes for selectableRange
	//normal: Object is passed and both rangeStart and rangeEnd are defined
	//start: Object is passed and only rangeStart is defined
	//end: Object is passed and only rangeEnd is defined
	//date: a Date Object is passed


	// Properties

	var __showToday:Boolean = true;

	var __disabledRanges:Array = [];

	var __enabled:Boolean = true;

	var __firstDayOfWeek:Number = 0; // Sunday

	var __selectableRange:Object = undefined;

	var __selectedDate:Date = undefined;

	var __displayedMonth:Number = undefined;

	var __displayedYear:Number = undefined;

	var __dayNames:Array = [ "S", "M", "T", "W", "T", "F", "S" ];

	var __disabledDays:Array = []; // Sunday and Saturday

	var __autoScale:Boolean = true;

	var __cellHeight:Number = 20;

	var __cellWidth:Number = 20;

	var __colMargin:Number = 8;

	var __leftMargin:Number = 8.5;

	var __rightMargin:Number = 8.5;

	var __dayToDateMargin:Number = 5;

	var __dateMargin:Number = 4;

	var __dragSelectMode = false;

	//default layout set
	//maintaining original values for layout
	var __defaultCellHeight;
	var __defaultCellWidth;
	var __defaultColMargin;
	var __defaultLeftMargin;
	var __defaultRightMargin;
	var __defaultDayToDateMargin;
	var __defaultDateMargin;

	var dayBlock0label0:MovieClip;
	var dayBlock6label0:MovieClip;


	// Children
	var boundingBox:MovieClip;
	var background_mc:MovieClip;
	var todayIndicator:MovieClip;
	var selectedIndicator:MovieClip;
	var rollOverIndicator:MovieClip;
	var hitAreaClip:MovieClip;

	function CalendarLayout()
	{
		__defaultCellHeight = __cellHeight;
		__defaultCellWidth = __cellWidth;
		__defaultColMargin = __colMargin;
		__defaultLeftMargin = __leftMargin;
		__defaultRightMargin = __rightMargin;
		__defaultDayToDateMargin = __dayToDateMargin;
		__defaultDateMargin = __dateMargin;
	}

	////////////////////////////////////////////////////////////////////////////
	//
	// Overridden methods
	//
	////////////////////////////////////////////////////////////////////////////

	function init(Void):Void
	{
		super.init();

		tabEnabled = false;

		if (__displayedMonth == undefined)
			__displayedMonth = (new Date()).getMonth();
		if (__displayedYear == undefined)
			__displayedYear = (new Date()).getFullYear();

		// Hide the author-time bounding box.
		boundingBox._visible = false;
		//boundingBox._width = boundingBox._height = 0;

	}

	/*

	A note about DayBlocks:

	dayBlock0..dayBlock6 are skins for the 7 grid columns.
	They are dynamically created instances of the "DayBlock" symbol.
	Three additional properties are set when each dayBlock is created
	in createChildren():

		columnIndex:Number (0-6)
			keeps track of where this dayBlock is in the grid

		selectedArray:Array
			7 elements, one for each row
			selectedArray[rowIndex] is true
				if that row in the dayBlock is selected

		disabledArray:Array
			7 elements, one for each row
			disabledArray[rowIndex] is true
				if that row in the dayBlock is disabled

	Additional properties are created dynamically to hold the skins
	for selected and disabled rows in the dayBlock:

		selectedSkin0..selectedSkin6

		disabledSkin0..disabledSkin6

	*/



	function createChildren():Void
	{
		// Create the background.
		var sizeXRatio = _parent.sizeXRatio;
		var sizeYRatio = _parent.sizeYRatio;
		var w:Number = width*sizeXRatio;
		var h:Number = height*sizeYRatio;
		var labelPosition:Number = 0;
		var blockY:Number = 0;

		__cellHeight = __cellHeight*sizeYRatio;
		__cellWidth = __cellWidth*sizeXRatio;
		__leftMargin = __leftMargin*sizeXRatio;
		__dateMargin = __dateMargin*sizeYRatio;
		__dayToDateMargin = __dayToDateMargin*sizeYRatio;
		__colMargin = __colMargin*sizeXRatio;

		var blockX:Number = __leftMargin;

		var selectIndicator:MovieClip = createEmptyMovieClip("selectedIndicator",selectedDateDepth);
		selectIndicator.lineStyle(0,0x009900,30);
		selectIndicator.beginFill(0x00FF33, 100);
		selectIndicator.lineTo(__cellWidth,0);
		selectIndicator.lineTo(__cellWidth,__cellHeight);
		selectIndicator.lineTo(0,__cellHeight);
		selectIndicator.lineTo(0,0);
		selectIndicator.styleName = this.styleName;
		ColoredSkinElement.setColorStyle(selectIndicator, "selectionColor");

		selectIndicator._visible = false;

		var rollIndicator:MovieClip = createEmptyMovieClip("rollOverIndicator",rollOverDateDepth);
		rollIndicator.lineStyle(0,0x009900,20);
		rollIndicator.beginFill(0x00ff00, 100);
		rollIndicator.lineTo(__cellWidth,0);
		rollIndicator.lineTo(__cellWidth,__cellHeight);
		rollIndicator.lineTo(0,__cellHeight);
		rollIndicator.lineTo(0,0);
		rollIndicator.styleName = this.styleName;
		ColoredSkinElement.setColorStyle(rollIndicator, "rollOverColor");

		rollIndicator._visible = false;

		createEmptyMovieClip("hitAreaClip", 300);
		rollIndicator.hitArea = hitAreaClip;


		for (var columnIndex:Number = 0; columnIndex < 7; columnIndex++)
		{
			var weekDistance:Boolean = false;

			// Remember the height of the cells if not set by user.
			// Create the 7 labels within each DayBlock.
			// The first row in each column displays a day name string, such as "Sun".
			// The other six rows displays day numbers in the range 1-31.

			for (var rowIndex:Number = 0; rowIndex < 7; rowIndex++)
			{
				var tempName:String = "dayBlock"+columnIndex+"label"+rowIndex;
				var label:TextField = createLabel(tempName, labelBaseDepth++, "");
				label.selectable = false;
				if(rowIndex==0)
				{
					labelPosition = 0;
					label.styleName =  "WeekDayStyle";
				}
				else if(rowIndex == 1 && weekDistance==false)
				{
					labelPosition = (rowIndex*__cellHeight)+__dayToDateMargin;
					weekDistance=true;
				}
				else if(rowIndex>1 && weekDistance==true)
				{
					labelPosition = (rowIndex*__cellHeight)+(rowIndex*__dateMargin);
				}

				label._width = __cellWidth;
				label._height = __cellHeight;
				label._x = blockX;
				label._y = labelPosition;
				//label.border = true;
			}

			this["dayBlock"+columnIndex+"label0"].disabledArray = new Array(7);
			blockX += (__cellWidth+__colMargin);
		}


			this.useHandCursor = false;
			this.onRelease = dayBlockReleaseHandler;
			this.onRollOver = dayBlockRollOverHandler;
			this.onRollOut = dayBlockRollOutHandler;
			this.onReleaseOutside = dayBlockRollOutHandler;

		// Everything that gets initially created now exists.
		// Some things, such as the selection skins and disabled skins,
		// are created later as they are needed.
		// Set the "S", "M", etc. labels in the first row.
		drawDayNames();

		// Set the day-number labels ("1".."31") in the other rows.
		// This method also displays the selection skins,
		// the disabled skins, and the "today" indicator.
		setSelectedMonthAndYear();
	}

	// -------------------------------------------------------------------------
	// Calendar logic
	// -------------------------------------------------------------------------


	//drawing the days of week
	function drawDayNames():Void
	{
		for (var columnIndex:Number = 0; columnIndex < 7; columnIndex++)
		{
			var dayOfWeek:Number = (columnIndex + __firstDayOfWeek) % 7;
			this["dayBlock"+columnIndex+"label" + 0].text = __dayNames[dayOfWeek];
		}
	}


	// dayBlock press handler. Would be active on when the "dragSelectMode" is true

	function dayBlockRollOverHandler():Void
	{
		this.onMouseMove = dayBlockMouseMoveHandler;
	}

	function dayBlockRollOutHandler():Void
	{
		delete this.onMouseMove;
		rollOverIndicator._visible = false;

		if(selectedIndicator._x != todayIndicator._x || selectedIndicator._y != todayIndicator._y)
		{
			todayIndicator._alpha = 100;
		}
	}

	function dayBlockMouseMoveHandler()
	{
		var firstColX = this.dayBlock0label0._x;
		var lastColX = this.dayBlock6label0._x;
		var firstRowY = this.dayBlock6label0._y+__cellHeight+__dayToDateMargin;

		var sizeXRatio:Number = _parent.sizeXRatio;
		var sizeYRatio:Number = _parent.sizeYRatio;

		if(_xmouse < firstColX && _xmouse > (lastColX+cellWidth) || _ymouse < firstRowY)
			return;
		var oldCell:TextField;
		var rowIndex:Number = Math.floor(_ymouse / (__cellHeight+__dateMargin));
		var colIndex:Number = Math.floor(_xmouse / (__cellWidth+__colMargin));
		selCell = this["dayBlock"+colIndex+"label"+rowIndex];

		// If it is disabled, we're done.
		if (this["dayBlock"+colIndex+"label0"].disabledArray[rowIndex] || rowIndex == 0)
			return;

		if(_ymouse >= selCell._y && _ymouse <=(selCell._y+__cellHeight) && _xmouse >= selCell._x && _xmouse <=(selCell._x+__cellWidth))
		{
			rollOverIndicator._x = selCell._x;
			rollOverIndicator._y = selCell._y;
			rollOverIndicator._visible = true;

			if(rollOverIndicator._x == todayIndicator._x && rollOverIndicator._y == todayIndicator._y)
			{
				todayIndicator._alpha = 60;
			}
			else if(selectedIndicator._x != todayIndicator._x || selectedIndicator._y != todayIndicator._y)
			{

				todayIndicator._alpha = 100;
			}
		}



	}


	function dayBlockReleaseHandler():Void
	{
		//pressFocus();
		var firstColX = this.dayBlock0label0._x;
		var lastColX = this.dayBlock6label0._x;
		var firstRowY = this.dayBlock6label0._y+__cellHeight+__dayToDateMargin;
		var sizeXRatio:Number = _parent.sizeXRatio;
		var sizeYRatio:Number = _parent.sizeYRatio;

		if(_xmouse < firstColX && _xmouse > (lastColX+__cellWidth) || _ymouse < firstRowY)
		{
			return;
		}

		var rowIndex:Number = Math.floor(_ymouse / (__cellHeight+__dateMargin));

		if(rowIndex <= 0)
			return;

		var colIndex:Number = Math.floor(_xmouse / (__cellWidth+__colMargin));

		selCell = this["dayBlock"+colIndex+"label"+rowIndex];
		// If it is disabled, we're done.
		if (this["dayBlock"+colIndex+"label0"].disabledArray[rowIndex])
			return;

		if(_ymouse >= selCell._y && _ymouse <=(selCell._y+__cellHeight) && _xmouse >= selCell._x && _xmouse <=(selCell._x+__cellWidth))
		{
			if(selectedCell == colIndex+"."+rowIndex)
			{
				selectedIndicator._visible = false;
				selectedCell = undefined;
				__selectedDate = undefined;
				_parent.dispatchChangeEvent();
			}
			else
			{
				selectedIndicator._x = selCell._x;
				selectedIndicator._y = selCell._y;
				selectedIndicator._visible = true;
				selectedCell = colIndex+"."+rowIndex;
				__selectedDate = new Date(__displayedYear, __displayedMonth, Number(selCell.text));
				_parent.dispatchChangeEvent();

				if(selectedIndicator._x == todayIndicator._x && selectedIndicator._y == todayIndicator._y)
				{
					todayIndicator._alpha = 60;
				}
				else
				{

					todayIndicator._alpha = 100;
				}

			}
		}


	}

	function setSize(w:Number, h:Number, noEvent:Boolean)
	{

		var cellHeight:Number;
		var cellWidth:Number;
		var colMargin:Number;
		var leftXMargin:Number;
		var rightXMargin:Number;
		var dayToDateMargin:Number;
		var dateMargin:Number;
		var owner = _parent;
		var sizeXRatio = owner.sizeXRatio;
		var sizeYRatio = owner.sizeYRatio;


		if(!autoScale)
		{
			if((__cellWidth==undefined || __cellWidth==NaN) ||
				(__cellHeight==undefined || __cellHeight==NaN) ||
				(__leftMargin==undefined || __leftMargin==NaN) ||
				(__rightMargin==undefined || __rightMargin==NaN) ||
				(__colMargin==undefined || __colMargin==NaN) ||
				(__dayToDateMargin==undefined || __dayToDateMargin==NaN) ||
				(__dateMargin==undefined || __dateMargin==NaN))
			{
				//because any one of the values is undefined, therefore maintain old values
				cellHeight = __defaultCellHeight;
				cellWidth =  __defaultCellWidth;
				colMargin = __defaultColMargin;
				leftXMargin = __defaultLeftMargin;
				rightXMargin = __defaultRightMargin;
				dayToDateMargin = __defaultDayToDateMargin;
				dateMargin = __defaultDateMargin;
			}
			else
			{
				cellHeight = __cellHeight;
				cellWidth =  __cellWidth;
				colMargin = __colMargin;
				leftXMargin = __leftMargin;
				rightXMargin = __rightMargin;
				dayToDateMargin = __dayToDateMargin;
				dateMargin = __dateMargin;
			}
		}
		else
		{
			//if autoScale is true
			cellHeight = __cellHeight = (__cellHeight*sizeYRatio);
			cellWidth = __cellWidth = (__cellWidth*sizeXRatio);
			colMargin = __colMargin = (__colMargin*sizeXRatio);
			leftXMargin = __leftMargin = (__leftMargin*sizeXRatio);
			rightXMargin = __rightMargin = (__rightMargin*sizeXRatio);
			dayToDateMargin = __dayToDateMargin = (__dayToDateMargin*sizeYRatio);
			dateMargin = __dateMargin = (__dateMargin*sizeYRatio);
		}


		for(var i = 0; i<7; i++)
		{
			for(var t = 0; t<7; t++)
			{
				var labelName:TextField = this["dayBlock"+i+"label"+t];
				labelName._width = cellWidth;
				labelName._height = cellHeight;
				labelName._x = (i==0) ? leftXMargin : ((i==1) ? (colMargin+cellWidth+leftXMargin) : ((colMargin*i)+(cellWidth*i)+leftXMargin));
				labelName._y = (t == 0) ? 0 : ((t==1) ? (dayToDateMargin+cellHeight) : ((t*dateMargin)+(cellHeight*t)));
			}
		}

		todayIndicator._x = (todayIndicator._x*sizeXRatio);
		todayIndicator._y = (todayIndicator._y*sizeYRatio);
		todayIndicator._width = cellWidth;
		todayIndicator._height = cellHeight;

		selectedIndicator._x = (selectedIndicator._x*sizeXRatio);
		selectedIndicator._y = (selectedIndicator._y*sizeYRatio);
		selectedIndicator._width = cellWidth;
		selectedIndicator._height = cellHeight;


		rollOverIndicator._x = (rollOverIndicator._x*sizeXRatio);
		rollOverIndicator._y = (rollOverIndicator._y*sizeYRatio);
		rollOverIndicator._width = cellWidth;
		rollOverIndicator._height = cellHeight;


	}

	function setStyle(n:String, val):Void
	{
		val = (val == "") ? undefined : val;
		var ifDisabledColor = (n=="disabledColor") ? true : false;
		var dColor = (ifDisabledColor) ? val : undefined;

		for(var i = 0; i < 7; i++)
		{
			this["dayBlock"+i+"label0"][n] = (!ifDisabledColor) ? val : undefined;

			for(var t = 1; t < 7; t++)
			{
				if(this["dayBlock"+i+"label"+t].enabled && !ifDisabledColor)
				{
					this["dayBlock"+i+"label"+t][n] = val;
				}
				else if(!ifDisabledColor)
				{
					this["dayBlock"+i+"label"+t][n] = val;
				}
				else
				{
					this["dayBlock"+i+"label"+t][n] = dColor;
				}
			}
		}
	}


	function setSelectedMonthAndYear(newMonth:Number, newYear:Number):Void
	{
		// This lengthy method updates the UI to display a specified month
		// and year. In particular, it updates the day numbers (1-31) in the grid.

		// It does NOT update the day names ("Sun", "Mon", etc.),
		// since these do not change when the month and year change.
		//
		// It also takes care of displaying days that are disabled or selected.
		// Instances of the skins cal_monthDayDisabled (for disabled days) and
		// cal_monthDaySelected (for selected days) get created as they
		// are required, to minimize initialization time.

		var dayNumber:Number; // 1 - 31
		var columnIndex:Number; // 0 - 6
		var rowIndex:Number; // 1 - 6
		var i:Number;
		var dayBlock:Object;
		var disabledName:String;
		var selectedName:String;
		var displayTodayInCurrentMonth:Boolean = false;
		var displaySelectedDate:Boolean = false;
		var owner = _parent;
		var displayDate = undefined;
		var displayDateColIndex:Number;

		// When another method needs to redraw the UI without changing the
		// currently selected month and year (because the firstDayOfWeek
		// property changed, for example) it calls setSelectedMonthAndYear()
		// with no arguments. Therefore we need to handle undefined arguments.

		if (newMonth == undefined)
			newMonth = __displayedMonth;

		if (newYear == undefined)
			newYear = __displayedYear;

		// Determine where in the grid the 1st of the month should appear,
		// how many days are in the month, and today's date.

		var offset:Number = getOffsetOfMonth(newYear, newMonth);
		var daysInMonth:Number = getNumberOfDaysInMonth(newYear, newMonth);

		// Determine whether this month contains today.
		var today:Date = new Date();
		var currentMonthContainsToday:Boolean = (today.getFullYear() == newYear && today.getMonth() == newMonth);
		var currentMonthContainsSelectedDate:Boolean  = (newMonth == __selectedDate.getMonth() && newYear == __selectedDate.getFullYear());

		// Set up the days (if any) in row 1 that come from the previous month.
		var previousMonth:Number = newMonth - 1; // !!! what if this is -1?
		var previousMonthDate:Date = new Date(newYear, previousMonth, 1);
		dayNumber = getNumberOfDaysInMonth(previousMonthDate.getFullYear(), previousMonthDate.getMonth());
		rowIndex = 1;

		offset = (offset < 0) ? 0 : offset;

		for (columnIndex = offset - 1; columnIndex >= 0; columnIndex--)
		{
			//dayBlock = this["dayBlock" + columnIndex]; // type? !!!
			this["dayBlock"+columnIndex+"label" + rowIndex].text = "";

			// Disable the day.
			this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
		}

		// Set up the days of the new month.
		// ---------------------------------
		for (dayNumber = 1; dayNumber <= daysInMonth; dayNumber++)
		{
			var cellDate:Date = new Date(newYear, newMonth, dayNumber);
			i = offset + dayNumber - 1;
			columnIndex = i % 7;
			rowIndex = 1 + Math.floor(i / 7);

			dayBlock = this["dayBlock" + columnIndex];
			var todayLabel = this["dayBlock" + columnIndex+"label" + rowIndex];
			todayLabel.text = dayNumber;
			// Enable the day.

			this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = false;
			todayLabel.enabled = true;
			todayLabel.styleName = undefined;


			// Some of these days may be selected.
			// One of these days may be today's date.
			if (currentMonthContainsToday && (cellDate.getDate() == today.getDate()) && __showToday)
			{
				displayTodayInCurrentMonth = true;
				if(todayIndicator == undefined)
				{
					createObject("cal_todayIndicator", "todayIndicator", showTodayDepth);
					todayIndicator._width = todayLabel._width;
					todayIndicator._height = todayLabel._height;
					todayIndicator.styleName = this.styleName;
					ColoredSkinElement.setColorStyle(todayIndicator, "todayColor");
				}
				else
				{
					todayIndicator._visible = __showToday;
				}

				todayLabel.styleName = "TodayStyle";
				todayLabel.draw();
				todayIndicator._y = todayLabel._y;
				todayIndicator._x = todayLabel._x;
				todaysLabelReference = todayLabel;

			}
			else
			{
				if(!displayTodayInCurrentMonth)
				{
					todaysLabelReference.styleName = undefined;
					todaysLabelReference.draw();
					todayIndicator._visible = false;
					todayLabel.styleName = undefined;
				}

			}



			//setting a selected Date

			if(cellDate.getDate() == __selectedDate.getDate() && currentMonthContainsSelectedDate && !displaySelectedDate && !this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex])
			{
				selectedIndicator._x = todayLabel._x;
				selectedIndicator._y = todayLabel._y;
				selectedIndicator._visible = true;
				selectedLabel = todayLabel;
				selectedCell = columnIndex+"."+rowIndex;
				displayDateColIndex = columnIndex;
				displaySelectedDate = true;
			}
			else if(!currentMonthContainsSelectedDate)
			{
				selectedCell = undefined;
				displayDateColIndex = undefined;
				selectedIndicator._visible = false;
			}



			// Selectable Range
			// -----------------------------------------------------------------------------
			// set up the selectable Range: type: Object/ Date Object
			// Object Attrib: rangeStart[Date Object], rangeEnd[Date Object]
			// 1 :: if both attribs are defined
			// 2 :: If only rangeStart is defined: All dates after the specified date are enabled
			// 3 :: if only rangeEnd is defined: All dates before ths specified date are enabled
			// 4 :: If selectable Range param is a Date Object, then only that day has to be defined

			if(__selectableRange != undefined)
			{
				var t:Number = selRangeMode;
				switch(t)
				{

					case 1:
						if(cellDate < __selectableRange.rangeStart || cellDate >__selectableRange.rangeEnd)
						{
							todayLabel.enabled = false;
							this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
						}
						break;

					case 2:
						if(cellDate < __selectableRange.rangeStart)
						{
							todayLabel.enabled = false;
							this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
						}
						break;

					case 3:
						if(cellDate > __selectableRange.rangeEnd)
						{
							todayLabel.enabled = false;
							this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
						}
						break;

					case 4:
						var cellString:String = cellDate.getFullYear()+"."+cellDate.getMonth()+"."+cellDate.getDate();
						var selRangeString:String = __selectableRange.getFullYear()+"."+__selectableRange.getMonth()+"."+__selectableRange.getDate();
						if(cellString != selRangeString)
						{
							todayLabel.enabled = false;
							this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
						}
						break;

					default:
						break;

				}

			}

			// Disabled Ranges
			// -----------------------------------------------------------------------------
			// set up the disabledRanges: type: Array
			// Array can contain an Object || Date Object.
			// Attrib for Object: rangeStart[Date Object], rangeEnd[Date Object]
			// "start"::All dates after the specified date are disabled, including the startDate
			// "end"::All dates before ths specified date are disabled, including the end Date
			// "date"::Only that day has to be disabled
			// "normal"::range is disabled including the start and end date
			if(__disabledRanges.length>0)
			{
				for(var dRanges = 0; dRanges < __disabledRanges.length; dRanges++)
				{
					var drMode:Number = disRangeMode[dRanges];
					switch (drMode)
					{

						case 1:

							if(cellDate >= __disabledRanges[dRanges].rangeStart && cellDate <= __disabledRanges[dRanges].rangeEnd)
							{
								todayLabel.enabled = false;
								this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
							}
							break;

						case 2:
							if(cellDate >= __disabledRanges[dRanges].rangeStart)
							{
								todayLabel.enabled = false;
								this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
							}
							break;

						case 3:
							if(cellDate <= __disabledRanges[dRanges].rangeEnd)
							{
								todayLabel.enabled = false;
								this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
							}
							break;

						case 4:
							var cellString:String = cellDate.getFullYear()+"."+cellDate.getMonth()+"."+cellDate.getDate();
							var disRangeString:String = __disabledRanges[dRanges].getFullYear()+"."+__disabledRanges[dRanges].getMonth()+"."+__disabledRanges[dRanges].getDate();
							if(cellString == disRangeString)
							{
								todayLabel.enabled = false;
								this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
							}
							break;

						default:
							break;

					}
				}
			}


		}

		// Set up the days (if any) at the end of the grid
		// that come from the following month.

				dayNumber = 1;
				for (i = offset + daysInMonth; i < 42; i++)
				{
					columnIndex = i % 7;
					rowIndex = 1 + Math.floor(i / 7);

					//dayBlock = this["dayBlock" + columnIndex]; // type? !!!
					this["dayBlock"+columnIndex+"label" + rowIndex].text = "";


					// Disable the day.
					this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
				}


			//disabling weekends
			// Property name :

			if (__disabledDays.length>0) // g/s bug !!!
			{
				for (i = 0; i < __disabledDays.length; i++)
				{
					if(__disabledDays[i] >=0 && __disabledDays[i] <=6 && !isNaN(__disabledDays[i]))
					{
						columnIndex = ((7+__disabledDays[i] -__firstDayOfWeek)%7);

						for (rowIndex = 1; rowIndex < 7; rowIndex++)
						{
							// Disable the day.
							this["dayBlock"+columnIndex+"label0"].disabledArray[rowIndex] = true;
							selectedCell = undefined;
							this["dayBlock"+columnIndex+"label"+rowIndex].enabled = false;
						}
					}
			}

				// The UI has been updated for the new month and year.
				// Now update the property variables.



		}

		checkSelectedIndicator(displayDateColIndex, currentMonthContainsSelectedDate);
		__displayedMonth = newMonth;
		__displayedYear = newYear;
		displayDate = new Date(newYear, newMonth, 1);
		owner.dateDisplay.text = owner.__monthNames[displayDate.getMonth()]+" "+displayDate.getFullYear();
		todayIndicator._alpha = (todaysLabelReference != undefined) ? ((todaysLabelReference.enabled == false) ? 30 : 100) : 100;
		invalidate();
}


	function checkSelectedIndicator(columnIndex:Number, selectCheck:Boolean):Void
	{
		if(!selectedLabel.enabled)
		{
			if(selectCheck)
			{
				__selectedDate = undefined;
				selectedCell = undefined;
			}

			selectedIndicator._visible = false;
			return;
		}
		else if(__selectedDate != undefined && selectCheck)
		{
			selectedIndicator._visible = true;
		}


	}

	//called from setSelectedMonthAndYear() to get an Offset of the starting day of the month
	function getOffsetOfMonth(year:Number, month:Number):Number
	{
		// Determine whether the 1st of the month is a Sunday, Monday, etc.
		// and then determine which column of the grid where it appears.
		var first:Date = new Date(year, month, 1);
		var offset:Number = first.getDay() - __firstDayOfWeek;
		return offset < 0 ? offset + 7 : offset;
	}

	function getNumberOfDaysInMonth(year:Number, month:Number):Number
	{
		// "Thirty days hath September..."

		var n:Number;

		if (month == 1) // Feb
		{
			if (((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0)) // leap year
				n = 29;
			else
				n = 28;
		}

		else if (month == 3 || month == 5 || month == 8 || month == 10)
			n = 30;

		else
			n = 31;

		return n;
	}

	function stepDate(deltaY:Number, deltaM:Number):Void
	{
		var owner = _parent;
		var oldYear:Number = __displayedYear;
		var oldMonth:Number = __displayedMonth;

		var newYear:Number = oldYear + deltaY;
		var newMonth:Number = oldMonth + deltaM;


		while (newMonth < 0)
		{
			newYear--;
			newMonth += 12;
		}

		while (newMonth > 11)
		{
			newYear++;
			newMonth -= 12;
		}

		setSelectedMonthAndYear(newMonth, newYear);

		if (newYear > oldYear)
		{
			owner.dispatchScrollEvent("nextYear");
		}
		else if (newYear < oldYear)
		{
			owner.dispatchScrollEvent("previousYear");
		}
		else if (newMonth > oldMonth)
		{
			owner.dispatchScrollEvent("nextMonth");
		}
		else if(newMonth < oldMonth)
		{
			owner.dispatchScrollEvent("previousMonth");
		}
	}

	/////////////////////////////////////////////////////////////////////////////////////
	//
	// Properties
	//
	/////////////////////////////////////////////////////////////////////////////////////


	////////////////////////////////////////////////////////////////////////////////////
	//
	// showToday
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get showToday():Boolean
	{
		return __showToday;
	}

	function set showToday(b:Boolean)
	{
		setShowToday(b);
	}

	function setShowToday(n:Boolean)
	{
		if(__showToday != n)
		__showToday = n;

		setSelectedMonthAndYear(__displayedMonth, __displayedYear);
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// enabled
	//
	////////////////////////////////////////////////////////////////////////////////////


	function get enabled():Boolean
	{
		return __enabled;
	}

	function set enabled(e:Boolean)
	{
		setEnabled(e);
	}

	function setEnabled(f:Boolean)
	{
		__enabled = f;
		for(var o = 0; o < 7; o++)
		{
			for(var r = 0; r < 7; r++)
			{
				this["dayBlock"+o+"label"+r].enabled = f;
				this["dayBlock"+o+"label0"].disabledArray[r] = f;
			}
		}
		if(!__enabled)
		{
			selectedIndicator._visible = false;
			todayIndicator._alpha = 30;
		}
		else
		{
			todayIndicator._alpha = 100;
			setSelectedMonthAndYear(__displayedMonth,__displayedYear);
		}

	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// first Day of week
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get firstDayOfWeek():Number
	{
		return __firstDayOfWeek;
	}


	function set firstDayOfWeek(n:Number):Void
	{
		setFirstDayOfWeek(n);
	}

	function setFirstDayOfWeek(b:Number):Void
	{
		if (b < 0 || b > 6)
			return;

		if (b == __firstDayOfWeek)
			return;

		__firstDayOfWeek = b;

		// Update the UI.
		drawDayNames();
		setSelectedMonthAndYear(__displayedMonth, __displayedYear);

	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// displayedMonth
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get displayedMonth():Number
	{
		return __displayedMonth;
	}

	function set displayedMonth(m:Number)
	{
		setDisplayedMonth(m);
	}

	function setDisplayedMonth(mo:Number)
	{
		if(mo<0 || mo>11)
			return;

		if(mo == __displayedMonth)
			return;
		if(!checkMonthValidity(mo))
		{
			__displayedMonth = mo;
			setSelectedMonthAndYear(mo,__displayedYear);
		}
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// displayedYear
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get displayedYear():Number
	{
		return __displayedYear;
	}

	function set displayedYear(y:Number)
	{
		setDisplayedYear(y);
	}

	function setDisplayedYear(ye:Number)
	{
		if(ye<=0)
			return;

		if(ye == __displayedYear)
			return;

		if(!checkYearValidity(ye))
		{
			__displayedYear = ye;
			setSelectedMonthAndYear(__displayedMonth, ye);
		}
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// dayNames
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get dayNames():Array
	{
		return getDayNames();
	}

	function getDayNames():Array
	{
		return __dayNames.slice(0);
	}

	function set dayNames(d:Array)
	{
		setDayNames(d);
	}

	function setDayNames(dn:Array)
	{
		if(dn.length<7)
		{
			for(var i=0;i<dn.length;i++)
			{
				__dayNames[i] = dn[i];
			}
		}
		else
		{
			__dayNames = dn.slice(0);
		}
		drawDayNames();
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// disabledDays
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get disabledDays():Array
	{
		return getDisabledDays();
	}

	function getDisabledDays():Array
	{
		var tempArray = new Array();
		for(var i=0, k=0; i<__disabledDays.length; i++)
		{
			if(__disabledDays[i] > 0 && __disabledDays[i] < 6)
			{
				tempArray[k] = __disabledDays[i];
				k++;
			}
		}
		return tempArray;
	}

	function set disabledDays(dd:Array)
	{
		setDisabledDays(dd);
	}

	function setDisabledDays(d:Array)
	{
		__disabledDays = d.slice(0);
		setSelectedMonthAndYear(__displayedMonth, __displayedYear);
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// autoscale
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get autoScale():Boolean
	{
		return __autoScale;
	}

	function set autoScale(a:Boolean)
	{
		setAutoScale(a);
	}

	function setAutoScale(au:Boolean)
	{
		if(au!=__autoScale)
			__autoScale = au;
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// cellHeight
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get cellHeight():Number
	{
		return __cellHeight;
	}

	function set cellHeight(c:Number)
	{
		setCellHeight(c);
	}

	function setCellHeight(ce:Number)
	{
		__cellHeight = ce;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// cellWidth
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get cellWidth():Number
	{
		return __cellWidth;
	}

	function set cellWidth(c:Number)
	{
		setCellWidth(c);
	}

	function setCellWidth(cw:Number)
	{
		__cellWidth = cw;
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// colMargin
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get colMargin():Number
	{
		return __colMargin;
	}

	function set colMargin(m:Number)
	{
		setColMargin(m);
	}

	function setColMargin(cm:Number)
	{
		__colMargin = cm;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// leftMargin
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get leftMargin():Number
	{
		return __leftMargin;
	}

	function set leftMargin(l:Number)
	{
		setLeftMargin(l);
	}

	function setLeftMargin(lm:Number)
	{
		__leftMargin = lm;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// rightMargin
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get rightMargin():Number
	{
		return __rightMargin;
	}

	function set rightMargin(r:Number)
	{
		setRightMargin(r);
	}

	function setRightMargin(rm:Number)
	{
		__rightMargin = rm;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// dayToDateMargin
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get dayToDateMargin():Number
	{
		return __dayToDateMargin;
	}

	function set dayToDateMargin(dtd:Number)
	{
		setDayToDateMargin(dtd);
	}

	function setDayToDateMargin(dm:Number)
	{
		__dayToDateMargin = dm;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// dateMargin
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get dateMargin():Number
	{
		return __dateMargin;
	}

	function set dateMargin(dm:Number)
	{
		setDateMargin(dm);
	}

	function setDateMargin(dtm:Number)
	{
		__dateMargin = dtm;
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// selectableRange
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get selectableRange()
	{
		return __selectableRange;
	}

	function set selectableRange(sr)
	{
		setSelectableRange(sr);
	}

	function setSelectableRange(srn)
	{
		if(srn == undefined)
		{
			__selectableRange = undefined;
			setSelectedMonthAndYear(__displayedMonth, __displayedYear);
		}
		var todaysDate = new Date();
		var todaysMonth = todaysDate.getMonth();
		var todaysYear = todaysDate.getFullYear();
		var callMonth:Number;
		var callYear:Number;
		var selectedDateFallsInRange:Boolean;
		if(srn instanceof Date)
		{
			selRangeMode = 4;
			__selectableRange = new Date(srn.getFullYear(), srn.getMonth(), srn.getDate());
			callMonth  = srn.getMonth();
			callYear = srn.getFullYear();
		}
		else if(srn instanceof Object)
		{
			__selectableRange = new Object();

			if(srn.rangeStart == undefined && srn.rangeEnd!= undefined)
			{
				selRangeMode = 3;
				__selectableRange.rangeEnd = srn.rangeEnd;
				if(todaysYear <= __selectableRange.rangeEnd.getFullYear())
				{
					if(todaysMonth >= __selectableRange.rangeEnd.getMonth())
					{
						callMonth = __selectableRange.rangeEnd.getMonth();
						callYear = __selectableRange.rangeEnd.getFullYear();
					}
					else if(todaysMonth <= __selectableRange.rangeEnd.getMonth())
					{
						callMonth = todaysMonth;
						callYear = todaysYear;
					}
				}
				else if(todaysYear > __selectableRange.rangeEnd.getFullYear())
				{
					callMonth = __selectableRange.rangeEnd.getMonth();
					callYear = __selectableRange.rangeEnd.getFullYear();
				}
				selectedDateFallsInRange = (__selectedDate!=undefined) ? ((__selectedDate <= __selectableRange.rangeEnd) ? true : false) : false;

			}
			else if(srn.rangeEnd ==  undefined && srn.rangeStart!= undefined)
			{
				selRangeMode = 2;
				__selectableRange.rangeStart = srn.rangeStart;
				if(todaysYear >= __selectableRange.rangeStart.getFullYear())
				{
					if(todaysMonth <= __selectableRange.rangeStart.getMonth())
					{
						callMonth = __selectableRange.rangeStart.getMonth();
						callYear = __selectableRange.rangeStart.getFullYear();
					}
					else if(todaysMonth >= __selectableRange.rangeStart.getMonth())
					{
						callMonth = todaysMonth;
						callYear = todaysYear;
					}
				}
				else if(todaysYear < __selectableRange.rangeStart.getFullYear())
				{
					callMonth = __selectableRange.rangeStart.getMonth();
					callYear = __selectableRange.rangeStart.getFullYear();
				}
				selectedDateFallsInRange = (__selectedDate!=undefined) ? ((__selectedDate >= __selectableRange.rangeStart) ? true : false) : false;
			}
			else if(srn.rangeStart!= undefined && srn.rangeEnd!= undefined)
			{
				selRangeMode = 1;
				__selectableRange.rangeStart = srn.rangeStart;
				__selectableRange.rangeEnd = srn.rangeEnd;
				if(todaysDate >= __selectableRange.rangeStart && todaysDate <= __selectableRange.rangeEnd)
				{
					callMonth = todaysMonth;
					callYear = todaysYear;
				}
				else if(todaysDate < __selectableRange.rangeStart)
				{
					callMonth = __selectableRange.rangeStart.getMonth();
					callYear = __selectableRange. rangeStart.getFullYear();
				}
				else if(todaysDate > __selectableRange.rangeEnd)
				{
					callMonth = __selectableRange.rangeEnd.getMonth();
					callYear = __selectableRange.rangeEnd.getFullYear();
				}
				if(__selectedDate!=undefined)
					selectedDateFallsInRange = !checkDateValidity(__selectedDate);
				//selectedDateFallsInRange = (__selectedDate!=undefined) ? ((__selectedDate >= __selectableRange.rangeStart || __selectedDate <= __selectableRange.rangeEnd) ? true : false) : false;
			}
		}

		if(selectedDateFallsInRange)
		{
			setSelectedMonthAndYear(__selectedDate.getMonth(), __selectedDate.getFullYear());
		}
		else
		{
			__selectedDate = undefined;
			setSelectedMonthAndYear(callMonth, callYear);
		}
	}

	////////////////////////////////////////////////////////////////////////////////////
	//
	// disabledRanges
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get disabledRanges():Array
	{
		return __disabledRanges.slice(0);
	}

	function set disabledRanges(dr:Array)
	{
		setDisabledRanges(dr);
	}

	function setDisabledRanges(drn:Array)
	{
		__disabledRanges = drn.slice(0);
		for(var t=0; t<__disabledRanges.length; t++)
		{
			if(__disabledRanges[t] instanceof Date)
			{
				disRangeMode[t] = 4;
				__disabledRanges[t] = new Date(drn[t].getFullYear(), drn[t].getMonth(), drn[t].getDate());
			}
			else if(__disabledRanges[t] instanceof Object)
			{
				__disabledRanges[t] = new Object();
				__disabledRanges[t] = drn[t];

				if(__disabledRanges[t].rangeStart==undefined && __disabledRanges[t].rangeEnd!=undefined)
				{
					disRangeMode[t] = 3;
				}
				else if(__disabledRanges[t].rangeStart!=undefined && __disabledRanges[t].rangeEnd==undefined)
				{
					disRangeMode[t] = 2;
				}
				else if(__disabledRanges[t].rangeStart!=undefined && __disabledRanges[t].rangeEnd!=undefined)
				{
					disRangeMode[t] = 1;
				}
			}

		}
		setSelectedMonthAndYear(__displayedMonth, __displayedYear);
	}


	////////////////////////////////////////////////////////////////////////////////////
	//
	// selectedDate
	//
	////////////////////////////////////////////////////////////////////////////////////

	function get selectedDate():Date
	{
		return __selectedDate;
	}

	function set selectedDate(d:Date)
	{
		setSelectedDate(d);
	}

	function setSelectedDate(sd:Date)
	{
		if(!checkDateValidity(sd))
		{
			__selectedDate = sd;
			setSelectedMonthAndYear(__selectedDate.getMonth(),__selectedDate.getFullYear());
		}
	}

	function get dragSelectMode():Boolean
	{
		return __dragSelectMode;
	}

	function set dragSelectMode(b:Boolean)
	{
		setDragSelectMode(b);
	}

	function setDragSelectMode(ds:Boolean)
	{
		__dragSelectMode = ds;
	}

	//checking for valid dates, months and Years before setting them through API

	function checkDateValidity(dt:Date):Boolean
	{

		var selectedDateIsDisabled:Boolean = false;

		if(__selectableRange != undefined)
		{
			var sMode:Number = selRangeMode;
			switch (sMode)
			{
				case 1:
					if(dt < __selectableRange.rangeStart || dt > __selectableRange.rangeEnd)
					{
						selectedDateIsDisabled = true;
					}
					break;

				case 2:
					if(dt < __selectableRange.rangeStart)
					{
						selectedDateIsDisabled = true;
					}
					break;

				case 3:
					if(dt > __selectableRange.rangeEnd)
					{
						selectedDateIsDisabled = true;
					}
					break;

				case 4:
					if(dt > __selectableRange || dt < __selectableRange)
					{
						selectedDateIsDisabled = true;
					}
					break;

				default:
					break;
			}
		}

		if(__disabledRanges.length > 0)
		{
			for(var dRanges = 0; dRanges < __disabledRanges.length; dRanges++)
			{
					var drMode:Number = disRangeMode[dRanges];
					switch (drMode)
					{

						case 1:

							if(dt >= __disabledRanges[dRanges].rangeStart && dt <= __disabledRanges[dRanges].rangeEnd)
							{
								selectedDateIsDisabled = true;
							}
							break;

						case 2:
							if(dt >= __disabledRanges[dRanges].rangeStart)
							{
								selectedDateIsDisabled = true;
							}
							break;

						case 3:
							if(dt <= __disabledRanges[dRanges].rangeEnd)
							{
								selectedDateIsDisabled = true;
							}
							break;

						case 4:
							var dtString:String = dt.getFullYear()+"."+dt.getMonth()+"."+dt.getDate();
							var disRangeString:String = __disabledRanges[dRanges].getFullYear()+"."+__disabledRanges[dRanges].getMonth()+"."+__disabledRanges[dRanges].getDate();
							if(dtString == disRangeString)
							{
								selectedDateIsDisabled = true;
							}
							break;

						default:
							break;

					}
				}
		}

		if(__disabledDays.length > 0)
		{
			for(var i = 0; i < __disabledDays.length; i++)
			{
				if(dt.getDay() == __disabledDays[i])
				{
					selectedDateIsDisabled = true;
				}
			}
		}

		return selectedDateIsDisabled;
	}

	function checkMonthValidity(m:Number):Boolean
	{
		var invalidMonth = false;
		if(__selectableRange != undefined)
		{
			var sMode = selRangeMode;
			switch (sMode)
			{
				case 1:
					if(m < __selectableRange.rangeStart.getMonth() || m > __selectableRange.rangeEnd.getMonth())
					{
						invalidMonth = true;
					}
					break;

				case 2:
					if(m < __selectableRange.rangeStart.getMonth())
					{
						invalidMonth = true;
					}
					break;

				case 3:
					if(m > __selectableRange.rangeEnd.getMonth())
					{
						invalidMonth = true;
					}
					break;

				case 4:
					if(m > __selectableRange.getMonth() || m < __selectableRange.getMonth())
					{
						invalidMonth = true;
					}
					break;

				default:
					break;
			}
		}

		return invalidMonth;
	}

	function checkYearValidity(y:Number):Boolean
	{
		var invalidYear = false;
		if(__selectableRange != undefined)
		{
			var sMode = selRangeMode;
			switch (sMode)
			{
				case 1:
					if(y < __selectableRange.rangeStart.getFullYear() || y > __selectableRange.rangeEnd.getFullYear())
					{
						invalidYear = true;
					}
					break;

				case 2:
					if(y < __selectableRange.rangeStart.getFullYear())
					{
						invalidYear = true;
					}
					break;

				case 3:
					if(y > __selectableRange.rangeEnd.getFullYear())
					{
						invalidYear = true;
					}
					break;

				case 4:
					if(y > __selectableRange.getFullYear() || y < __selectableRange.getFullYear())
					{
						invalidYear = true;
					}
					break;

				default:
					break;
			}
		}

		return invalidYear;

	}

	function invalidateStyle():Void
	{
		selectedIndicator.invalidateStyle();
		rollOverIndicator.invalidateStyle();
		todayIndicator.invalidateStyle();
	}

}



