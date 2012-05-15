//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

//import mx.core.UIObject;
import mx.controls.Alert;
import mx.controls.Button;
import mx.controls.TextArea;
import mx.core.UIComponent;
import mx.managers.DepthManager;
import mx.skins.SkinElement;

/**
* form within the alert window containing 
* message,buttons, and/or icon
*
* @helpid 3362
* @tiptext
*/
class mx.controls.alertClasses.AlertForm extends UIComponent
{
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = UIComponent;
/**
* @private
* list of elements within the form 
*/
	var idNames:Array = [ "text_mc", "icon_mc" ];
/**
* @private
* declare textArea 
*/	
	var text_mc:TextArea;
/**
* @private
* declare SkinElement
*/	
	var icon_mc:SkinElement;
/**
* @private
* declare buttons array
*/
	var buttons:Array;
/**
* @private
* declare extent Object
*/
	var extent:Object;
/**
* @private
* declare detail - proxy for SimpleButtons
*/
	var detail:Number;
/**
* @private
* set defButtonName 
*/
	var	defButtonName:String = undefined;

	var textMeasure_mc:TextField;

	function AlertForm()
	{
	}
/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/	
	function init(Void):Void
	{
		super.init();
	}
/**
* @private
* sets the button to receive Focus
*/	
	function setDefaultButton():Void
	{
		_parent.focusManager.defaultPushButton = this[defButtonName];
	}
/**
* @private
* create child objects.
*/	
	function createChildren(Void):Void
	{
		tabChildren = true;
		tabEnabled = false;
		
		if (text_mc == undefined)
		{
			createClassObject(TextArea, "text_mc", 0, {styleName: this, borderStyle:"none", readOnly:true});
		}
		text_mc.tabEnabled = false;
		text_mc.tabChildren = false;
		text_mc.hScrollPolicy = "off";
		text_mc.vScrollPolicy = "off";
		text_mc.label.selectable = false;
		
 		// a rather heavy weight way of computing the height of window we need to contain our text.
 		if (textMeasure_mc == undefined)
 		{
 			createTextField("textMeasure_mc", -1, 0, 0, 0, 0);
 		}
 		textMeasure_mc._visible = false;
 		textMeasure_mc.multiline = true;
 		textMeasure_mc.wordWrap = true;
 		textMeasure_mc.autoSize = "left";

		if (icon_mc == undefined && _parent.icon != undefined)
		{
			setSkin(1, _parent.icon);
		}
		
		buttons = new Array();
		var defButton:Number = _parent.defButton;
		if (_parent.okButton)
		{
			createButton("okButton", Alert.okLabel, Alert.OK);
			if (defButton == Alert.OK)
				defButtonName = "okButton";
		}
		if (_parent.yesButton)
		{
			createButton("yesButton", Alert.yesLabel, Alert.YES);
			if (defButton == Alert.YES)
				defButtonName = "yesButton";
		}
		if (_parent.noButton)
		{
			createButton("noButton", Alert.noLabel, Alert.NO);
			if (defButton == Alert.NO)
				defButtonName = "noButton";
		}
		if (_parent.cancelButton)
		{
			createButton("cancelButton", Alert.cancelLabel, Alert.CANCEL);
			if (defButton == Alert.CANCEL)
				defButtonName = "cancelButton";
		}
		
		if (defButtonName != undefined)
		{
			this[defButtonName].emphasized = true;
			this[defButtonName].redraw(true);
			doLater(this, "setDefaultButton");
		}		
	}
	
