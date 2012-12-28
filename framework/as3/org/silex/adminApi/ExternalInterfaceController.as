/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi{
	/**
	 * Delegate class for SilexAdminApi, exposes its methods to ExternalInterface
	 * Ideally there should be 3 methods: call a function on a member of the SilexAdminApilist, call a function on listed object and receive a call on a list.
	 * There should be no method to receive a call on a listed object because they have no real existance outside the AS2.
	 * This works for now, so leave it. There are some unused functions in AS2, JS and AS3
	 */
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.util.Serialization;
	
	public class ExternalInterfaceController{
		private static var _instance:ExternalInterfaceController;

		/**
		 * prefix, to make sure we don't have a collision on external interface
		 */
		private static const EE_PREFIX:String = "SilexAdminApi_";
		
		private static const FUNC_CALL_API_FUNCTION:String = "callApiFunction";
		
		private static const FUNC_CALL_API_LAYOUT_FUNCTION:String = "callApiLayoutFunction";
		
		private static const FUNC_CALL_API_LAYER_FUNCTION:String = "callApiLayerFunction";
		
		private static const FUNC_CALL_API_COMPONENT_FUNCTION:String = "callApiComponentFunction";
		
		private static const FUNC_UPDATE_PROPERTY:String = "updateProperty";
		
		private static const FUNC_UPDATE_ACTION:String = "updateAction";
		
		private static const FUNC_CALL_DISPATCH_EVENT:String = EE_PREFIX + "dispatchEvent";		
		
		private var _timer2DelayedEvent:Dictionary;

		/**
		 * constructor. Don't use, use getInstance
		 * */
		public function ExternalInterfaceController(){
			//trace("init as3 ExternalInterfaceController");
			if(!ExternalInterface.available){
				throw new Error("no external interface");
			} 
			
			_timer2DelayedEvent = new Dictionary();

			ExternalInterface.addCallback(FUNC_CALL_DISPATCH_EVENT, dispatchEvent);
			
			
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
		 * gets an object belonging to the SilexAdminApi singleton
		 * */
		private function getTarget(targetName:String):Object{
			return SilexAdminApi.getInstance()[targetName];
		}

		/**
		 * use this function to make a call straight on an object in javascript.
		 * generates the necessary javascript wrapper code on the fly
		 * note: can't use the old silex AS2 code for json serialisation because it doesn't work in AS3 (we need to use describeType)
		 * @param functionName The function to call
		 * @param parameters the parameters of the call
		 * @param objectPath the path of the object to call
		 * */
		public static function makeJsFunctionCall(functionName:String, parameters:Array, objectPath:String):Object{
			var command:String = "function( ) { return "+objectPath+"." + functionName + "(";
			var jsonEncoded:Array = new Array(); 
			for each(var param:Object in parameters){
				jsonEncoded.push(new JSONEncoder(param).getString()); 
			}
			command += jsonEncoded.join(", ") + "); }";
			//trace(command);
			var ret:Object = ExternalInterface.call(command);
			//trace("makeJsSilexAdminApiFunctionCall returns " + ObjectUtil.toString(Serialization.unmangle(ret)));
			return Serialization.unmangle(ret);
			
		}
		/**
		 * Calls a function on an object on the SilexadminApi singleton
		 * */
		public function callJsApiFunction(targetName:String, functionName:String, parameters:Array):Object{
			return ExternalInterfaceController.makeJsFunctionCall(FUNC_CALL_API_FUNCTION, [targetName, functionName, parameters],"silexNS.SilexAdminApi");
		}
		
		
		/**
		 * Calls a function on a layout in silex
		 * */
		public function callJsApiLayoutFunction(layoutUid:String, functionName:String, parameters:Object):Object{
			return ExternalInterfaceController.makeJsFunctionCall(FUNC_CALL_API_LAYOUT_FUNCTION, [layoutUid, functionName, parameters], "silexNS.SilexAdminApi");
		}
		
		/**
		 * Calls a function on an layer in silex
		 * */
		public function callJsApiLayerFunction(layerUid:String, functionName:String, parameters:Object):Object{
			return ExternalInterfaceController.makeJsFunctionCall(FUNC_CALL_API_LAYER_FUNCTION, [layerUid, functionName, parameters], "silexNS.SilexAdminApi");
		}
		
		/**
		 * Calls a function on an component in silex
		 * */
		public function callJsApiComponentFunction(componentUid:String, functionName:String, parameters:Object):Object{
			return ExternalInterfaceController.makeJsFunctionCall(FUNC_CALL_API_COMPONENT_FUNCTION, [componentUid, functionName, parameters], "silexNS.SilexAdminApi");
		}
		
		/**
		 * updates a remote property, through js api
		 * */
		public function updateProperty(propertyUid:String, value:Object, originatorId:String = ""):void{
			ExternalInterfaceController.makeJsFunctionCall(FUNC_UPDATE_PROPERTY, [propertyUid, value, originatorId], "silexNS.SilexAdminApi");
		}
		
		
		/**
		 * updates a remote action, through js api
		 * */
		public function updateAction(actionUid:String, functionName:String, modifier:String, parameters:Array):void{

			ExternalInterfaceController.makeJsFunctionCall(FUNC_UPDATE_ACTION, [actionUid, functionName, modifier, parameters], "silexNS.SilexAdminApi");
		}
		

		/**
		 * dispatches an event on an object belonging to the SilexAdminApi singleton
		 * The dispatching is delayed using a timer, as a security to avoid creating too complicated situations with js, AS2, and AS3 calling each other mutually
		 * mapping between the timer and the delayed event is done in the _timer2DelayedEvent dictionary
		 * 
		 * @param event. Type object. See AdminApiAvent. Typing lost when converted from JS to AS3, so don't use real type
		 * */
		public function dispatchEvent(event:Object):void{
			//trace("dispatchEvent" + event.type + " event on " + event.targetName);
			var timer:Timer = new Timer(10, 1); 
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onEventTimer);
			timer.start();
			_timer2DelayedEvent[timer] = event;
		}
		
		private function onEventTimer(event:TimerEvent):void{
			var timer:Timer = event.target as Timer;
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onEventTimer);
			var delayedEvent:Object = _timer2DelayedEvent[timer];
			delete _timer2DelayedEvent[event.target];
			if(!delayedEvent){
				//trace("error getting delayed event");
			}
			var eventDispatcher:IEventDispatcher = getTarget(delayedEvent.targetName) as IEventDispatcher;
			if(!eventDispatcher){
				Err.err("event dispatcher not found for " + delayedEvent.targetName + ", " + delayedEvent.type);
				return;
			}
			//trace("as3 external interface controller dispatch " + delayedEvent.type + " event on " + delayedEvent.targetName);// + ", data : " + ObjectUtil.toString(event.data)); 
			eventDispatcher.dispatchEvent(new AdminApiEvent(delayedEvent.type, delayedEvent.data));
		}
		
	}	
}
 