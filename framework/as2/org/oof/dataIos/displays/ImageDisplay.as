/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.dataIos.Display;

/** This component displays an Image. Useful for slideshows. 
 *  
 * see org.oof.dataIos.display to see how to configure this component. The only additional
 * properties are keepImageProportions and timeForEachSlide.
 * 
* @author Ariel Sommeria-klein
 * */
class org.oof.dataIos.displays.ImageDisplay extends Display{
	
	/** 
	 * Group: constants (internal)
	 * */
	static var ALIGN_LEFT:String = "left";
	static var ALIGN_CENTER:String = "center";
	static var ALIGN_RIGHT:String = "right";
	static var ALIGN_TOP:String = "top";
	static var ALIGN_MIDDLE:String = "middle";
	static var ALIGN_BOTTOM:String = "bottom";
	
	// additional events specific to the ImageDisplay
	static var EVENT_MEDIA_SIZED:String = "mediaSized";
	
	//screen movieclip in base class contains containerMc
	private var _mcLoader:MovieClipLoader = null;
	private var _keepImageProportions:Boolean = false;		
	private var _timerId:Number = 0;
	private var _tickCount:Number = 0;
	private var _tickInterval:Number = 50;
	private var _bytesLoaded:Number = 0;
	private var _bytesTotal:Number = 0;
	private var _verticalAlign:String;
	private var _horizontalAlign:String;
	
	/** constructor
	*/
	public function ImageDisplay(){
		super();
		_className = "org.oof.dataIos.displays.ImageDisplay";
		typeArray.push(_className);
		_mcLoader = new MovieClipLoader();
		_mcLoader.addListener(this);
	}

	private function onTimer(){
		if(playerState != PLAYER_STATE_PAUSE){
			_tickCount++;
		}
		if(_tickCount * _tickInterval > streamDuration * 1000){
			clearInterval(_timerId);
			haltPlayback();
			playerState = PLAYER_STATE_END;
		}
	}
	private function loadMediaFile(url:String){
		_mcLoader.unloadClip(screen.containerMc);
		if(!_mcLoader.loadClip(url, screen.containerMc)){
			_errorMessage = "loadClip error. _mcLoader : " + _mcLoader + ", url : " + url + ", screen.containerMc" + screen.containerMc;
			playerState = PLAYER_STATE_ERROR;
		}
	}
	
	private function haltPlayback(){
		super.haltPlayback();
		_tickCount = 0;
		clearInterval(_timerId);
	 }
	///////////////////////////////////////
	//listeners for the mcloader
	///////////////////////////////////////
	function onLoadComplete(target_mc:MovieClip, httpStatus:Number){
		super.onLoadComplete();
		//if error in http, onLoadError called. why httpstatus ? ignored here.
		if(_streamDuration > 0){
			clearInterval(_timerId);
			_timerId = setInterval(this, "onTimer", _tickInterval); 
		}
	}
	
	function onLoadProgress(target:MovieClip, bytesLoaded:Number, bytesTotal:Number):Void {
		_bytesLoaded = bytesLoaded;
		_bytesTotal = bytesTotal;
	}

	function onLoadInit(mc:MovieClip) {
		size();
		// playerState = PLAYER_STATE_INIT;
	}	
	
	function onLoadError(target_mc:MovieClip, errorCode:String, httpStatus:Number) {
		_errorMessage = "onLoadError, errorCode: " + errorCode + ",  httpStatus: " + httpStatus;
		playerState = PLAYER_STATE_ERROR;
	}
	
	function getBytesLoaded():Number{
		return _bytesLoaded;
	}

	function getBytesTotal():Number{
		return _bytesTotal;
	}
	
	function set position(val:Number){
		_tickCount = val * (streamDuration * 1000) / _tickInterval;
	}
	
	function get position():Number{
		return _tickCount * _tickInterval / (streamDuration * 1000);
	}

	///////////////////////////////////////
	//UICOmponent Methods
	///////////////////////////////////////
	
	function size()
	{
		var container:MovieClip = screen.containerMc;
		
		if(!_keepImageProportions)
		{
			container._width = width;
			container._height = height;
		}
		else
		{
			var widthProp = width / container._width;
			var heightProp = height / container._height;
			var resizeProp = Math.min(widthProp, heightProp);
			
			if(widthProp <  heightProp)
			{
				container._width *= widthProp;
				container._height *= widthProp;
			}
			else
			{
				container._width *= heightProp;
				container._height *= heightProp;
			}
			
			switch(_horizontalAlign)
			{
				case ALIGN_LEFT :
					container._x = 0;
					break;
				case ALIGN_RIGHT :
					container._x = width - container._width;
					break;
				default :
					//center
					container._x = (width - container._width) / 2;
			}
			
			switch(_verticalAlign)
			{
				case ALIGN_TOP :
					container._y = 0;
					break;
				case ALIGN_BOTTOM :
					container._y = height - container._height;
					break;
				default :
					//middle
					container._y = (height - container._height) / 2;
			}
		}
		
		// dispatch event if other UI components properties depend on the sized media dimensions
		dispatch({target:this, type:EVENT_MEDIA_SIZED});
	}
	
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	

	/** 
	 * property: keepImageProportions
	 * the image display will keep image proportions unless you set this to true.
	 * */
	[Inspectable(name="keep proportions", type=Boolean, defaultValue=true)]
	public function set keepImageProportions(val:Boolean){
		_keepImageProportions = val;
	}
	

	public function get keepImageProportions():Boolean{
		return _keepImageProportions;
	}

	/** 
	 * property: timeForEachSlide
	 * the image display will keep play each slide for a fixed number of seconds, set here.
	 * the default is 99999999999, which is more or less infinite.
	 * */
	[Inspectable(name="slide duration",type=Number, defaultValue=99999999999)]
	public function set timeForEachSlide(val:Number){
		streamDuration = val;
	}
	

	public function get timeForEachSlide():Number{
		return streamDuration;
	}

	/** 
	 * property: horizontalAlign
	 * when keepProportion is enabled and the image's width is smaller than the ImageDisplay component's width, this property lets you decide if the image must be horizontally aligned to the left, center or to the right of the ImageDisplay component.
	 * Default is center.
	 */
	[Inspectable(name="horizontal align",type=String, defaultValue="center")]
	public function set horizontalAlign(val:String){
		_horizontalAlign = val;
	}
	

	public function get horizontalAlign():String{
		return _horizontalAlign;
	}

	/** 
	 * property: verticalAlign
	 * when keepProportion is enabled and the image's height is smaller than the ImageDisplay component's height, this property lets you decide if the image must be vertically aligned to the top, middle or to the bottom of the ImageDisplay component.
	 * Default is middle.
	 */
	[Inspectable(name="vertical align",type=String, defaultValue="middle")]
	public function set verticalAlign(val:String){
		_verticalAlign = val;
	}
	

	public function get verticalAlign():String{
		return _verticalAlign;
	}
	
}