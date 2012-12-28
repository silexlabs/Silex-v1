//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.containers.Window;
import mx.controls.alertClasses.AlertForm;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;

[RequiresDataBinding(true)]
[IconFile("Alert.png")]
[InspectableList("")] 



/**
* a alert window with a title bar, caption
* The title bar can be used to drag the alert window to a new location.
*
* @helpid 3350
* @tiptext Alert displays a message with button(s) and optional title
*/
class mx.controls.Alert extends Window
{
	static var symbolOwner:Object = Window;
	//#include "../core/ComponentVersion.as"
/**
* width of Alert buttons 
*
* @tiptext Gets or sets the width of the buttons
* @helpid 3501
*/
	static var buttonWidth:Number = 50;
/**
* height of Alert buttons 
*
* @tiptext Gets or sets the height of the buttons
* @helpid 3502
*/
	static var buttonHeight:Number = 22;
/**
* label for OK button
*
* @tiptext Gets or sets the label for the OK button
* @helpid 3351
*/
	static var okLabel:String = "OK";
/**
* label for YES button
*
* @tiptext Gets or sets the label for the YES button
* @helpid 3352
*/
	static var yesLabel:String = "Yes";
/**
* label for NO button
*
* @tiptext Gets or sets the label for the NO button
* @helpid 3353
*/
	static var noLabel:String = "No";
/**
* label for CANCEL button
*
* @tiptext Gets or sets the label for the CANCEL button
* @helpid 3354
*/
	static var cancelLabel:String = "Cancel";
/**
* symbol name for the up state for the alert buttons
*/
	static var buttonUp:String = "ButtonSkin";
/**
* symbol name for the down state for the alert buttons
*/
	static var buttonDown:String = "ButtonSkin";
/**
* symbol name for the over state for the alert buttons
*/
	static var buttonOver:String = "ButtonSkin";
/**
* symbol name of skin element for background of the title bar
*/
	static var titleBackground:String = "TitleBackground";
/**
*  symbol name of skin element for emphasized up button state
*/	
	static var buttonUpEmphasized:String = "ButtonSkin";
/**
* symbol name of skin element for emphasized over button state
*/
	static var buttonOverEmphasized:String = "ButtonSkin";
/**
* symbol name of skin element for emphasized down button state
*/
	static var buttonDownEmphasized:String = "ButtonSkin";
	
/**
* style declaration name for the message text 
*
* @tiptext The CSSStyleDeclaration name for setting styles on the message text
* @helpid 3358
*/
	static var messageStyleDeclaration:String;
/**
* style declaration name for the text in the title bar
*
* @tiptext The CSSStyleDeclaration name for setting styles on the title text
* @helpid 3359
*/
	static var titleStyleDeclaration:String;
/**
* style declaration name for the button text
*
* @tiptext The CSSStyleDeclaration name for setting styles on the buttons
* @helpid 3360
*/
	static var buttonStyleDeclaration:String;
/**
* @private
* declare style object
*/
	static var style:Object;	
/**
* @private
* name this class
*/
	var className:String = "Alert";
/**
* @private
* declare backgoundColor 
*/
	var backgroundColor:Number;
/**
* @private
* allow for setSize 
*/	
	var allowSize:Boolean = false;
/**
* @private
* not _parent but the original parent for centering
*/
	var parent:MovieClip; 
/**
* @private
* assign hex values that are used later for bitwise comparison
*/
	static var NONMODAL:Number = 0x8000;
	static var YES:Number = 0x1;
	static var NO:Number = 0x2;
	static var OK:Number = 0x4;
	static var CANCEL:Number= 0x8;
	static var P:MovieClip = _root;
/**
* static method that shows the alert with title,message and requested buttons
*
* @tiptext A static method that displays an Alert dialog
* @helpid 3361
*/		
	static function show (text,title,flags,parent,listener,icon,defButton):Alert
	{
		
		var o = new Object();
		var modal = (flags & Alert.NONMODAL) ? false : true;
		if (parent == undefined){parent = o.parent = _root;}else{o.parent = parent;};
		o.okButton = (flags &  Alert.OK) ? true : false;
		o.cancelButton = (flags & Alert.CANCEL) ? true : false;
		o.yesButton = (flags &  Alert.YES) ? true : false;
		o.noButton = (flags &  Alert.NO) ? true : false;
		o.defButton = defButton;
		if (o.okButton == false && o.cancelButton == false && o.yesButton == false && o.noButton == false)
		{
			o.okButton = true;
			o.defButton = Alert.OK;
		}
		o.title = title;
		o.text = text;
		o.icon = icon;
		o.style = Alert.style;
		o.skinTitleBackground = Alert.titleBackground;
		o.titleStyleDeclaration = Alert.titleStyleDeclaration;
		o.validateNow = true;
		var m = PopUpManager.createPopUp(parent,Alert, modal, o);
		if (m == undefined) {
			trace("Failed to create a new alert, probably because there is no Alert in the Library");
		}
		m.addEventListener("click", listener);
		return m;
	}
	
