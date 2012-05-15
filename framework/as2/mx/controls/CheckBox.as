//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.Button;
import mx.core.UIObject;

/**
* @tiptext click event
* @helpid 3902
*/
[Event("click")]

[TagName("CheckBox")]
[IconFile("CheckBox.png")]
[InspectableList("labelPlacement","label","selected")]

/**
* CheckBox class
* extends Button
* @tiptext CheckBox provides the ability to check or uncheck an option.  Extends Button
* @helpid 3049
*/ 
class mx.controls.CheckBox extends Button
{
	
	function CheckBox ()
	{
	}
/**
* @private
* SymbolName for object
*/	
	static var symbolName:String = "CheckBox";
/**
* @private
* Class used in createClassObject
*/	
	static var symbolOwner:Object = mx.controls.CheckBox;
	//#include "../core/ComponentVersion.as"
/**
* @private
* className for object
*/	
	var	className:String = "CheckBox";
/**
* @private
* 
*/		
	var ignoreClassStyleDeclaration = { Button: 1 };
/**
* @private
* number of pixels icon and label offset on press/release
*/	
	var btnOffset = 0; 
/**
* @private
*  check box needs to toggle 
*/
	var __toggle:Boolean = true;
/**
* @private
* default  value representing the checked/unchecked state
*/	
	var __selected:Boolean = false;
/**
* @private
*  default label placement 
*/	
	var __labelPlacement:String = "right";
/**
* @private
*  default label name 
*/	
	var __label:String = "CheckBox";
/**
* @private
*  falseUpSkin name not assigned since only icon is displayed for a check box
*/	
	var falseUpSkin:String = "";
/**
* @private
*  falseDownSkin name not assigned since only icon is displayed for a check box
*/	
	var falseDownSkin:String  = "";
/**
* @private
*  falseOverSkin name not assigned since only icon is displayed for a check box
*/	
	var falseOverSkin:String  = "";
/**
* @private
*  falseDisabledSkin name not assigned since only icon is displayed for a check box
*/	
	var falseDisabledSkin:String  = "";
/**
* @private
*  trueUpSkin name not assigned since only icon is displayed for a check box
*/	
	var trueUpSkin:String  = "";
/**
* @private
*  trueDownSkin name not assigned since only icon is displayed for a check box
*/	
	var trueDownSkin:String  = "";
/**
* @private
*  trueOverSkin name not assigned since only icon is displayed for a check box
*/	
	var trueOverSkin:String  = "";
/**
* @private
*  trueDisabledSkin name not assigned since only icon is displayed for a check box
*/	
	var trueDisabledSkin:String  = "";
/**
* @private
*   falseUpIcon is the check box 
*/	
	var falseUpIcon:String  = "CheckFalseUp";
/**
* @private
*  falseDownIcon is the check box 
*/	
	var falseDownIcon:String  = "CheckFalseDown";
/**
* @private
*  falseOverIcon is the check box 
*/	
	var falseOverIcon:String  = "CheckFalseOver";
/**
* @private
*  falseDisabledIcon is the check box 
*/	
	var falseDisabledIcon:String  = "CheckFalseDisabled";
/**
* @private
*  trueUpIcon is the check box 
*/	
	var trueUpIcon:String  = "CheckTrueUp";
/**
* @private
*  trueDownIcon is the check box 
*/	
	var trueDownIcon:String  = "CheckTrueDown";
/**
* @private
*  trueOverIcon is the check box 
*/	
	var trueOverIcon:String  = "CheckTrueOver";
/**
* @private
*  trueDisabledIcon is the check box 
*/	
	var trueDisabledIcon:String = "CheckTrueDisabled";
	
	// overrides just to get different helpIDs
/**
* sets the label placement of left,right,top, or bottom
* @tiptext Gets or sets the label placement relative to the check
* @helpid 3900
*/ 
	var labelPlacement:String;
/**
* @tiptext Gets or sets the CheckBox checked state
* @helpid 3901
*/
	var selected:Boolean;
	
/**
* @private
* list of clip parameters to check at init
*/	
	var clipParameters = { label: 1, labelPlacement: 1 ,selected: 1 };
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(mx.controls.CheckBox.prototype.clipParameters, mx.controls.Button.prototype.clipParameters);
/**
* @private
*  define centerContent value to false layout code is found in Button
*/		
	var centerContent : Boolean = false;
/**
* @private
*  define borderW value layout code is found in Button
*/
	var borderW : Number = 0;
/**
* @private
* call onRelease within button 
*/			
	function onRelease ()
	{
		super.onRelease();
	}
/**
* @private
* init variables. Components should implement this method and call super.init() to 
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*/	
	function init ()
	{	
		super.init();
	}
/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size  () 
	{
		super.size();
	}
/**
* @private
*  buttons that can't be default buttons need this
*/	
	function get emphasized  () 
	{
		return undefined;
	}
/**
* @private
*  returns the height that will accomodate the text and icon 
*/	
	function calcPreferredHeight ()
	{
		var myTF = _getTextFormat();
		var textH = myTF.getTextExtent2(labelPath.text).height;
		var iconH = iconName._height;
		var h = 0;
		if (__labelPlacement == "left" || __labelPlacement == "right") h = Math.max(textH, iconH);
		else h = textH+iconH;
		return Math.max(14, h);
	}
	
	// additional metadata for databinding.
	[Bindable]
	[ChangeEvent("click")]
	var _inherited_selected : Boolean;
	

	function set toggle(v)
	{
		
	}
	
	function get toggle()
	{
		
	}

	function set icon(v)
	{
		
	}

	function get icon()
	{
		
	}

/**
* gets the associated label text
* @tiptext Gets or sets the CheckBox label
* @helpid 3423
*/	
	[Inspectable(defaultValue="CheckBox")]
	var label:String;
	
}

