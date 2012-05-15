//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;

/**
* @tiptext complete event
* @helpid 3156
*/
[Event("complete")]
/**
* @tiptext progress event
* @helpid 3157
*/
[Event("progress")]

[TagName("ProgressBar")]
[IconFile("ProgressBar.png")]

/**
* The class for handling ProgressBar functionality.
*
* @helpid 3158
* @tiptext ProgressBar displays progress of a process over time
*/
class mx.controls.ProgressBar extends UIObject
{
	/**
	* @private
	* SymbolName for ProgressBar
	*/
	static var symbolName:String = "ProgressBar";

	/**
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = Object(mx.controls.ProgressBar);

	/**
	* name of this class
	*/
	var	className:String = "ProgressBar";


// Version string//#include "../core/ComponentVersion.as"

	var	__mode:String = "event";
	var	__direction:String = "right";
	var	__labelPlacement:String = "bottom";
	// space in the end is required for replace() to work properly.
	var	__label:String = "LOADING %3%% ";
	var	__conversion:Number = 1;

	var	__maximum:Number = 0;
	var	__minimum:Number = 0;
	var	__value:Number = 0;

	var	__indeterminate:Boolean = false;

	var	progTrackLeftName:String = "ProgTrackLeft";
	var	progTrackMiddleName:String = "ProgTrackMiddle";
	var	progTrackRightName:String = "ProgTrackRight";
	var	progBarLeftName:String  = "ProgBarLeft";
	var	progBarMiddleName:String  = "ProgBarMiddle";
	var	progBarRightName:String  = "ProgBarRight";
	var	progIndBarName:String  = "ProgIndBar";

	var	idNames:Array = new Array("progTrackLeft_mc", "progTrackMiddle_mc", "progTrackRight_mc", "progBarLeft_mc", "progBarMiddle_mc", "progBarRight_mc", "progIndBar_mc");
	var	boundingBox_mc:Object;

	var	progTrackLeft_mc:Object;
	var	progTrackMiddle_mc:Object;
	var	progTrackRight_mc:Object;
	var	progBarLeft_mc:Object;
	var	progBarMiddle_mc:Object;
	var	progBarRight_mc:Object;
	var	progIndBar_mc:Object;
	var	mask_mc:Object;

	var	labelPath:Object;

	var	skinIDProgTrackLeft:Number = 0;
	var	skinIDProgTrackMiddle:Number = 1;
	var	skinIDProgTrackRight:Number = 2;
	var	skinIDProgBarLeft:Number = 3;
	var	skinIDProgBarMiddle:Number = 4;
	var	skinIDProgBarRight:Number = 5;
	var	skinIDProgIndBar:Number = 6;
	var	skinIDMask:Number = 100;
	var	skinIDLabel:Number = 200;

	var	__interval:Number = 30;
	var	__leave:Number = 2;

	var	clipParameters:Object = {mode: 1, source: 1, direction: 1, label: 1, labelPlacement: 1, conversion: 1};

	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(ProgressBar.prototype.clipParameters, UIObject.prototype.clipParameters);

	var	__indValue:Number;
	var	__source:Object;
	var	__stringSource:String;
	//leave interval references untyped
	var	si;
	
	/**
	* Constructor
	*/
	function ProgressBar()
	{
	}
	
	/**
	* @private
	* init variables.
	*
	*/
	function init(Void):Void
	{
		super.init();
		_xscale = _yscale = 100;
		tabEnabled = false;
		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;
	}

