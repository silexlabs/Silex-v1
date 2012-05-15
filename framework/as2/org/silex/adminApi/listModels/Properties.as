/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for Properties
 * */
 
import org.silex.adminApi.listModels.IListModel;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.LayerProxy;
import org.silex.adminApi.listedObjects.PropertyProxy;
import org.silex.adminApi.util.T;
import org.silex.core.Interpreter;
import org.silex.core.Utils;
import org.silex.link.HaxeLink;
import org.silex.ui.Layer;
import org.silex.ui.UiBase;

class  org.silex.adminApi.listModels.Properties extends ListModelBase
{
	public function Properties()
	{
		super();
		_objectName = "properties";
	}
	
	/**
	 * gets the properties for a component. Uses a component descriptor if it exists, 
	 * and if not falls back on looking for an "editableProperties" object on it
	 * So that editableProperties are still supported, descriptors are loaded by as2. It might be 
	 * more interesting in the future to load them is as3
	 * */
	private function getComponentPropertyProxies(componentUid:String):Array{
		//T.y("getComponentPropertyProxies. componentUid : ", componentUid);
		var componentProxy:ComponentProxy = ComponentProxy.createFromUid(componentUid);  
		var component:UiBase = componentProxy.getComponent();
		var editableProperties:Array = componentProxy.getEditableProperties();		
		 
		var numEditableProperties:Number = editableProperties.length;
		var propertyProxys:Array = new Array();
		for(var j:Number = 0; j < numEditableProperties; j++){
			var propertyProxy:PropertyProxy = PropertyProxy.createPropertyProxyFromComponent(component, j, editableProperties);
			propertyProxys.push(propertyProxy);
			//T.y("propertyProxy", propertyProxy);
		}
		
		return propertyProxys;
		
	}
	
	private function doGetData(containerUids:Array):Array{
		//T.y("Properties getData", containerUids);
		var ret:Array = new Array();
		if(!containerUids){
			containerUids = SilexAdminApi.getInstance().components.getSelection();
		}
		var numComponents: Number = containerUids.length;
		for(var i:Number = 0; i < numComponents; i++){
			var componentUid:String = containerUids[i];
			ret.push(getComponentPropertyProxies(componentUid));
		}
		return ret;
	}
	
	public function getParent():IListModel
	{
		return SilexAdminApi.getInstance().components;
	}
	
	
			
}