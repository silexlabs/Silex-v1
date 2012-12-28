//****************************************************************************
//Copyright (C) 2003-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

class mx.transitions.easing.Strong {

//#include "../Version.as"

	static function easeIn (t:Number, b:Number, c:Number, d:Number):Number {
		return c*(t/=d)*t*t*t*t + b;
	}
	static function easeOut (t:Number, b:Number, c:Number, d:Number):Number {
		return c*((t=t/d-1)*t*t*t*t + 1) + b;
	}
	static function easeInOut (t:Number, b:Number, c:Number, d:Number):Number {
		if ((t/=d/2) < 1) return c/2*t*t*t*t*t + b;
		return c/2*((t-=2)*t*t*t*t + 2) + b;
	}
}
