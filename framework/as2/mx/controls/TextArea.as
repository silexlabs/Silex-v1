//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.ScrollView;
import mx.core.UIObject;

/**
* @tiptext change event
* @helpid 3170
*/
[Event("change")]

[TagName("TextArea")]
[IconFile("TextArea.png")]
[DataBindingInfo("editEvents","&quot;focusIn;focusOut&quot;")]

/**
* a multi-line text area, complete with optional scrollbars
*
* @helpid 3171
* @tiptext TextArea is a multi-line, editable text field with optional scrollbars
*/
class mx.controls.TextArea extends ScrollView
{
/**
@private
* SymbolName for object
*/
	static var symbolName:String = "TextArea";
/**
@private
* Class used in createClassObject
*/
	static var symbolOwner:Object = TextArea;

	// Version string//#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "TextArea";

/**
* @private
* true until the component has finished initializing
*/
	var initializing:Boolean = true;

/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters:Object = { text: 1, wordWrap: 1, editable: 1, maxChars: 1, restrict: 1, html: 1, password: 1};
/**
* @private
* all components must use this mechanism to merge their clip parameters with their base class clip parameters
*/
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(TextArea.prototype.clipParameters, ScrollView.prototype.clipParameters);

/**
* @private
* vertical bars default to auto
*/
	var __vScrollPolicy:String = "auto";
/**
* @private
* horizontal bars default to auto
*/
	var __hScrollPolicy:String = "auto";

/**
* @private
* instance name of the internal text field
*/
	var label:TextField;

/**
* @private
* TextAreas are editable by default
*/
	var __editable:Boolean = true;

	// store the initial value of the component so we only stuff it into the textfield once
	var initText:String;

	// cached size of textfield
	var tfx:Number;
	var tfw:Number;
	var tfy:Number;
	var tfh:Number;

	// whether we've hooked up events to the scrollbars
	var hookedV:Boolean;
	var hookedH:Boolean;
	// position of the scrollbars
	var _vpos:Number;
	var _hpos:Number;

/**
* maximum number of characters that can be input into this component
*
* @tiptext	The maximum number of characters that the TextArea can contain
* @helpid 3172
*/
	[Inspectable(defaultValue=null, verbose=1, category="Limits")]
	function get maxChars():Number
	{
		return label.maxChars;
	}
	function set maxChars(x:Number)
	{
		label.maxChars = x;
	}

/**
* current length of text in component
*
* @tiptext	The number of characters in the TextArea
* @helpid 3173
*/
	function get length():Number
	{
		return label.length;
	}

/**
* list of characters to accept or deny
*
* @tiptext	The set of characters that may be entered into the TextArea
* @helpid 3174
*/
	[Inspectable(defaultValue="", verbose=1, category="Limits")]
	function get restrict():String
	{
		return label.restrict;
	}
	function set restrict(s:String)
	{
		label.restrict = s == "" ? null : s;
	}

/**
* true if should wordwrap.  If false, long lines get clipped
*
* @tiptext	If true, lines will wrap. If false, long lines get clipped.
* @helpid 3175
*/
	[Inspectable(defaultValue=true)]
	function get wordWrap():Boolean
	{
		return label.wordWrap;
	}
	function set wordWrap(s:Boolean)
	{
		label.wordWrap = s;
		invalidate();
	}

/**
* true if the component is editable
*
* @tiptext	Specifies whether the component is editable or not
* @helpid 3176
*/
	[Inspectable(defaultValue=true)]
	function get editable():Boolean
	{
		return __editable;
	}
	function set editable(x:Boolean)
	{
		__editable = x;
		label.type = (x) ? "input" :  "dynamic";
	}

/**
* true to use '*' instead of the actual characters
*
* @tiptext	Specifies whether to display '*' instead of the actual characters
* @helpid 3177
*/
	[Inspectable(defaultValue=false, verbose=1, category="Other")]
	function get password():Boolean
	{
		return label.password;
	}
	function set password(s:Boolean)
	{
		label.password = s;
	}

/**
* true if text is supplied as html
*
* @tiptext	Specifies Whether the TextArea contains html
* @helpid 3178
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
* @tiptext Gets or sets the TextArea content
* @helpid 3179
*/
	[Inspectable(defaultValue="")]
	[Bindable]
	[ChangeEvent("change")]
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

