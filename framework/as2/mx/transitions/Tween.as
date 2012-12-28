//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.BroadcasterMX;
import mx.transitions.OnEnterFrameBeacon;

class mx.transitions.Tween {

//#include "Version.as"

	static var __initBeacon = OnEnterFrameBeacon.init();
	static var __initBroadcaster = BroadcasterMX.initialize (Tween.prototype, true);

	public var isPlaying:Boolean;
	public var addListener:Function;
	public var removeListener:Function;
	public var broadcastMessage:Function;

	public var onMotionFinished:Function;
	public var onMotionLooped:Function;
	public var onMotionChanged:Function;
	public var onMotionStarted:Function;
	public var onMotionStopped:Function;
	public var onMotionResumed:Function;

	public var obj:Object;
	public var prop:String;
	public var func:Function = function (t, b, c, d) { return c*t/d + b; };
	public var begin:Number;
	public var change:Number;
	public var useSeconds:Boolean;
	public var prevTime:Number;
	public var prevPos:Number;
	public var looping:Boolean;

	
	private var _listeners:Array;
	private var _duration:Number;
	private var _time:Number;
	private var _pos:Number;
	private var _fps:Number;
	private var _position:Number;
	private var _startTime:Number;
	private var _intervalID:Number;
	private var _finish:Number;




	function set time (t:Number):Void {
		this.prevTime = this._time;
		if (t > this.duration) {
			if (this.looping) {
				this.rewind (t - this._duration);
				this.update();
				this.broadcastMessage ("onMotionLooped", this);
			} else {
				if (this.useSeconds) {
					this._time = this._duration;
					this.update();
				}
				this.stop();
				this.broadcastMessage ("onMotionFinished", this);
			}
		} else if (t < 0) {
			this.rewind();
			this.update();
		} else {
			this._time = t;
			this.update();
		}
	}
	
	function get time ():Number {
		return this._time;
	}
	

	function set duration (d:Number):Void {
		this._duration = (d == null || d <= 0) ? _global.Infinity : d;
	}
	
	function get duration ():Number {
		return this._duration;
	}
	
	
	

	function set FPS (fps:Number):Void {
		var oldIsPlaying = this.isPlaying;
		this.stopEnterFrame();
		this._fps = fps;
		if (oldIsPlaying) {
			this.startEnterFrame();
		}
	}

	function get FPS ():Number {
		return this._fps;
	}

	function set position (p:Number):Void {
		this.setPosition (p);
	}
	
	function setPosition (p:Number):Void {
		this.prevPos = this._pos;
		this.obj[this.prop] = this._pos = p;
		this.broadcastMessage ("onMotionChanged", this, this._pos);	
		// added updateAfterEvent for setInterval-driven motion
		updateAfterEvent();
	}

	
	
	function get position ():Number {
		return this.getPosition();
	};
	function getPosition (t:Number):Number {
		if (t == undefined) t = this._time;
		return this.func (t, this.begin, this.change, this._duration);
	};
	
	function set finish (f:Number):Void {
		this.change = f - this.begin;
	};
	
	function get finish ():Number {
		return this.begin + this.change;
	};
	
/////////////////////////////////////////////////////////////////////////

/*  constructor for Tween class

	obj: reference - the object which the Tween targets
	prop: string - name of the property (in obj) that will be affected
	begin: number - the starting value of prop
	duration: number - the length of time of the motion; set to infinity if negative or omitted
	useSeconds: boolean - a flag specifying whether to use seconds instead of frames
*/
	function Tween (obj, prop, func, begin, finish, duration, useSeconds) {
		OnEnterFrameBeacon.init();
		if (!arguments.length) return;
		this.obj = obj;
		this.prop = prop;
		this.begin = begin;
		this.position = begin;
		this.duration = duration;
		this.useSeconds = useSeconds;
		if (func) this.func = func;
		this.finish = finish;
		this._listeners = [];
		this.addListener (this);
		this.start();
	}

	function continueTo (finish:Number, duration:Number):Void {
		this.begin = this.position;
		this.finish = finish;
		if (duration != undefined)
			this.duration = duration;
		this.start();
	};
	
	function yoyo ():Void {
		this.continueTo (this.begin, this.time);
	};
	
	function startEnterFrame ():Void {
		if (this._fps == undefined) {
			// original frame rate dependent way
			_global.MovieClip.addListener (this);
		} else {
			// custom frame rate
			this._intervalID = setInterval (this, "onEnterFrame", 1000 / this._fps);
		}
		this.isPlaying = true;
	}
	
	function stopEnterFrame ():Void {
		if (this._fps == undefined) {
			// original frame rate dependent way:
			_global.MovieClip.removeListener (this);
		} else {
			// custom frame rate
			clearInterval (this._intervalID);
		}
		this.isPlaying = false;
	}
	
	function start ():Void {
		this.rewind();
		this.startEnterFrame();
		this.broadcastMessage ("onMotionStarted", this);
	}
	
	function stop ():Void {
		this.stopEnterFrame();
		this.broadcastMessage ("onMotionStopped", this);
	}
	
	function resume ():Void {
		this.fixTime();
		this.startEnterFrame();
		this.broadcastMessage ("onMotionResumed", this);
	}
	
	function rewind (t):Void {
		this._time = (t == undefined) ? 0 : t;
		this.fixTime();
		this.update(); // added Mar. 18, 2003
	}
	
	function fforward ():Void {
		this.time = this._duration;
		this.fixTime();
	}
	
	function nextFrame ():Void {
		if (this.useSeconds) {
			this.time = (getTimer() - this._startTime) / 1000;
		} else {
			this.time = this._time + 1;
		}
	}

	function onEnterFrame ():Void {
		this.nextFrame();
	}


	function prevFrame ():Void {
		if (!this.useSeconds) this.time = this._time - 1;
	}
	
	function toString ():String {
		return "[Tween]";
	}

	///////// PRIVATE METHODS

	private function fixTime ():Void {
		if (this.useSeconds) 
			this._startTime = getTimer() - this._time*1000;
	}
	
	private function update ():Void {
		this.position = this.getPosition (this._time);
	}

}

