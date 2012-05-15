/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import mx.utils.Delegate;
import mx.events.EventDispatcher;
import mx.controls.List;
import org.oof.OofBase;
import org.oof.dataIos.stringIos.TextFieldIo;

//color picker
import org.sepy.ColorPicker
/** this is oof's excuse for a text editor. It sucks, but it's all we have at the moment. 
 * @author Ariel Sommeria-klein
 * */
class org.oof.ui.TextEditor extends OofBase
{
	// constants
	var INDENT_STEP_POINTS:Number=20;
	
	// _targetTextFieldIo.ioTextField text field io
    private var _targetTextFieldIoPath:String; 
	private var _targetTextFieldIo:TextFieldIo;
	var _format:TextFormat;
	var dispatchEvent;
	
	/* _useEmbeddedFonts
	 * if true, then use [font name]+"_bold" instead of <b> tag
	 * same for italic
	 */
	var _useEmbeddedFonts:Boolean;
	//select
	var endSelec:Number;
	var startSelec:Number;
	var caretSelec:Number
	var currentFocus;
	//text
	//var _text:TextField;
	//btn
	var bold_btn:MovieClip;
	var italic_btn:MovieClip;
	var underline_btn:MovieClip;
	var align_left_btn:MovieClip;
	var align_center_btn:MovieClip;
	var align_right_btn:MovieClip;
	var align_justify_btn:MovieClip;
	var bullet_btn:MovieClip;
	var indent_more_btn:MovieClip;
	var indent_less_btn:MovieClip;
	var blocIndent_more_btn:MovieClip;
	var blocIndent_less_btn:MovieClip;
	var reset_btn:MovieClip;
	var fontList:List;
	var sizeList:List;
	var colorPicker;
	// numeric stepers
	//var leading_stp:mx.controls.NumericStepper;
	//var spacing_stp:mx.controls.NumericStepper;
	var leading_tf:TextField;
	var spacing_tf:TextField;
	var right_btn:Button;
	var left_btn:Button;
	
	//listeners
	var fontListListener:Object;
	var sizeListListener:Object;
	var colorListener:Object;
	
	// hasFocus is true when _targetTextFieldIoPath.ioTextFieldIo.ioTextField has focus
	var hasFocus:Boolean=false;

	public function TextEditor():Void
	{
		typeArray.push("org.oof.ui.TextEditor");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tryToLinkWith(_targetTextFieldIoPath, Delegate.create(this, doOnTargetTextFieldIoFound));
/*		if (useEmbeddedFonts!=undefined) _useEmbeddedFonts=useEmbeddedFonts;
		else
		*/
	}
	