	/**
	* @private
	* create subobjects in the component. Recommended way is to make text objects
	* invisible and make them visible when the draw() method is called to
	* avoid flicker on the screen.
	*
	*/
	function createChildren(Void):Void
	{
		if (progTrackLeft_mc == undefined)
		{
			setSkin(skinIDProgTrackLeft, progTrackLeftName);
		}
		if (progTrackMiddle_mc == undefined)
		{
			setSkin(skinIDProgTrackMiddle, progTrackMiddleName);
		}

		if (progTrackRight_mc == undefined)
		{
			setSkin(skinIDProgTrackRight, progTrackRightName);
		}

		if (progBarLeft_mc == undefined)
		{
			setSkin(skinIDProgBarLeft, progBarLeftName);
		}
		if (progBarMiddle_mc == undefined)
		{
			setSkin(skinIDProgBarMiddle, progBarMiddleName);
		}

		if (progBarRight_mc == undefined)
		{
			setSkin(skinIDProgBarRight, progBarRightName);
		}

		if (progIndBar_mc == undefined)
		{
			setSkin(skinIDProgIndBar, progIndBarName);
			progIndBar_mc._visible = false;
		}

		if (mask_mc == undefined)
		{
			mask_mc = createObject("BoundingBox", "mask_mc", skinIDMask);
			mask_mc._visible = false;
			progIndBar_mc.setMask(mask_mc);
		}

		if(labelPath == undefined)
		{
			labelPath = createLabel("labelPath",skinIDLabel);
			labelPath.tabEnabled = false;
			labelPath.selectable = false;
			labelPath.styleName = this;
		}

		setSize(__width, __height);
	}

	/**
	* @private
	* size the object.  called by setSize().  Laysout the contents.  
	* The width and height properties are set to the
	* new desired size by the time size() is called.
	*/
	function size(Void):Void
	{
		invalidate();
	}

