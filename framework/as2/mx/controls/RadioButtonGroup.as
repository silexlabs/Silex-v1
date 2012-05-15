//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.events.UIEventDispatcher;

/**
* @tiptext click event
* @helpid 3168
*/
[Event("click")]

/**
* RadioButtonGroup class
* @tiptext RadioButtonGroup used in conjunction with RadioButton 
* @helpid 3166
*/ 
// TODO check "extends MovieClip"
class mx.controls.RadioButtonGroup extends MovieClip
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "RadioButtonGroup";
/**
* @private
* Class used in createClassObject
*/	
	static var symbolOwner:Object = mx.controls.RadioButtonGroup;
//#include "../core/ComponentVersion.as"
/**
* @private
* className for object
*/	
	var	className:String = "RadioButtonGroup";
/**
* @private
*  define the array to store references to radio buttons
*/	
	var radioList:Array;
/**
* @private
*  reference to the selected radio button 
*/	
	var selectedRadio:Object;
/**
* @private
*  name of the radio group 
*/	
	var __groupName:String;
/**
* @private
*  for strictly typed 
*/	
	var addEventListener:Function;
/**
* @private
*   for strictly typed 
*/	
	var removeEventListener:Function;
/**
* @private
*  for strictly typed 
*/	
	var dispatchEvent:Function;
/**
* @private
*  deafult index for the radio button refrences
*/	
	var indexNumber:Number = 0;
/**
* @private
* Constructor function 
*/	
	function RadioButtonGroup ()
	{
		init();
		UIEventDispatcher.initialize(this);
	}
/**
* @private
* init variables. Components should implement this method and call super.init() to 
* ensure this method gets called.  The width, height and clip parameters will not
* be properly set until after this is called.
*/		
	function init (Void):Void
	{
		radioList = new Array();
	}
/**
* @private
* changes the groupname for all the radio  buttons in the group
*/
	function setGroupName (groupName:String):Void
	{
		if(groupName == undefined || groupName == "")return;
		var gn = __groupName;
		var sel;
		
		_parent[groupName] = this;
		for (var i in radioList){
			radioList[i].groupName = groupName;
			sel = radioList[i];
		}
		sel.deleteGroupObj(gn);
	}
/**
* @private
* returns the group name for the group 
*/		
	function getGroupName ():String
	{
		return __groupName;
	}
/**
* @private
* add a radio button to the group 
*/		
	function addInstance( instance:MovieClip):Void
	{
			instance.indexNumber = indexNumber++;
			radioList.push(instance);
	}
/**
* @private
* return the data or the label value of the selected radio button 
*/	
	function getValue():String
	{
		if (selectedRadio.data == "")
		{
			return selectedRadio.label;
		}else{
			return (selectedRadio.__data);
		}
	}
/**
* @private
* return label placement of the group
*/	
	function getLabelPlacement():String
	{
		var r;
		for (var i in radioList)
		{
			r = radioList[i].getLabelPlacement();
		}
		return r;
	}
/**
* @private
*  set the label placement of the group 
*/	
	function setLabelPlacement(pos:String)
	{
		for (var i in radioList)
		{
			radioList[i].setLabelPlacement(pos);
		}
	}
/**
* @private
* set the enabled state of the group 
*/	
	function setEnabled(val:Boolean)
	{
		for (var i in radioList)
		{
			radioList[i].enabled = val;
		}
	}
/**
* @private
* Each component should implement this method and lay out
* its children based on the .width and .height properties
*/	
	function setSize(val:Number,val1:Number)
	{
		for (var i in radioList)
		{
			radioList[i].setSize(val,val1);
		}
	}
/**
* @private
* return the enabled state of the radio button group 
*/	
	function getEnabled()
	{	
		var t = 0;
		for (var i in radioList)
		{
			var s = radioList[i].enabled;
			t = t + (s + 0);
		}
		if ( t == radioList.length )
		{
			return true;
		}
		if ( t== 0 )
		{
			return false;
		}
	}
