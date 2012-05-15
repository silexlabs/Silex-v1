/*
This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.ui.toolItemUI
{
	/**
	 * This class is used to control the ToolItemUI
	 */
	public class ToolItemController
	{
		import mx.collections.ArrayCollection;
		import mx.utils.ObjectProxy;
		
		import org.silex.adminApi.SilexAdminApi;
		import org.silex.adminApi.listedObjects.ToolBarGroup;
		import org.silex.adminApi.listedObjects.ToolBarItem;

		/**
		 * This function is used to create an array collection containing all the items to be added in the corresponding toolbox
		 * @param toolUid: the uid of the target toolUid
		 * @return: ArrayCollection
		 */ 
		public function generateItemsArrayCollection(toolUid:String):ArrayCollection
		{
			var groupsData = new ArrayCollection();
			
			//this try/catch is used to prevent error thrown
			//when the user refresh the page while the wysiwyg is initialising
			try{
				var toolbarGroups:Array = SilexAdminApi.getInstance().toolBarGroups.getData([toolUid])[0];
			}
			catch(e:TypeError)
			{
				return null;
			}
		
			
			for (var i:int = 0; i<toolbarGroups.length; i++)
			{
				var currentGroup:ObjectProxy = new ObjectProxy();
				currentGroup.group = toolbarGroups[i];
				//same as above
				try{
					currentGroup.itemGroup = SilexAdminApi.getInstance().toolBarItems.getData([currentGroup.group.uid])[0];
				}
				catch(e:TypeError)
				{
					return null;
				}
				groupsData.addItem(currentGroup);
			}
			
			return groupsData;
		}
	}
}