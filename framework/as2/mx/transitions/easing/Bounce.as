//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

class mx.transitions.easing.Bounce {

//#include "../Version.as"

	static function easeOut (t:Number, b:Number, c:Number, d:Number):Number {
		if ((t/=d) < (1/2.75)) {
			return c*(7.5625*t*t) + b;
		} else if (t < (2/2.75)) {
			return c*(7.5625*(t-=(1.5/2.75))*t + .75) + b;
		} else if (t < (2.5/2.75)) {
			return c*(7.5625*(t-=(2.25/2.75))*t + .9375) + b;
		} else {
			return c*(7.5625*(t-=(2.625/2.75))*t + .984375) + b;
		}
	}
	static function easeIn (t:Number, b:Number, c:Number, d:Number):Number {
		return c - mx.transitions.easing.Bounce.easeOut (d-t, 0, c, d) + b;
	}
	static function easeInOut (t:Number, b:Number, c:Number, d:Number):Number {
		if (t < d/2) return mx.transitions.easing.Bounce.easeIn (t*2, 0, c, d) * .5 + b;
		else return mx.transitions.easing.Bounce.easeOut (t*2-d, 0, c, d) * .5 + c*.5 + b;
	}
}
