/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is a user interface for displays that handles play, pause, stop, jumping to
 * content in a stream etc. This needs to evolve quite a bit as you cannot position
 * elements separately in silex and are therefore you are stuck to a flash design.
 * @author Ariel Sommeria-klein
 * */

import org.oof.OofBase;
import org.oof.dataIos.Display;
import org.oof.ui.elements.ScrollUi;
import mx.utils.Delegate;
import org.oof.ui.elements.ProgressBar;
import org.oof.util.TimeFormat;
import mx.transitions.Tween;
import mx.transitions.easing.*;

class org.oof.ui.DisplayUi extends OofBase{
	static private var className:String = "org.oof.dataIos.Display";

	private var _display:Display = null;
	private var _displayPath:String = null;
	private var _unmutedVolume:Number = 0;
	
	// UI
	var play_btn:Button;
	var pause_btn:Button;
	var stop_btn:Button;
	var mute_btn:MovieClip;
	var unmute_btn:MovieClip;
	var volumeCtrl:ScrollUi;
	var positionCtrl:ScrollUi;
	var loadProgressBar: ProgressBar;
	var duration_txt:TextField;
	var position_txt:TextField;
	
	public function DisplayUi():Void
	{
		typeArray.push("org.oof.dataIos.Display");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		mute_btn._visible = true;
		unmute_btn._visible = false;
		pause_btn._visible = false;
		tryToLinkWith(_displayPath, Delegate.create(this, doOnDisplayFound));
	 }
	 
	 /** function doOnDisplayFound
	*@returns void
	*/
	function doOnDisplayFound(oofComp:OofBase){
		_display = Display(oofComp);
		_display.addEventListener(Display.EVENT_PLAY, Delegate.create(this, updateUi));
		_display.addEventListener(Display.EVENT_PAUSE, Delegate.create(this, updateUi));
		_display.addEventListener(Display.EVENT_STOP, Delegate.create(this, updateUi));
		_display.addEventListener(Display.EVENT_END, Delegate.create(this, updateUi));
		_display.addEventListener(Display.EVENT_DURATIONKNOWN, Delegate.create(this, setMediaDuration));
		// UI init
		play_btn.onRelease = Delegate.create(_display, _display.playMedia);
		pause_btn.onRelease = Delegate.create(_display, _display.pauseMedia);
		stop_btn.onRelease = Delegate.create(_display, _display.stopMedia);
		
		// mute
		mute_btn.onRelease = Delegate.create(this, muteMedia);
		unmute_btn.onRelease = Delegate.create(this, unmuteMedia);
		//volume
		volumeCtrl.onChange = Delegate.create(this, onVolumeChange);
		
		//load progress
		//loadProgressBar.mode = "polled";
		loadProgressBar.source = _display;
		//loadProgressBar.addEventListener("complete", Delegate.create(this, loadComplete));
		
		//position
		positionCtrl.onChange = Delegate.create(this, onPositionChange);
		updateUi();		
	}
	
	function loadComplete(){
		//loadProgressBar.visible = false;
	}
	
	function onVolumeChange(){
		_display.volume = volumeCtrl.position * 100;
		
	}
	
	
	function muteMedia(){
		_unmutedVolume = _display.volume;
		_display.volume = 0;
		unmute_btn._visible = true;
		mute_btn._visible = false;

	}

	function unmuteMedia(){
		_display.volume = _unmutedVolume;
		mute_btn._visible = true;
		unmute_btn._visible = false;

	}
	
	function onPositionChange(){
		_display.position = positionCtrl.position;
	}
	
	function onEnterFrame(){
		var pos = _display.position;
		position_txt.text = TimeFormat.format(pos * _display.streamDuration);
		positionCtrl.position = pos;
	}
		
	
	///////////////////////////////////////
	//listeners for the display's events, set the display state
	///////////////////////////////////////
	function updateUi(evtObj:Object){
		if(evtObj.type == Display.EVENT_PLAY){
			play_btn._visible = false;
			pause_btn._visible = true;
		}else{
			play_btn._visible = true;
			pause_btn._visible = false;
		}
		
		volumeCtrl.position = _display.volume / 100;
	}
	
	function setMediaDuration(){
		duration_txt.text = TimeFormat.format(_display.streamDuration);
	}

	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** function set displayPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="display", type=String, defaultValue="")]
	public function set displayPath(val:String){
		_displayPath = val;
	}
	
	/** function get displayPath
	* @returns String
	*/
	
	public function get displayPath():String{
		return _displayPath;
	}		

	
}