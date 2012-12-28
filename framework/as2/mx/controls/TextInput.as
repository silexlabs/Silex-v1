//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.UIComponent;
import mx.core.UIObject;
import mx.skins.RectBorder;

/**
* @tiptext change event
* @helpid 3186
*/
[Event("change")]
/**
* @tiptext enter event
* @helpid 3187
*/
[Event("enter")]

[TagName("TextInput")]
[IconFile("TextInput.png")]
[DataBindingInfo("editEvents","&quot;focusIn;focusOut&quot;")]

/**
* a single-line text input control
*
* @helpid 3188
* @tiptext TextInput is a single-line, editable text field
*/
class mx.controls.TextInput extends UIComponent
{

/**
@private
* SymbolName for object
*/
    static var symbolName:String = "TextInput";
/**
@private
* Class used in createClassObject
*/
    static var symbolOwner:Object = mx.controls.TextInput;

	// Version string//#include "../core/ComponentVersion.as"

/**
* name of this class
*/
    var className:String = "TextInput";
/**
* @private
* true until the component has finished initializing
*/
    var initializing:Boolean = true;
/**
* @private
* list of clip parameters to check at init
*/
    var clipParameters:Object = { text: 1, editable: 1, password: 1, maxChars: 1, restrict: 1};
/**
* @private
* all components must use this mechanism to merge their clip parameters with their base class clip parameters
*/
    static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(TextInput.prototype.clipParameters, UIComponent.prototype.clipParameters);

/**
* @private
* By default, input fields have stretchy width
*/
    var _maxWidth:Number = mx.core.UIComponent.kStretch;

    // object that listens for the enter key
    var enterListener:Object;

    // textField's x, y, w, h
    var tfx:Number;
    var tfy:Number;
    var tfw:Number;
    var tfh:Number;

	// databinding hook
	var updateModel:Function;

	// event hooks
	var enterHandler:Function;
	var changeHandler:Function;

	// style hook
	var borderStyle:String;

/**
* @private
* By default, input fields have editable
*/
    var __editable:Boolean = true;

  	// true if datamodel connected
    var bind:Boolean;


    //this gets us around rescoping
    var owner:MovieClip;

	// store the initial value of the component so we only stuff it into the textfield once
    var initText:String = "";

/**
* @private
* instance name of the border
*/
    var border_mc:RectBorder;
/**
* @private
* instance name of the internal text field
*/
    var label:TextField;

    // Class Constructor
    function TextInput()
    {
    }

	// override of addEventListener so we can trap and report Enter key
    function addEventListener(event:String, handler):Void
    {
	    if (event == "enter")
    	{
      		addEnterEvents();
	    }
    	super.addEventListener(event, handler);
    }

  	// look for Enter key and report it
  	function enterOnKeyDown():Void
  	{
    	if (Key.getAscii() == Key.ENTER)
    	{
      		owner.dispatchEvent({type:"enter"});
    	}
  	}

	// create the listener if needed so we can watch for the Enter key
    function addEnterEvents():Void
  	{
    	if (enterListener == undefined)
    	{
      		enterListener = new Object();
      		enterListener.owner = this;
      		enterListener.onKeyDown = enterOnKeyDown;
    	}
  	}

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
  	function init(Void):Void
  	{
    	super.init();

    	label.styleName = this;
	    tabChildren = true;
    	tabEnabled = false;
		focusTextField = label;

    	// mark as using color "color"
	    _color = UIObject.textColorList;

		label.onSetFocus = function()
		{
		  	this._parent.onSetFocus();
		};
		label.onKillFocus = function(n)
		{
		  	this._parent.onKillFocus(n);
		};
		label.drawFocus = function(b)
		{
		  	this._parent.drawFocus(b);
		};
		label.onChanged = onLabelChanged;
  	}

/**
* @private
* focus should always be on the internal textfield
*/
	function setFocus():Void
	{
		Selection.setFocus(label);
	}

/**
* @private
* broadcast change event if text is changed ('this' is label TextField)
*/
  	function onLabelChanged(changedField:TextField):Void
  	{
		_parent.dispatchEvent({type:"change"});

		// Send a "valueChanged" event
		_parent.dispatchValueChangedEvent(text);
  	}

/**
* @private
* create child objects.
*/
    function createChildren(Void):Void
  	{
		super.createChildren();
		
		if (border_mc == undefined)
		{
			createClassObject(_global.styles.rectBorderClass, "border_mc", 0, {styleName:this});
		}
		border_mc.swapDepths(label);
		label.autoSize = "none";
    }

/**
* true if text is supplied as html
*
* *tiptext	Whether the text field contains text or html.
* *helpid 3189
*/
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
		return label.html;
	}

	function setHtml(value:Boolean):Void
	{
		if (value != label.html)
			label.html = value;
	}

/**
* the text in the component
*
* @tiptext Gets or sets the TextInput content
* @helpid 3190
*/
  	[Inspectable(defaultValue="")]
  	[Bindable]
  	[ChangeEvent("focusOut","enter")]
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

		if (label.html == true)
			return label.htmlText;

		return label.text;
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
		    var l = label;
			if (l.html == true)
			{
				l.htmlText = t;
			}
			else
			{
				l.text = t;
			}
		}

		// Send a "valueChanged" event
		dispatchValueChangedEvent(t);
	}

	// stretch the border and fit the textfield inside it
  	function size(Void):Void
  	{
		border_mc.setSize(width, height);
		var o:Object = border_mc.borderMetrics;
		var bW:Number = o.left+o.right;
		var bH:Number = o.top+o.bottom;
		var bX:Number = o.left;
		var bY:Number = o.top;

		tfx = bX;
		tfy = bY;
		tfw = width - bW;
		tfh = height - bH;

		label.move(tfx, tfy);
		label.setSize(tfw, tfh+1);
	}

	// disable textfield when we're disabled
  	function setEnabled(enable:Boolean):Void
  	{
		label.type = (__editable == true || enable == false) ? "input" : "dynamic";
		label.selectable = enable;
		var tmpColor:Number = getStyle( (enable) ? "color" : "disabledColor");
		if (tmpColor==undefined) {
			tmpColor = (enable) ? 0x000000 : 0x888888;
		}
		setColor(tmpColor);
  	}