	/** function doOnTargetTextFieldIoFound
	*@returns void
	*/
	function doOnTargetTextFieldIoFound(oofComp:OofBase){
		_targetTextFieldIo = TextFieldIo(oofComp);
//		 _useEmbeddedFonts = _targetTextFieldIo.ioTextField.embedFonts = true;
        _format = _targetTextFieldIo.ioTextField.getTextFormat();
		startSelec = endSelec = caretSelec = 0;
		//listener
		Selection.addListener(this);
		//Btn actions
		bold_btn.onRelease = Delegate.create(this, toBold);
		italic_btn.onRelease = Delegate.create(this, toItalic);
		underline_btn.onRelease = Delegate.create(this, toUnderline);
		bullet_btn.onRelease = Delegate.create(this, toBullet);
		blocIndent_more_btn.onRelease = Delegate.create(this, toBlocIndentMore);
		blocIndent_less_btn.onRelease = Delegate.create(this, toBlocIndentLess);
		indent_more_btn.onRelease = Delegate.create(this, toIndentMore);
		indent_less_btn.onRelease = Delegate.create(this, toIndentLess);
		align_left_btn.onRelease = Delegate.create(this, toAlignLeft);
		align_center_btn.onRelease = Delegate.create(this, toAlignCenter);
		align_right_btn.onRelease = Delegate.create(this, toAlignRight);
		align_justify_btn.onRelease = Delegate.create(this, toAlignJustify);
		//
		reset_btn.onRelease = Delegate.create(this, resetFormat);

		// **
		// steppers
		right_btn.onRelease=Delegate.create(this, leadingMore);
		left_btn.onRelease=Delegate.create(this, leadingLess);
		leading_tf.onChanged=Delegate.create(this, leadingChanged);
		//leading_tf.onKillFocus=Delegate.create(this, triggerRenew);
		leading_tf.onSetFocus=Delegate.create(this, refocus);
		//leading_tf.restrict="0-9 \-";
		spacing_tf.onChanged=Delegate.create(this, spacingChanged);
		spacing_tf.onKillFocus=Delegate.create(this, triggerRenew);
		spacing_tf.onSetFocus=Delegate.create(this, refocus);
		//spacing_tf.restrict="0-9 \-";
		if (!(parseInt(_global.getSilex().config.flashPlayerVersion)>7))
			spacing_tf._visible=false;
		
/*		With numeric steppers (focus bug) :
		var nstepListener:Object = new Object();
		nstepListener.change = Delegate.create(this, leadingChanged);
		nstepListener.focusIn = Delegate.create(this, refocus);
		// Add listener.
		leading_stp.addEventListener("change", nstepListener);
//		leading_stp.addEventListener("focusIn", nstepListener);
*/
/*		nstepListener = new Object();
		nstepListener.change = Delegate.create(this, spacingChanged);
		nstepListener.focusIn = Delegate.create(this, refocus);
		// Add listener.
		spacing_stp.addEventListener("change", nstepListener);
//		spacing_stp.addEventListener("focusIn", nstepListener);
*/		
		// **
		//font list
		if(silexPtr.isSilexServer){
			for(var fontIdx:Number=0;fontIdx<_global.getSilex().config.embeddedFont.length;fontIdx++){
				fontList.addItem(_global.getSilex().config.embeddedFont[fontIdx]);
			}
		}else{
			fontList.addItem("_sans");
			fontList.addItem("_serif");
			fontList.addItem("_typewriter");
			fontList.addItem("arial");
			fontList.addItem("arial_black");
			fontList.addItem("courier_new");
			fontList.addItem("impact");
			fontList.addItem("georgia");
			fontList.addItem("helvetica");
			fontList.addItem("tahoma");
			fontList.addItem("times_new_roman");
			fontList.addItem("verdana");
		}
		fontListListener = new Object();
		fontListListener.change = Delegate.create(this, fontChange);
		fontList.addEventListener("change",fontListListener);
		//font size
		sizeList.addItem("5");
		sizeList.addItem("6");
		sizeList.addItem("7");
		sizeList.addItem("8");
		sizeList.addItem("9");
		sizeList.addItem("10");
		sizeList.addItem("11");
		sizeList.addItem("12");
		sizeList.addItem("13");
		sizeList.addItem("14");
		sizeList.addItem("15");
		sizeList.addItem("16");
		sizeList.addItem("17");
		sizeList.addItem("18");
		sizeList.addItem("19");
		sizeList.addItem("20");
		sizeList.addItem("21");
		sizeList.addItem("22");
		sizeList.addItem("23");
		sizeList.addItem("24");
		sizeList.addItem("25");
		sizeList.addItem("26");
		sizeList.addItem("27");
		sizeList.addItem("28");
		sizeList.addItem("29");
		sizeList.addItem("30");
		sizeList.addItem("31");
		sizeList.addItem("32");
		sizeList.addItem("33");
		sizeList.addItem("34");
		sizeList.addItem("35");
		sizeList.addItem("36");
		sizeList.addItem("38");
		sizeList.addItem("40");
		sizeList.addItem("42");
		sizeList.addItem("44");
		sizeList.addItem("46");
		sizeList.addItem("48");
		sizeList.addItem("50");
		sizeList.addItem("55");
		sizeList.addItem("60");
		sizeList.addItem("65");
		sizeList.addItem("70");
		sizeList.addItem("72");
		sizeList.addItem("80");
		sizeList.addItem("90");
		sizeList.addItem("100");
		sizeListListener = new Object();
		sizeListListener.change = Delegate.create(this, sizeChange);
		sizeList.addEventListener("change",sizeListListener);

		//colorpicler
		colorListener = new Object();
		//color picker
/*		colorPicker.color = 0x006699
		// choose where the component will be opened
		colorPicker.direction = ColorPicker.UP_RIGHT
	*/	// register event listener
		colorPicker.addListener(colorListener)
		// when the component change
		colorListener.change = Delegate.create(this, colorChange);
	
		//get selections indices
		//this.setSelectionValues();
	}
	
