//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.skins.RectBorder;
import mx.skins.SkinElement;
import mx.core.ext.UIObjectExtensions;

class mx.skins.halo.AccordionHeaderSkin extends RectBorder
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "AccordionHeaderSkin";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = mx.skins.halo.AccordionHeaderSkin;

/**
* name of this class
*/
	var className = "AccordionHeaderSkin";

	var drawRoundRect:Function;

	function AccordionHeaderSkin()
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
		var dkCol = getStyle("textSelectedColor");

		clear();
		switch (borderStyle) {
			case "falseup":
			drawRoundRect( 0,0,w,h,0,0x8a938a,100);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100); // hilight
			gradientFill( 2,2,w-2,h-2,[0xDADADA,0xFFFFFF]); // fill
			break;
			case "falsedown":
			drawRoundRect( 0,0,w,h,0,dkCol,50);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,themeCol,100); // hilight
			drawRoundRect( 2,2,w-4,h-4,0,0xFFFFFF,100);
			drawRoundRect( 2,2,w-4,h-4,0,themeCol,20);// fill
			break;
			case "falserollover":
			drawRoundRect( 0,0,w,h,0,dkCol,50);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,themeCol,50); // hilight
			gradientFill( 2,2,w-2,h-2,[0xDADADA,0xFFFFFF]); // fill
			break;
			case "falsedisabled":
			drawRoundRect( 0,0,w,h,0,0x8a938a,100);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,0xc8cccc,60); // hilight
			gradientFill( 2,2,w-2,h-2,[0xDADADA,0xFFFFFF]); // fill
			break;
			case "trueup":
			drawRoundRect( 0,0,w,h,0,dkCol,50);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,themeCol,50); // hilight
			drawRoundRect( 2,2,w-4,h-4,0,0xFFFFFF,100);
			drawRoundRect( 2,2,w-4,h-4,0,themeCol,20);// fill
			break;
			case "truedown":
			drawRoundRect( 0,0,w,h,0,dkCol,50);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,themeCol,50); // hilight
			drawRoundRect( 2,2,w-4,h-4,0,0xFFFFFF,100);
			drawRoundRect( 2,2,w-4,h-4,0,themeCol,20);// fill
			break;
			case "truerollover":
			drawRoundRect( 0,0,w,h,0,dkCol,50);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,themeCol,50); // hilight
			drawRoundRect( 2,2,w-4,h-4,0,0xFFFFFF,100);
			drawRoundRect( 2,2,w-4,h-4,0,themeCol,20);// fill
			break;
			case "truedisabled":
			drawRoundRect( 0,0,w,h,0,0x8a938a,100);//OuterBorder
			drawRoundRect( 1,1,w-2,h-2,0,0xFFFFFF,100);
			drawRoundRect( 1,1,w-2,h-2,0,0xc8cccc,60); // hilight
			gradientFill( 2,2,w-2,h-2,[0xDADADA,0xFFFFFF]); // fill
			break;
		}
	}

	function gradientFill(x,y,w,h,c)
	{
		var alphas = [ 100, 100 ];
        var ratios = [ 0, 0xFF ];
		var matrix = { matrixType:"box", x:x, y:y, w:w, h:h, r:(0.5)*Math.PI };

		beginGradientFill("linear", c, alphas, ratios, matrix);
		drawRect(x,y,w,h);
		endFill();
	}

	static function classConstruct():Boolean
	{
		UIObjectExtensions.Extensions();
		_global.skinRegistry["AccordionHeaderSkin"] = true;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var UIObjectExtensionsDependency = UIObjectExtensions;
}



