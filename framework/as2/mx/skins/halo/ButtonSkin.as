//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.RectBorder;
import mx.skins.SkinElement;
import mx.core.ext.UIObjectExtensions;

class mx.skins.halo.ButtonSkin extends RectBorder
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "ButtonSkin";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.halo.ButtonSkin;

/**
* name of this class
*/
	var className = "ButtonSkin";

	var backgroundColorName = "buttonColor";

	var drawRoundRect:Function;

	function ButtonSkin()
	{
	}

	function init():Void
	{
		super.init();
	}

	function size():Void
	{
		drawHaloRect(width,height);
	}

	function drawHaloRect(w:Number,h:Number):Void
	{
		var borderStyle = getStyle("borderStyle");
		var themeCol = getStyle("themeColor");
		var emph:Boolean = _parent.emphasized;
		clear();
		switch (borderStyle) {
			case "falseup":
			if (emph)
			{
				drawRoundRect( x,y,w,h,5,0x919999,100);//OuterBorder
				drawRoundRect( x,y,w,h,5,themeCol,75);//OuterBorder
				drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xffffff],85,0,"radial");
				drawRoundRect( x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
				drawRoundRect( x+2,y+2,w-4,h-4,3,themeCol,75);
				drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
				drawRoundRect( x+3,y+4,w-6,h-7,2,0xf8f8f8,100);//face
			}
			else
			{
				drawRoundRect( 0,0,w,h,5,0x919999,100);//OuterBorder
				drawRoundRect( 1,1,w-2,h-2,4,[0xcad1d1,0xf7f7f7],100,0,"radial");
				drawRoundRect( 2,2,w-4,h-4,3,[0x919999,0xd2dada],100,0,"radial");
				drawRoundRect( 3,3,w-6,h-6,2,0xffffff,100);//highlight
				drawRoundRect( 3,4,w-6,h-7,2,0xf8f8f8,100);//face
			}
			break;
			case "falsedown":
			drawRoundRect( x,y,w,h,5,0x919999,100);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xfcfcfc],100,0,"radial");
			drawRoundRect( x+1,y+1,w-2,h-2,4,themeCol,50);
			drawRoundRect( x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( x,y,w,h,5,themeCol,40);//OuterBorder
			drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,2,themeCol,20);//face
			break;
			case "falserollover":
			drawRoundRect( x,y,w,h,5,0x919999,100);//OuterBorder
			drawRoundRect( x,y,w,h,5,themeCol,50);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xffffff],100,0,"radial");
			drawRoundRect( x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( x+2,y+2,w-4,h-4,3,themeCol,50);
			drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,2,0xf8f8f8,100);//face
			break;
			case "falsedisabled":
			drawRoundRect( 0,0,w,h,5,0xc8cccc,100);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,4,0xf2f2f2,100);
			drawRoundRect( 2,2,w-4,h-4,3,0xd4d9d9,100);
			drawRoundRect( 3,3,w-6,h-6,2,0xf2f2f2,100);//face
			break;
			case "trueup":
			drawRoundRect( x,y,w,h,5,0x999999,100);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xfcfcfc],100,0,"radial");
			drawRoundRect( x+1,y+1,w-2,h-2,4,themeCol,50);
			drawRoundRect( x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( x,y,w,h,5,themeCol,40);//OuterBorder
			drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,2,0xf7f7f7,100);//face
			break;
			case "truedown":
			drawRoundRect( x,y,w,h,5,0x999999,100);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xfcfcfc],100,0,"radial");
			drawRoundRect( x+1,y+1,w-2,h-2,4,themeCol,50);
			drawRoundRect( x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( x,y,w,h,5,themeCol,40);//OuterBorder
			drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,2,themeCol,20);//face
			break;
			case "truerollover":
			drawRoundRect( x,y,w,h,5,0x919999,100);//OuterBorder
			drawRoundRect( x,y,w,h,5,themeCol,50);//OuterBorder
			drawRoundRect( x+1,y+1,w-2,h-2,4,[0x333333,0xffffff],100,0,"radial");
			drawRoundRect( x+1,y+1,w-2,h-2,4,themeCol,40);
			drawRoundRect(x+2,y+2,w-4,h-4,3,[0x000000,0xdadada],100,0,"radial");
			drawRoundRect( x+2,y+2,w-4,h-4,3,themeCol,40);
			drawRoundRect( x+3,y+3,w-6,h-6,2,0xffffff,100);//highlight
			drawRoundRect( x+3,y+4,w-6,h-7,2,0xf8f8f8,100);//face
			break;
			case "truedisabled":
			drawRoundRect( 0,0,w,h,5,0xc8cccc,100);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,4,0xf2f2f2,100);
			drawRoundRect( 2,2,w-4,h-4,3,0xd4d9d9,100);
			drawRoundRect( 3,3,w-6,h-6,2,0xf2f2f2,100);//face
		}
	}

	static function classConstruct():Boolean
	{
		UIObjectExtensions.Extensions();
		_global.skinRegistry["ButtonSkin"] = true;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIObjectExtensionsDependency = UIObjectExtensions;
}
