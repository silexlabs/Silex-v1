//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.SimpleButton;
import mx.controls.TextInput;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.managers.SystemManager;

/**
* @tiptext change event
* @helpid 3152
*/
[Event("change")]
/**
* @tiptext move event
* @helpid 3153
*/
[Event("move")]
/**
* @tiptext draw event
* @helpid 3154
*/
[Event("draw")]

[TagName("NumericStepper")]
[IconFile("NumericStepper.png")]

/**
* NumericStepper class
* extends UIComponent
* @tiptext NumericStepper allows stepping through values in a numeric text field
* @helpid 3155
*/ 
class mx.controls.NumericStepper extends UIComponent
{
/**
* @private
* SymbolName for object
*/	
	static var symbolName:String = "NumericStepper";
/**
* @private
* Class used in createClassObject
*/	
	static var symbolOwner:Object = NumericStepper;
	//#include "../core/ComponentVersion.as"
/**
* @private
* className for object
*/	
	var className:String = "NumericStepper";
/**
* @private
*	name of the clip that represents this state
*/	
	var upArrowUp:String	= "StepUpArrowUp"; 
/**
* @private
*	name of the clip that represents this state
*/	
	var upArrowDown:String = "StepUpArrowDown"; 
/**
* @private
*	name of the clip that represents this state
*/	
	var upArrowOver:String = "StepUpArrowOver"; 
/**
* @private
*	name of the clip that represents this state
*/	
	var upArrowDisabled:String = "StepUpArrowDisabled";
/**
* @private
* name of the clip that represents this state
*/
	var downArrowUp:String = "StepDownArrowUp";
/**
* @private
* name of the clip that represents this state
*/	
	var downArrowDown:String = "StepDownArrowDown";
/**
* @private
*	name of the clip that represents this state
*/	
	var downArrowOver:String = "StepDownArrowOver";
/**
* @private
*	name of the clip that represents this state
*/ 
	var downArrowDisabled:String = "StepDownArrowDisabled";
/**
* @private
*	depth of arrow
*/
	var skinIDUpArrow:Number = 10;
/**
* @private
*	depth of arrow
*/	
	var skinIDDownArrow:Number = 11;
/**
* @private
* depth of text area
*/	
	var skinIDInput:Number = 9;
/**
* @private
*	define the bounding box
*/		
	var boundingBox_mc:MovieClip;
/**
* @private
*	define the text field
*/	
	var inputField:Object; 
/**
* @private
* define the next button 
*/	
	var nextButton_mc:SimpleButton; 
/**
* @private
* define the prev button 
*/	
	var prevButton_mc:SimpleButton; 
/**
* @private
* define the tarck that appears of the stepper is taller than default height
*/	
	var StepTrack_mc:MovieClip; 
/**
* @private
* initialization variable
*/
	var initializing:Boolean = true;
/**
* @private
* visible variable
*/
	var __visible:Boolean = true;
/**
* @private
* minimum range value
*/	
	var __minimum:Number = 0;
/**
* @private
* maximium range value
*/	
	var __maximum:Number = 10;
/**
* @private
* step size 
*/	
	var __stepSize:Number = 1;
/**
* @private
* value of the stepper
*/	
	var __value:Number = 0;
/**
* @private
* next value that is in step and range
*/	
	var __nextValue:Number = 0;
/**
* @private
*	previous value that is in step and range
*/	
	var __previousValue:Number = 0;
/**
* @private
*	maximum number of characters that can be entered
*/	
	var __maxChars:Number;
/**
* @private
* list of clip parameters to check at init
*/	
	var clipParameters:Object = { minimum: 1,
						maximum: 1,
						stepSize: 1,
						value: 1,
						maxChars: 1
						};
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(NumericStepper.prototype.clipParameters, UIComponent.prototype.clipParameters);
/**
* @private
*	constructor
*/	
	 function NumericStepper()
	{
	}
	
/**
* @private
* init variables. Components should implement this method and call super.init() to 
* ensure this method gets called.	The width, height and clip parameters will not
* be properly set until after this is called.
*/	
	function init():Void
	{
		super.init();	 
		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;
		_visible = false;
		tabEnabled = false;
		tabChildren = true;
	}
/**
* @private
* save call to visible when initializing
*/	
	function setVisible(x:Boolean,noEvent:Boolean):Void
	{
		super.setVisible(x, noEvent);
		if (initializing) {
			__visible = x;				
		}
	}
	
/**
* @private
* place the buttons to the right of the text field
*/
	function layoutControl():Void
	{
		nextButton_mc._x = __width - nextButton_mc.__width;
		nextButton_mc._y = 0;
	 
		prevButton_mc._x = __width - prevButton_mc.__width;
		prevButton_mc._y = __height - prevButton_mc.__height;
		
		inputField.setSize(__width - nextButton_mc.__width, __height);
		StepTrack_mc._width = Math.max(nextButton_mc.__width, prevButton_mc.__width);
		StepTrack_mc._x = __width - StepTrack_mc._width;
		StepTrack_mc._height = __height - (nextButton_mc._height + prevButton_mc._height);
		StepTrack_mc._y = nextButton_mc.__height;
	}
	
/**
* @private
* create children objects. Components implement this method to create the
* subobjects in the component.	Recommended way is to make text objects
* invisible and make them visible when the draw() method is called to
* avoid flicker on the screen.
*/
	function createChildren():Void
	{
		super.createChildren();
		addAsset("nextButton_mc", skinIDUpArrow);
		addAsset("prevButton_mc", skinIDDownArrow);
		addAsset("inputField", skinIDInput);
		focusTextField = TextField(inputField.label);

		createObject("StepTrack", "StepTrack_mc", 2);
		this.size();
	}
	
/**
* @private
*	
*/
	function draw():Void
	{
		prevButton_mc.enabled = enabled;
		nextButton_mc.enabled = enabled;
		inputField.enabled = enabled;
					
		size();
		initializing = false;
		visible = __visible;
	}
	
/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size():Void
	{
		var minH:Number = calcMinHeight();
		var minW:Number = calcMinWidth();
		if (__height < minH )
			setSize (__width, minH);
		if (__width < minW )
			setSize (minW, __height);
		
		layoutControl();
	}
	
/**
* @private
* return the minimum height of the stepper
*/
	function calcMinHeight():Number
	{
		return 22;
	}
	
/**
* @private
* return the minimum width of the control
*/
	function calcMinWidth():Number
	{
		return 40;
	}
	
 
/**
* @private
* add the parts to the stepper control 
*/
	function addAsset(id:String, skinID:Number):Void
	{
		var o = new Object();
		o.styleName = this;
		
		if (skinID == 10)
		{
			o.falseUpSkin = upArrowUp;
			o.falseOverSkin = upArrowOver;
			o.falseDownSkin = upArrowDown;
			o.falseDisabledSkin = upArrowDisabled;
			createClassObject(SimpleButton, id, skinID,o);
			
			var upButton:Object = nextButton_mc;
			upButton.tabEnabled = false;
			upButton.styleName = this;
			upButton._x = __width - upButton.__width;
			upButton._y = 0;
			upButton.owner = this; 
			upButton.autoRepeat = true;
			upButton.clickHandler = function() { Selection.setSelection(0,0); };
			upButton.buttonDownHandler = function() { this.owner.buttonPress(this); };
		}
		else if (skinID == 11)
		{
			o.falseUpSkin=downArrowUp;
			o.falseOverSkin=downArrowOver;
			o.falseDownSkin = downArrowDown;
			o.falseDisabledSkin=downArrowDisabled;
			createClassObject(SimpleButton, id, skinID,o);
			
			var downButton:Object = prevButton_mc;
			downButton.tabEnabled = false;
			downButton.styleName = this;
			downButton._x = __width - downButton.__width;
			downButton._y = __height - downButton.__height;
			downButton.owner = this;
			downButton.autoRepeat = true;
			downButton.clickHandler = function() { Selection.setSelection(0,0); };
			downButton.buttonDownHandler = function() { this.owner.buttonPress(this); };
		}
		else if (skinID == 9)
		{
			createClassObject(TextInput, id, skinID);
			var iField:Object = inputField;
			iField.styleName = this;

			iField.setSize(__width - nextButton_mc.__width, __height);
			
			iField.restrict = "0-9\\-\\.\\,"; // restrict to numbers - dashes - commas - decimals 
			iField.maxChars = __maxChars;
			iField.text = value;
				
			iField.onSetFocus = function()
			{ 
				this._parent.onSetFocus();
			};
			 
			iField.onKillFocus = function() 
			{	 
				this._parent.onKillFocus();
			};
			 
			iField.drawFocus = function(b) 
			{	 
				this._parent.drawFocus(b);
			};
			 
			iField.onKeyDown = function ()
			{
				this._parent.onFieldKeyDown(); 
			};
		}
	}
	
/**
* @private
* set the	focus for the text field
*/
	function setFocus():Void
	{
		Selection.setFocus(inputField);
	}
	
/**
* @private
* remove the focus from the text field 
*/	
	function onKillFocus():Void
	{
		SystemManager.form.focusManager.defaultPushButtonEnabled = true;
		super.onKillFocus();
		Key.removeListener(inputField);
		
		if (Number(inputField.text) != value)
		{
			var newVal:Number = checkValidValue(Number(inputField.text));
			inputField.text = newVal;
			value = newVal;
			dispatchEvent({type:"change"});
		}
	}
	
/**
* @private
* on focus set add key listener
*/
	function onSetFocus():Void
	{
		super.onSetFocus();
		Key.addListener(inputField);
		SystemManager.form.focusManager.defaultPushButtonEnabled = false;
	}
	
/**
* @private
* support use of keyboard interaction 
*/
	function onFieldKeyDown():Void
	{
		var oldValue:Number = value;
		
		switch (Key.getCode())
		{
			case Key.DOWN:
			{
				var tmpV:Number = this.value - this.stepSize;
				{
					this.value = tmpV;
					if (oldValue != value) dispatchEvent({type:"change"});
				}
				break;
			}
			
			case Key.UP:
			{
				var tmpV:Number = this.stepSize + this.value;
				{
					this.value = tmpV;
					 if (oldValue != value) dispatchEvent({type:"change"});
				} 
				break;
			}
			
			case Key.HOME:
			{
				this.inputField.text =	this.minimum;
				this.value = this.minimum;
				 if (oldValue != value) dispatchEvent({type:"change"});
				break;
			}
			
			case Key.END:
			{
				this.inputField.text = this.maximum;
				this.value = this.maximum;
				 if (oldValue != value) dispatchEvent({type:"change"});
				break;
			}
			case Key.ENTER:
			{
				
				this.value = Number(this.inputField.text);
				 if (oldValue != value) dispatchEvent({type:"change"});
				}
			 }
	}

/**
* return the next value that is in step and range
* @tiptext	The next sequential value that is in step and range
* @helpid 3912
*/
	function get nextValue():Number
	{
		if (checkRange(value + stepSize))
		{
			__nextValue = value + stepSize;
			return __nextValue;
		} 
	}
	
/**
* return the previous value that is in step and range
* @tiptext	The previous value that is in step and range
* @helpid 3913
*/
	function get previousValue():Number
	{
		if (checkRange(__value - stepSize))
		{
			__previousValue = value - stepSize;
			return __previousValue;
		} 
	}
/**
* @private
* set the maximum number of characters that can be entered in the field
*/	
	function set maxChars (num:Number)
	{
		__maxChars = num;
		inputField.maxChars = __maxChars;
	}
/**
* @private
* get the maximum number of characters that can be entered in the field
*/		
	function get maxChars ():Number
	{
		return __maxChars;
	}
	
/**
* return the current value of the stepper
* @tiptext	The value currently displayed in NumericStepper's text area
* @helpid 3915
*/
	[Bindable]
	[ChangeEvent("change")]
	function get value():Number
	{
		return __value;
	}
	
/**
* set value that is in step and range 
*/		
	[Inspectable(defaultValue=0)]
	function set value(v:Number):Void
	{
		var tmpv:Number = checkValidValue(v);
		if (tmpv == __value)
			return;
		inputField.text = __value = tmpv; 
	}	
	
/**
* return the minimum range value
* @tiptext	Specifies the minimum range value
* @helpid 3911
*/
	function get minimum():Number
	{
		return __minimum ;
	}

/**
* minimum range value
*/
	 [Inspectable(defaultValue=0)]
	function set minimum(v:Number):Void
	{
		__minimum = v;
	}
	
/**
* return the maximum range value
* @tiptext	Specifies the maximum range value
* @helpid 3910
*/
	function get maximum():Number
	{
		return __maximum;
	}
			
/**
* set the maximum range value
*/
	 [Inspectable(defaultValue=10)]
	function set maximum(v:Number):Void
	{
		__maximum = v;
	}

/**
*	returns the unit change 
* @tiptext	Specifies the unit of change
* @helpid 3914
*/
	function get stepSize():Number
	{
		return __stepSize;
	}
/**
* sets the unit change 
*/
	 [Inspectable(defaultValue=1)]
	function set stepSize(v:Number):Void
	{
		__stepSize = v;
	}
	
/**
* @private
* 
*/	
	function onFocus():Void
	{
	}
/**
* @private
*	increase/decrease the step value
*/
	function buttonPress(button:SimpleButton):Void
	{	 
		var oldValue:Number = value;
		if (button._name == "nextButton_mc")
			value += stepSize;
		else
			value -= stepSize;
		
		if(oldValue != value)
		{
			dispatchEvent({type:"change"});
			Selection.setSelection(0,0);
		}
	}
/**
* @private
* verify the that the value is within range 
*/
	function checkRange(v:Number):Boolean
	{
		return (v >= minimum && v <= maximum);
	}
/**
* @private
* check if value is within range and adjust for floating point errors
*/
	function checkValidValue(val:Number):Number
	{
		var initDiv:Number = val / stepSize;
 		var roundD:Number = Math.floor(initDiv);

		var stepS:Number = stepSize;
		var minVal:Number = minimum;
		var maxVal:Number = maximum;

		if (val > minVal && val < maxVal)
		{
			if (initDiv - roundD == 0)
  			{
				return val;
  			}
  			else
  			{
  				var tmpV:Number = Math.floor(val / stepS);
  				var stepDownV:Number = tmpV * stepS;
  				if ((val - stepDownV >= stepS / 2 && maxVal >= stepDownV + stepS && minVal <= stepDownV - stepS)
  					|| (val + stepS == maxVal && maxVal - stepDownV - stepS > 0.00000000000001))
  				{
  					stepDownV += stepS;
  				}
  				return stepDownV;
  			}
		}
		else
		{
			if (val >= maxVal)
				return maxVal;
			else
				return minVal;
		}
	}
/**
* @private
* update the text field 
*/
	function onLabelChanged(o:TextInput):Void
	{
		var newVal = checkValidValue(Number(o.text)); 
		o.text =	newVal;
		value = newVal;
	}
/**
* @private
* tabindex of the control
*/
	function get tabIndex():Number
	{
		return inputField.tabIndex;
	}
/**
* @private
* set the tab index of the control 
*/
	function set tabIndex(w:Number):Void
	{
		inputField.tabIndex=w;
	}
}