	/**
	* @private
	* draw the object.  Called by redraw() which is called explicitly or 
	* by the system if the object is invalidated.
	* Makes subobjects visible and lays them out.
	*/
	function draw(Void):Void
	{
		// for source specifid in PB's PI and but created after PB
		// give one more chance to source thru sourceString
		if(__source == undefined && __stringSource != undefined)
		{
			setSource(__stringSource);
			__stringSource = undefined;
		}

		var pb__width:Number = __width;
		var pb__height:Number = __height;

		var widthLeftGreater:Number = (progBarLeft_mc._width > progTrackLeft_mc._width) ? progBarLeft_mc._width : progTrackLeft_mc._width;
		var heightLeftGreater:Number = (progBarLeft_mc._height > progTrackLeft_mc._height) ? progBarLeft_mc._height : progTrackLeft_mc._height;
		
		var widthRightGreater:Number = (progBarRight_mc._width > progTrackRight_mc._width) ? progBarRight_mc._width : progTrackRight_mc._width;

		// width of the graphic
		var newWidth:Number = pb__width;

		// offsets of the graphic
		var vOffset:Number = 0;
		var hOffset:Number = 0;
		
		if(__labelPlacement == "top")
		{
			vOffset = pb__height - heightLeftGreater;
		}

		// draw label first
		if(__label != undefined && __label != "")
		{
			// will make it true later on
			labelPath._visible = false;

			// the label is by default made at 3,5. add 1,1  makes 4,6
			var xDisplacement:Number = 1;
			var yDisplacement:Number = 1;
			
			// 5, 4 is the recommended text padding
			var xPad:Number = 5;
			var yPad:Number = 4;
			
			var current:Number = (__value - __minimum);
			if(current < 0)
			{
				current = 0;
			}
			
			var total:Number = (__maximum - __minimum);
			if(total < 0)
			{
				total = 0;
			}

			// for left and right
			if(__labelPlacement == "left" || __labelPlacement == "right")
			{
				var widthCalcText = __label;
				
				if(!__indeterminate)
				{
					widthCalcText = replace(widthCalcText,"%1",String(Math.floor(total/__conversion)));
					widthCalcText = replace(widthCalcText,"%2",String(Math.floor(total/__conversion)));
					widthCalcText = replace(widthCalcText,"%3",String(100));
		
					widthCalcText = replace(widthCalcText,"%%","%");
				}
				else
				{
					widthCalcText = replace(widthCalcText,"%1",String(Math.floor(current/__conversion)));
					widthCalcText = replace(widthCalcText,"%2","??");
					
					widthCalcText = replace(widthCalcText,"%3","");
					widthCalcText = replace(widthCalcText,"%%","");
				}
				labelPath.text = widthCalcText;

				newWidth = pb__width - (labelPath.textWidth + xPad + xDisplacement);

				if(newWidth < widthLeftGreater + widthRightGreater)
				{
					newWidth = 0;
				}
				
				if(__labelPlacement == "left")
				{
					hOffset = pb__width - newWidth;
				}
			}
			
			var labelText:String = __label;
			if(!__indeterminate)
			{
				labelText = replace(labelText,"%1",String(Math.floor(current/__conversion)));
				labelText = replace(labelText,"%2",String(Math.floor(total/__conversion)));
				labelText = replace(labelText,"%3",String(Math.floor(percentComplete)));
	
				labelText = replace(labelText,"%%","%");
			}
			else
			{
				labelText = replace(labelText,"%1",String(Math.floor(current/__conversion)));
				labelText = replace(labelText,"%2","??");
				
				labelText = replace(labelText,"%3","");
				labelText = replace(labelText,"%%","");
			}
	
			labelPath.text = labelText;

			var avail:Number = 0;

			// truncate text within bounding box set _width
			if(__labelPlacement == "left" || __labelPlacement == "right")
			{
				// for left and right
				avail = pb__width - newWidth - xDisplacement;
			}
			else
			{
				avail = pb__width - xDisplacement;
			}

			if(avail < labelPath.textWidth + xPad)
			{
				labelPath._width = avail;
			}
			else
			{
				labelPath._width = labelPath.textWidth + xPad;
			}

			// truncate text within bounding box set _height
			if(__labelPlacement == "left" || __labelPlacement == "right" || __labelPlacement == "center")
			{
				avail = pb__height;
			}
			else
			{
				avail = pb__height - yDisplacement - heightLeftGreater;
			}
			
			if(avail < labelPath.textHeight + yPad)
			{
				labelPath._height = avail;
			}
			else
			{
				labelPath._height = labelPath.textHeight + yPad;
			}

			// set _x
			if(__labelPlacement == "left")
			{
				// for left and right
				labelPath._x = xDisplacement;
			}
			else if(__labelPlacement == "right")
			{
				// for left and right
				labelPath._x = newWidth + xDisplacement;
			}
			else
			{
				labelPath._x = xDisplacement;
			}
	
			// set _y
			if(__labelPlacement == "center" || __labelPlacement == "left" || __labelPlacement == "right")
			{
				labelPath._y = heightLeftGreater/2 - labelPath.height/2;
			}
			else if(__labelPlacement == "top")
			{
				labelPath._y =  vOffset - yDisplacement - labelPath.height;
			}
			else
			{
				labelPath._y = heightLeftGreater + yDisplacement;
			}
			labelPath._visible = true;
		}
		else
		{
			labelPath.text = "";
			labelPath._visible = false;
		}

		if(newWidth >= widthLeftGreater + widthRightGreater)
		{
			// draw graphic after label
			
			// track
			
			var bounds:Object = progTrackLeft_mc.getBounds(progTrackLeft_mc);

			var progTrackLeftRegPointX:Number = - bounds.xMin;
			var progTrackLeftRegPointY:Number = - bounds.yMin;

			progTrackLeft_mc.move(hOffset + widthLeftGreater - progTrackLeft_mc._width + progTrackLeftRegPointX, vOffset + (heightLeftGreater - progTrackLeft_mc._height)/2 + progTrackLeftRegPointY);

			bounds = progTrackMiddle_mc.getBounds(progTrackMiddle_mc);
			var progTrackMiddleRegPointX:Number = - bounds.xMin;
			var progTrackMiddleRegPointY:Number = - bounds.yMin;
			
			progTrackMiddle_mc.setSize(newWidth - widthLeftGreater - widthRightGreater,progTrackMiddle_mc._height);
			// assuming heightLeftGreater == heightMiddleGreater
			progTrackMiddle_mc.move(hOffset + widthLeftGreater + progTrackMiddleRegPointX, vOffset + (heightLeftGreater - progTrackLeft_mc._height)/2 + progTrackMiddleRegPointY);

			bounds = progTrackRight_mc.getBounds(progTrackRight_mc);
			var progTrackRightRegPointX:Number = - bounds.xMin;
			var progTrackRightRegPointY:Number = - bounds.yMin;
			
			// assuming heightLeftGreater == heightRightCapGreater
			progTrackRight_mc.move(hOffset + widthLeftGreater + progTrackMiddle_mc._width + progTrackRightRegPointX,vOffset + (heightLeftGreater - progTrackRight_mc._height)/2 + progTrackRightRegPointY);


			// bar
			
			var remWidth:Number = newWidth - widthLeftGreater - widthRightGreater;
			var midSize:Number = remWidth*percentComplete/100;
			
			var dirOffset:Number = 0;

			if(__indeterminate == true)
			{
				midSize = remWidth;

				mask_mc._width = midSize;
				mask_mc._height = progIndBar_mc._height;
				
				mask_mc._x = hOffset + widthLeftGreater ;
				mask_mc._y = vOffset + (heightLeftGreater - progIndBar_mc._height)/2;
				
				// the current bar of 200 is good for 150 mask. else change its width.
				progIndBar_mc._width = newWidth*200/150;

				var indLoc:Number = progIndBar_mc._x;

				bounds = progIndBar_mc.getBounds(progIndBar_mc);
				var progIndBarRegPointX:Number = - bounds.xMin;
				var progIndBarRegPointY:Number = - bounds.yMin;
			
				var leftEdge:Number = hOffset + widthLeftGreater + progIndBarRegPointX;
				
				var leftMost:Number = progIndBar_mc._width*50/200;
				var rightMost:Number = progIndBar_mc._width*20/200;
				var change:Number = 3;
				var startSide:Number = leftMost;
				
				if(__direction == "left")
				{
					leftMost = progIndBar_mc._width*30/200;
					rightMost = 0;
					change = -3;
					startSide = rightMost;
				}
				
				if(indLoc <= leftEdge - leftMost || indLoc >= leftEdge - rightMost)
				{
					progIndBar_mc._x = leftEdge - startSide + change;
				}
				else
				{
					progIndBar_mc._x += change;
				}

				progIndBar_mc._y = vOffset + (heightLeftGreater - progIndBar_mc._height)/2 + progIndBarRegPointY;

				progIndBar_mc._visible = true;
				// check if it should depend upon si for polled and complete for event
				invalidate();
			}
			else
			{
				progIndBar_mc._visible = false;
				if(__direction == "left")
				{
					dirOffset = remWidth - midSize;
				}
			}

			bounds = progBarMiddle_mc.getBounds(progBarMiddle_mc);
			var progBarMiddleRegPointX:Number = - bounds.xMin;
			var progBarMiddleRegPointY:Number = - bounds.yMin;

			progBarMiddle_mc.setSize(midSize,progBarMiddle_mc._height);
			// assuming heightLeftGreater == heightMiddleGreater
			progBarMiddle_mc.move(dirOffset + hOffset + widthLeftGreater + progBarMiddleRegPointX, vOffset + (heightLeftGreater - progBarLeft_mc._height)/2 + progBarMiddleRegPointY);
			
			bounds = progBarLeft_mc.getBounds(progBarLeft_mc);
			var progBarLeftRegPointX:Number = - bounds.xMin;
			var progBarLeftRegPointY:Number = - bounds.yMin;
			
			progBarLeft_mc.move(dirOffset + hOffset + widthLeftGreater - progBarLeft_mc._width + progBarLeftRegPointX,vOffset + (heightLeftGreater - progBarLeft_mc._height)/2 + progBarLeftRegPointY);

			bounds = progBarRight_mc.getBounds(progBarRight_mc);

			var progBarRightRegPointX:Number = - bounds.xMin;
			var progBarRightRegPointY:Number = - bounds.yMin;
			
			// assuming heightLeftGreater == heightRightCapGreater
			progBarRight_mc.move(dirOffset + hOffset + widthLeftGreater + progBarMiddle_mc._width + progBarRightRegPointX,vOffset + (heightLeftGreater - progBarRight_mc._height)/2 + progBarRightRegPointY);

			progTrackLeft_mc._visible = true;
			progTrackMiddle_mc._visible = true;
			progTrackRight_mc._visible = true;

			progBarLeft_mc._visible = true;
			progBarMiddle_mc._visible = true;
			progBarRight_mc._visible = true;
		}
		else
		{
			progTrackLeft_mc._visible = false;
			progTrackMiddle_mc._visible = false;
			progTrackRight_mc._visible = false;

			progBarLeft_mc._visible = false;
			progBarMiddle_mc._visible = false;
			progBarRight_mc._visible = false;
		}
	}

