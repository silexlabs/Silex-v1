/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
* Delegate class for SilexAdminApi, exposes its methods to ExternalInterface
*/
import flash.external.ExternalInterface;

import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listedObjects.ActionProxy;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.adminApi.listedObjects.LayoutProxy;
import org.silex.adminApi.listedObjects.PropertyProxy;
import org.silex.adminApi.util.T;
import org.silex.adminApi.util.Serialization;

class org.silex.adminApi.ExternalInterfaceController{
	
	private static var _instance:ExternalInterfaceController;

	/**
	* prefix, to make sure we don't have a collision on external interface
	*/
	private static var EE_PREFIX:String = "SilexAdminApi_";
	
	private static var FUNC_CALL_AS2_API_FUNCTION:String = EE_PREFIX + "callAs2ApiFunction";
	
	private static var FUNC_CALL_AS2_API_LAYOUT_FUNCTION:String = EE_PREFIX + "callAs2ApiLayoutFunction";
	
	private static var FUNC_CALL_AS2_API_LAYER_FUNCTION:String = EE_PREFIX + "callAs2ApiLayerFunction";
	
	private static var FUNC_CALL_AS2_API_COMPONENT_FUNCTION:String = EE_PREFIX + "callAs2ApiComponentFunction";
	
	private static var FUNC_UPDATE_PROPERTY:String = EE_PREFIX + "updateProperty";
	
	private static var FUNC_UPDATE_ACTION:String = EE_PREFIX + "updateAction";
	
	private static var FUNC_CALL_DISPATCH_EVENT:String = "dispatchEvent";
	
	
	
	/**
	 * constructor. Don't use, use getInstance
	 * */
	public function ExternalInterfaceController(){
		//T.y("init as2 ExternalInterfaceController");
		if(!ExternalInterface.available){
			throw new Error("no external interface");
		}
		
		
		ExternalInterface.addCallback(FUNC_CALL_AS2_API_FUNCTION, this, callAs2ApiFunction);
		ExternalInterface.addCallback(FUNC_CALL_AS2_API_LAYOUT_FUNCTION, this, callAs2ApiLayoutFunction);
		ExternalInterface.addCallback(FUNC_CALL_AS2_API_LAYER_FUNCTION, this, callAs2ApiLayerFunction);
		ExternalInterface.addCallback(FUNC_CALL_AS2_API_COMPONENT_FUNCTION, this, callAs2ApiComponentFunction);
		ExternalInterface.addCallback(FUNC_UPDATE_PROPERTY, this, updateProperty);
		ExternalInterface.addCallback(FUNC_UPDATE_ACTION, this, updateAction);
		
	}
	
	/**
	 * use to get the singleton instance
	 * */
	static public function getInstance():ExternalInterfaceController 
	{ 
		if(!_instance){
			_instance = new ExternalInterfaceController();
		}
		return _instance;
	}	
	
	/**
	 * use this function to make a call straight on the silexNS.SilexAdminApi object in javascript.
	 * generates the necessary javascript wrapper code on the fly
	 * @param functionName The function to call
	 * @param parameters the parameters of the call
	 * */
	public function makeJsSilexAdminApiFunctionCall(functionName:String, parameters:Array, objectPath:String):Object {
		
		if (objectPath == null)
		{
			objectPath = "silexNS.SilexAdminApi";
		}
		
		var command:String = "function( ) { return "+objectPath+"."+functionName + "(";
		var jsonEncoded:Array = new Array(); 
		var numParams:Number = parameters.length;
		for(var i:Number = 0; i < numParams; i++){
			var param:Object = parameters[i];
			jsonEncoded.push(_global.getSilex(this).utils.obj2json(param)); 
		}
		command += jsonEncoded.join(", ") + "); }";
		//T.y(command);
		var ret:Object = ExternalInterface.call(command);
		//T.y("makeJsSilexAdminApiFunctionCall returns ",ret);
		return ret;
		
	}
	
	/**
	 * called from JS. Calls a function on an object on SilexAdminApi
	 * use to call something on the silexAdminApi. For example: SilexAdminApi.getInstance().layouts.getData is callable with layouts, getData, null	
	 * */
	public function callAs2ApiFunction(targetName:String, functionName:String, parameters:Object):Object{
		var apiObj:Object = SilexAdminApi.getInstance()[targetName];
		if(!apiObj){
			//T.y("as2 api object not found at " + targetName);	
		}
		var apiFunction:Function = apiObj[functionName];
		if(!apiFunction){
			//T.y("as2 api function not found at ", functionName, " on ", targetName);	
		}
		var paramsAsArray:Array = Serialization.unmangleArray(parameters);
		var ret:Object = apiFunction.apply(apiObj, paramsAsArray);
		//encode the returned string in base64
		var encoded:Object = Serialization.encodeString(ret);
		//T.y("callAs2ApiFunction ",  targetName, ".", functionName, ".",paramsAsArray, " returns ",ret, encoded);
		return encoded;

	}
	
