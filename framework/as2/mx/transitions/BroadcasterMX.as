//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

class mx.transitions.BroadcasterMX {

//#include "Version.as"

	private var _listeners:Array;
	
	static function initialize (o:Object, dontCreateArray:Boolean) {
		if (o.broadcastMessage != undefined) delete o.broadcastMessage;
		o.addListener = mx.transitions.BroadcasterMX.prototype.addListener;
		o.removeListener = mx.transitions.BroadcasterMX.prototype.removeListener;
		if (!dontCreateArray) o._listeners = new Array();
		//_global.ASSetPropFlags (o, "addListener,removeListener,_listeners", 1);
	}

	function addListener (o:Object):Number {
		this.removeListener (o);
		if (this.broadcastMessage == undefined) {
			this.broadcastMessage = mx.transitions.BroadcasterMX.prototype.broadcastMessage;
			//_global.ASSetPropFlags (this, "broadcastMessage", 1);
		}
		return this._listeners.push(o);
	}
	
	function removeListener (o:Object):Boolean {
		var a:Array = this._listeners;	
		var i:Number = a.length;
		while (i--) {
			if (a[i] == o) {
				a.splice (i, 1);
				if (!a.length) this.broadcastMessage = undefined;
				return true;
			}
		}
		return false;
	}
	
	function broadcastMessage ():Void {
		var e:String = String(arguments.shift());
		var a:Array = this._listeners.concat();
		var l:Number = a.length;
		for (var i=0; i<l; i++) a[i][e].apply(a[i], arguments);
	}

};