	// replaces the from string to to string and returns the modified 
	function replace(str:String,from:String,to:String):String
	{
		var arrStr:Array = str.split(from);
		var repStr:String = arrStr.join(to);
		return repStr;
	}

	/**
	* @private
	* Gets the component's mode of operation.
	*
	* @return String The mode of operation
	*/
	function getMode(Void):String
	{
		return __mode;
	}

	/**
	* @private
	*
	* @param	String	new mode of operation
	* This is called whenever the component's mode of operation changes.
	*/
	function setMode(val:String):Void
	{
		if(val == "polled" || val == "manual")
		{
			__mode = val;
		}
		else
		{
			delete __mode;
		}
		invalidate();
	}

	/**
	* @private
	* Gets the direction.
	*
	* @return String direction of fill
	*/
	function getDirection(Void):String
	{
		return __direction;
	}

	/**
	* @private
	*
	* @param	String	new ProgressBar direction
	* This is called whenever the component's direction of fill changes.
	*/
	function setDirection(val:String):Void
	{
		if(val == "left")
		{
			__direction = val;
		}
		else
		{
			delete __direction;
		}
		invalidate();
	}

	/**
	* @private
	* Gets the label placement.
	*
	* @return String label placement 
	*/
	function getLabelPlacement(Void):String
	{
		return __labelPlacement;
	}

