/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * This class does all the work of saving/reading sections data in/from db.
 * In the repository : /trunk/core/DynDataManager.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-18
 * @mail : lex@silex.tv
 */
import org.silex.adminApi.util.T;

class org.silex.core.DynDataManager {
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	var silex_ptr:org.silex.core.Api;

	/**
	 * Constructor.
	 */
	function DynDataManager (api:org.silex.core.Api) {
		// api reference
		silex_ptr=api;
	}

	/**
	 * Register a variable in SILEX:
	 * - load the corresponding value from dom to the variable
	 * - mark the variable so that its value will be saved into the dom when core.silex.save will be called
	 * @param target_mc		the object which contains the variable to be registered
	 * @param variableName	the name of the variable
	 * @param type			[optional] - the type of the variable (as returned by typeof ActionScript function)
	 * @return				true if a value was found in the XML and false otherwise
	 */
	function registerVariable(target_mc:MovieClip,variableName:String,type:String):Boolean{
		//T.y("registerVariable ", target_mc, variableName, type);
		
		// check inputs
		if (!target_mc || !variableName || variableName==""){
			return false;
		}
		
		// retrieve the layout root and the path of the container
		var ptr_mc:MovieClip=target_mc;
		var containerPath_array:Array=new Array;
		
		while (ptr_mc && !ptr_mc.silexLayout){
			// compute path
			containerPath_array.unshift(ptr_mc._name);
			
			// go up one level
			ptr_mc=ptr_mc._parent;
		}
		
		// handel error if we could not find a layout object
		if (!ptr_mc){
			return false;
		}
		
		// **
		// store a reference to the registered variable in the layout's registeredVariables array
		// array init
		if (!ptr_mc.silexLayout.registeredVariables)
			ptr_mc.silexLayout.registeredVariables=new Array;
		// new object in the array
		var _obj:Object=new Object;
		_obj.variableName_str=variableName;
		_obj.containerPath_array=containerPath_array;
		_obj.target_str=target_mc.target;
		_obj.type_str=type;
		ptr_mc.silexLayout.registeredVariables.push(_obj);

		// retrieve the value in the dom object if there was one in the corresponding XML file
		var ptr_obj:Object=ptr_mc.silexLayout.dom;
		for (var pathIdx:Number=0;pathIdx<containerPath_array.length;pathIdx++){
			// get next object's name
			var path_str:String=containerPath_array[pathIdx];
			// if this object does not exist, there is no value in the dom for the variable
			if (!ptr_obj[path_str]){
				return false;
			}
			// explore this object
			ptr_obj=ptr_obj[path_str];
		}
		if (ptr_obj[variableName]!=undefined){// there is a value for this variable
			//T.y("registerVariable set ", variableName, ptr_obj[variableName]);
			target_mc[variableName]=ptr_obj[variableName];
			return true;
		}
		else{// there is no value in the dom for the variable
			return false;
		}
	}
	/**
	 * Removes a variable from the registeredVariables array.
	 * Not used?! TO BE TESTED
	 * @param target_mc		the object which contains the variable to be registered
	 * @param variableName	the name of the variable
	 */
	function unRegisterVariable(target_mc:MovieClip,variableName:String):Boolean{
		var layout:org.silex.core.Layout=silex_ptr.application.getLayout(target_mc);
		for (var idx:Number=0;idx<layout.registeredVariables.length;idx++){
			if (layout.registeredVariables[idx].target_str==target_mc.target && variableName==layout.registeredVariables[idx].variableName_str){
				// remove from registered variables
				layout.registeredVariables.splice(idx,1);
				return true;
			}
		}
		// not found
		return false;
	}
	/**
	 * Stop keeping track of that variable so that its value will be updated in the dom during the save process.
	 * There are still some BUGs in this process.
	 * @param target_mc		the object which contains the variable to be registered
	 * @param variableName	the name of the variable
	 */
	function unRegisterClipOutOfContext(target_mc:MovieClip,variableName:String){
		////////////////////////////////
		// LIKE registerVariable
		// retrieve the layout root and the path of the container
		var ptr_mc:MovieClip=target_mc;
		var containerPath_array:Array=new Array;
		
		while (ptr_mc && !ptr_mc.silexLayout){
			// compute path
			containerPath_array.unshift(ptr_mc._name);
			
			// go up one level
			ptr_mc=ptr_mc._parent;
		}
		// handel error if we could not find a layout object
		if (!ptr_mc){
			return false;
		}
		var layout:org.silex.core.Layout=ptr_mc.silexLayout;

		
		// working pointer
		var ptrOut_obj:Object=layout.domOutOfContext;
		
		// for each object name in the path array
		for (var pathIdx:Number=0;pathIdx<containerPath_array.length;pathIdx++){
			// get next object's name
			var path_str:String=containerPath_array[pathIdx];
			// if this object does not exist, give away
			if (!ptrOut_obj[path_str]){
				return true;
			}
			// and explore the object
			ptrOut_obj=ptrOut_obj[path_str];
		}

		// stores the value in the out of context dom
		ptrOut_obj[variableName]=undefined;
		return true;		
	}
	/**
	 * Keep track of the variable so that it will still be saved in db, even if the container does not exist anymore (because it is out of context).
	 * Retrieve the layout root and the path of the target.
	 * Retrieve the corresponding dom node in layout's dom object.
	 * Add the target's dom to the domOutOfContext of the layout.
	 * There are still some BUGs in this process.
	 * @param target_mc		the object which contains the variable to be registered
	 * @param variableName	the name of the variable
	 */
	function registerClipOutOfContext(target_mc:MovieClip,variableName:String):Boolean{
		////////////////////////////////
		// LIKE registerVariable
		// retrieve the layout root and the path of the container
		var ptr_mc:MovieClip=target_mc;
		var containerPath_array:Array=new Array;
		
		while (ptr_mc && !ptr_mc.silexLayout){
			// compute path
			containerPath_array.unshift(ptr_mc._name);
			
			// go up one level
			ptr_mc=ptr_mc._parent;
		}
		// handel error if we could not find a layout object
		if (!ptr_mc){
			return false;
		}
		else{
		}
		var layout:org.silex.core.Layout=ptr_mc.silexLayout;
		// remove all the clip's properties from the registeredVariables arry so that are not saved (they are allready in the dom)
		for (var idx:Number=0;idx<layout.registeredVariables.length;idx++){
			if (layout.registeredVariables[idx].target_str.indexof(target_mc.target)==0){
				// remove from registered variables and restart from previous index
				layout.registeredVariables.splice(idx--,1);
			}
		}
		// use addValueToDom
		if (layout.domOutOfContext==undefined)
			layout.domOutOfContext=new Object;
		if (layout.dom==undefined)
			layout.dom=new Object;
			
		// working pointer
		var ptrDom_obj:Object=layout.dom;
		var ptrOut_obj:Object=layout.domOutOfContext;
		
		// for each object name in the path array
		for (var pathIdx:Number=0;pathIdx<containerPath_array.length;pathIdx++){
			// if there is no data for the object in the dom, just quit
			if (!ptrDom_obj){
				break;
			}
			// get next object's name
			var path_str:String=containerPath_array[pathIdx];
			// if this object does not exist, create it
			if (!ptrOut_obj[path_str]){
				ptrOut_obj[path_str]=new Object;
			}
			// and explore the object
			ptrOut_obj=ptrOut_obj[path_str];
			ptrDom_obj=ptrDom_obj[path_str];
		}
		// stores the value in the out of context dom
		if (ptrDom_obj && ptrDom_obj[variableName]!=undefined){
			ptrOut_obj[variableName]=duplicateDom(ptrDom_obj[variableName]);
		}
		else{
			// no data for the object in the dom
			return false;
		}
		return true;		
	}
	/**
	 * Duplicate a dom object and its child objects.
	 * Recursive function.
	 * @param	_obj	the dom object to be duplicated
	 * @return	the duplicated dom object
	 */
	function duplicateDom(_obj:Object):Object{
	
		if (_obj==undefined) return undefined;
		
		var res_obj:Object=new Object;
		for (var propName_str:String in _obj){
			if (typeof(_obj[propName_str])=="object")
				res_obj[propName_str]=duplicateDom(_obj[propName_str]);
			else 
				res_obj[propName_str]=_obj[propName_str];
		}
		return res_obj;
	}
	/**
	 * Use a layout's registeredVariables array to build it's dom object.
	 * The registeredVariables elements have these attributes: variableName_str,containerPath_array,type_str, target_str (which is the container_mc.target property).
	 * @param layout	the layout
	 */
	function buildLayoutDom(layout:org.silex.core.Layout){
		if (layout.domOutOfContext!=undefined)
			layout.dom=duplicateDom(layout.domOutOfContext);
		else
			layout.dom=new Object;
		
		// for each registered variable
		for (var variableIdx:Number=0;variableIdx<layout.registeredVariables.length;variableIdx++){
			// **
			// retrieve the value of the variable
			var ptr_obj:Object=layout._parent;
			var path_array:Array=layout.registeredVariables[variableIdx].containerPath_array;

			// for each object name in the path array
			for (var pathIdx:Number=0;pathIdx<path_array.length;pathIdx++){
				// get next object's name
				var path_str:String=path_array[pathIdx];
				// if this object does not exist, there is no value for the variable
				// otherwise explore the object
				if (ptr_obj[path_str]){
					ptr_obj=ptr_obj[path_str];
				}
			}
			// if there is a value for this variable, store it in the dom
			if (ptr_obj && ptr_obj[layout.registeredVariables[variableIdx].variableName_str]!=undefined){
				addValueToDom(layout.dom,path_array,layout.registeredVariables[variableIdx].variableName_str,ptr_obj[layout.registeredVariables[variableIdx].variableName_str]);
			}
		}
	}
	/**
	 * Update the a variable in the dom object.
	 * @param dom			the dom object
	 * @param path_array	the path of the variable
	 * @param variableValue	the variable's value
	 */
	private function addValueToDom(dom:Object,path_array:Array,variableName:String,variableValue){
		// woriking pointer
		var ptr_obj:Object=dom;
		
		// for each object name in the path array
		for (var pathIdx:Number=0;pathIdx<path_array.length;pathIdx++){
			// get next object's name
			var path_str:String=path_array[pathIdx];
			// if this object does not exist, create it
			if (!ptr_obj[path_str]){
				ptr_obj[path_str]=new Object;
			}
			// and explore the object
			ptr_obj=ptr_obj[path_str];
		}
		// stores the value
		ptr_obj[variableName]=variableValue;
	}
}