		var l = label;
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
    		var l = label;
			if (l.html == true)
			{
				l.htmlText = t;
			}
			else
			{
				l.text = t;
			}
			invalidate(); // to get scrollbars to sync.
		}

		// Send a "valueChanged" event
		dispatchValueChangedEvent(t);
	}

/**
* pixel offset when scrolled horizontally
*
* @tiptext	The pixel offset into the content from the left edge
* @helpid 3180
*/
	function get hPosition():Number
	{
		return getHPosition();
	}
	function set hPosition(pos:Number)
	{
		setHPosition(pos);
		label.hscroll = pos;
		// this works around a great player bug
		label.background = false;
	}

/**
* line number of the topmost line of characters displayed
*
* @tiptext	The pixel offset into the content from the top edge
* @helpid 3181
*/
	function get vPosition():Number
	{
		return getVPosition();
	}
	function set vPosition(pos:Number)
	{
		setVPosition(pos);
		label.scroll = pos + 1;
		// this works around a great player bug
		label.background = false;
	}

/**
* maximum allowed setting for vPosition
*
* @tiptext	The maximum pixel offset into the content from the top edge
* @helpid 3182
*/
	function get maxVPosition():Number
	{
		var m:Number = label.maxscroll - 1;
		return (m==undefined) ? 0 : m;
	}

/**
* maximum allowed setting for hPosition
*
* @tiptext	The maximum pixel offset into the content from the left edge
* @helpid 3183
*/
	function get maxHPosition():Number
	{
		var m:Number = label.maxhscroll;
		return (m==undefined) ? 0 : m;
	}

	function TextArea()
	{
	}

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
	function init(Void):Void
	{
		super.init();

		label.styleName = this;

		// mark as using color "color"
		_color = UIObject.textColorList;

		focusTextField = label;

		label.owner = this;
		label.onSetFocus = function(x)
		{
			this._parent.onSetFocus(x);
		};
		label.onKillFocus = function(x)
		{
			this._parent.onKillFocus(x);
		};
		label.drawFocus = function(b)
		{
			this._parent.drawFocus(b);
		};

		// only gets called on keyboard not programmatic setting of text
		label.onChanged = function()
		{
			this.owner.adjustScrollBars();

			this.owner.dispatchEvent({type:"change"});

			// Send a "valueChanged" event
			this.owner.dispatchValueChangedEvent(this.owner.text);
		};


		label.onScroller = function()
		{
			//trace("label :: onScroller");
			this.owner.hPosition = this.hscroll;
			this.owner.vPosition = this.scroll - 1;
		};
		if (text==undefined) {
			text="";
		}
	}


/**
* @private
* create child objects.
*/
	function createChildren(Void):Void
	{
		super.createChildren();
		label.autoSize = "none";
	}

/**
* @private
* position the internal textfield taking scrollbars into consideration
*/
	function layoutContent(x:Number, y:Number, totalW:Number, totalH:Number, displayW:Number, displayH:Number):Void
	{
		var l = label;
		if (tfx!=x || tfy!=y || tfw!=displayW || tfh!=displayH) {
		//trace("TextArea :: layoutContent(" + x + "," + y + "," + totalW + "," + totalH + "," + displayW + "," + displayH + ")");
			tfx = x;
			tfy = y;
			tfw = displayW;
			tfh = displayH;
			l.move(tfx, tfy);
			l.setSize(tfw, tfh);

			// maxscroll isn't updated yet in some cases
			doLater(this, "adjustScrollBars");
		}
	}

	// we're done scrolling to put the selection back where we started
	function scrollChanged(Void):Void
	{
		var currentSelection:Object = Selection;
		if (currentSelection.lastBeginIndex != undefined)
		{
			restoreSelection();
		}
		label.background = false;
	}

/**
* @private
* we got a scroll event so update everything
*/
	function onScroll(docObj:Object):Void
	{
		var l = label;
		// trace("TextArea :: onScroll");
		super.onScroll(docObj);
		l.hscroll = hPosition + 0;
		l.scroll = vPosition + 1;
		_vpos = l.scroll;
		_hpos = l.hscroll;

		// this works around a great player bug
		l.background = false;
		if (hookedV != true)
		{
			vScroller.addEventListener("scrollChanged", this);
			hookedV = true;
		}
		if (hookedH != true)
		{
			hScroller.addEventListener("scrollChanged", this);
			hookedH = true;
		}

	}

