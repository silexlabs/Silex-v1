/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.controls.List;
import org.oof.OofBase;
import org.oof.DataContainer;
import org.oof.lists.CustomList;
import org.oof.ui.ListUi;
import mx.utils.Delegate;
import mx.controls.Button;
/** this is a design tool for inspecting the dynamic contents held in a datacontainer. This
 * should be moved to design tools.  
 * @author Ariel Sommeria-klein
 * */
//would be nice to do this with a tree, but mx components mess things up pretty badly(selectors don't work???!)
//, so stick to oof list
//use names with "__" to make sure nobody else uses the same ones
class org.oof.util.DataContainerViewer extends OofBase{
	private var _objToWatch:DataContainer = null;
	private var _objToWatchPath:String = null;
	
	
	//ui
	var refreshBtn:Button;
	var output_txt:TextField;

	function DataContainerViewer(){
		super();
		typeArray("org.oof.util.DataContainerViewer");
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		tabChildren = true;
		tryToLinkWith(_objToWatchPath, Delegate.create(this, doOnObjToWatchFound));
		refreshBtn.onRelease = Delegate.create(this, doRefresh);
		//size();
	 }

	 function getObjInfo(ret:String, obj:Object, depth:Number){
		for(var i in obj){
			var str:String = "";
			for(var j = 0; j < depth; j++){
				str = str + " -> ";
			}
			ret += str + i + " : " + obj[i] + "\n";
			if(typeof obj[i] == "object"){
				getObjInfo(ret, obj[i], depth + 1);      
			}
		}
	 }
	 
	 function doRefresh(){
		 var ret:String = _objToWatch.playerName + ": \n";
		 for(var i in _objToWatch.dataNames){
			 var heldObjName = _objToWatch.dataNames[i];
			ret += heldObjName + ": \n"; 
			ret += mx.data.binding.ObjectDumper.toString(_objToWatch[heldObjName], true, true, true, 100000, 4);
		 }
		 
		 output_txt.text = ret;
	 }

	 /** function doOnObjToWatchFound
	*@returns void
	*/
	function doOnObjToWatchFound(oofComp:OofBase){
		
		_objToWatch = DataContainer(oofComp);
		doRefresh();
	}
	
	/** function set objToWatchPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="objToWatch", type=String, defaultValue="")]
	public function set objToWatchPath(val:String){
		_objToWatchPath = val;
	}
	
	/** function get objToWatchPath
	* @returns String
	*/
	
	public function get objToWatchPath():String{
		return _objToWatchPath;
	}		

	 
}