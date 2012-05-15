/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.utils.Delegate;
/**
 * @author lex@silex-ria.org
 */
class org.lexayo.TransparentWModePatch
{
	/**
	 * true if the browser needs the patch to work properly
	 * mozilla, internet explorer
	 */
	var isPatchNeeded:Boolean = false;

	/**
	 * store the current TextField
	 */
	var currentTextField_txt;
	/**
	 * variables used to store carret position and selection range in the current TextField
	 */
	var caretIndexStart:Number = -1;
	var caretIndexEnd:Number = -1;
	
	/**
	 * implementation of the singleton pattern
	 * store the singleton instance
	 */
	static var _instance:TransparentWModePatch;
	/**
	 * implementation of the singleton pattern
	 */
	static function getInstance():TransparentWModePatch
	{
		if (_instance) return _instance;
		return new TransparentWModePatch(true);
	}

	/**
	 * constructor
	 */
	function TransparentWModePatch(isCalledByGetInstance:Boolean)
	{
		// check if getInstance was called (implementation of the singleton pattern)
		if (!isCalledByGetInstance || _instance)
		{
			throw(new Error("Use getInstance to create a new class (implementation of the singleton pattern)"));
			return;
		}
		
		// store the singleton instance
		_instance = this;
		
		// start the process
		// or wait for javascript to set the type of browser
		if (_root.browserTypeTransparentWModePatch)
			turnOnPatch("browserTypeTransparentWModePatch","",_root.browserTypeTransparentWModePatch);
		else
			// wait for javascript to set the type of browser
			_root.watch("browserTypeTransparentWModePatch", Delegate.create(this, turnOnPatch));
	}
	/**
	 * start the patch
	 * called by the system if there is a change in _root.browserTypeTransparentWModePatch (watch)
	 * or directly by the constructor
	 */
	function turnOnPatch(prop, oldVal, newVal)
	{
		if (newVal.indexOf("gecko")>-1 || newVal.indexOf("chrome")>-1 /* || newVal.indexOf("msie")>-1 */)
		{
			isPatchNeeded = true;
		}
		else
			return;
		
		// initialize listener for focus changes
		Selection.addListener(this);

		// initialise js communication
		_root.keyboardInputFromJS = "";
		_root.watch("keyboardInputFromJS", Delegate.create(this, keyboardInputChanged));
		
		// initialize the main loop
		/*
		var loopTransparentWModePatch_mc:MovieClip;
		loopTransparentWModePatch_mc = _root.createEmptyMovieClip("loopTransparentWModePatch_mc", _root.getNextHighestDepth());
		loopTransparentWModePatch_mc.onEnterFrame = Delegate.create(this, this.onEnterFrame);
		*/
		_global.getSilex().sequencer.addEventListener("onEnterFrame",Delegate.create(this, this.onEnterFrame));
	}
	/**
	 * handle focus changes
	 */
	function onSetFocus(oldfocus,newfocus) 
	{
		// store new TextField instance
		currentTextField_txt = newfocus;
		// store the new current value
		currentTextField_txt.wmodePatchText = currentTextField_txt.htmlText;
	}
	/**
	 * handle text changes
	 */
	function keyboardInputChanged(prop:String, oldVal:String, newVal:String)
	{
		// do nothing if we are not on an input text field
		if (!currentTextField_txt || (currentTextField_txt && currentTextField_txt.type != "input"))
			return "";

		
		// check for double byte in IE
		if (System.capabilities.playerType=="ActiveX" && newVal.length > 1)
		{
			//newVal = newVal.charAt(1);
		}
		
		// if there is a significant change
		if (currentTextField_txt.htmlText!=currentTextField_txt.wmodePatchText && !(Key.isDown(Key.CONTROL) && (String.fromCharCode(Number(newVal))=="c" || String.fromCharCode(Number(newVal))=="v" || String.fromCharCode(Number(newVal))=="x" || String.fromCharCode(Number(newVal))=="z")))
		{
			var initial_str:String = currentTextField_txt.htmlText;
			currentTextField_txt.htmlText = currentTextField_txt.wmodePatchText;
			switch(newVal) 
			{
			case "8":
				// backspace
				deleteBefore();
				break;
			case "12":
				// some artifact that happens when keyboard layouts are being switched
				// do nothing
			case "13":
				// enter
				Selection.setSelection(caretIndexStart,caretIndexEnd);
				currentTextField_txt.replaceText(caretIndexStart,caretIndexEnd,"\n");
				Selection.setFocus(currentTextField_txt);
				Selection.setSelection(caretIndexStart+1,caretIndexStart+1);
				break;
			case "46":
				// suppr
				// delete comes in as 46 but so does "."
				if (initial_str.length < currentTextField_txt.wmodePatchText.length)
				{
					// delete case
					deleteAfter();
					break;
				}
				// dot case
				// => continue to default
			default:
				Selection.setSelection(caretIndexStart,caretIndexEnd);
				currentTextField_txt.replaceText(caretIndexStart,caretIndexEnd,String.fromCharCode(Number(newVal)));
	//			currentTextField_txt.replaceSel(String.fromCharCode(Number(newVal)));
				Selection.setFocus(currentTextField_txt);
				Selection.setSelection(caretIndexStart+1,caretIndexStart+1);
			}
		}
		else
		{
			// copy, paste or anything which doesn't change the text
		}
		// store the new value
		currentTextField_txt.wmodePatchText = currentTextField_txt.htmlText;
		
		// return "" so that keyboardInputFromJS allways equals ""
		return "";
	}
	/**
	 * delete a character after the caret
	 */
	function deleteAfter ()
	{
		if (caretIndexStart == caretIndexEnd)
		{
			caretIndexStart++;
			caretIndexEnd++;
		}
			
		deleteBefore();
	}
	/**
	 * delete a character before the caret
	 */
	function deleteBefore()
	{
		if (caretIndexStart == caretIndexEnd && caretIndexStart>0) caretIndexStart--;
		
		if (currentTextField_txt.text.charAt(caretIndexEnd) == "")
		{
			if (currentTextField_txt.text.charAt(caretIndexStart-1) == "")
			{
				// erase all case (and of line and beginning of line)
				currentTextField_txt.text = "";
			}
			else
			{
				// end of line case
				Selection.setSelection(caretIndexStart,caretIndexEnd);
				currentTextField_txt.replaceText(caretIndexStart-1,caretIndexEnd,currentTextField_txt.text.charAt(caretIndexStart-1));
				Selection.setSelection(caretIndexStart,caretIndexStart);
			}
		}
		else
		{
			// not the end of the line case
			Selection.setSelection(caretIndexStart,caretIndexEnd);
			currentTextField_txt.replaceText(caretIndexStart,caretIndexEnd+1,currentTextField_txt.text.charAt(caretIndexEnd));
			Selection.setSelection(caretIndexStart,caretIndexStart);
		}
	}

	/**
	 * store the carret position and selection range in the current TextField
	 */
	function onEnterFrame () {
		

		// do nothing if we are not on an input text field
		if (!currentTextField_txt || (currentTextField_txt && currentTextField_txt.type != "input"))
			return;

		// init currentTextField_txt.wmodePatchText
		if (!currentTextField_txt.wmodePatchText)
			currentTextField_txt.wmodePatchText = currentTextField_txt.htmlText;
		
		// do nothing if we are waiting for js to correct the input which was just made
		if (currentTextField_txt.htmlText == currentTextField_txt.wmodePatchText)
		{
			//store the carret position and selection range in the current TextField
			caretIndexStart = Selection.getBeginIndex();
			caretIndexEnd = Selection.getEndIndex();
		}
	}
}