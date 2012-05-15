//****************************************************************************
//Copyright (C) 2004 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product. 
//****************************************************************************

import mx.controls.scrollClasses.ScrollBar;
import mx.core.UIObject;
[IconFile("VScrollBar.png")]

class mx.controls.UIScrollBar extends ScrollBar

{
	static var symbolName:String = "UIScrollBar";
	static var symbolOwner:Object = UIScrollBar;
	var className:String = "UIScrollBar";
	var clipParameters:Object = {_targetInstanceName:1,horizontal:1};
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(UIScrollBar.prototype.clipParameters);
	var textField:TextField;
	var wasHorizontal:Boolean;
	var hScroller:Object; 
	var vScroller:Object;
	var synchScroll:Number;
	var onChanged;
	var onScroller;
	
	function UIScrollBar () 
	{	
	}
//#include "../core/ComponentVersion.as"

	function init (Void):Void
	{
		super.init();
		textField.owner = this;
		horizontal = wasHorizontal;
		if (horizontal)
		{	
			if (textField != undefined)
				super.setSize(textField._width,16);
			else
				super.setSize(__width,__height);
		}else{
			if (textField != undefined) 
				super.setSize(16,textField._height);
			else 
				super.setSize(__width,__height);
		}
		
		if(horizontal)
		{
			var t = __width;
			__height =__width;
			width = t;
			__width = 16;
		}
					
		textField.onScroller = function()
		{
			this.hPosition = this.hscroll;
			this.vPosition = this.scroll - 1;
		};
		
		if (_targetInstanceName != undefined)
		{
			setScrollTarget(_targetInstanceName);
			_targetInstanceName.addListener(this); 
		}	
	}

	[Inspectable(_targetInstanceName="")]
	function get _targetInstanceName():TextField
	{
		 return textField;
	}
	
	function get height() 
	{
		if (wasHorizontal) {
			return __width;
		}else{
			return __height;
		}
	}
	
	function get width() 
	{
		if (wasHorizontal) {
			return __height;
		}else{
			return __width;
		}
	}

	function size(Void):Void
	{
		super.size();
		onTextChanged();
	}
	
	function draw()
	{
		super.draw();
	}

	function set _targetInstanceName(t:TextField)
	{
		if (t == undefined)
		 {
		 	textField.removeListener(this);
		 	delete textField[ (horizontal) ? "hScroller" : "vScroller" ]; 
		 	if (!(textField.hScroller==undefined) && !(textField.vScroller==undefined))
		 	 {
				textField.unwatch("text");
				textField.unwatch("htmltext");
			}
		}
	
		var ref = _parent[t];
		textField = _parent[t];
		onTextChanged();
	}
	
	function setSize(w,h)
	{
		if (horizontal) {
			super.setSize(h,w);
		}else{
			super.setSize(w,h);
		}
	}
	function onTextChanged(Void):Void
	{
		if (textField==undefined) return;
		clearInterval(synchScroll);
		if (horizontal) 
		{
			var pos = textField.hscroll;
			setScrollProperties(textField._width, 0, textField.maxhscroll);
			scrollPosition = Math.min(pos, textField.maxhscroll);

		} 
		else 
		{
			var pos = textField.scroll;
			var pageSize = textField.bottomScroll - textField.scroll;
			setScrollProperties(pageSize, 1, textField.maxscroll);
			scrollPosition = Math.min(pos, textField.maxscroll);
		}
	}
	
	[Inspectable(defaultValue=false)]
	function get horizontal():Boolean
	{
		 return wasHorizontal;
		
	}
	
	function set horizontal(v:Boolean)
	{
		//rotate sb 
		wasHorizontal = v;
		if ( v && initializing ) {
			if (_rotation ==  90 ) return;
			_xscale = -100;
			_rotation = -90;
		}
		
		if (!initializing) 
		{
			if (v)
			{
				if (_rotation == 0 )
				{
					_rotation = -90;
					_xscale = -100;
				}
			}
			else
			{
				if (_rotation == -90 ) 
				{
					_rotation = 0;
					_xscale = 100;
				}
			}
		}
	}	
	
	function callback(prop:String, oldval:String, newval:String):String
	{	
		clearInterval(hScroller.synchScroll);
		clearInterval(vScroller.synchScroll);
		hScroller.synchScroll = setInterval(hScroller, "onTextChanged", 50);
		vScroller.synchScroll = setInterval(vScroller, "onTextChanged", 50);
		return newval;	
	}	

	function setScrollTarget(tF:TextField):Void
	{	
			if (tF == undefined)
			{
				textField.removeListener(this);
				delete textField[ (horizontal) ? "hScroller" : "vScroller" ]; 
				if (!(textField.hScroller==undefined) && !(textField.vScroller==undefined))
				{
					textField.unwatch("text");
					textField.unwatch("htmltext");
				}
			}
			textField = undefined;
			if (!(tF instanceof TextField)) return;
			textField = tF;
			if (horizontal)
			{
				textField.hScroller = this;
				textField.hScroller.lineScrollSize = 5;
			}
			else
			{
				textField.vScroller = this;
				textField.vScroller.lineScrollSize = 1;
			}
			onTextChanged();		
	
			this.onChanged = function(Void):Void
			{
				this.onTextChanged();
			};
			
			this.onScroller = function(Void):Void
			{
				if (!this.isScrolling) 
				{
					if (!this.horizontal)
					{
						this.scrollPosition = this.textField.scroll;
					}
					else
					{ 
						this.scrollPosition = this.textField.hscroll;
					}
				}
			};
			textField.addListener(this);
			textField.watch("text", callback);
			textField.watch("htmlText", callback);	
	}
	
	function scrollHandler(Void):Void
	{
		if (horizontal) 
		{
			//bug with textField causes background to be set when hscroll is set
			var bc = textField.background;
			textField.hscroll = scrollPosition;
			textField.background = bc;
		}
		else
		{
			textField.scroll = scrollPosition;
		}
	}
	
	function setEnabled(enable:Boolean):Void
	{
		super.setEnabled(enable);
		if (enable)
		{
			textField.addListener(this);
		}
		else
		{
			textField.removeListener();
		}
	}
	
	function dispatchScrollEvent(detail:String):Void
	{
		dispatchEvent({type: "scroll"});
	}
	
	private static var VScrollBarDependency = mx.controls.VScrollBar;
	private static var HScrollBarDependency = mx.controls.HScrollBar;
		
}