/**
* @private
* we got resized so layout everything again
*/
	function size(Void):Void // note that height is textFormat-based.
	{
		var o:Object = getViewMetrics();
		var bW:Number = o.left+o.right;
		var bH:Number = o.top+o.bottom;
		var bX:Number = o.left;
		var bY:Number = o.top;

		tfx = bX;
		tfy = bY;
		tfw = width - bW;
		tfh = height - bH;

		//trace("TextArea :: size");
		super.size();

		// resize and reposition internal text field
		// (using offsets saved during layoutContent)
		label.move(tfx, tfy);
		label.setSize(tfw, tfh);

		if (height <= 40) {
			hScrollPolicy = "off";
			vScrollPolicy = "off";
		}
		doLater(this, "adjustScrollBars");
	}

	// disable scrollbars and textfield if we're disabled.
	function setEnabled(enable:Boolean):Void
	{
		vScroller.enabled = enable;
		hScroller.enabled = enable;
		label.type = (editable == false || enable == false) ? "dynamic" : "input";
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
* focus should always be on the internal textfield
*/
	function setFocus(Void):Void
	{
		Selection.setFocus(label);
	}

/**
* @private
* gets called by internal field so we draw a focus rect around us
*/
	function onSetFocus(x:Object):Void
	{

		// we might get called from the label or from Selection so figure it out
		var f:String = Selection.getFocus();
		var o:Object = eval(f);
		if (o != label)
		{
			Selection.setFocus(label);
			return;
		}

		getFocusManager().defaultPushButtonEnabled = false;
		addEventListener("keyDown", this);
		super.onSetFocus(x);

	}

/**
* @private
* gets called by internal field so we remove focus rect
*/
	function onKillFocus(x:Object):Void
	{
		getFocusManager().defaultPushButtonEnabled = true;
		removeEventListener("keyDown", this);
		super.onKillFocus(x);
	}

/**
* @private
* gets called by internal field so we remove focus rect
*/
	function restoreSelection(x:Object):Void
	{
			var currentSelection:Object = Selection;
			//trace("restore selection " + currentSelection.lastBeginIndex + " " + currentSelection.lastEndIndex);
			Selection.setSelection(currentSelection.lastBeginIndex, currentSelection.lastEndIndex);
			label.scroll = _vpos;
			label.hscroll = _hpos;
	}

/**
* @private
* gets called by pageUp/pageDown key handler to figure out the end of lines
*/

	function getLineOffsets(Void):Array
	{
		// get the text format (use Object so we can use getTextExtent2
		var tf:Object = _getTextFormat();
		// this forces the textExtent object to be created
		var tw:Object = tf.getTextExtent2(label.text);
		// get a pointer to the textExtent object
		var x:TextField = _root._getTextExtent;
		x.setNewTextFormat(TextFormat(tf));

		var ww:Boolean = label.wordWrap;

		var offset:Number = 0;
		// the displayable width = width - 1 pixel of white space
		// on each side, plus one more one each side
		// if borders are on
		var w:Number = label._width - 2 - 2;
		// r is the return array of line offsets
		var r:Array = new Array();
		// get a array of lines in the text control
		var z:String = new String(label.text);
		// y is the array of lines
		var y:Array = z.split("\r");

		for (var m:Number = 0; m < y.length; m++)
		{
			// push the offset of the start of this line
			r.push(offset);

			// s is the reference to the current line
			var s:String = y[m];
			// load the measuring textfield with the line
			x.text = s;
			// l is the approximate number of lines
			var l:Number = Math.ceil(x.textWidth / w);
			// a is the approximate offset of the end of a line
			var a:Number = Math.floor(s.length / l);
			var n:Number;

			// while the line is wider than the displayable area..
			while (ww && x.textWidth > w)
			{
				// find the word break nearest our guess at the end
				n = s.indexOf(" ", a);
				// cut the line there
				var k:String;
				if (n == -1)
				{
					// we didn't find a space look before a
					n = s.lastIndexOf(" ");
					if (n == -1)
					{
						n = a;
					}
				}
				k = s.substr(0, n);
				// measure the cut line
				x.text = k;
				// if the cut line is still too wide...
				if (x.textWidth > w)
				{
					// while it is too wide, shrink it.
					while (x.textWidth > w)
					{
						var lastN = n;
						// find the next word break
						n = s.lastIndexOf(" ", n-1);
						if (n == -1)
							n = lastN - 1;
						// cut it there
						k = s.substr(0, n);
						// measure it
						x.text = k;
					}
				}
				// if the cut line is not wide enough
				else if (x.textWidth < w)
				{
					var lastN = n;
					// while it is not wide enough, grow it.
					while (x.textWidth < w)
					{
						lastN = n;
						// find the next word break
						n = s.indexOf(" ", n+1);
						if (n == -1) // if no more word breaks
						{
							if (s.indexOf(" ", 0) != -1)
								// there's a word break earlier so we're done
								break;
							else
								n = lastN + 1;
						}
						// cut it there
						k = s.substr(0, n);
						// measure it
						x.text = k;
					}
					n = lastN;
				}
				// n is the offset of the next line so save it
				offset += n;
				r.push(offset + 1);
				// and make s the remainder of the string starting
				// on the next line
				s = s.substr(n);
				// strip space that forced line break
				if (s.charAt(0) == " ")
				{
					s = s.substr(1, s.length - 1);
					offset += 1;
				}
				// measure it and start over
				x.text = s;
			}
			offset += s.length + 1; // take into account the \r at the end of line
		}
		return r;
	}

/**
* @private
* listen to keyboard so we can react to pageUp and pageDown.
*/
	function keyDown(e:Object):Void
	{
		var k:Number = e.code;
		if (k == Key.PGDN)
		{
			var rows:Number = label.bottomScroll - label.scroll + 1;
			var r:Array = getLineOffsets();
			var g:Number = Math.min(label.bottomScroll + 1, label.maxscroll);
			if (g == label.maxscroll)
			{
				var l:Number = label.length;
				Selection.setSelection(l, l);
			}
			else
			{
				label.scroll = g;
				Selection.setSelection(r[g-1], r[g-1]);
			}
		}
		else if (k == Key.PGUP)
		{
			var rows:Number = label.bottomScroll - label.scroll + 1;
			var r:Array = getLineOffsets();
			var g:Number = label.scroll - 1;
			if (g < 1)
			{
				Selection.setSelection(0, 0);
			}
			else
			{
				Selection.setSelection(r[g-1], r[g-1]);
				label.scroll = Math.max(g - rows, 1);
			}
		}
	}

	// draw by resetting the text and therefore the scrollbars
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

		l.multiline = true;
		l.wordWrap = (wordWrap == true);
//		if (l.wordWrap) __hScrollPolicy = "off";

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
		l.type = (editable == true) ? "input" : "dynamic";

		// for some reason the textfield resizes itself when initialized and
		// needs to be forced back to its new size
		size();
		l.background = false;
	}

	function adjustScrollBars()
	{
		var l = label;
		var visibleRows = l.bottomScroll-l.scroll + 1;
		var rows:Number =  visibleRows + l.maxscroll - 1;
		if (rows < 1) rows = 1;

		var hWidth = 0;
		if (l.textWidth + 5 > l._width) {
			if (!l.wordWrap) {
				hWidth = l._width + l.maxhscroll;
			}
		} else {
			l.hscroll=0;
			l.background = false;
		}

		// if not integral number of rows, fudge by 1
		if ((l.height/visibleRows) != Math.round(l.height/visibleRows))
		{
			rows--;
		}
		setScrollProperties(hWidth, 1, rows, l.height/visibleRows);

	}

 	function setScrollProperties(colCount:Number, colWidth:Number, rwCount:Number, rwHeight:Number, hPadding:Number, wPadding:Number):Void
 	{
 		super.setScrollProperties(colCount, colWidth, rwCount, rwHeight, hPadding, wPadding);
 		if (vScroller == undefined) hookedV = false;
 		if (hScroller == undefined) hookedH = false;
 	}
 		

/**
* tab order when using tab key to navigate
*
* @tiptext tabIndex of the component
* @helpid 3184
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
* @helpid 3185
*/
	 function set  _accProps(val:Object)
	 {
		 label._accProps = val;
	 }

	 function get  _accProps():Object
	 {
		 return label._accProps;
	 }

	function get styleSheet():TextField.StyleSheet
	{
		return label.styleSheet;
	}

	function set styleSheet(v:TextField.StyleSheet):Void
	{
		label.styleSheet = v;
	}

/**
* @tiptext Specifies if horizontal scrollbar is on, off or automatically adjusts
* @helpid 3427
*/
	var hScrollPolicy:String;	// just for metadata, actually a getter/setter
/**
* @tiptext Specifies if vertical scrollbar is on, off or automatically adjusts
* @helpid 3428
*/
	var vScrollPolicy:String;
}