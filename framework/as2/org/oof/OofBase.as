/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.silex.ui.UiBase;
import org.silex.adminApi.util.ObjectDumper;
/**
 * base class for all oof components. Its main task is functionality for components to
 * find each other regardless of the order in which they are loaded.
 * this is the glue between a connector and inputs/outputs. 
 * @author Ariel Sommeria-klein
 * 
 * */
class org.oof.OofBase extends UiBase{
	static private var doTrace:Boolean = true;
	static private var traceClassOnLoad:Boolean = true;
	
	private var _className:String = null;
	static private var _alloofCompsList:Array = new Array();
	static private var _linkQueue:Array = new Array();
	static private var silexPtr:org.silex.core.Api = null;
	private var _onLoadEventOccurred:Boolean = false;
	
	/** visu_txt
	 * visualization text for Flash IDE
	 */
	private var visu_txt:TextField;

	
 /**
 * function constructor
 * @return void
 */
	function OofBase(){
		super();
		typeArray.push("org.oof.OofBase");
		//this bit about silex should be in a static constructor :-(
		playerName = _name; //will be replaced in uibase.onload if comp used in silex
		var globalSilex = _global.getSilex(this);
		if(globalSilex != null){
			silexPtr = globalSilex;
		}else{
			silexPtr = new org.silex.core.Api;
		}
		
	}	
	
	 
	private function findObj(path:String){
		return silexPtr.utils.getTarget(this._parent, path);
	}
	 
	 //withWho is always this, except for the finder, which will pass its target object
	private function lookForObjectsWantingToLink(withWho:Object){
		//look for objects wanting to link
		var size = _linkQueue.length;
		for(var i = 0; i < size; i++){
			var targetInQueue = findObj(_linkQueue[i].targetPath);
			if((targetInQueue == withWho) && (withWho.onLoadEventOccurred)){
				//found targetInQueue waiting to link with "withWho"
				_linkQueue[i].requestSource.tyu("found " + withWho.playerName);
				_linkQueue[i].doOnLinkTargetFound(targetInQueue);
				_linkQueue[i].found = true;
			}
		}
	}
	
	/** function _onLoad
	 * @returns void
	 */
	 public function _onLoad()
	 {		
		// initialise size attributes (usefull in Flash, not in SILEX because SILEX will change this during the register process)
/*		var cosAlpha:Number = Math.abs(Math.cos(_rotation * Math.PI / 180));
		if (cosAlpha != 0) width = _width / cosAlpha;
		else width = Math.abs(_height);
*/
		//setSize(_width, _height);
		//height = _height;
		//width = _width;
		//_xscale = 100;
		//_yscale = 100;
		//size();
		
	 	//set at beginning of onLoad, so that children know during their own onLoad. 
		//This is useful for example when redraw is called during onLoad, 
		//and redraw has a switch to do nothing unless _onLoadEventOccurred is true
		_onLoadEventOccurred  = true;
	 	super._onLoad();
		
		//setup oof linking. This is done here (and not in initAfterRegister) 
		//because it should only be done once a component is fully initalized
	
		//add self to _alloofCompsList
		_alloofCompsList.push(this);
		lookForObjectsWantingToLink(this);
		if(traceClassOnLoad){
		}
		 visu_txt._visible = false;
	 }
	 
	 /** function tryToLinkWith
	 * looks for another oof object this one must connect with, and link with it
	 *@returns Void
	 */
	function tryToLinkWith(targetPath:String, doOnLinkTargetFound:Function){
		if((targetPath == null) || (targetPath == ''))
			return;
		//stock link in link queue
		_linkQueue.push({targetPath:targetPath, doOnLinkTargetFound:doOnLinkTargetFound, requestSource:this, found:false});
		//look for link target
		var size = _linkQueue.length;
		for(var i = 0; i < size; i++){
			if((_linkQueue[i].targetPath == targetPath) && (_linkQueue[i].requestSource == this)){
				var candidate = findObj(targetPath);
				if((candidate!= null) && (candidate.onLoadEventOccurred)){
					//target found, and is loaded. update queue status, and execute link method
					_linkQueue[i].found = true;
					doOnLinkTargetFound(candidate);
					break;
				}
			}
			
		}
	}


	/** function get identifier
	* @returns String
	*/
	
	public function get identifier():String{
		return playerName;
	}	
	
	/** function get onLoadEventOccurred
	* @returns Boolean
	*/
	
	public function get onLoadEventOccurred():Boolean{
		return _onLoadEventOccurred;
	}		
	
	/** readOnly function for diagnosis. get linkQueue
	*@returns Array
	*/
	static function get linkQueue():Array{
		return _linkQueue;
	}

	/**static function getObjAtPath
	* looks for an object in an Object. syntax example: enclosure/attributes/url
	*/
	static function getObjAtPath(itemToSearch:Object, path:String){
		var reference = itemToSearch;
		var splitted = path.split("/");
		var len = splitted.length;
		for(var i = 0; i< len; i++){
			reference = reference[splitted[i]];
		}
		return reference;
	}
	
	/** function tyu
	* replace the trace function with some extras
	*/
	function tyu():String {
		if (!doTrace) {
			return "";
		}
		var out:String = "";
		if(arguments.length > 1){
			out = ObjectDumper.toString(arguments, true, true, true, 100000, 4);
		}else{
			out = arguments[0];
		}
		
		out = out  + ", " + this.playerName + "(" + _className + ")";
/*		if(_global.Xray){
			_global.Xray.tt(out);
		}else{
			trace(out);
		}
		*/
		trace(out);
		return out;
	}
	
	function get className():String{
		return _className;
	}
}
