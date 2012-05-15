//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/**
* The class that manages:
*   -which CSS style properties are inheriting
*   -which style properties are colors and therefore get special handling
*   -a list of strings that are aliases for color values
*
* @helpid 3347
* @tiptext Management of CSS style properties.
*/
class mx.styles.StyleManager
{
	// initialize set of inheriting non-color styles.  This is not the complete set
	// from CSS.  Some of the omitted we don't support at all, others may be added later
	// as needed.
	static var inheritingStyles:Object =
	{
		color: true,
		direction: true,
		fontFamily: true,
		fontSize: true,
		fontStyle: true,
		fontWeight: true,
		textAlign: true,
		textIndent: true
	};

	// initialize set of inheriting color styles.
	static var colorStyles:Object =
	{
		barColor: true,
		trackColor: true,
		borderColor: true,
		buttonColor: true,
		color: true,
		dateHeaderColor: true,
		dateRollOverColor: true,
		disabledColor: true,
		fillColor: true,
		highlightColor: true,
		scrollTrackColor: true,
		selectedDateColor: true,
		shadowColor: true,
		strokeColor: true,
		symbolBackgroundColor: true,
		symbolBackgroundDisabledColor: true,
		symbolBackgroundPressedColor: true,
		symbolColor: true,
		symbolDisabledColor: true,
		themeColor:true,
		todayIndicatorColor: true,
		shadowCapColor:true,
		borderCapColor:true,
		focusColor:true
	};

	// initialize set of color names.
	static var colorNames:Object =
	{
		black: 0x000000,
		white: 0xFFFFFF,
		red: 0xFF0000,
		green: 0x00FF00,
		blue: 0x0000FF,
		magenta: 0xFF00FF,
		yellow: 0xFFFF00,
		cyan: 0x00FFFF,
		haloGreen: 0x80FF4D,
		haloBlue: 0x2BF5F5,
		haloOrange: 0xFFC200
	};

	// object used to determine which Flash TextFormat property values are
	// inheriting (calculated by examining the parent if not defined on the child)
	static var TextFormatStyleProps:Object =
	{
		font: true,
		size: true,
		color: true,
		leftMargin: false,
		rightMargin: false,
		italic: true,
		bold: true,
		align: true,
		indent: true,
		underline: false,
		embedFonts: false
	};

	// object used to map CSS style properties to Flash TextFormat properties
	static var TextStyleMap:Object =
	{
		textAlign: true,
		fontWeight: true,
		color: true,
		fontFamily: true,
		textIndent: true,
		fontStyle: true,
		lineHeight: true,
		marginLeft: true,
		marginRight: true,
		fontSize: true,
		textDecoration: true,
		// not really in TextFormat, but here as an optimization
		embedFonts: true
	};

/**
* @private
* add to the list of styles that can inherit values from their parents
*
* warning:  watch out for name collisions otherwise you will
* cause lots of extra processing if an already used style
* becomes inheriting.
*
* @param styleName the style name
*/
	static function registerInheritingStyle(styleName:String):Void
	{
		StyleManager.inheritingStyles[styleName] = true;
	}

/**
* @private
* returns true if style is inheriting.
*
* @param styleName the style name
* @return Boolean
*/
	static function isInheritingStyle(styleName:String):Boolean
	{
		return (StyleManager.inheritingStyles[styleName] == true);
	}

/**
* @private
* add to the list of styles that are colors so they can be specially handled
*
* @param styleName the style name
*/
	static function registerColorStyle(styleName:String):Void
	{
		StyleManager.colorStyles[styleName] = true;
	}

/**
* @private
* returns true if style is a color style.
*
* @param styleName the style name
* @return Boolean
*/
	static function isColorStyle(styleName:String):Boolean
	{
		return (StyleManager.colorStyles[styleName] == true);
	}

/**
* @private
* add to the list of aliases for colors
*
* @param colorName the style name (e.g. "blue")
* @param colorValue the color value (e.g. 0x0000FF)
*/
	static function registerColorName(colorName:String, colorValue:Number):Void
	{
		StyleManager.colorNames[colorName] = colorValue;
	}

/**
* @private
* returns true if colorName is an alias for a color.
*
* @param colorName the color name
* @return Boolean
*/
	static function isColorName(colorName:String):Boolean
	{
		return (StyleManager.colorNames[colorName] != undefined)
	}

/**
* @private
* returns true if colorName is an alias for a color.
*
* @param colorName the color name
* @return Number (the color value)
*/
	static function getColorName(colorName:String):Number
	{
		return StyleManager.colorNames[colorName];
	}
}

