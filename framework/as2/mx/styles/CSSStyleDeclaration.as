//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.styles.CSSTextStyles;
import mx.styles.StyleManager;

/**
* The class that represents a set of CSS style rules.  Note that UIObject
* also has a similar implementation.  Styles may be set directly on UIObjects or
* indirectly by referencing an instance of this class using the styleName property.
* @see mx.core.UIObject
*
* @helpid 3334
* @tiptext A set of CSS style properties and values.
*/
class mx.styles.CSSStyleDeclaration
{
	// local copy of the Flash TextFormat
	var _tf:TextFormat;
	// the name of a CSSStyleDeclaration as found on  _global.styles.
	var styleName:String;

	// these get replaced by getters and setters via the TextStyles mixin
	var textAlign:String;
	var fontWeight:String;
	var color:Number;
	var fontFamily:String;
	var textIndent:Number;
	var fontStyle:String;
	var marginLeft:Number;
	var marginRight:Number;
	var fontSize:Number;
	var textDecoration:String;
	var embedFonts:Boolean;

	// used to calculate the Flash TextFormat object
	function __getTextFormat(tf:TextFormat, bAll:Boolean):Boolean
	{
		var bUndefined:Boolean = false;

		if (_tf != undefined)
		{
			var j:String;
			// for each field in the mapping
			for (j in StyleManager.TextFormatStyleProps)
			{
				if (bAll || StyleManager.TextFormatStyleProps[j])
				{
					if (tf[j] == undefined)
					{
						// get the value from the textFormat
						var v = _tf[j];
						// store it in the tf if not defined
						if (v != undefined)
						{
							tf[j] = v;
						}
						else
							bUndefined = true;
					}
				}
			}
		}
		else
			bUndefined = true;

		return bUndefined;
	}

/**
* get a style property
*
* @param	String	prop	name of style property
* @return	Variant	the style value
*
* @tiptext
* @helpid 3335
*/
	function getStyle(styleProp:String)
	{
		var val = this[styleProp];
		var c = StyleManager.getColorName(val);
		return (c==undefined) ? val : c;
	}

	static function classConstruct():Boolean
	{
		CSSTextStyles.addTextStyles(CSSStyleDeclaration.prototype, true);
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var CSSTextStylesDependency = CSSTextStyles;
}
