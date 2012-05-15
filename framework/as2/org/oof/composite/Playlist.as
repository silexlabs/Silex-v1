/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import org.oof.dataIos.Display;
import org.oof.dataUsers.DataSelector;
import org.oof.dataConnectors.RssConnector;
import mx.utils.Delegate;
/** This is a composite component, made for building playlists. This is a work in progress.
 * @author Ariel Sommeria-klein
 * */ 
class org.oof.composite.Playlist extends OofBase{
	//instanciated in init
	private var _connector:RssConnector = null;
	private var _selector:DataSelector = null;
	
	//outside of object, on stage
	private var _list:Object = null;
	private var _display:Display = null;

	private var _listPath:String = null;
	private var _displayPath:String = null;
	private var _loop:Boolean = null;
	private var _scriptUrl:String = null;
	
	public function Plalist():Void
	{
		typeArray.push("org.oof.composite.Playlist");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		var connectorInitObj = new Object();
		connectorInitObj.urlBase = "";
		_connector = RssConnector(attachMovie("RssConnector", playerName + "_connector", this.getNextHighestDepth(), connectorInitObj));
		var selectorInitObj = new Object();
		selectorInitObj.formName = _scriptUrl;
		selectorInitObj.selectedFieldNames = ["*"];
		selectorInitObj.cellFormat = "<<title>>";
		selectorInitObj.iconField = "<<link>>";
		selectorInitObj.whereClause = "";
		selectorInitObj.orderBy = "";
		selectorInitObj.count = 0;
		selectorInitObj.offset = 0;
		selectorInitObj.listBoxPath = "";
		selectorInitObj.outputFormats = new Array(_displayPath + ".value=<<link>>");
		_selector = DataSelector(attachMovie("DataSelector", playerName + "_selector", this.getNextHighestDepth(), selectorInitObj));
		_selector.addEventListener("onResult", Delegate.create(this, selectorOnResult));
		_selector.doOnConnectorFound(_connector);
		tryToLinkWith(_listPath, Delegate.create(this, doOnListFound));
		tryToLinkWith(_displayPath, Delegate.create(this, doOnDisplayFound));		
	}
	
	 /** function doOnListFound
	*@returns void
	*/
	function doOnListFound(oofComp:OofBase){
		_list = oofComp;
		_selector.doOnListFound(oofComp);		
		redraw();
	}
	
	function doOnDisplayFound(oofComp:OofBase){
		_display = Display(oofComp);
		_display.addEventListener(Display.EVENT_END, this);
	}
	
	function getNextIndex(currentIndex:Number, maxIndex:Number):Number{
		if(currentIndex == undefined){
			return 0;
		}else if(currentIndex == maxIndex){
			if(_loop){
				return 0;
			}else{
				return undefined;
			}
		}else{
			return currentIndex + 1;
		}
		
	}
	///////////////////////
	//listeners
	///////////////////////	

	function selectorOnResult(){
		_selector.selectedIndex = 0;
	}
	
	function displayDisplayEnd(){
		if(_list){
			//use list, that controls the selector
			_list.selectedIndex = getNextIndex(_list.selectedIndex, _list.length - 1);
		}else{
			//control selector directly
			_selector.selectedIndex = getNextIndex(_selector.selectedIndex, _selector._listResult.length - 1);
		}
			
	}
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** function set scriptUrl
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="rss_folder script url",type=String, defaultValue="")]
	public function set scriptUrl(val:String){
		_scriptUrl = val;
	}
	
	/** function get scriptUrl
	* @returns String
	*/
	
	public function get scriptUrl():String{
		return _scriptUrl;
	}			

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

	/** function set listPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="list",type=String, defaultValue="")]
	public function set listPath(val:String){
		_listPath = val;
	}
	
	/** function get listPath
	* @returns String
	*/
	
	public function get listPath():String{
		return _listPath;
	}			
	
	/** function set loop
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="list loop",type=Boolean, defaultValue=false)]
	public function set loop(val:Boolean){
		_loop = val;
	}
	
	/** function get loop
	* @returns Boolean
	*/
	
	public function get loop():Boolean{
		return _loop;
	}
	
}