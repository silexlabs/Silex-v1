//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.Button;
import mx.controls.RadioButtonGroup;
import mx.core.UIObject;

/**
* @tiptext click event
* @helpid 3425
*/
[Event("click")]

[TagName("RadioButton")]
[IconFile("RadioButton.png")]
[InspectableList("labelPlacement","label","selected","groupName","data")]
/**
* RadioButton class
* extends Button
* @tiptext RadioButton provides the ability to select an option from a group.  Extends Button
* @helpid 3165
*/ 
class mx.controls.RadioButton extends Button
{
/**
* @private
* 
*/	
	function RadioButton ()
	{
	}
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "RadioButton";
/**
* @private
* Class used in createClassObject
*/	
	static var symbolOwner:Object = mx.controls.RadioButton;
/**
* @private
* className for object
*/	
//#include "../core/ComponentVersion.as"
	var	className:String = "RadioButton";
/**
* @private
* number of pixels icon and label offset on press/release
*/		
	var btnOffset:Number = 0; // # of pixels icon and label offset on press.
/**
* @private
* set the radio button to toggle
*/	
	var __toggle:Boolean = true;
/**
* @private
* private value 
*/	
	var __value:Object;
/**
* @private
* defualt value of label
*/	
	var __label:String = "Radio Button";
/**
* @private
* default label placement or radio button
*/	
	var __labelPlacement:String = "right";
/**
* @private
* 
*/		
	var ignoreClassStyleDeclaration = { Button: 1 };
/**
* @private
* default radio button group name
*/	
	var __groupName:String = "radioGroup";
/**
* @private
* default inital index value 
*/	
	var indexNumber:Number = 0;
/**
* @private
* define private data variable for use later
*/	
	var __data:String;
/**
* @private
* define offset value to false layout code is found in Button
*/	
	var offset:Boolean = false;
/**
* @private
* falseUpSkin name not assigned since only icon is displayed for a check box
*/	
	var falseUpSkin:String = "";
/**
* @private
* falseDownSkin name not assigned since only icon is displayed for a radio button
*/	
	var falseDownSkin:String = "";
/**
* @private
* falseOverSkin name not assigned since only icon is displayed for a radio button
*/	
	var falseOverSkin:String = "";
/**
* @private
*  falseDisabledSkin name not assigned since only icon is displayed for a radio button
*/	
	var falseDisabledSkin:String = "";
/**
* @private
*  trueUpSkin name not assigned since only icon is displayed for a radio button
*/	
	var trueUpSkin:String = "";
/**
* @private
*  trueDownSkin name not assigned since only icon is displayed for a radio button
*/	
	var trueDownSkin:String = "";
/**
* @private
* trueOverSkin name  not assigned since only icon is displayed for a radio button
*/	
	var trueOverSkin:String = "";
/**
* @private
*  trueDisabledSkin name not assigned since only icon is displayed for a radio button
*/	
	var trueDisabledSkin:String = "";
/**
* @private
*  falseUpIcon name  is the radio icon 
*/			
	var falseUpIcon:String = "RadioFalseUp";
/**
* @private
* falseDownIcon name  is the radio icon 
*/	
	var falseDownIcon:String = "RadioFalseDown";
/**
* @private
*  falseOverIcon name  is the radio icon 
*/	
	var falseOverIcon:String = "RadioFalseOver";
/**
* @private
*  falseDisabledIcon name  is the radio icon 
*/	
	var falseDisabledIcon:String = "RadioFalseDisabled";
/**
* @private
*  trueUpIcon name  is the radio icon 
*/	
	var trueUpIcon:String = "RadioTrueUp";
/**
* @private
*  trueDownIcon name is not defined since the radio button only requires one true state
*/	
	var trueDownIcon:String = "";
/**
* @private
*  trueOverIcon name is not defined since the radio button only requires one true state
*/	
	var trueOverIcon:String = "";
/**
* @private
*  trueDisabledIcon name  is the radio icon 
*/	
	var trueDisabledIcon:String = "RadioTrueDisabled";
/**
* @private
*  define centerContent value to false layout code is found in Button
*/		
	var centerContent : Boolean = false;
/**
* @private
*  define cborderW value  layout code is found in Button	
*/	
	var borderW : Number = 0;
/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters  = { labelPlacement: 1, data: 1, label: 1, groupName: 1, selected: 1 };
/**
* @private
* list of clip parameters to check at init
*/	
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(mx.controls.RadioButton.prototype.clipParameters, mx.controls.Button.prototype.clipParameters);

