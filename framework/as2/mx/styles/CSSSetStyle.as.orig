//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.styles.StyleManager;
import mx.styles.CSSStyleDeclaration;

/**
* runtime style changes of CSS properties requires this package
*
*/
class mx.styles.CSSSetStyle
{
	// actually defined on the hosting class
	var styleName:String;
	var stylecache:Object;
	var _color:Number;
	var setColor:Function;
	var invalidateStyle:Function;

	// metadata is in UIObject.as
	function _setStyle(styleProp:String, newValue):Void
	{
		this[styleProp] = newValue;
		if (StyleManager.TextStyleMap[styleProp] != undefined)
		{
			if (styleProp == "color")
			{
				if (isNaN(newValue))	// a color name
				{
					// convert it to rgb
					newValue = StyleManager.getColorName(newValue);
					this[styleProp] = newValue;
					if (newValue == undefined) return;
				}
			}
			_level0.changeTextStyleInChildren(styleProp);
			return;
		}
		if (StyleManager.isColorStyle(styleProp))
		{
			if (isNaN(newValue))	// a color name
			{
				// convert it to rgb
				newValue = StyleManager.getColorName(newValue);
				this[styleProp] = newValue;
				if (newValue == undefined) return;
			}
			if (styleProp=="themeColor") {
				var hb = StyleManager.colorNames["haloBlue"];
				var hg = StyleManager.colorNames["haloGreen"];
				var ho = StyleManager.colorNames["haloOrange"];

				var selectionColor = {};
				selectionColor[hb] = 0xB9FBFA;	//haloBlue
				selectionColor[hg]= 0xCDFFC1;	//haloGreen
				selectionColor[ho] = 0xFFD56F;	//haloOrange

				var rollOverColor = {};
				rollOverColor[hb] = 0xD4FDFD;	//haloBlue
				rollOverColor[hg]= 0xe3ffd6;		//haloGreen
				rollOverColor[ho] = 0xFFEEB3;	//haloOrange

				var newValueS = selectionColor[newValue];
				var newValueR = rollOverColor[newValue];

				if ( newValueS == undefined)
						var newValueS  = newValue;

				if ( newValueR == undefined)
						var newValueR  = newValue;

				this.setStyle("selectionColor", newValueS);
				this.setStyle("rollOverColor", newValueR);
			}
			_level0.changeColorStyleInChildren(styleName, styleProp, newValue);
		}
		else
		{
			// special case for background color
			if (styleProp == "backgroundColor" && isNaN(newValue))
			{
				// convert it to rgb
				newValue = StyleManager.getColorName(newValue);
				this[styleProp] = newValue;
				if (newValue == undefined) return;
			}
			_level0.notifyStyleChangeInChildren(styleName, styleProp, newValue);
		}
	}

	// propagate text style changes to the children
	function changeTextStyleInChildren(styleProp:String):Void
	{
		var searchKey:Number = getTimer();
		// apply to all children unless overridden
		var j:String;
		for (j in this)
		{
			var i = this[j];
			if (i._parent == this)
			{
				// multiple properties can point to the same clip so use
				// depth as a uniqueness check
				if (i.searchKey != searchKey)
				{
					if (i.stylecache != undefined)
					{
						delete i.stylecache.tf;
						delete i.stylecache[styleProp];
					}
					i.invalidateStyle(styleProp);
					// apply to the child's children
					i.changeTextStyleInChildren(styleProp);
					i.searchKey = searchKey;
				}
			}
		}
	}

	// propagate color style changes to the children
	function changeColorStyleInChildren(sheetName:String, colorStyle:String, newValue):Void
	{
		var searchKey:Number = getTimer();
		// apply to all children unless overridden
		var j:String;
		for (j in this)
		{
			var i = this[j];
			if (i._parent == this)
			{
				// multiple properties can point to the same clip so use
				// depth as a uniqueness check
				if (i.searchKey != searchKey)
				{
					// if using this StyleDeclaration, then you get this style
					if (i.getStyleName() == sheetName || sheetName == undefined || sheetName=="_global")
					{
						if (i.stylecache != undefined)
							delete i.stylecache[colorStyle];
						// if this element is using this colorname
						if (typeof(i._color) == "string")
						{
							if (i._color == colorStyle)
							{
								var v = i.getStyle(colorStyle)
								if (colorStyle == "color")
								{
									if (stylecache.tf.color != undefined)
										stylecache.tf.color = v;
								}
								i.setColor(v);
							}
						}
						else
						{
							if (i._color[colorStyle] != undefined)
							{
								// if not a movieclip, must be a textfield
								// so invalidate its parent
								if (typeof(i) != "movieclip")
									i._parent.invalidateStyle();
								else
									i.invalidateStyle(colorStyle);
							}
						}
					}

					// apply to the child's children
					i.changeColorStyleInChildren(sheetName, colorStyle, newValue);
					i.searchKey = searchKey;
				}
			}
		}
	}

