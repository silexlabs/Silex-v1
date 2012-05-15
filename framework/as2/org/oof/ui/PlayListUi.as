/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is an extension of list ui, but adds next and previous buttons, and coordinates 
 * a display with a list for playlist functionalities, such as jumping to the next media 
 * in the playlist once the preceding one has finished playing.
 * If the list is not derived from oofbase, 
 * use a finder(org.oof.util.Finder)with it, otherwise it won't be possible for listUi 
 * to link with it.
 * @author Ariel Sommeria-klein
 * */
import org.oof.ui.ListUi;
import org.oof.OofBase;
import org.oof.dataIos.Display;
import mx.utils.Delegate;

class org.oof.ui.PlayListUi extends ListUi{
	var _displayPath:String = null;
	var _automaticNext:Boolean = null;
	var _display:Display = null;

	
	public function PlayListUi(){
		super();
		_className = "org.oof.ui.PlayListUi";
		typeArray.push("org.oof.ui.PlayListUi");
	}
	
	/**
	 * when movieclip is transformed to UIoObject
	 */
	 public function _onLoad(){		
	 	super._onLoad();
		tryToLinkWith(_displayPath, Delegate.create(this, doOnDisplayFound));		
						
	}
	
	function doOnDisplayFound(oofComp:OofBase){
		_display = Display(oofComp);
		_display.addEventListener(Display.EVENT_END, Delegate.create(this, displayEnd));
		_display.addEventListener(Display.EVENT_ERROR, Delegate.create(this, displayEnd));
	}
	 /** function doOnListFound
	*@returns void
	*/
	
	function displayEnd(){
		if(automaticNext){
			nextItem();
		}
	}
	
	
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** function set displayPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="display",type=String, defaultValue="")]
	public function set displayPath(val:String){
		_displayPath = val;
	}
	
	/** function get displayPath
	* @returns String
	*/
	
	public function get displayPath():String{
		return _displayPath;
	}			

	
	/** 
	 * property: automatic next
	 * Once the media being played in the display is finished, go to next without having to click "next"
	 * */
	[Inspectable(name="automatic next",type=Boolean, defaultValue=false)]
	public function set automaticNext(val:Boolean){
		_automaticNext = val;
	}
	
	/** function get automaticNext
	* @returns Boolean
	*/
	
	public function get automaticNext():Boolean{
		return _automaticNext;
	}			
}