	// overrides just to get different helpIDs
/**
* @tiptext Gets or sets the RadioButton selected state
* @helpid 3928
*/
	var selected:Boolean;
/**
* sets the label placement of left,right,top, or bottom
* @tiptext Gets or sets the label placement relative to the radio dot
* @helpid 3900
*/ 
	var labelPlacement:String;
	
/**
* gets the associated label text
* @tiptext Gets or sets the RadioButton label
* @helpid 3424
*/	
	[Inspectable(defaultValue="Radio Button")]
	var label:String;

/**
* @private
* init variables. Components should implement this method and call super.init() to 
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*/
	function init (Void):Void
	{
		setToggle(__toggle);
		__value  = this;
		super.init();
	}
/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/
	function size  (Void):Void
	{
		super.size();
	}
/**
* @private
* set radio button to selected and dispatch that there has been a change of 
*/
	function onRelease  () 
	{
		if (this.selected) return; // prevent a selected button from broadcasting "click"
		releaseFocus();
		phase = "up";
		setSelected(true);
		dispatchEvent({type:"click"});
		_parent[__groupName].dispatchEvent({type: "click"});
	}
/**
* @private
* value used to identify a particular radio instance
*/
	function setData  (val)
	{
		__data = val;
	}
/**
* hang data off of a radio instance 
* @tiptext  Data to associate with the radio button instance
* @helpid 3430
*/	
	[Inspectable(defaultValue="")]
	function set data  (val)
	{
		__data = val;
	}
/**
* @private
*  return data that is hung off of the radio instance
*/
	function getData  (val)
	{
		return __data;
	}
/**
* @private
* return data that is hung off of a radio instance
* @helpid 3924
*/	
	function get data  ()
	{
		return __data;
	}
/**
* @private
*  remove the radio button 
*/
	function onUnload ()
	{
		if (_parent[__groupName].selectedRadio == this) {_parent[__groupName].selectedRadio = undefined;}
		 _parent[__groupName].radioList[indexNumber] = null;
		delete  _parent[__groupName].radioList[indexNumber];
	}
/**
* @private
*  sets the selected state of the radio button 
*/
	function setSelected (val:Boolean):Void
	{
		var s:Object = _parent[__groupName];
		
		var tmpW:Number = s["selectedRadio"].__width;
		var tmpH:Number = s["selectedRadio"].__height;
			if (val){
			
				s["selectedRadio"].setState(false);
				s["selectedRadio"] = this;
				
			} else {
				if (s["selectedRadio"] == this)
				{
				s["selectedRadio"].setState(false);
				s["selectedRadio"] = undefined;
				}
			}
			setState(val);
	}
/**
* @private
* remove the radio button group object
*/
	function deleteGroupObj  (groupName:String):Void
	{
		delete _parent[groupName];
	}
/**
* @private
*  return the group name 
*/
	function getGroupName  ()
	{
		return __groupName;
	}
/**
*  return the group name 
*/	
	function get groupName  ()
	{
		return __groupName;
	}
/**
* @private
*  sets the group name associated with the radio button 
*/
	function setGroupName (groupName:String):Void
	{
		if(groupName == undefined || groupName == "")return;
		delete _parent[__groupName].radioList[__data];
		addToGroup(groupName);
		__groupName = groupName;
	}
/**
*  sets the group name associated with the radio button
*  @tiptext Gets or sets the group name of a RadioButton
*  @helpid 3927
*/	
	[Inspectable(defaultValue="radioGroup")]
	function set groupName  (groupName:String) 
	{
		setGroupName(groupName);
	}
/**
* @private
*  create radio button group if it does not exist and add the instance to the group
*/
	function addToGroup (groupName:String):Void
	{
		if (groupName == "" || groupName == undefined) return;
		var g = _parent[groupName];
		if (g == undefined) {
			g = _parent[groupName] = new RadioButtonGroup();
			g.__groupName = groupName;
		}
		g.addInstance(this);
		if (__state){
			g["selectedRadio"].setState(false);
			g["selectedRadio"] = this;
			
		}
	}
/**
* @private
* 
*/	
	function get emphasized  () 
	{
		return undefined;
	}
/**
* @private
* support the use of keyboard within the group 
*/	
	function keyDown(e:Object):Void
	{
		switch (e.code)
		{
			case Key.DOWN:
			{
				this.setNext();
				break;
			}
			
			case Key.UP:
			{
				this.setPrev();
				break;
			}
			
			case Key.LEFT:
			{
				this.setPrev();
				break;
			}
			
			case Key.RIGHT:
			{
				this.setNext();
				break;
			}
		}
	}
/**
* @private
*  set next radio button in the group
*/	
	function setNext ()
	{
		var g = _parent[groupName];
		if (g.selectedRadio.indexNumber +1 == g.radioList.length) {return;};
		
		var	index = (g.selectedRadio) ? g.selectedRadio.indexNumber : -1;
		for (var i:Number =1;i<g.radioList.length;i++)
		{
			if ( (g.radioList[index + i] != undefined) && ((g.radioList[index + i]).enabled) )
			{
				var fMgr = getFocusManager();
				g.radioList[index + i].selected = true;
				fMgr.setFocus(g.radioList[g.selectedRadio.indexNumber]);
				g.dispatchEvent({type:"click"});
				break;
			}
		}
	}
/**
* @private
* set the previous radio button in the group
*/	
	function setPrev () 
	{
		var g = _parent[groupName];
		if(g.selectedRadio.indexNumber == 0){return;};

		var index = (g.selectedRadio) ? g.selectedRadio.indexNumber : 1;	
		for (var i:Number =1;i<g.radioList.length;i++)
		{
			if ( (g.radioList[index - i] != undefined) && ((g.radioList[index - i]).enabled) )
			{
				var fMgr = getFocusManager();
				g.radioList[index - i].selected = true;
				fMgr.setFocus(g.radioList[g.selectedRadio.indexNumber]);
				g.dispatchEvent({type:"click"});
				break;
			}
		}
	}
			
 	function set toggle(v)
 	{
 		// for the inspectables
 	}
 	
 	function get toggle()
 	{
 		// for the inspectables
 	}
 	
 	function set icon(v)
 	{
 		//  for the inspectables
 	}
 	
 	function get icon()
 	{
 		// for the inspectables
	}
}  




