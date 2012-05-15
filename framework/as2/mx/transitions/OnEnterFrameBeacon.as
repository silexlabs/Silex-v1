//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.transitions.BroadcasterMX;

class mx.transitions.OnEnterFrameBeacon {

//#include "Version.as"

	static function init () {
		var gmc = _global.MovieClip;
		if (!_root.__OnEnterFrameBeacon) {
			BroadcasterMX.initialize (gmc);
			var mc = _root.createEmptyMovieClip ("__OnEnterFrameBeacon", 9876);
			mc.onEnterFrame = function () {  _global.MovieClip.broadcastMessage ("onEnterFrame"); };
		}
	}
};