	function createButton(name:String, title:String, detail:Number):Void
	{
		var ss = Alert.buttonStyleDeclaration;
		var o:Button = Button(createClassChildAtDepth(Button, DepthManager.kTop, 
						{falseUpSkin: Alert.buttonUp, falseDownSkin: Alert.buttonDown, falseOverSkin: Alert.buttonOver, falseOverSkinEmphasized: Alert.buttonOverEmphasized,
						 falseUpSkinEmphasized: Alert.buttonUpEmphasized, falseDownSkinEmphasized: Alert.buttonDownEmphasized,
						 styleName: (ss == undefined) ? this : Alert.buttonStyleDeclaration, validateNow:true}));
		o.setLabel(title);
		o.setSize(Alert.buttonWidth,Alert.buttonHeight);
		buttons.push(o);
		o.clickHandler = onClick;
		o.detail = detail;
		this[name] = o;
	}
	
/**
* @private
* get size according to contents of form 
*/	
	function getSize(Void):Object
	{
		var s:Object = new Object();
		s.height = buttons[0].height + (3 * 8);
		var tf2:Object = _parent.back_mc.title_mc._getTextFormat();
		extent = tf2.getTextExtent2(_parent.title) ;
 		s.width = Math.max( Math.max(2, buttons.length) * (buttons[0].width + 8),(extent.width) + 4 + 8);
		var tf:Object = text_mc._getTextFormat();
 		extent = tf.getTextExtent2(_parent.text);
 
 		// stick the text in the measuring TextField and let it flow baby
 		textMeasure_mc.embedFonts = tf["embedFonts"];
 		textMeasure_mc._width = 2*s.width;
 		textMeasure_mc.setNewTextFormat(text_mc._getTextFormat());
 		textMeasure_mc.text = _parent.text;
 		
 		// now the TextField height should have been adjusted since its' autoFlow
 		s.height += textMeasure_mc.textHeight + 8;
 		var numlines:Number = Math.ceil(textMeasure_mc.textHeight / extent.height);
 
		if (numlines > 1)
		{
			extent.width = 2* s.width;
			text_mc.wordWrap = true;
		}
			

//width is larger of buttons or text but not more than twice as wide as buttons
//  add extra 8 to extent.width for the 8 pixel galley on the right side

		var width:Number = Math.min(extent.width + 4 + 8, 2 * s.width);
		var bWidth = s.width;
		s.width = Math.max(width, s.width) + 8 ; 
		if (icon_mc != undefined)
		{

//calculate the additional width if we add the icon

			extent.width += icon_mc.width + 8;
			width = Math.min(extent.width + 4 + 8, 2 * bWidth);
			s.width = Math.max(width, s.width) + 8 ; 

//increase size if bigger

			var i:Number = icon_mc.height - (numlines * (extent.height + 4));
			if (i > 0)
				s.height += i;
		}
		return s;
	}
/**
* @private
* draw by making everything visible, then laying out
*/		
	function draw(Void):Void
	{
		size();
		_parent.visible = true;
	}
/**
* @private
* size according to form contents
*/
	function size (Void):Void
	{
//layout buttons first

		var y:Number = height - buttons[0].height - 8;
		var x:Number = buttons.length * (buttons[0].width + 8) - 8;

//center the buttons

		x = (width - x) / 2;
		for (var i:Number = 0; i < buttons.length; i++)
		{
			buttons[i].move(x, y);
			buttons[i].tabIndex = i + 1;
			x += buttons[i].width + 8;
		}

//pixel spacing around text

		y -= 8;
		x =  Math.max((width - extent.width - 4) / 2, 8);
		if (icon_mc != undefined)
		{

//center vertically

			icon_mc.move(x, (height - buttons[0].height - icon_mc.height) / 2);
			x += icon_mc.width + 8;
		}
		text_mc.move(x, 8);
		text_mc.setSize(width - x - 8, y - 8);
		if (_parent.text == undefined){
			text_mc.text = "";
		}else{
			text_mc.text = _parent.text;
		}
		
	}
/**
* @private
* on a button click, dismiss the popup and send notification
*/
	function onClick(evt:Object):Void
	{
		var mb:Alert = Alert(_parent._parent);
		
		mb.visible = false;
		mb.dispatchEvent({type:"click", detail:detail});
	
		mb.deletePopUp();
	}

}
	
