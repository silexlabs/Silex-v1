/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.core.Utils;
import org.silex.adminApi.SilexAdminApi;
import org.silex.ui.UiBase;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.util.T;
/**
 * We need to be listen to clicks on components to select them when they are editable. ComponentProxies can't be used directly 
 * because they are discarded, so use this singleton to manipulate eventListeners etc.
 * This solution should be portable to AS3
 * */
class org.silex.adminApi.listedObjects.ComponentClickListener
{
	
	static private var _instance:ComponentClickListener;
	
	private var onComponentClickDelegate:Function;
	
	public function ComponentClickListener()
	{
		onComponentClickDelegate = Utils.createDelegate(this, onComponentClick);
	}
	
	
	/**
	 * use to get the singleton instance
	 * */
	static public function getInstance():ComponentClickListener 
	{
		if(!_instance){
			_instance = new ComponentClickListener();
		}
		return _instance;
	}
	
	/**
	 * select when the component is clicked. This listener is active anly when the component is editable
	 * */		
	private function onComponentClick(event:Object):Void{
		//T.y("onComponentClick : " , event.target , ", isEditable: " , event.target.isEditable);
		var component:UiBase = UiBase(event.target);
		if(!component){
			//T.y("onComponentClick event target not uibase. fail selection");
			return;
		}
		var componentProxy:ComponentProxy = ComponentProxy.createFromComponent(component);
		var layerProxy:LayerProxy = LayerProxy.createFromComponent(component);
		
		var componentsSelection:Array = new Array();
		var layersSelection:Array = new Array();
		
		if (Key.isDown(Key.SHIFT))
		{
			componentsSelection = SilexAdminApi.getInstance().components.getSelection();
			layersSelection = SilexAdminApi.getInstance().layers.getSelection();
		}
		
		componentsSelection.push(componentProxy.uid);
		layersSelection.push(layerProxy.uid);
		
		
		SilexAdminApi.getInstance().layers.select(layersSelection);
		SilexAdminApi.getInstance().components.select(componentsSelection);
	}
	
	public function startListening(component:UiBase):Void{
		component.addEventListener("onPress", onComponentClickDelegate);
	}
	
	public function stopListening(component:UiBase):Void{
		component.removeEventListener("onPress", onComponentClickDelegate);
	}
	
}