	// propagate other style changes to the children
	function notifyStyleChangeInChildren(sheetName:String, styleProp:String, newValue):Void
	{

		var searchKey:Number = getTimer();
		// apply to all children unless overridden
		var j:String;
		for (j in this)
		{
			var i = this[j];
			if (i._parent == this)
			{
				// multiple properties can point to the same clip so use
				// depth as a uniqueness check
				if (i.searchKey != searchKey)
				{
					// if using this StyleDeclaration, then you get this style
					if ((i.styleName == sheetName) || (i.styleName != undefined && typeof(i.styleName) == "movieclip") || sheetName==undefined)
					{
						if (i.stylecache != undefined)
						{
							delete i.stylecache[styleProp];
							delete i.stylecache.tf;
						}
						delete i.enabledColor;
						i.invalidateStyle(styleProp);
						// cascade to your children as well
					}
					i.notifyStyleChangeInChildren(sheetName, styleProp, newValue);
					i.searchKey = searchKey;
				}
			}
		}
	}

/**
* set a style property.  Causes lots of processing so use sparingly
*
* @param	String	prop	name of style property
* @param	Variant	value	new value for style
*
* @tiptext
* @helpid 3333
*/
	function setStyle(styleProp:String, newValue):Void
	{
		if (stylecache != undefined)
		{
			delete stylecache[styleProp];
			delete stylecache.tf;
		}

		this[styleProp] = newValue;
		if (StyleManager.isColorStyle(styleProp))
		{
			if (isNaN(newValue))	// a color name
			{
				// convert it to rgb
				newValue = StyleManager.getColorName(newValue);
				this[styleProp] = newValue;
				if (newValue == undefined) return;
			}
			if (styleProp=="themeColor") {
				var hb = StyleManager.colorNames["haloBlue"];
				var hg = StyleManager.colorNames["haloGreen"];
				var ho = StyleManager.colorNames["haloOrange"];

				var selectionColor = {};
				selectionColor[hb] = 0xB9FBFA;	//haloBlue
				selectionColor[hg]= 0xCDFFC1;	//haloGreen
				selectionColor[ho] = 0xFFD56F;	//haloOrange

				var rollOverColor = {};
				rollOverColor[hb] = 0xD4FDFD;	//haloBlue
				rollOverColor[hg]= 0xe3ffd6;		//haloGreen
				rollOverColor[ho] = 0xFFEEB3;	//haloOrange

				var newValueS = selectionColor[newValue];
				var newValueR = rollOverColor[newValue];

				if ( newValueS == undefined)
						var newValueS  = newValue;

				if ( newValueR == undefined)
						var newValueR  = newValue;

				this.setStyle("selectionColor", newValueS);
				this.setStyle("rollOverColor", newValueR);
			}
			if (typeof(_color) == "string")
			{
				if (_color == styleProp)
				{
					if (styleProp == "color")
					{
						if (stylecache.tf.color != undefined)
							stylecache.tf.color = newValue;
					}
					setColor(newValue);
				}
			}
			else
			{
				if (_color[styleProp] != undefined)
				{
					invalidateStyle(styleProp);
				}
			}
			changeColorStyleInChildren(undefined, styleProp, newValue);
		}
		else
		{
			// special case for background color
			if (styleProp == "backgroundColor" && isNaN(newValue))
			{
				// convert it to rgb
				newValue = StyleManager.getColorName(newValue);
				this[styleProp] = newValue;
				if (newValue == undefined) return;
			}
			// mark the component as invalid so it repaints with new style
			invalidateStyle(styleProp);
		}

		if (StyleManager.isInheritingStyle(styleProp) || styleProp == "styleName")
		{
			var sheet;
			var val = newValue;
			if (styleProp=="styleName") {
				sheet = (typeof(newValue) == "string") ? _global.styles[newValue] : val;
				val = sheet.themeColor;
				if (val!=undefined)
					sheet.rollOverColor = sheet.selectionColor = val;
			}

			notifyStyleChangeInChildren(undefined, styleProp, newValue);
		}
	}

	static function enableRunTimeCSS():Void
	{
	}

	static function classConstruct():Boolean
	{
		var mc = MovieClip.prototype;
		var ui = CSSSetStyle.prototype;
		CSSStyleDeclaration.prototype.setStyle = ui._setStyle;
		mc.changeTextStyleInChildren = ui.changeTextStyleInChildren;
		mc.changeColorStyleInChildren = ui.changeColorStyleInChildren;
		mc.notifyStyleChangeInChildren = ui.notifyStyleChangeInChildren;
		mc.setStyle = ui.setStyle;
		_global.ASSetPropFlags(mc, "changeTextStyleInChildren",1);
		_global.ASSetPropFlags(mc, "changeColorStyleInChildren",1);
		_global.ASSetPropFlags(mc, "notifyStyleChangeInChildren",1);
		_global.ASSetPropFlags(mc, "setStyle",1);
		
		var tf = TextField.prototype;
		tf.setStyle = mc.setStyle;
		tf.changeTextStyleInChildren = ui.changeTextStyleInChildren;
		return true;
	}
	static var classConstructed:Boolean = classConstruct();
	static var CSSStyleDeclarationDependency = CSSStyleDeclaration;
}