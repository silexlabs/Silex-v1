//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;

[TagName("Label")]
[IconFile("Label.png")]

/**
* Label class
* @tiptext Label is a single-line, non-editable text field
* @helpid 3410
*/

class mx.controls.Label extends UIObject
{
	var	tabEnabled:Boolean;
	var	tabChildren:Boolean;
	var	useHandCursor:Boolean;
	var	_color;


/**
@private
* SymbolName for object
*/
	static var symbolName:String = "Label";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = Object(mx.controls.Label);

/**
* name of this class
*/
	var	className:String = "Label";
//#include "../core/ComponentVersion.as"

	var	initializing:Boolean = true;

	var	clipParameters:Object = { text: 1, html: 1, autoSize: 1};
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(Label.prototype.clipParameters, UIObject.prototype.clipParameters);

	var	labelField:TextField;

	var __autoSize:String;

	var	initText:String;

	function Label()
	{
	}

	function init(Void):Void
	{
		super.init();
		_xscale = _yscale = 100;

		labelField.selectable = false;
		labelField.styleName = this;
		tabEnabled = false;
		tabChildren = false;
		useHandCursor = false;

		// mark as using color "color"
		_color = UIObject.textColorList;
	}

/**
* true if text is supplied as html
*
* @tiptext Specifies whether the Label contains html
* @helpid 3906
*/
	[Inspectable(defaultValue=false)]
	function get html():Boolean
	{
		return getHtml();
	}
	function set html(value:Boolean):Void
	{
		setHtml(value);
	}

	function getHtml():Boolean
	{
		return labelField.html;
	}

	function setHtml(value:Boolean):Void
	{
		if (value != labelField.html)
			labelField.html = value;
	}

/**
* the text in the component
*
* @tiptext Gets or sets the Label content
* @helpid 3907
*/
	[Inspectable(defaultValue="Label")]
	[Bindable("writeonly")]
	function get text():String
	{
		return getText();
	}
	function set text(t:String):Void
	{
		setText(t);
	}

/**
* @private
* called by the getter to get the text.
*/
	function getText():String
	{
		if (initializing)
			return initText;

		var l = labelField;
		if (l.html == true)
			return l.htmlText;

		return l.text;
	}

/**
* @private
* called by the setter to set the text.
*/
	function setText(t:String):Void
	{
		if (initializing)
		{
			initText = t;
		}
		else
		{
    		var l = labelField;
			if (l.html == true)
			{
				l.htmlText = t;
			}
			else
			{
				l.text = t;
			}
    		adjustForAutoSize();
		}
	}

	/**
	* @tiptext Controls automatic sizing and alignment
	* @helpid 3905
	*/
	[Inspectable(enumeration="left,center,right,none",defaultValue="none")]
	function get autoSize():String
	{
		return __autoSize; //labelField.autoSize;
	}

	function set autoSize(v:String):Void
	{
		if (_global.isLivePreview == true)
		{
			v = "none";
		}
		__autoSize = v;
		if (!initializing)
			draw();
	}

	// should not get called during construction.
	function draw(Void):Void
	{
		var l = labelField;
		var t;

		if (initializing)
		{
			// If we are initializing, get the text from initText.
			t = text;
			initializing = false;
			// After setting initializing to false, set the appropriate
			// field (.text or .htmlText) with the contents of text.
			setText(t);
			delete initText;
		}

		// have to reset the html after you apply TextFormat
		if (l.html)
			t = l.htmlText;

		var tf = _getTextFormat();

		l.embedFonts = (tf.embedFonts == true);

		if (tf != undefined)
		{
			l.setTextFormat(tf);
			l.setNewTextFormat(tf);
		}
		if (l.html)
			l.htmlText = t;

		adjustForAutoSize();
	}

	function adjustForAutoSize()
	{
		var l = labelField;
		var as = __autoSize;
		if (as != undefined && as != "none")
		{
			// font size changed so recalc height
			l._height = l.textHeight + 3;
			var oldw:Number = __width;
			setSize(l.textWidth + 4, l._height);
			if (as == "right")
			{
				// Move the textField to the right by the difference between the old Label width and the text width.
				// This will line up the right edge of the text with the right edge of the Label.
				_x += oldw - __width;
			}
			else if (as == "center")
			{
				// Move the textField to the right by half the difference between the old Label width and the text width.
				// Because the textField has been sized to the text, this will center the textField and the text within the Label.
				_x += (oldw - __width) / 2;
			}
			else if (as == "left")
			{
				// Move the textField all the way to the left.
				_x += 0;
			}
		}
		else
		{
			// For no autoSizing, make sure the textField is left-aligned, and the same size as the Label.
			l._x = 0;
			l._width = __width;
			l._height = __height;
		}
	}

	function size(Void):Void // note that height is textFormat-based.
	{
		//super.size();
		var l = labelField;
		l._width = __width;
		l._height = __height;
	}

	function setEnabled(enable:Boolean):Void
	{
		var tmpColor:Number = getStyle( (enable) ? "color" : "disabledColor");
		if (tmpColor==undefined) {
			tmpColor = (enable) ? 0x000000 : 0x888888;
		}
		setColor(tmpColor);
	}

	function setColor(col:Number):Void
	{
		labelField.textColor = col;
	}

	function get styleSheet():TextField.StyleSheet
	{
		return labelField.styleSheet;
	}

	function set styleSheet(v:TextField.StyleSheet):Void
	{
		labelField.styleSheet = v;
	}
}