	/**
	* @private
	*
	* @param	String	new label placement for ProgressBar
	* This is called whenever the component's placement of label changes.
	*/
	function setLabelPlacement(val:String):Void
	{
		if(val == "top" || val == "center" || val == "left" || val == "right")
		{
			__labelPlacement = val;
		}
		else
		{
			delete __labelPlacement;
		}
		invalidate();
	}

	/**
	* @private
	* Gets the indeterminate status.
	*
	* @helpid 3916
	* @return Boolean indeterminate status 
	*/
	function getIndeterminate(Void):Boolean
	{
		return __indeterminate;
	}

	/**
	* @private
	*
	* @param	Boolean	new value for indeterminate flag
	* This is called whenever the component's indeterminate status changes.
	*/
	function setIndeterminate(val:Boolean):Void
	{
		if(val == true)
		{
			__indeterminate = true;
		}
		else
		{
			delete __indeterminate;
		}
		invalidate();
	}

	/**
	* @private
	* Gets the progress bar label.
	*
	* @return String label 
	*/
	function getLabel(Void):String
	{
		return __label;
	}

	/**
	* @private
	*
	* @param	String	new value for ProgressBar Label
	* This is called whenever the component's label changes.
	*/
	function setLabel(val:String):Void
	{
		__label = val;
		invalidate();
	}

	/**
	* @private
	* Gets the conversion factor.
	*
	* @return Number conversion factor
	*/
	function getConversion(Void):Number
	{
		return __conversion;
	}

	/**
	* @private
	*
	* @param	Number	new value for conversion property
	* This is called whenever the component's conversion factor changes.
	*/
	function setConversion(val:Number):Void
	{
		if(!_global.isNaN(val) && Number(val) > 0)
		{
			__conversion = Number(val);
			invalidate();
		}
	}

