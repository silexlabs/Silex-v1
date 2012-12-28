/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.util.SimpleTimer;
import mx.utils.Delegate;

/**
* adds an animation control to the timer class.
* can't simply use 'Timer' name, because compiler doesn't like it
*/


class org.oof.ui.VisualTimer extends SimpleTimer{
	
	/**
	 * group: public
	 * */
	 public static var NUM_FRAMES_IN_ANIM:Number = 100;
	/**
	 * group: internal
	 * */
	 
	 
	 //the animation we are going to drive. Has to have NUM_FRAMES_IN_ANIM frames. This could be made into a property later, maybe
	private var anim:MovieClip;	
	private var _animStopped:Boolean = false;
	
	public function VisualTimer()
	{
		typeArray.push("org.oof.util.VisualTimer");
	}
	
	/** function _initAfterRegister
	* @returns void
	*/
	public function _initAfterRegister(){
		super._initAfterRegister(); 
		if(anim){
			anim.stop();
		}
			
	}
	
	private function doTimer(interval:Number):Void{
		super.doTimer(interval);
		onEnterFrame = Delegate.create(this, onEnterFrameWhenTimerRunning);
	}
		
	private function onEnterFrameWhenTimerRunning():Void{
		if(!anim){
			return;
		}
		var newPlayHeadPos:Number = Math.round((getTimer() - _doTimerTime + _timeSpent) / _interval * NUM_FRAMES_IN_ANIM);
		anim.gotoAndStop(newPlayHeadPos);
		
	}

	/**
	 * group: public
	 * */
	
	/**
	* function: stop
	* stop the timer
	*/
	public function stop():Void{
		super.stop();
		onEnterFrame = null;
	}
	
	
}