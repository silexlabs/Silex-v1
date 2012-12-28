/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is a button that calls a method on a component when clicked. Mostly useful in Flash,
 * as in Silex there are commands. 
 * @author Ariel Sommeria-klein
 * */

import org.oof.OofBase;
import mx.utils.Delegate;
import mx.controls.Button;
class org.oof.ui.ActionButton extends OofBase{
	static private var className:String = "org.oof.ui.ActionButton";
	private var _caption:String;
	private var _targetComponentPath:String;
	private var _targetComponent:OofBase = null;
	private var _targetFunction:Function = null;
	private var _targetComponentMethod:String;
	var callBtn:Button;
	var getAuthoringUiTxt:TextField;
	
	public function ActionButton():Void
	{
		typeArray.push("org.oof.ui.ActionButton");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tabChildren = true;
		callBtn.label = _caption;
		getAuthoringUiTxt.onSetFocus = Delegate.create(this, openUi);
		tryToLinkWith(_targetComponentPath, Delegate.create(this, doOnTargetComponentFound));
	}
	
	/** function doOnTargetComponentFound
	*@returns void
	*/
	function doOnTargetComponentFound(oofComp:OofBase){
		_targetComponent = oofComp;
		_targetFunction = Delegate.create(oofComp, _targetComponent[_targetComponentMethod]);
		callBtn.onRelease = _targetFunction;
	}
	

	 
	 function openUi(){
		var container:MovieClip = createEmptyMovieClip("container", getNextHighestDepth());
		container._x = width;
		var mcLoader:MovieClipLoader = new MovieClipLoader();
		mcLoader.addListener(this);
		mcLoader.loadClip("ActionButtonUi.swf", container);
		//_root.xch = this;		 
	 }
	
	function onLoadInit(target_mc:MovieClip){
		target_mc.instance3.propertyHolder = this;
	}
	/** function set targetComponentPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="")]
	public function set targetComponentPath(val:String){
		_targetComponentPath = val;
	}
	
	/** function get targetComponentPath
	* @returns String
	*/
	
	public function get targetComponentPath():String{
		return _targetComponentPath;
	}		
	
	/** function set targetComponentMethod
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="")]
	public function set targetComponentMethod(val:String){
		_targetComponentMethod = val;
	}
	
	/** function get targetComponentMethod
	* @returns String
	*/
	
	public function get targetComponentMethod():String{
		return _targetComponentMethod;
	}		
	
	/** function set caption
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="")]
	public function set caption(val:String){
		_caption = val;
	}
	
	/** function get caption
	* @returns String
	*/
	
	public function get caption():String{
		return _caption;
	}	
}