	function setSize(w:Number,h:Number){
		sizeList.setSize(sizeList.width,h);
		fontList.setSize(fontList.width,h);
	}
	
	
	function leadingChanged(_tf:TextField){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.leading = parseInt(_tf.text);
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
		//refocus();
	}
	var LEADING_DELTA:Number=1;
	function leadingMore(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
		if (!_format.leading) _format.leading=LEADING_DELTA;
        _format.leading += LEADING_DELTA;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		leading_tf.text=_format.leading.toString();
		//Set focus on textfield
		triggerRenew();
		//refocus();
	}
	function leadingLess(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
		if (!_format.leading) _format.leading=LEADING_DELTA;
        _format.leading -= LEADING_DELTA;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		leading_tf.text=_format.leading.toString();
		//Set focus on textfield
		triggerRenew();
		//refocus();
	}
	// ONLY FOR FP 8
	function spacingChanged(_tf:TextField){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format["letterSpacing"] = parseInt(_tf.text);
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		//triggerRenew();
		//refocus();
	}
	
/*	With numeric stepper - bug focus
	function leadingChanged(evt_obj:Object){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.leading = evt_obj._targetTextFieldIo.ioTextField.value;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		//triggerRenew();
		//refocus();
	}
	
	// ONLY FOR FP 8
	function spacingChanged(evt_obj:Object){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format["letterSpacing"] = evt_obj._targetTextFieldIo.ioTextField.value;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		//triggerRenew();
		//refocus();
	}
*/	
	function colorChange(evt_obj:Object){
		var color = '0x'+evt_obj.getRGB()
		toColor (color);
		triggerRenew();
	}
	
	function fontChange(evt_obj:Object){
		var font:String = evt_obj.target.value;
		toFont( font );		
		triggerRenew();
	}
	
	function sizeChange(evt_obj:Object){
		var size:Number = evt_obj.target.value;
		toSize( size );
		triggerRenew();
	}
	