/**
* @private
* pass the style to all memebers of the radio button group 
*/		
	function setStyle(name:String,val):Void
	{
		for (var i in radioList)
		{
			radioList[i].setStyle(name,val);
		}
	}
/**
* @private
* set the selected instance value 
*/	
	function setInstance(val:MovieClip)
	{
		for (var i in radioList)
		{
		  if (radioList[i] == val)
		  {
			radioList[i].selected = true;
		  }
		}
	}
/**
* @private
* return the selected radio instance
*/		
	function getInstance():Object
	{
		return selectedRadio;
	}
/**
* @private
* set the selected radio button based on the data or the label 
*/		
	function setValue(val:String)
	{
		var item;
		for (var i in radioList){
			if (radioList[i].__data == val || radioList[i].label == val){
				item = i;
				break;
			}
		}
		if(item != undefined )
		{
			selectedRadio.setState(false);
			selectedRadio.hitArea_mc._height = selectedRadio.__height;
			selectedRadio.hitArea_mc._width = selectedRadio.__width;
			selectedRadio = radioList[item];
			selectedRadio.setState(true);
			selectedRadio.hitArea_mc._height = selectedRadio.hitArea_mc._width = 0;
		}
	}
/**
* @private
*  sets the group name for the group 
*/	
	function set groupName (groupName:String) 
	{
		if(groupName == undefined || groupName == '')return;
		var gn = __groupName;
		var sel;
		_parent[groupName] = this;
		for (var i in radioList){
			radioList[i].groupName = groupName;
			sel = radioList[i];
		}
		sel.deleteGroupObj(gn);
	}
/**
*  return the group name for the group
*  @tiptext The group name for the RadioButton group
*  @helpid 3431
*/	
	function get groupName () 
	{
		return __groupName;
	}
/**
*  find the radio button and change the state to selected state of previous
*  to false and selected value to true
*/	
	function set selectedData(val)
	{
		var item;
		for (var i in radioList){
			if (radioList[i].__data == val || radioList[i].label == val){
				item = i;
				break;
			}
		}
		if(item != undefined )
		{
			selectedRadio.setState(false);
			selectedRadio = radioList[item];
			selectedRadio.setState(true);
		}
	}
/**
*  returns the data or the label associated with the selected radio button 
*  @tiptext The data or label associated with the selected RadioButton
*  @helpid 3929
*/	
	function get selectedData() 
	{
		if (selectedRadio.data == "" || selectedRadio.data == undefined)
		{
			return selectedRadio.label;
		}else{
			return (selectedRadio.__data);
		}
	}
/**
* return the reference of the selected radio button 
*/		
	function get selection():Object
	{
		return selectedRadio;
	}
/**
*  set the selected radio to true
*  @tiptext The object reference of the currently selected RadioButton
*  @helpid 3930
*/	
	function set selection(val:Object)
	{ 
		for (var i in radioList)
		{
		  if (radioList[i] == val)
		  {
			radioList[i].selected = true;
		  }
		}
	}
/**
* @private
*  set the label placement of all the group 
*/	
	function set labelPlacement(pos:String)
	{
		for (var i in radioList)
		{
			radioList[i].setLabelPlacement(pos);
		}
	}
/**
* get the label placement of the group 
* @tiptext Gets or sets the label placement of the group
* @helpid 3432
*/		
	function get labelPlacement():String
	{
		var r;
		for (var i in radioList)
		{
			r = radioList[i].getLabelPlacement();
		}
		return r;
	}
/**
* @private
*  set the enabled state of the group 
*/	
	function set enabled(val:Boolean)
	{
		for (var i in radioList){
			radioList[i].enabled = val;
		}
	}
/**
* @tiptext Gets or sets the enabled state of the group
* @helpid 3167
*/	function get enabled():Boolean
	{
		var s:Number = 0;	
		for (var i in radioList)
		{
			 s = s + radioList[i].enabled;
		}
		if (s == 0)
		{
			return false;
		}
		if (s ==  radioList.length)
		{
			return true;
		}
	}
} 
