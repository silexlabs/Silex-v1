/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.dataIos.Display;
/** This component displays HTML, as interpreted by Flash. 
 * The Flash HTML interpreter is pretty limited, be warned.
 * see org.oof.dataIos.display to see how to configure this component. The only additional
 * properties are timeForEachSlide, autosize and wordwrap.
 * 
 * @author Ariel Sommeria-klein
 * */

class org.oof.dataIos.displays.RichTextDisplay extends Display{
	static private var className:String = "org.oof.dataIos.displays.RichTextDisplay";
	
	//screen movieclip in base class contains ioTextField
	//setting _txt.htmlText doesn't work properly. So use _txt.variable as a workaround
	var textHolder:String;
	
	private var _timerId:Number = 0;
	private var _tickCount:Number = 0;
	private var _tickInterval:Number = 50;

	/** constructor
	*/
	public function RichTextDisplay(){
		super();
		_className = "org.oof.dataIos.displays.RichTextDisplay";
		typeArray.push(_className);
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		screen.ioTextField.variable = "textHolder";
		
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
		if(url == null){
			playerState = PLAYER_STATE_ERROR;
		}
		screen.ioTextField.text = url;
		screen._alpha = 100;
		if(_streamDuration > 0){
			_timerId = setInterval(this, "onTimer", _tickInterval); 
		}
		return;
	}
	
	function reset(){
		super.haltPlayback();
		_tickCount = 0;
		clearInterval(_timerId);
	 }	
	function getBytesLoaded():Number{
		return 1;
	}

	function getBytesTotal():Number{
		return 1;
	}
	
	function set position(val:Number){
		_tickCount = val * (streamDuration * 1000) / _tickInterval;
	}
	
	function get position():Number{
		return _tickCount * _tickInterval / (streamDuration * 1000);
	}
	
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** 
	 * property: timeForEachSlide
	 * the image display will keep play each slide for a fixed number of seconds, set here.
	 * the default is 99999999999, which is more or less infinite.
	 * */
	[Inspectable(name="slideshow duration",type=Number, defaultValue=0)]
	public function set timeForEachSlide(val:Number){
		_streamDuration = val;
	}
	
	public function get timeForEachSlide():Number{
		return _streamDuration;
	}	

	
	/**
	 * property: autosize
	 * the autosize property of the wrapped textfield.
	 * see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextField.html 
	 * */
	[Inspectable(name="auto size", type=Object, defaultValue="right", enumeration="none, left, right, center")]
	public function set autoSize(val:Object){
		screen.ioTextField.autoSize = val;
	}

	
	public function get autoSize():Object{
		return screen.ioTextField.autoSize;
	}	
	
	/**
	 * property: wordWrap
	 * the wordWrap property of the wrapped textfield.
	 * see http://livedocs.adobe.com/flash/9.0/ActionScriptLangRefV3/flash/text/TextField.html 
	 * */
	[Inspectable(name="word wrap", type=Boolean, defaultValue=true)]
	public function set wordWrap(val:Boolean){
		screen.ioTextField.wordWrap = val;
	}

	
	public function get wordWrap():Boolean{
		return screen.ioTextField.wordWrap;
	}	
	
	
}