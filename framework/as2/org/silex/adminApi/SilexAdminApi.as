/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * the singleton used to manipulate the silex Administration API
 * */
 

import org.silex.adminApi.Helper;
import org.silex.adminApi.listModels.ToolBarGroups;
import org.silex.adminApi.listModels.ToolBarItems;
import org.silex.adminApi.listModels.ToolBars;
import org.silex.adminApi.Shortcut;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.adminApi.SilexAdminApiHooks;
import org.silex.adminApi.PublicationModel;
import org.silex.adminApi.listModels.Actions;
import org.silex.adminApi.listModels.Components;
import org.silex.adminApi.listModels.IListModel;
import org.silex.adminApi.listModels.Layers;
import org.silex.adminApi.listModels.Layouts;
import org.silex.adminApi.listModels.Properties;
import org.silex.adminApi.util.T;
import org.silex.core.Api;
import org.silex.core.plugin.HookManager;
import org.silex.adminApi.listModels.Messages;
import org.silex.link.HaxeLink;

class org.silex.adminApi.SilexAdminApi
{
	
	
	static private var _silexPtr:Api = null;	
	static private var _instance:SilexAdminApi;
	
	private var _layouts:IListModel;
	private var _layers:IListModel;
	private var _components:IListModel;
	private var _properties:IListModel;
	private var _contexts:IListModel;
	private var _actions:IListModel;
	private var _viewMenuItems:IListModel;
	private var _publicationModel:PublicationModel;
	private var _eeController:ExternalInterfaceController;
	private var _shortcut:Shortcut;
	private var _helper:Helper;
	private var _messages:Messages;
	private var _toolBars:ToolBars;
	private var _toolBarGroups:ToolBarGroups;
	private var _toolBarItems:ToolBarItems;
	
	
	//haxe objects. untyped
	private var _historyManager:Object;
	private var _selectionManager:Object;
	private var _componentDescriptorManager:Object;
	
	
	/**
	 * constructor. Don't use, use getInstance
	 * */
	public function SilexAdminApi()
	{
		HookManager.getInstance().callHooks(SilexAdminApiHooks.ADMIN_API_LOAD_START_HOOK_UID);
		_silexPtr = _global.getSilex(this);
		_silexPtr.com.silexOnStatus({ type:SilexAdminApiHooks.ADMIN_API_LOAD_START_HOOK_UID});		
		_layouts = new Layouts();
		_layers = new Layers();
		_components = new Components();
		_properties = new Properties();
		_actions = new Actions();
		_publicationModel = new PublicationModel();
		_eeController = new ExternalInterfaceController(this);
		_shortcut = new Shortcut();
		_helper = new Helper();
		_historyManager = new HaxeLink.getHxContext().org.silex.adminApi.HistoryManager();
		_messages = new Messages();
		_toolBars = new ToolBars();
		_toolBarGroups = new ToolBarGroups();
		_toolBarItems = new ToolBarItems();
		_selectionManager = new HaxeLink.getHxContext().org.silex.adminApi.selection.SelectionManager();
		
		_componentDescriptorManager = HaxeLink.getHxContext().org.silex.adminApi.ComponentDescriptorManager.getInstance();
		_componentDescriptorManager.loadDescriptors(onComponentDescriptorsLoaded);
		//note: end hooks are called only once component descriptors are loaded
	}
	
	/**
	 * use to get the singleton instance
	 * */
	static public function getInstance():SilexAdminApi 
	{
		if(!_instance){
			_instance = new SilexAdminApi();
		}
		return _instance;
	}
	
	/**
	* callback for whne the component descriptors are loaded
	*/
	private function onComponentDescriptorsLoaded():Void {
		//T.y("onComponentDescriptorsLoaded", _componentDescriptorManager._descriptors );
		HookManager.getInstance().callHooks(SilexAdminApiHooks.ADMIN_API_LOAD_END_HOOK_UID);
		_silexPtr.com.silexOnStatus({ type:SilexAdminApiHooks.ADMIN_API_LOAD_END_HOOK_UID});
	}
	
	public function get layouts():IListModel
	{
		return _layouts;
	}

	public function get layers():IListModel
	{
		return _layers;
	}

	public function get components():IListModel
	{
		return _components;
	}

	public function get properties():IListModel
	{
		return _properties;
	}

	public function get contexts():IListModel
	{
		return _contexts;
	}
	

	public function get actions():IListModel
	{
		return _actions;
	}
	
	public function get publicationModel():PublicationModel
	{
		return _publicationModel;
	}
	
	public function get shortcut():Shortcut
	{
		return _shortcut;
	}
	
	public function get helper():Helper
	{
		return _helper;
	}
	
	public function get historyManager():Object
	{
		return _historyManager;
	}
	
	public function get eeController():ExternalInterfaceController
	{
		return _eeController;
	}
	
	public function get messages():Messages
	{
		return _messages;
	}
	
	public function get toolBars():ToolBars
	{
		return _toolBars;
	}
	
	public function get toolBarGroups():ToolBarGroups
	{
		return _toolBarGroups;
	}
	
	public function get toolBarItems():ToolBarItems
	{
		return _toolBarItems;
	}
	
	public function get selectionManager():Object
	{
		return _selectionManager;
	}
	


}