/**
* @private
* gets called if a color style value changes
*/
  	function setColor(col:Number):Void
  	{
    	label.textColor = col;
  	}

/**
* @private
* gets called by internal field so we remove focus rect
*/
  	function onKillFocus(newFocus:Object):Void
  	{
		if (enterListener != undefined)
		{
			Key.removeListener(enterListener);
		}

		// If this control is bound to a field of a data model, update
		// the data model now.
		if (bind != undefined)
		{
		  	this.updateModel(text);
		}
		super.onKillFocus(newFocus);
	}

/**
* @private
* gets called by internal field so we draw a focus rect around us
*/
  	function onSetFocus(oldFocus:Object):Void
  	{
		// we might get called from the label or from Selection so figure it out
		var f:String = Selection.getFocus();
		var o:Object = eval(f);
		if (o != label)
		{
		  	Selection.setFocus(label);
		  	return;
		}

		if (enterListener != undefined)
		{
		  	Key.addListener(enterListener);
		}

		super.onSetFocus(oldFocus);
  	}

	// when drawing set the styles on the text
  	function draw(Void):Void
  	{
		var l = label;
		var t = getText();

		if (initializing)
		{
		    // We're into the first draw, so it is OK to stop initializing.
			initializing = false;
			// We've already got the text from initText (see getText call above).
			// It's OK to delete this now unused field.
			delete initText;
		}

		var tf = _getTextFormat();

		l.embedFonts = (tf.embedFonts == true);

		if (tf != undefined)
		{
			l.setTextFormat(tf);
			l.setNewTextFormat(tf);
		}

		l.multiline = false;
		l.wordWrap = false;

		// if you changed wordwrap, you have to reset the text in
		// order to see the change
		if (l.html == true)
		{
    		// Set the text format again after setting the text for html, since
    		// setNewTextFormat doesn't seem to do anything for htmlText.
			l.setTextFormat(tf);
			l.htmlText = t;
		}
		else
		{
			l.text = t;
		}

		// set the read-only
		l.type = (__editable == true || enabled == false) ? "input" : "dynamic";

		// for some reason the textfield resizes itself when initialized and
		// needs to be forced back to its new size
		size();
  	}

/**
* @private
* set the editability here so accessibility can hook it
*/
	function setEditable(s:Boolean):Void
	{
		__editable = s;
		label.type = (s) ? "input" : "dynamic";
	}

/**
* maximum number of characters that can be input into this component
*
* @tiptext The maximum number of characters that the TextInput can contain
* @helpid 3191
*/
  	[Inspectable(defaultValue=null, verbose=1, category="Limits")]
  	function get maxChars():Number
  	{
    	return label.maxChars;
  	}

  	function set maxChars(w:Number):Void
  	{
    	label.maxChars = w;
  	}

/**
* current length of text in component
*
* @tiptext The number of characters in the TextInput
* @helpid 3192
*/
  	function get length():Number
  	{
    	return label.length;
  	}

/**
* list of characters to accept or deny
*
* @tiptext The set of characters that may be entered into the TextInput
* @helpid 3193
*/
  	[Inspectable(defaultValue="", verbose=1, category="Limits")]
  	function get restrict():String
  	{
    	return label.restrict;
  	}
  	function set restrict(w:String):Void
  	{
    	label.restrict = w == "" ? null : w;
  	}

/**
* pixel offset when scrolled horizontally
*
* @tiptext The pixel position of the left-most character that is currently displayed
* @helpid 3194
*/
  	function get hPosition():Number
  	{
    	return label.hscroll;
  	}
  	function set hPosition(w:Number):Void
  	{
    	label.hscroll = w;
  	}

/**
* maximum allowed setting for hPosition
*
* @tiptext The maximum allowed value of hPosition.
* @helpid 3195
*/
  	function get maxHPosition():Number
  	{
    	return label.maxhscroll;
  	}

/**
* true if the component is editable
*
* @tiptext Specifies whether the component is editable or not
* @helpid 3196
*/
  	[Inspectable(defaultValue=true)]
  	function get editable():Boolean
  	{
    	return __editable;
  	}
  	function set editable(w:Boolean):Void
  	{
    	setEditable(w);
  	}

/**
* true to use '*' instead of the actual characters
*
* @tiptext Specifies whether to display '*' instead of the actual characters
* @helpid 3197
*/
  	[Inspectable(defaultValue=false)]
  	function get password():Boolean
  	{
    	return label.password;
  	}
  	function set password(w:Boolean):Void
  	{
    	label.password=w;
  	}

/**
* tab order when using tab key to navigate
*
* @tiptext tabIndex of the component
* @helpid 3198
*/
  	function get tabIndex():Number
  	{
    	return label.tabIndex;
  	}

  	function set tabIndex(w:Number):Void
  	{
    	label.tabIndex=w;
  	}

/**
* accessibility data
*
* @tiptext
* @helpid 3199
*/
  	function set _accProps(val:Object)
  	{
		label._accProps = val;
  	}

  	function get _accProps():Object
  	{
		return label._accProps;
  	}

  	private static var RectBorderDependency = mx.skins.halo.RectBorder;
  	
}