	function Alert()
	{
	}
/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/	
	function init(Void):Void
	{
		super.init();
		visible = false;
	}
/**
* @private
* create child objects.
*/
	function createChildren(Void):Void
	{
		if (Alert.messageStyleDeclaration != undefined)
			styleName = Alert.messageStyleDeclaration;
		var tmp = AlertForm;
		contentPath = tmp;
		
		super.createChildren();
	}
/**
* get the thickness of the edges of the object taking into account the border, title bar and scrollbars if visible
* @return object with left, right, top and bottom edge thickness in pixels
*/	
	function getViewMetrics(Void):Object
	{
		//-!! init __viewMetrics
		var o:Object = super.getViewMetrics();
		return o;
	}
/**
* @private
* layout the title bar and size the content below it
*/	
	function doLayout(Void):Void
	{
		super.doLayout();
	}
/**
* @private
* draw by making everything visible, then laying out
*/	
	function draw(Void):Void
	{
		
		var i:Boolean = initializing;
		super.draw();	
		if (i)
		{
			// center us in the window
			// parent and _parent may be different.
			var p:Object = new Object();
			p.x = parent._x; 
			p.y = parent._y; 
			parent.localToGlobal(p);	// p is now global coordinates of its position
			
			var w:Number = parent.width;
			var h:Number = parent.height;
			
			if ((parent == _root && parent._parent == undefined) || w == undefined) 
			{	
				// not a UIObject so center on stage or _root
				// so center on Stage
				var s:Object = SystemManager.screen;
				w = s.width;
				h = s.height;
				p.x = s.x;
				p.y = s.y;
			}
			//prevent the instance from offsetting multiple instances in during LP
			if (_global.isLivePreview)
			{
				return;
			}
			p.x += (w - width) / 2;
			p.y += (h - height) / 2;
			parent.globalToLocal(p);
			move(p.x, p.y);
			
			if (_child0.defButtonName != undefined)
			{
				_child0[_child0.defButtonName].setFocus();
			}else{
				_child0.buttons[0].setFocus();
			}
		}
	}
/**
* @private
* size according to width and height
*/	
	function size(Void):Void
	{
		if(_global.isLivePreview)
		{
			__width = width;
			__height = height;   
		}
		else
		{
			var s:Object = _child0.getSize();
			//prevent an Alert that is placed on stage from appearing really small.
			if (isNaN(s.width) || s.width < 20 ){s.width = 96;};
			if (isNaN(s.height) || s.height < 20 ){s.height = 66;};
			
			var m:Object = border_mc.borderMetrics;
			if (!allowSize)
			{
				__width = s.width + (2 * m.left);
				__height = s.height + m.top + m.bottom + back_mc.height;
				allowSize = false;
			}
			
		}
		super.size();
	}
/**
* size the Alert
*
* @param	w	width of the Alert
* @param	h	height of the Alert
*
*/	
	function setSize(w:Number, h:Number) 
	{
		__width = w;
		__height = h;
		initializing = allowSize = true;
		invalidate();
	}
	
}
