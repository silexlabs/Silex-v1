/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * Name space for silex Api
 */
var silexNS;
if(!silexNS)
	silexNS = new Object;


// root from silex index.php page
var $rootUrl;

/**
 * SilexAdminApiClass is the base class for SilexAdminApi singleton
 */

silexNS.SilexAdminApiClass = function ()
{
	this.SilexAdminApiClass();
}
silexNS.SilexAdminApiClass.prototype =
{
	
	/**
	 * handle on the main silex flash object(stage)
	 */
	silex : $('#silex')[0],
	
	/**
	 * the eventListeners for events coming from AS2 or JS. Each flash object that instanciates the AS3 SilexAdminApi singleton must add and remove itself from this array
	 * PRIVATE
	 */
	eventListeners:Array,
	
	/**
	 * plugged classes. For example, the wysiwyg model plugs itself here.
	 * These classes take precedence over AS2 classes.
	 * TODO: access methods 
	 */
	pluggedClasses : Object,
	/**
	 * Constructor
	 */
	SilexAdminApiClass : function ()
	{
		this.eventListeners = new Array;
	},
	
	/**
	 * call a function on the Api. By default this calls a function on the AS2 SilexAdminApi.
	 * @param {Object} targetName the target object. This is the name of the instance in Silex, so starts with lowercase character. For example "layouts" 
	 * @param {Object} functionName. the name of the function to call.
	 * @param {Object} parameters. an Object. For empty pass nothing, or {}
	 */
	callApiFunction : function (targetName, functionName, parameters)
	{
		//alert("callApiFunction : " + targetName + "." + functionName + this.pluggedClasses[targetName] + this.pluggedClasses[targetName][functionName]);
		var ret;
		if(this.pluggedClasses[targetName] && this.pluggedClasses[targetName][functionName]){
			//the API function is in JS. find the function on the DOM and call it there. Note : we need targetObj for the "apply" function
			var targetObj = this.pluggedClasses[targetName];
			var funcObj = targetObj[functionName];
			//alert("func obj : " + funcObj + funcObj.apply); 
			if(!funcObj){
				alert("can't find " + functionName + " on " + targetName);
			}
			if(!parameters){
				//ie fails if apply is called with parameters == null
				ret = funcObj.apply(targetObj);		
			}else{
				ret = funcObj.apply(targetObj, parameters);	
			}
			//alert("ret : " +ret);		
		}else{
		 	ret = this.silex.SilexAdminApi_callAs2ApiFunction(targetName, functionName, parameters);		
		}
		//alert("callApiFunction" + ret + typeof ret);
		return ret;
		
	},

	
	/**
	 * call a function on a as2 layout's Api. 
	 * @param {Object} layoutUid the layout's uid
	 * @param {Object} functionName. the name of the function to call.
	 * @param {Object} parameters. an Array. For empty pass nothing, or ['hi']
	 */
	callApiLayoutFunction : function (layoutUid, functionName, parameters)
	{
		//alert("callApiLayoutFunction : " + layoutUid + "." + functionName);
		var ret = this.silex.SilexAdminApi_callAs2ApiLayoutFunction(layoutUid, functionName, parameters);		
		//alert("callApiLayoutFunction returns " + ret);
		return ret;
		
	},
		
	/**
	 * call a function on a as2 layer's Api. 
	 * @param {Object} layerUid the layer's uid
	 * @param {Object} functionName. the name of the function to call.
	 * @param {Object} parameters. an Array. For empty pass nothing, or ['hi']
	 */
	callApiLayerFunction : function (layerUid, functionName, parameters)
	{
		//alert("callApiLayerFunction : " + layerUid + "." + functionName);
		var ret = this.silex.SilexAdminApi_callAs2ApiLayerFunction(layerUid, functionName, parameters);		
		//alert("callApiLayerFunction returns " + ret);
		return ret;
		
	},
	
	/**
	 * call a function on a as2 component's Api. 
	 * @param {Object} componentUid the component's uid
	 * @param {Object} functionName. the name of the function to call.
 	 * @param {Object} parameters. an Array. For empty pass nothing, or ['hi']
	 */
	callApiComponentFunction : function (componentUid, functionName, parameters)
	{
		//alert("callApiComponentFunction : " + componentUid + "." + functionName);
		var ret = this.silex.SilexAdminApi_callAs2ApiComponentFunction(componentUid, functionName, parameters);		
		//alert("callApiComponentFunction returns " + ret);
		//alert("testt " + document.getElementById('toolBox').test);
		return ret;
		
	},

	/**
	* update a property in silex.
	*/
	updateProperty : function (propertyUid, value, originatorId){
		//alert("updateProperty : " + propertyUid + "." + value);
		this.silex.SilexAdminApi_updateProperty(propertyUid, value, originatorId);				
	},
	
	/**
	* update an action in silex.
	*/
	updateAction : function (actionUid, functionName, modifier, parameters){
		//alert("updateAction : " + actionUid + "." + functionName);
		this.silex.SilexAdminApi_updateAction(actionUid, functionName, modifier, parameters);				
	},	
	
	/**
	 * tell a member object of the silex admin Api that an event has occured. Should call indescriminately AS2, JS and AS3, but for now just calls AS3
	 * @param {Object} targetName the target object. This is the name of the instance in Silex, so starts with lowercase character. For example "layouts" 
	 * @param {Object} type the name of the event. For example dataChanged
	 * @param {Object} data. Optional. An object for passing on info
	 */
	dispatchEvent : function ( event)
	{
		for(i = 0; i < this.eventListeners.length;i++){
			//alert("dispatch " + this.eventListeners[i]);
			if(this.eventListeners[i].SilexAdminApi_dispatchEvent){
				this.eventListeners[i].SilexAdminApi_dispatchEvent(event);
			}else{
				//this is not necessarily bad. Can happen if the flash obj isn't fully loaded yet, for example. Only use for debug
				//alert(event.targetName + "." + event.type + ' dispatchEvent fail on eventListener number ' + i);			
			}
		}
	},
	
	/**
	 * get the position of eventListener in the event eventListener array
	 * @param {Object} eventListener
	 */
	getEventListenerIndex : function (eventListener){
		//alert("getEventListenerIndex" + this.eventListeners + ", " + eventListener);
		for (i = 0; i < this.eventListeners.length; i++) {
			if(this.eventListeners[i] == eventListener){
				return i;
			}
		}
		return -1;
			
	},
	
	/**
	 * add a eventListener for events coming from AS2 and JS
	 * @param {Object} eventListener
	 */
	addEventListener : function (eventListener){
		if(this.getEventListenerIndex(eventListener) == -1){
			this.eventListeners.push(eventListener);
		}else{
			alert("event eventListener already known. addEventListener failed");
		}
		//alert("addEventListener. length : " + this.eventListeners.length);
	},
	
	/**
	 * remove a eventListener for events coming from AS2 and JS
	 * @param {Object} eventListener
	 */
	removeEventListener : function (eventListener){
		var index = this.getEventListenerIndex(eventListener); 
		if(index != -1){
			this.eventListeners.splice(index, 1);
		}else{
			alert("event eventListener not found. removeEventListener failed. length : " + this.eventListeners.length + ", eventListener" + eventListener);
		}
		//alert("removeEventListener. length : " + this.eventListeners.length);
		
	}
	
};

// initialize

silexNS.SilexAdminApi = new silexNS.SilexAdminApiClass();


silexNS.HookManager.callHooks({type:"silexAdminApiReady"});