/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.plugins.viewMenu
{
	import mx.utils.ObjectUtil;
	
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.ExternalInterfaceController;
	import org.silex.adminApi.PublicationModel;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.IListModel;

	/**
	 * 	ViewMenuController. Listens to events on the SilexAdminAPI, and updates the ViewMenuModel. Listens to events on the view and updates the model and/or the API.
	 * */
	public class ViewMenuController
	{
		
		private var _model:ViewMenuModel;
		private var _view:ViewMenuUi;
		private var _viewMenuItemsListModel:IListModel;
		public function ViewMenuController(model:ViewMenuModel, view:ViewMenuUi)
		{
			_model = model;
			_view = view;
			//refreshModel();
		}
		
	
		private function refreshModel():void{
			
			
		}
	}
}