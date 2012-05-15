/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;

/**
* simple timer class with events. No autostart, no repeat. 
* This extends OofBase to have access to silex events, but doesn't need oof linking
*/

[Event("onTimer")]

class org.oof.util.SimpleTimer extends OofBase{
	
	/**
	 * group: public
	 * */
	public static var EVENT_TIMER:String = "onTimer";
	 
	//public callback for users who don't like events
	public var onTimer:Function = null;
	/**
	 * group: internal
	 * */
	 
	private var _interval:Number = 0;
	private var _timerId:Number = 0;
	//absolute: as from when the flash player started ( see getTimer doc)
	private var _doTimerTime:Number = 0;
	private var _isRunning:Boolean = false;
	 
	//for pausing
	private var _pauseTime:Number = 0;
	private var _timeSpent:Number = 0;
	private var _isPaused:Boolean = false;
		
	private function timerCallBack():Void{
		dispatch({type:EVENT_TIMER, target:this});
		if(onTimer != null){
			onTimer();
		}
		
		//clean up
		stop();
	}
	
	private function doTimer(interval:Number):Void{
		_doTimerTime = getTimer();
		//make sure we don't have an old timer still running
		clearInterval(_timerId);
		_timerId = setInterval(Delegate.create(this, timerCallBack), interval);
		_isRunning = true;
	}
	
	public function SimpleTimer(){
		typeArray.push("org.oof.util.SimpleTimer");
	}

	/**
	 * group: public
	 * */
	
	/**
	* function: start
	* start  the timer
	*/
	public function start():Void{
		_timeSpent = 0;
		doTimer(_interval);
	}
	
	/**
	* function: stop
	* stop the timer
	*/
	public function stop():Void{
		clearInterval(_timerId);
		_isRunning = false;
	}
	
	/**
	* function: pause
	* pause the timer
	*/
	public function pause():Void{
		if(_isRunning){
			stop();
			_timeSpent += getTimer() - _doTimerTime;
			_pauseTime = getTimer();
			_isPaused = true;
		}
	}
	
	/**
	* function: resume
	* stop the timer
	*/
	public function resume():Void{
		if(_isPaused){
			doTimer(_interval - _timeSpent);
			_isPaused = false;
		}
	}
	
	
	/**
	* function: togglePause
	* pause if not paused, otherwise resume
	*/
	public function togglePause():Void{
		if(_isPaused){
			resume();
		}else{
			pause();
		}
	}
	
	/** function set interval
	* @param val(Number)
	* @returns void
	*/
	[Inspectable(type=Number, defaultValue="")]
	public function set interval(val:Number){
		_interval = val;
	}
	
	/** function get interval
	* @returns Number
	*/
	
	public function get interval():Number{
		return _interval;
	}	
	
	/** function get isPaused
	* @returns Boolean
	*/
	
	public function get isPaused():Boolean{
		return _isPaused;
	}	
	
	
}