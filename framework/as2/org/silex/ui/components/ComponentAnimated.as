/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 *
 * Name : Animated.as
 * Package : ui.components
 * Version : 1
 * Date :  2008-13-02
 */
 
import org.silex.core.Utils;
import mx.transitions.Tween;
import mx.transitions.easing.*;

class org.silex.ui.components.ComponentAnimated extends org.silex.ui.components.ComponentBase {
	
	var HIDE_CHILD_ANIM_NAME:String="hideChild_mc";
	var SHOW_CHILD_ANIM_NAME:String="showChild_mc";
	var HIDE_CONTENT_ANIM_NAME:String="hideContent_mc";
	var SHOW_CONTENT_ANIM_NAME:String="showContent_mc";
	
	var CLICKABLE_BUTTON_NAME:String="clickable_btn";

	// constants
	var interval_num:Number;
	var delay_num :Number;


	/* clickable
	 * if not clickable, onRelease, onRollOver... are not used
	 * workaround the fact that some swf may be over other and should not disturb roll over etc
	 */
	var _clickable:Boolean;
	function get clickable():Boolean{
		return _clickable; 
	}
	function set clickable(val:Boolean){
		// target bg_mc or  bg_mc.clickable_btn
		var target_obj:MovieClip;
		if (bg_mc[CLICKABLE_BUTTON_NAME]){
			target_obj=bg_mc[CLICKABLE_BUTTON_NAME];
		}
		else {
			target_obj=bg_mc;
		}
		// apply change
		if (val==true){
			//events buttons
			target_obj.onRelease 	= Utils.createDelegate(this, _onRelease);
			target_obj.onPress 	= Utils.createDelegate(this, _onPress);
			target_obj.onRollOver  = Utils.createDelegate(this, _onRollOver);
			target_obj.onRollOut 	= Utils.createDelegate(this, _onRollOut);
		}
		_clickable=val;
	}

	/* bg_mc
	 * button bg
	 * may be a MovieClip or a Button
	 */
	var bg_mc;
	
	/**
	 * stores label after reveal accessors
	 * it is not stored in xml files of silex
	 */
	var labelAfterRevealAccessors:String;
	/**
	 * setter and getter for label
	 * it sets the labelAfterRevealAccessors variable
	 * it is stored in silex xml files
	 */
	private var _label:String;
	public function get label():String
	{
		return _label;
	}
	public function set label(val:String)
	{
		_label = val;
		labelAfterRevealAccessors = silexInstance.utils.revealAccessors(val,this);
	}
	
	// __width and __height are used to store width an height while media may not be loaded yet
	var __width:Number;
	var __height:Number;
	
	/**
	 * constructor
	 */
	function ComponentAnimated(){
	}
	
	
	/**
	 * onLoad 
	 */
	function onLoad(){
		//call parent
		super.onLoad()
		//Add sequencer
		//silexInstance.sequencer.addItem(this,Utils.createDelegate(this,startTimer));
	}

	
	
	function _initialize() {
		//parent
		super._initialize()		
		
		
		//editableProperties
		this.editableProperties.unshift(
			{ name :"followMouse" ,		description:"PROPERTIES_LABEL_FOLLOW_MOUSE", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN	, defaultValue: false, isRegistered:true, group:"parameters"	},
			{ name :"easingDuration" ,		description:"PROPERTIES_LABEL_EASING_DURATION", 				type: silexInstance.config.PROPERTIES_TYPE_NUMBER	, defaultValue: 3, isRegistered:true, group:"parameters"	},
			{ name :"clickable" ,		description:"PROPERTIES_LABEL_CLICKABLE", 				type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN	, defaultValue: true, isRegistered:true, group:"parameters"	},
			{ name :"useHandCursor" , 	description:"PROPERTIES_LABEL_SHOW_HAND_ON_ROLLOVER", 	type: silexInstance.config.PROPERTIES_TYPE_BOOLEAN		, defaultValue: false	, isRegistered:true, group:"attributes" },
			{ name :"delay" , 		description:"PROPERTIES_LABEL_DELAYED_APPARITION_MS", 			type: silexInstance.config.PROPERTIES_TYPE_NUMBER, 			defaultValue: 0		, minValue:0,  		maxValue:10000,	isRegistered:true, group:"parameters" },
			{ name :"imageUrl" , 		description:"PROPERTIES_LABEL_IMAGE_URL", 			type: silexInstance.config.PROPERTIES_TYPE_URL, 			defaultValue: "media/"		, isRegistered:true, group:"attributes" },
			{ name :"label" , 		description:"PROPERTIES_LABEL_LABEL", 			type:"Text", 			defaultValue: "label"		, isRegistered:true, group:"attributes" }
		);	
		
	}
	

	 
	
