/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.listedObjects.ComponentProxy;
import org.silex.adminApi.listedObjects.ListedObjectBase;
import org.silex.adminApi.util.ClipFind;
import org.silex.adminApi.util.ComponentHelper;
import org.silex.core.Layout;
import org.silex.ui.Layer;
import org.silex.ui.UiBase;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.T;
 /**
 * the Action proxy. A proxy for accessing and manipulating a Action remotely.
 * An action is a way of creating an event listener on a silex component. 
 * a Silex component has a n array of actions
 * an example representation in silex:
 * onRelease imagePlayer.playMedia:'test.mp3'
 * Here it is represented with a separation between he event, the target, the function and the function parameters
 * 
 * note, a action is on a component(uibase), not a ComponentLoadInfo. 
 * This is due to the internal structure of silex, where components can be referred to without necessarily being loaded
 * */

class org.silex.adminApi.listedObjects.ActionProxy extends ListedObjectBase
{
	
	public var functionName:String;
	public var modifier:String;
	public var parameters:Array;

	/**
	 * get proxied action
	 * note: don't use use ComponentProxy methods to get the component, because they are for load infos, not actual components. 
	 * */
	public function getAction():Object{
		var split:Array = uid.split("/");
		var actionIndex:Object = split.pop();
		var untypedAction:Object = getRelativeComponent().actions[actionIndex];
		return untypedAction;
	}
	/**
	 * find the comonent to whom this action belongs
	 * */
	public function getRelativeComponent():UiBase{
		var split:Array = uid.split("/");
		var actionName:Object = split.pop();
		var component:UiBase = UiBase(ClipFind.findClip(split));
		//T.y("getRelativeComponent : " , component);
		return component;
	}
	
	
	/**
	 * get index  in Relative layer's player array
	 * */
	public function getIndexInRelativeComponent():Number{
		var split:Array = uid.split("/");
		var index:Number = Number(split.pop());
		//T.y("getIndexInRelativeComponent " , index);
		return index;
	}	
	/**
	 * changes the current value in the proxy, updates the component's action, and does everything necessary so that the change is taken into account
	 * */
	public function update(functionName:String, modifier:String, parameters:Array):Void
	{
		var component:UiBase = getRelativeComponent();
		if(!component){
			//component doesn't exist
			//T.y("component not found, couldn't update action");
			return;
		}
		var action:Object = new Object();
		action.functionName = functionName;
		action.modifier = modifier;
		action.parameters = parameters;
		//T.y("update of action");
		var split:Array = uid.split("/");
		var actionIndex:Object = split.pop();
		component.actions[actionIndex] = action;
		SilexAdminApi.getInstance().actions.signalDataChanged();
	}
	
	/**
	 * generate a uid for a Action, that can be used to find the Action again
	 * note. Here we don't use _target on the component, because for some reason it doesn't return a complete path, but just "/main".
	 * so do String(component) to get it in dot notation, then convert it. hackish, but works
	 * 
	 * */
	public static function getActionUid(component:UiBase, actionIndex:Number):String{
		var ret:String = ComponentHelper.getComponentUid(component) + "/" + actionIndex;
		//T.y("getActionUid : " , ret); 
		return ret;		
	}
	
	/**
	 * create a ActionProxy from a component and an index in its editableActions array. 
	 * */
	public static function createFromComponent(component:UiBase, actionIndex:Number):ActionProxy{
		var actionProxy:ActionProxy = new ActionProxy();
		var untypedAction:Object = component.actions[actionIndex];
		for(var key:String in untypedAction){
			actionProxy[key] = untypedAction[key];
		}
		actionProxy.uid = getActionUid(component, actionIndex);
		return actionProxy;
	}	
	
	/**
	 * create a ActionProxy from its uid. 
	 * */
	public static function createFromUid(actionUid:String):ActionProxy{
		var split:Array = actionUid.split("/");
		var actionIndex:Number = Number(split.pop());
		var component:UiBase = UiBase(ClipFind.findClip(split));
		return createFromComponent(component, actionIndex);
	}	
	
	
}