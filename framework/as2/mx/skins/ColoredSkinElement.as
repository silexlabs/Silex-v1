//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
* Class used for coloring graphical objects in response to color style changes.
* Each ColoredSkinElement is all one color so multi-color graphics must be
* composited from multiple ColoredSkinElements.  Add the setColorStyle method
* to the actions for each colored graphical object.
*
* @tiptext Colored object support
* @helpid 3322
*/
class mx.skins.ColoredSkinElement
{
	// create an instance of yourself so you can add methods to other graphic objects
	static var mixins:ColoredSkinElement = new ColoredSkinElement();

	// the colorStyle for the object
	var _color;

	// onEnterFrame is used in the invalidate/draw mechanism
	var onEnterFrame:Function;
	// this gets applied in UIObjectExtensions
	var getStyle:Function;

	// called by the color style system when color changes
	function setColor(c:Number):Void
	{
		if (c != undefined)
		{
			var colorizer = new Color(this);
			colorizer.setRGB(c);
		}
	}

	// called when a whole StyleDeclaration changes
	function draw(Void):Void
	{
		setColor(getStyle(_color));
		onEnterFrame = undefined;
	}

	// called when a whole StyleDeclaration changes
	function invalidateStyle(Void):Void
	{
		onEnterFrame = draw;
	}

/**
* call this in the actions for each colorable graphic element
* Example:  mx.skins.ColoredSkinElement.setColorStyle(this, "borderColor");
* Element will now use "borderColor" for its actual color.
*/
	static function setColorStyle(p:Object, colorStyle:String):Void
	{
		if (p._color == undefined)
			p._color = colorStyle;

		p.setColor = ColoredSkinElement.mixins.setColor;
		p.invalidateStyle = ColoredSkinElement.mixins.invalidateStyle;
		p.draw = ColoredSkinElement.mixins.draw;
		p.setColor(p.getStyle(colorStyle));
	}
}