	/**
	 * function redraw
	 * @return void
	 */
	function redraw(){
		// target bg_mc or  bg_mc.clickable_btn
		var target_obj:MovieClip;
		if (bg_mc[CLICKABLE_BUTTON_NAME]){
			target_obj=bg_mc[CLICKABLE_BUTTON_NAME];
		}
		else {
			target_obj=bg_mc;
		}
		//usehandcursor
		if(!this.useHandCursor){
			target_obj.useHandCursor = false;
		}else{
			target_obj.useHandCursor = true;
		}
	}
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// resize
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
		
	/**
	 * function set/get width
	 * @param 	Number		
	 * @return  void|Number
	 */ 
	function set width( value_num:Number):Void{
		__width=value_num;
		bg_mc._width = value_num;
		//refresh
		redraw()
	}
	
	function get width ():Number{
		return __width;
	}
	
	
	
	/**
	 * function set/get height
	 * @param 	Number		
	 * @return  void|Number
	 */ 
	function set height( value_num:Number):Void{
		__height=value_num;
		bg_mc._height = value_num;
		//refresh
		redraw()
	}
	
	function get height ():Number{
		return __height;
	}

	
	/**
	 * set/get scale
	 * @param 	Number		
	 * @return  void|Number
	 */
	function set scale( numValue:Number):Void{
		this.bg_mc._xscale = numValue;
		this.bg_mc._yscale = numValue;
		width = this.bg_mc._width 
		height = this.bg_mc._height
		//refresh
		redraw()
	}
	
	function get scale():Number{
		return Math.round( this.bg_mc._xscale + this.bg_mc._yscale)/2;
	}
		
	
	/**
	 * set/get rotation
	 * @param 	Number		show/hide
	 * @return  void|Number
	 */ 
	 
	public function set rotation( rotationNumber:Number):Void{
		this.bg_mc._rotation = rotationNumber;
		//refresh
		redraw();
	}
	
	public function get rotation():Number{
		return this.bg_mc._rotation;
	}
	
	/**
	 * function set/get useHandcursor
	 * @param 	Boolean		
	 * @return  void|Boolean
	 */
	function set useHandcursor( value_bool:Boolean):Void{
		bg_mc.useHandCursor = value_bool;
		redraw();
	}
	
	function get useHandcursor ():Boolean{
		return bg_mc.useHandCursor;
	}
	
	///////////////////////////////////////////////////////////////////////
	
	/**
	 * 
	 */
	function set delay( value_number:Number):Void{
		this.delay_num = value_number;
	}
	function get delay():Number{
		return this.delay_num;
	}
	/**
	 * 
	 */
	var _followMouse:Boolean=false;
	var easingDuration:Number=3;
	var rotation_tween:Tween;
	var easingFunction:Function;
	var previousRotation:Number;
	function set followMouse(value_bool:Boolean):Void{
		_followMouse = value_bool;
		
		var easingFunctions_array=[Back.easeIn,Back.easeOut,Back.easeInOut,Bounce.easeIn,Bounce.easeOut,Bounce.easeInOut,Elastic.easeIn,Elastic.easeOut,Elastic.easeInOut,Regular.easeIn,Regular.easeOut,Regular.easeInOut,Strong.easeIn,Strong.easeOut,Strong.easeInOut,None];
		easingFunction=easingFunctions_array[Math.floor(Math.random()*easingFunctions_array.length-1)];
		if (_followMouse==true)
			onMouseMove=_onMouseMove;
		else
			onMouseMove=undefined;
	}
	function get followMouse():Boolean{
		return _followMouse;
	}
	function _onMouseMove(){
		var rot:Number;
		if (!silexInstance.authentication.isLoggedIn()){
			rot=-45+Math.atan2(_ymouse,_xmouse)*180/Math.PI;
			if (Math.abs(bg_mc._rotation-(rot-360))<Math.abs(bg_mc._rotation-rot)) rot-=360;
			else if (Math.abs(bg_mc._rotation-(rot+360))<Math.abs(bg_mc._rotation-rot)) rot+=360;
		}
		else
			rot=0;
			
		if (rot!=previousRotation){
			previousRotation=rot;
			if (rotation_tween) rotation_tween.continueTo(rot);
			else
				rotation_tween=new Tween(bg_mc, "_rotation", easingFunction, bg_mc._rotation, rot, easingDuration, true);
		}
	}
	/**
	 * override _hideContent UiBase
	 */
	function _hideChild(){
		super._hideChild();

		//Start anim
		bg_mc[HIDE_CHILD_ANIM_NAME].play();
	}
	
