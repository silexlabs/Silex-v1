/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.util;
import flash.Lib;
import haxe.Log;


/**
 * Stores all the data used to paste a component
 */
typedef CopiedComponentsData = {
	var name:String;
	var metadata:String;
	var className:String;
	var type:String;
	var initObj:Dynamic;
	var properties:Array<Dynamic>;
	var actions:Array<Dynamic>;
	var targetLayerUid:String;
};

/**
 * This is helper class copying and pasting an array of components
 * with the SilexAdminApi
 */
class ComponentCopier
{
	//////////////////////////////
	// CONSTANTS
	/////////////////////////////
	
	/**
	 * The name of the playerName property field on a component
	 */
	private static var PLAYER_NAME_PROPERTY_FIELD_NAME:String = "playerName";
	
	//////////////////////////////
	// ATTRIBUTES
	/////////////////////////////
	
	/**
	 * The class instance returned by the singleton
	 */
	private static var _componentCopier:ComponentCopier;
	
	/**
	 * An array storing each selected components name, type, url, and an array containing all of it's propertyProxy.
	 */ 
	private var _copiedComponents:Array<CopiedComponentsData>;
	
	/**
	 * stores the number of remaining components to paste.
	 */ 
	private var _addedComponentsPendingCalls:Int;
	
	/**
	 * Stores the uid of an optionnal layer that can be
	 * defined as the one to add copied components to
	 */
	private var _targetLayerUid:String;
	
	/**
	 * stores the uids of the pasted component to select them all at the end of the process.
	 */ 
	private var _addedComponentsUids:Array<String>;
	
	/**
	 * Stores a reference to the component created callback
	 */
	private var _componentCreatedDelegate:Void->Void;
	
	//////////////////////////////
	// CONSTRUCTOR
	/////////////////////////////
	
	/**
	 * Singleton, don't use, use getInstance()
	 */ 
	private function new()
	{
		_addedComponentsUids = new Array<String>();
	}
	
	//////////////////////////////
	// PUBLIC METHODS
	/////////////////////////////
	
	/**
	 * return the singleton class instance
	 * @return the class instance
	 */
	public static function getInstance():ComponentCopier
	{
		if (_componentCopier == null)
		{
			_componentCopier = new ComponentCopier();
		}
		
		return _componentCopier;
	}
	
	/**
	 * Returns wether components have already been copied
	 */ 
	public function areItemsCopied():Bool
	{
		if (_copiedComponents != null)
		{
			return true;
		}
		
		else
		{
			return false;
		}
	}
	
	/**
	 * Get the components to copy from SilexAdminAPI and their properties.
	 * Store the data in the _copiedComponents array.
	 * @param componentsUids an optionnal array of components uids to copy only specific components
	 */ 
	public function copy(componentsUids:Array<String>):Void
	{
		var silexAdminApi:Dynamic = Lib._global.org.silex.adminApi.SilexAdminApi.getInstance();
		
		var componentsToCopyUids:Array<String> = new Array<String>();
		if (componentsUids != null)
		{
			componentsToCopyUids = componentsUids;
		}
		else
		{
			componentsToCopyUids = silexAdminApi.components.getSelection();
			
			//reverse uids, else component will be pasted in wrong order
			//resulting in switched names and properties among components
			componentsToCopyUids.reverse();
		}
		//reset the stored components array and the target layer uid
		_copiedComponents = new Array();
		_targetLayerUid  = null;
		
		//stops here if no components needs to be copied
		if (componentsToCopyUids.length == 0)
		{
			return;
		}
		
		//retrieve all the layouts uid
		var layouts:Array<Dynamic> = silexAdminApi.layouts.getData()[0];
		var layoutsUids:Array<String> = new Array<String>();
		for (i in 0...layouts.length)
		{
			layoutsUids.push(layouts[i].uid);
		}
		
		var layers:Array<Dynamic> = silexAdminApi.layers.getData(layoutsUids);
		for (i in 0...layers.length)
		{
			for (j in 0...layers[i].length)
			{
				var components:Array<Dynamic> = silexAdminApi.components.getData([layers[i][j].uid])[0];
				
				for (k in 0...components.length)
				{
					for (l in 0...componentsToCopyUids.length)
					{
						if (components[k].uid == componentsToCopyUids[l])
						{
							var selectedComponent:Dynamic = components[k];
							//store the component name
							var componentName:String = selectedComponent.name;
							//stores the component url
							var componentMetadata:String = selectedComponent.getAs2Url();
							//stores the className of the component
							var componentClassName:String = selectedComponent.getClassName();
							//determine it's type
							var componentType:String = Lib._global.org.silex.adminApi.listModels.adding.ComponentAddInfo.TYPE_COMPONENT;
							//stores all of the component properties	
							var componentProperties:Array<Dynamic> = silexAdminApi.properties.getData([selectedComponent.uid])[0];
							//stores all the component actions
							var componentActions:Array<Dynamic> =  silexAdminApi.actions.getData([selectedComponent.uid])[0];
							
							//stores the uid of the component's parent layer to which it's copy will be added by default
							var targetLayerUid:String = layers[i][j].uid;
							
							//stores the copied component properties, so that we can set 
							//them on the pasted component
							//stores in a key/value object where the key is the name of the property
							//and the value is it's value
							var initObj:Dynamic = {};
							for (i in 0...componentProperties.length)
							{
								//check for the playerName property as it is a special case
								if (componentProperties[i].name != PLAYER_NAME_PROPERTY_FIELD_NAME)
								{
									Reflect.setField(initObj, componentProperties[i].name, componentProperties[i].currentValue);
								}
								//when playerName is found, check that it still matches the stored component name (meaning
								//that it wasn't changed by the user meanwhile)
								else if (componentProperties[i].currentValue != componentName)
								{
									//if it different, then a new name is generated
									componentName = generatePlayerName(componentProperties[i].currentValue);
								}
							}
							_copiedComponents.push({
								name: componentName, 
								metadata:componentMetadata, 
								className:componentClassName,
								type:Lib._global.org.silex.adminApi.listModels.adding.ComponentAddInfo.TYPE_COMPONENT, 
								initObj:initObj,
								properties:componentProperties,
								actions:componentActions,
								targetLayerUid:targetLayerUid
								});
						}
					
					}
				}
			}
		}
		
	}
	