    function toBold(){
		if (_useEmbeddedFonts==true){
			if (!_format.font){
				return;
			}
			if (isBold==false){
				// prevent from being italic ADN bold
				if (isItalic==true) toItalic();
				
				toFont(_format.font+"_bold");
			}
			else{
				var _str:String=_format.font.substring(0,_format.font.lastIndexOf("_bold"));
				toFont(_str);
			}
		}
		else{
		   _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
	        _format.bold = !_format.bold;
	        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
			//Set focus on textfield
			triggerRenew();
		}
    } 
	
	
    function toItalic(){
		if (_useEmbeddedFonts==true){
			if (!_format.font){
				return;
			}
			if (isItalic==false){

				// prevent from being italic ADN bold
				if (isBold==true) toBold();
				
				toFont(_format.font+"_italic");
			}
			else{
				var _str:String=_format.font.substring(0,_format.font.lastIndexOf("_italic"));
				toFont(_str);
			}
		}
		else{
	        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
	        _format.italic = !_format.italic;
	        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
			//Set focus on textfield
			triggerRenew();
		}
    }
	
	
	function toBlocIndentMore(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.blockIndent += INDENT_STEP_POINTS;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	function toBlocIndentLess(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.blockIndent -= INDENT_STEP_POINTS;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	function toIndentMore(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.indent += INDENT_STEP_POINTS;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	function toIndentLess(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.indent -= INDENT_STEP_POINTS;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	function toBullet(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.bullet = !_format.bullet;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
    function toUnderline(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.underline = !_format.underline;
	    _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    }
	
	function toAlignLeft(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.align = 'left';
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	
	function toAlignCenter(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.align = 'center';
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	
	function toAlignRight(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.align = 'right';
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	// FLASH 8 ONLY
	function toAlignJustify(){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.align = 'justify';
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
	
	
	
	
    function toColor(n){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.color = n;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    }
	
	
    function toFont(s){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.font = s;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    } 
		
		
    function toSize(n){
        _format = _targetTextFieldIo.ioTextField.getTextFormat(startSelec, endSelec);
        _format.size = n;
        _targetTextFieldIo.ioTextField.setTextFormat(startSelec, endSelec, _format);
		//Set focus on textfield
		triggerRenew();
    }
	

	function resetFormat(){
		
		var tf = new TextFormat();
		tf.font = "_sans";
		tf.size = 12;
		tf.align = "left";
		tf.italic = tf.bold = tf.underline = false;
		tf.leading = 2;
		tf.bullet = false;
		tf.blockIndent = tf.indent = tf.leftMargin = tf.rightMargin = tf.bullet = false;
		tf.color = 0;
		tf.url = null;
		tf._targetTextFieldIo.ioTextField = 0;
		tf["letterSpacing"] = 0;
		tf.kerning = false;
		triggerRenew();
    }
	
	function get format(){
        return _format;
    }
	
	
	function onSetFocus(oldFocus, newFocus){

	   //current
	   currentFocus = newFocus
	   
	   //add listener
	   if (newFocus == _targetTextFieldIo.ioTextField){
            Mouse.addListener(this);
            Key.addListener(this);
			refocus();
			hasFocus=true;
        }
        else{
			hasFocus=false;
			if (oldFocus == _targetTextFieldIo.ioTextField){
				//remove listener
			   Mouse.removeListener(this);
	           Key.removeListener(this);
	        }
		}
    }
	
	function refocus(){
		
		if(startSelec != endSelec){
			Selection.setSelection(startSelec, endSelec);
		}else{
			Selection.setSelection(caretSelec, caretSelec);
		}
	}
	
	
	
	function onMouseUp(){
		this.setSelectionValues();
		//dispatch renew
		//this.triggerRenew();
    }
	
	var onChanged:Function;
	function triggerRenew(){
		// give the focus to _targetTextFieldIo.ioTextField
		Selection.setFocus(_targetTextFieldIo.ioTextField);
        Selection.setSelection(startSelec, endSelec);		
       // this.dispatchEvent({type: "formatRenew", _targetTextFieldIo.ioTextField: this});
	   this.dispatchEvent({type: "change", target: this});
	   if (onChanged) onChanged();
    }
	

	
    function onKeyDown(){
       // keyDownCaret = caret;
    }
	
    function onKeyUp(){
		
        this.setSelectionValues();
        var keyCode = Key.getCode();
        if (keyCode == 39 || keyCode == 37 || keyCode == 38 || keyCode == 40)
        {
           // newFormat = {};
        }
		//dispatch renew
        triggerRenew();
    } 
	
	
    function setSelectionValues(){
		if (hasFocus!=true)
			return;
	
        if (_format.size == 2)
        {
            if (Key.getCode() == 37)
            {
                Selection.setSelection(caretSelec - 2, caretSelec - 2);
            }
            else
            {
                Selection.setSelection(caretSelec + 2, caretSelec + 2);
            }
        }
		//get indexes
        startSelec = Selection.getBeginIndex();
        endSelec = Selection.getEndIndex();
        caretSelec = Selection.getCaretIndex();
		
		displayCurrentFont();
    }
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// display font of current selection
	var _isBold:Boolean=false;
	function set isBold(value:Boolean){
		_isBold=value;
		//isBold_mc._visible=_isBold;
	}
	function get isBold():Boolean{
		return _isBold;
	}
	////
	var _isItalic:Boolean=false;
	function set isItalic(value:Boolean){
		_isItalic=value;
		//isItalic_mc._visible=_isItalic;
	}
	function get isItalic():Boolean{
		return _isItalic;
	}
	///
	function displayCurrentFont(){
		var idx:Number;
		var _str:String;
		_format=_targetTextFieldIo.ioTextField.getTextFormat(startSelec,endSelec);
		//////////////////////////////////////
		// display font in the font list
		_str=_format.font;
		// case bold
		idx=_str.lastIndexOf("_bold");
		if (idx>-1){
			_str=_str.substring(0,idx);
			isBold=true;
		}
		else{
			isBold=false;
		}
		// case italic
		idx=_str.lastIndexOf("_italic");
		if (idx>-1){
			_str=_str.substring(0,idx);
			isItalic=true;
		}
		else{
			isItalic=false;
		}
		// display corresponding font
		setListSelection(fontList,_str);

		//////////////////////////////////////
		// display font size in the font size list
		setListSelection(sizeList,_format.size);
		
		/////////////////////////////////////
		// steppers
		if (_format["letterSpacing"]!=undefined)
			spacing_tf.text=_format["letterSpacing"].toString();
			//spacing_stp.value=_format["letterSpacing"] ;
		if (_format.leading!=undefined)
			leading_tf.text=_format.leading.toString();
			//leading_stp.value=_format.leading;
	}
	function setListSelection(_lst:List,itemValue):Boolean{
		//if (!itemValue) _lst.selectable=false;
		
		for (var idx:Number=0;idx<_lst.length;idx++){
			if (_lst.getItemAt(idx).label==itemValue){
				_lst.selectedIndex=idx;
				_lst.vPosition=idx;
				return true;
			}
		}
		_lst.selectedIndex=-1;
		_lst.selectedItem=undefined;
		return false;
	}


	/** function set targetTextFieldIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="")]
	public function set targetTextFieldIoPath(val:String){
		_targetTextFieldIoPath = val;
	}
	
	/** function get targetTextFieldIoPath
	* @returns String
	*/
	
	public function get targetTextFieldIoPath():String{
		return _targetTextFieldIoPath;
	}		
}