	/**
	 * call to JS. Sends an Event to the whole API
	 * */
	public function dispatchEvent(event:AdminApiEvent):Void{
		makeJsSilexAdminApiFunctionCall(FUNC_CALL_DISPATCH_EVENT, [event]);
		//T.y("dispatchEvent", event);
	}

	/**
	 * called from JS. Calls a function on a layout proxy
	 * use to call something on the silexAdminApi.
	 * */
	public function callAs2ApiLayoutFunction(layoutUid:String, functionName:String, parameters:Object):Object{
		var layoutProxy:LayoutProxy = LayoutProxy.createFromUid(layoutUid);
		if(!layoutProxy){
			//T.y("as2 api layoutProxy not found at ", layoutUid);	
		}		
		var apiFunction:Function = layoutProxy[functionName];
		if(!apiFunction){
			//T.y("as2 api layout function not found at ", functionName, " on ", layoutProxy);	
		}
		var paramsAsArray:Array = Serialization.unmangleArray(parameters);
		var ret:Object = apiFunction.apply(layoutProxy, paramsAsArray);
		//T.y("callAs2ApiLayoutFunction ", layoutUid, ".", functionName, ".",paramsAsArray, " returns ",ret);
		return ret;
		
	}
	
	/**
	 * called from JS. Calls a function on a layer proxy
	 * use to call something on the silexAdminApi. For example:
	 * */
	public function callAs2ApiLayerFunction(layerUid:String, functionName:String, parameters:Object):Object{
		var layerProxy:LayerProxy = LayerProxy.createFromUid(layerUid);
		if(!layerProxy){
			//T.y("as2 api layerProxy not found at ", layerUid);	
		}		
		var apiFunction:Function = layerProxy[functionName];
		if(!apiFunction){
			//T.y("as2 api layer function not found at ", functionName, " on ", layerProxy);	
		}
		var paramsAsArray:Array = Serialization.unmangleArray(parameters);
		var ret:Object = apiFunction.apply(layerProxy, paramsAsArray);
		//T.y("callAs2ApiLayerFunction ", layerUid, ".", functionName, ".",paramsAsArray, " returns ",ret);
		return ret;
		
	}
	
	/**
	 * called from JS. Calls a function on a component proxy
	 * use to call something on the silexAdminApi. For example: Component.openIcon is callable with <uid>, openIcon, null	
	 * */
	public function callAs2ApiComponentFunction(componentUid:String, functionName:String, parameters:Object):Object{
		var componentProxy:ComponentProxy = ComponentProxy.createFromUid(componentUid);
		if(!componentProxy){
			//T.y("as2 api componentProxy not found at ", componentUid);	
		}		
		var apiFunction:Function = componentProxy[functionName];
		if(!apiFunction){
			//T.y("as2 api component function not found at ", functionName, " on ", componentProxy);	
		}
		var paramsAsArray:Array = Serialization.unmangleArray(parameters);
		var ret:Object = apiFunction.apply(componentProxy, paramsAsArray);
		ret = Serialization.encodeString(ret);
		//T.y("callAs2ApiComponentFunction ", componentUid, ".", functionName, ".",paramsAsArray, " returns ",ret);
		return ret;
		
	}
		
	/**
	 * update a property
	 * */
	public function updateProperty(propertyUid:String, value:Object, originatorId:String):Void{
		var propertyProxy:PropertyProxy = PropertyProxy.createPropertyProxyFromUid(propertyUid);
		var unmangledValue:Object = Serialization.unmangle(value);		
		propertyProxy.updateCurrentValue(unmangledValue, originatorId);
		//T.y("updateProperty ", propertyUid, value, unmangledValue);
	}
	
	
	/**
	 * update an action
	 * */
	public function updateAction(actionUid:String, functionName:String, modifier:String, parameters:Object):Void{
		var paramsAsArray:Array = Serialization.unmangleArray(parameters);
		var actionProxy:ActionProxy = ActionProxy.createFromUid(actionUid);
		actionProxy.update(functionName, modifier, paramsAsArray);
		//T.y("updateAction ", actionUid, functionName, modifier, parameters,paramsAsArray);
	}
		

	

}