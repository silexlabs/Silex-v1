/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.utils.Delegate;
import org.oof.dataUsers.DataSelector;
/** this is a user interface for filtering in a data selector. Not sure if this still works,  or 
 * is necessary. 
 * @author Ariel Sommeria-klein
 * */
class org.oof.ui.FilterUi extends OofBase{
	var doFilter_btn:MovieClip;
	private var _selector:DataSelector = null;
	private var _selectorPath:String = null;
	private var _filterFunctionName:String = null;
	private var _key:String = null;
	private var _fieldPath:String;
	
	public function FilterUi():Void
	{
		typeArray.push("org.oof.ui.FilterUi");
	}
	
	/**
	 * when movieclip is transformed to UIoObject
	 */
	 public function _onLoad(){		
	 	 
	 	super._onLoad();
		tryToLinkWith(_selectorPath, Delegate.create(this, doOnSelectorFound));
		doFilter_btn.onPress = Delegate.create(this, doFilter);
		if(traceClassOnLoad){
		}

		
	}
	/**function doFilter
	* sets the selector list filter functions and asks it to render the list again
	*/
	
	function doFilter(){
		_selector.listFilterCallback = Delegate.create(this, filter);
		_selector.refreshList();
	}
	 
	/**function filter
	* called by the selector
	* @returns true if item should be shown, false otherwise
	*/
	
	function filter(item:Object){
		var dat:String = getObjAtPath(item, _fieldPath);
		var indexOfKey:Number = dat.indexOf(key);
		if(_filterFunctionName == "contains"){
			return (indexOfKey != -1);
		}else{
			return (indexOfKey == -1);
		}
	}
	
	/** function doOnSelectorFound
	*@returns void
	*/
	function doOnSelectorFound(oofComp:OofBase){
		_selector = DataSelector(oofComp);
	}
	
	/** function set selectorPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="selector", type=String, defaultValue="")]
	public function set selectorPath(val:String){
		_selectorPath = val;
	}
	
	/** function get selectorPath
	* @returns String
	*/
	
	public function get selectorPath():String{
		return _selectorPath;
	}		

	/** function set filterFunctionName
	* @param val(String)
	* @returns void
	*/
    [Inspectable(name="type", enumeration="contains,excludes",defaultValue="contains")]
	public function set filterFunctionName(val:String){
		_filterFunctionName = val;
	}
	
	/** function get filterFunctionName
	* @returns String
	*/
	
	public function get filterFunctionName():String{
		return _filterFunctionName;
	}		

	/** function set key
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="")]
	public function set key(val:String){
		_key = val;
	}
	
	/** function get key
	* @returns String
	*/
	
	public function get key():String{
		return _key;
	}		

	/** function set fieldPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="field path", type=String, defaultValue="")]
	public function set fieldPath(val:String){
		_fieldPath = val;
	}
	
	/** function get fieldPath
	* @returns String
	*/
	
	public function get fieldPath():String{
		return _fieldPath;
	}	

}