	/**
	 * set the _addedComponentsPendingCalls to the length of the _copiedComponents array then calls the do paste function.
	 * @param targetLayerUid an optionnal layer uid to which had the copied components to. If it is null, the copied
	 * components will be attached to the same layer as the original component
	 */ 
	public function paste(targetLayerUid:String):Void
	{
		//if no components were previously copied, end the pasting
		if (_copiedComponents.length == 0)
		{
			signalEndPaste();
		}
		
		if (targetLayerUid != null)
		{
			_targetLayerUid = targetLayerUid;
		}
		
		_addedComponentsPendingCalls = _copiedComponents.length;
		doPaste();
	}
	
	//////////////////////////////
	// PRIVATE METHODS
	/////////////////////////////
	
	/**
	 * Generate a unique name for a copied component using a method from
	 * SilexAdminApi ComponentAdder
	 * @param	playerName
	 * @return
	 */
	private function generatePlayerName(playerName:String):String
	{
		return Lib._global.org.silex.adminApi.listModels.adding.ComponentAdder.generatePlayerName(playerName, this);
	}
	
	/**
	 * add the component at index _addedComponentsPendingCalls, set listener on SilexAdminApi 
	 * for a COMPONENT_CREATED event setting the callback to the endPaste() method.
	 * Stores the added component'uid in the _addedComponentsUid array.
	 */ 
	private function doPaste():Void
	{
		var silexAdminApi:Dynamic = Lib._global.org.silex.adminApi.SilexAdminApi.getInstance();
		
		_componentCreatedDelegate = endPaste;
		
		silexAdminApi.components.addEventListener(Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_CREATED, _componentCreatedDelegate);
		
		var componentData:Dynamic = {
			playerName : _copiedComponents[_addedComponentsPendingCalls - 1].name,
			metaData : _copiedComponents[_addedComponentsPendingCalls -1 ].metadata,
			className : _copiedComponents[_addedComponentsPendingCalls -1 ].className,
			initObj : _copiedComponents[_addedComponentsPendingCalls -1 ].initObj,
			type : _copiedComponents[_addedComponentsPendingCalls - 1].type
		};
		
		var componentTargetUid:String;
		
		//if no layer is defined to add the component to, add it
		//to the same layer as the orginal component
		if (_targetLayerUid == null)
		{
			componentTargetUid =  _copiedComponents[_addedComponentsPendingCalls - 1].targetLayerUid;
		}
		else
		{
			componentTargetUid = _targetLayerUid;
		}
		
		_addedComponentsUids.push(silexAdminApi.components.addItem(componentData, componentTargetUid));
	}
	
	/**
	 * Removes the COMPONENT_CREATED event listener, 
	 * get the last added components propertyProxies using 
	 * it's uid stored in the _addedComponentsUid, 
	 * and set all it's values to match those of the stored data of 
	 * the _copiedComponents array at the _addedComponentsPendingCalls index. 
	 * decrement the _addedComponentsPendingCalls value. 
	 * if the value is superior to 0, calls the doPaste() 
	 * method, else signal the end of the paste process, 
	 * then empties the array.
	 */ 
	private function endPaste():Void
	{
		var silexAdminApi:Dynamic = Lib._global.org.silex.adminApi.SilexAdminApi.getInstance();
		
		silexAdminApi.components.removeEventListener(Lib._global.org.silex.adminApi.listModels.Components.EVENT_COMPONENT_CREATED, _componentCreatedDelegate);
		
		var lastAddedComponentProperties:Array<Dynamic> = silexAdminApi.properties.getData([_addedComponentsUids[_addedComponentsUids.length - 1]])[0];
		var copiedComponentsActions:Array<Dynamic> = _copiedComponents[_addedComponentsPendingCalls -1].actions;
		
		
		//add a new action for each saved action
		for (i in 0...copiedComponentsActions.length)
		{
			silexAdminApi.actions.addItem({
				functionName: copiedComponentsActions[i].functionName,
				modifier: copiedComponentsActions[i].modifier,
				parameters: copiedComponentsActions[i].parameters
			}, _addedComponentsUids[_addedComponentsUids.length - 1] );
		}
		
		_addedComponentsPendingCalls--;
		
		if (_addedComponentsPendingCalls > 0)
		{
			doPaste();
		}
		
		else
		{
			_addedComponentsUids = new Array();
			
			signalEndPaste();
			
		}
	}
	
	/**
	 * Signals the end of the paste process after a successful or
	 * aborted paste
	 */
	private function signalEndPaste():Void
	{
		var silexAdminApi:Dynamic = Lib._global.org.silex.adminApi.SilexAdminApi.getInstance();
		silexAdminApi.components.signalComponentPasted();
	}
	
}