	/**
	* @private
	* Gets the progress bar source.
	*
	* @return source
	*/
	function getSource(Void)
	{
		return __source;
	}

	/**
	* @private
	*
	* @param	Untyped	new value for Source
	* This is called whenever the ProgressBar source changes.
	*/
	function setSource(val):Void
	{
		if(typeof(val) == "string")
		{
			__stringSource = val;
			// dont give eval(__stringSource) else val does not come back as undefined
			val = eval(val);
		}

		if(val != null && val != undefined && val != "")
		{
			__source = val;
			
			if(__mode == "event")
			{
				if(__source.addEventListener)
				{
					__source.addEventListener("progress",this);
					__source.addEventListener("complete",this);
				}
				else
				{
					// the Loader object is not yet initialized properly,
					// as it is put on stage after the progressbar
					// so make it go thru the source re-setting in draw
					__source = undefined;
				}
			}
			if(__mode == "polled")
			{
				si = setInterval(this,"update",this.__interval);
			}
		}
		else if(__source != null)
		{
			delete __source;
			// if(mode == polled)
			clearInterval(si);
			delete si;
		}
	}

	/**
	* @private
	* callback method for polled mode
	*/
	function update(Void):Void
	{
		// mode = polled
		var comp = __source;
		
		var bytesLoaded:Number = comp.getBytesLoaded();
		var bytesTotal:Number = comp.getBytesTotal();
	
		_setProgress(bytesLoaded, bytesTotal);
	
		// 0 is the size of an empty movie clip??
		if (percentComplete>=100 && __value > 0)
		{
			clearInterval(si);
		}
	}

	/**
	* @private
	*
	* @param	Untyped	progress Event object
	* progress event handler for event mode
	*/
	function progress(pEvent):Void
	{
		// mode = event
		var comp = pEvent.target;
		
		var bytesLoaded:Number = comp.bytesLoaded;
		var bytesTotal:Number = comp.bytesTotal;
	
		_setProgress(bytesLoaded, bytesTotal);
	}

	/**
	* @private
	*
	* @param	Untyped	complete Event object
	* complete event handler for event mode
	*/
	function complete(pEvent):Void
	{
	}

	/**
	* @private
	*
	* @param	Number	current value
	* @param	Number	total value
	* private method to change the value and the maximum properties
	*/
	function _setProgress(completed:Number, total:Number):Void
	{
		if(!_global.isNaN(completed) && !_global.isNaN(total))
		{
			__value = Number(completed);
			__maximum = Number(total);
			
			dispatchEvent({type:"progress", current:completed, total:total});
			if(__value == __maximum && __value > 0)
			{
				dispatchEvent({type:"complete", current:completed, total:total});
			}
			
			invalidate();
		}
	}

	/**
	* @param	Number	current value
	* @param	Number	total value
	* method to change the value and the maximum properties in the manual mode
	* @tiptext	Sets the state of the bar to reflect the amount of progress made
	* @helpid 3922
	*/
	function setProgress(completed:Number, total:Number):Void
	{
		// only for manual mode
		if(__mode == "manual")
		{
			_setProgress(completed,total);
		}
	}

	/**
	* @private
	* Gets the percentage of progress made.
	*
	* @return Number percentage of progress made
	*/
	function getPercentComplete(Void):Number
	{
		if(__value < __minimum || __maximum < __minimum)
		{
			return 0;
		}
	
		var perc:Number = 100 * (__value - __minimum)/(__maximum - __minimum);
		
		if(_global.isNaN(perc) || perc < 0)
		{
			return 0;
		}
		else if(perc > 100)
		{
			return 100;
		}
		else
		{
			return perc;
		}
	}

	/**
	* @private
	* Gets the maximum value.
	*
	* @return Number maximum value
	*/
	function getMaximum(Void):Number
	{
		return __maximum;
	}

	/**
	* @private
	*
	* @param	Number	new maximum value
	* This is called whenever the maximum value changes.
	*/
	function setMaximum(val:Number):Void
	{
		if(!_global.isNaN(val) && __mode == "manual")
		{
			__maximum = Number(val);
			invalidate();
		}
	}