	/**
	 * override _showContent UiBase
	 */
	function _showChild(){
		 super._showChild();
		//Start anim
		bg_mc[SHOW_CHILD_ANIM_NAME].play();
	 }
	/**
	 * override _showContent UiBase
	 */
	function _showContent(){
		 super._showContent();
		//Start timer
		startTimer();
	 }
	
	/**
	 * override _hideContent UiBase
	 */
	function _hideContentStart(){
		super._hideContentStart();
		
		hasBeenShown = false;
		//Start anim
		bg_mc[HIDE_CONTENT_ANIM_NAME].play();
	}
	
	
	/**
	 * startTimer
	 */
	function startTimer(){
		//set interval with delay
		if (delay_num>0)
			interval_num = setInterval(this,'startShowAnim', delay_num );		
		else
			startShowAnim();

	}
	
	
	/**
	 * startShowAnim
	 */
	var hasBeenShown:Boolean=false;
	function startShowAnim(){
		//clear interval
		clearInterval(interval_num);

		if (hasBeenShown==true) return;
		hasBeenShown=true;
		
		//Start anim
		bg_mc[SHOW_CONTENT_ANIM_NAME].play();
	}
	
		
	
	
	
	///////////////////////////////////////////////////////////////	


	/**
	 * function _onRelease
	 * @return 	void
	 */
	function _onRelease():Void{

		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_RELEASE ,target:this });
	}
	
	/**
	 * function _onPress
	 * @return 	void
	 */	
	function _onPress():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_PRESS ,target:this });
	}
	
	/**
	 * function _onRollOver
	 * @return 	void
	 */
	function _onRollOver():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOVER ,target:this });
	}
	
	/**
	 * function _onRollOut
	 * @return 	void
	 */	
	function _onRollOut():Void{
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_ROLLOUT ,target:this });
	}
	
	///////////////////////////////////////////////////////////////	

	// **
	// override PlayerBase class :
	// setGlobalCoordTL sets coordinates of the media
	// it substracts the registration point coords to coord
	// and apply the new coordinates to the player
	function setGlobalCoordTL(coord:Object){
		// to local
		layerInstance.globalToLocal(coord);
		
		// apply the new coordinates to the player
		_x=coord.x;
		_y=coord.y;
	}
	function setGlobalCoordBR(coord:Object){
		// to local
		layerInstance.globalToLocal(coord);
		// get width and height
		coord.x=coord.x-_x;
		coord.y=coord.y-_y;

		// apply the new coordinates to the player
		width=coord.x;
		height=coord.y;
	}
	function getGlobalCoordTL(){
		// from global coords
		var coordTL:Object={x:_x,y:_y};
	
		// to global
		layerInstance.localToGlobal(coordTL);
		
		return coordTL;
	}
	function getGlobalCoordBR(){
		// from global coords
		var coordBR:Object={x:width+_x,y:height+_y};
	
		// to global
		layerInstance.localToGlobal(coordBR);
		
		return coordBR;
	}
	
/*	//override abstract method
	function getHtmlTags(url_str:String):Object {
		var res_obj:Object=new Object;
		res_obj.keywords=descriptionText;
		res_obj.description=descriptionText;
		res_obj.htmlEquivalent=null;
		return res_obj;
	}*/

///////////////////////////////////////////////////////////////////	
	
	public function loadMedia(url:String):Void{
	}
	
	
	
	/**
	 * implementations interface 
	 * @return  void
	 */
	public function unloadMedia():Void {
	}
	
}