	/**
	* @private
	* Gets the minimum value.
	*
	* @return Number minimum value
	*/
	function getMinimum(Void):Number
	{
		return __minimum;
	}

	/**
	* @private
	*
	* @param	Number	new minimum value
	* This is called whenever the minimum value changes.
	*/
	function setMinimum(val:Number):Void
	{
		if(!_global.isNaN(val) && __mode == "manual")
		{
			__minimum = Number(val);
			invalidate();
		}
	}

	/**
	* @private
	* Gets the current value.
	*
	* @return Number current value
	*/
	function getVal(Void):Number
	{
		return __value;
	}

	/**
	* mode of operation
	* @helpid 3159
	* @tiptext The mode of operation of the ProgressBar
	*/
	function get mode():String
	{
		return getMode();
	}

	[Inspectable(enumeration="event,polled,manual", defaultValue="event")]
	function set mode(x:String):Void
	{
		setMode(x);
	}

	/**
	* ProgressBar source object
	* @helpid 3160
	* @tiptext The instance name of the source object for ProgressBar
	*/
	function get source()
	{
		return getSource();
	}
	
	[Inspectable(defaultValue="")]
	function set source(x)
	{
		setSource(x);
	}

	/**
	* direction of fill
	* @helpid 3161
	* @tiptext The direction of fill of the ProgressBar
	*/
	function get direction():String
	{
		return getDirection();
	}
	
	[Inspectable(enumeration="left,right", defaultValue="right")]
	function set direction(x:String):Void
	{
		setDirection(x);
	}

	/**
	* label text
	* @helpid 3162
	* @tiptext The default label text displayed
	*/
	function get label():String
	{
		return getLabel();
	}
	
	// important to keep space in the end, else replace() method has problems
	[Inspectable(defaultValue="LOADING %3%% ")]
	function set label(x:String):Void
	{
		setLabel(x);
	}

	/**
	* label placement
	* @helpid 3163
	* @tiptext The label placement with respect to the graphic
	*/
	function get labelPlacement():String
	{
		return this.getLabelPlacement();
	}
	
	[Inspectable(enumeration="left,right,top,bottom,center", defaultValue="bottom")]
	function set labelPlacement(x:String):Void
	{
		setLabelPlacement(x);
	}

	/**
	* indeterminate status
	* @helpid 3421
	* @tiptext Specifies the determinate or indeterminate look of the bar
	*/
	function get indeterminate():Boolean
	{
		return this.getIndeterminate();
	}
	
	function set indeterminate(x:Boolean):Void
	{
		setIndeterminate(x);
	}

	/**
	* conversion factor
	* @helpid 3164
	* @tiptext The divisor for displayed values
	*/
	function get conversion():Number
	{
		return getConversion();
	}
	
	[Inspectable(defaultValue=1)]
	function set conversion(x:Number):Void
	{
		setConversion(x);
	}

	/**
	* percentage of progress
	* Read-Only:  use setProgress() to change.
	* @tiptext	The percentage of completion of the process
	* @helpid 3921
	*/
 	[Bindable("readonly")]
  	[ChangeEvent("progress")]
	function get percentComplete():Number
	{
		return getPercentComplete();
	}

	/**
	* maximum value.
	* @tiptext	The largest progress value
	* @helpid 3918
	*/
	function get maximum():Number
	{
		return getMaximum();
	}
	function set maximum(x:Number):Void
	{
		setMaximum(x);
	}

	/**
	* minimum value.
	* @tiptext	The smallest progress value
	* @helpid 3920
	*/
	function get minimum():Number
	{
		return getMinimum();
	}
	function set minimum(x:Number):Void
	{
		setMinimum(x);
	}

	/**
	* current value.
	* @tiptext	The current number between the minimum and maximum
	* @helpid 3923
	*/
  	[Bindable("readonly")]
  	[ChangeEvent("progress")]
	function get value():Number
	{
		return getVal();
	}
}