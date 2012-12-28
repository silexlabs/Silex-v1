/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for toolItems
 * */

import org.silex.adminApi.listedObjects.ToolBarItem;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.util.T;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.Serialization;
import flash.external.ExternalInterface;

class org.silex.adminApi.listModels.ToolBarItems extends ListModelBase
{
	/**
	 * the array containing the groups of ToolBarGroups
	 */
	private var _groups:Array;
	
	/**
	 * add two callback to the silex JS object, so that
	 * plugins can register groups and items via JavascriptScript
	 */
	public function ToolBarItems()
	{
		super();
		
		_objectName = "toolBarItems";
		_groups = new Array();
		
	}
	
	/**
	 * called when a plugin wants to add items to a group. Creates the group if it does'nt exist and
	 * add it as the last group. If the item already exists, may
	 * override it's properties like it's level and label
	 * @param	dataArr the object containg all the data of the item to add
	 */
	public function addItem(data:Object):Void
	{
		//will store the group to which we must add the item
		var group:Array;
		
		//the first step is to determine to which group this item
		//must be added to
		var groupIdx:Number;
		for (groupIdx = 0; groupIdx < _groups.length; groupIdx++)
		{
			//in all the groups array, we look for the group of item
			//who have the same groupUid as the provided data
			if (data.groupUid == _groups[groupIdx][0].groupUid)
			{
				//when a match is found
				//we will add our new item among
				//these group
				group = _groups[groupIdx];
			}
		}
		
		//if no group has been found
		//add a new group on the groups array
		//corresponding to a new toolbar
		if (group == undefined)
		{
			group = new Array();
			SilexAdminApi.getInstance().toolBarGroups.addItem( {
				toolUid:data.toolUid,
				uid:data.groupUid
			});
			_groups.push(group);
		}
		
		
		var flagGroup:Number;
		
		//search in the group array if an item with the same uid already exists
		for (var i:Number = 0; i < group.length; i++)
		{
			//if a match is found, stores it's index in the flagGroup var
			if (group[i].uid == data.uid)
			{
				flagGroup = i;
			}
		}
		
		//if no match was found
		if (flagGroup == undefined)
		{
			
			//create a new item and set it up with
			//the sent data
			var toolBarItem:ToolBarItem = new ToolBarItem();
			
			var key:String;
			for (key in data)
			{
				toolBarItem[key] = data[key];
			}
			
			//then loop in the group array looking
			//for the place where the new item must be added
			var flagLevel:Number;
			
			//if the group already contains other item
			if (group.length > 0)
			{
				//and if a level has been defined for the new item
				if (toolBarItem.level != null)
				{
					//search in the group array for the first item
					//which level is superior to the new item level
					for (var i:Number = 0; i < group.length; i++)
					{
						//if an item is found with a superior level
						if (group[i].level > toolBarItem.level)
						{
							//store it's index then break the loop
							flagLevel = i;
							break;
						}
					}
					
					//if the flagLevel was set, add the new item to the flag index
					//in the group
					if (flagLevel != undefined)
					{
						group.splice(flagLevel, 0, toolBarItem);
					}
					
					//else if the flagLevel was not set, it means that the new item level
					//is superior to every item's level in the array, and so it is added to the
					//end of the array
					else
					{
						group.push(toolBarItem);
					}
					
				}
				
				//if no level was defined for the new item, add it to the end of the array
				//and gives a level superior to the last item in the array
				else
				{
					toolBarItem.level = group[group.length -1].level + 1;
					group.push(toolBarItem);
				}
			}
			
			//if no items has already been added to the group array, just add the new item
			else
			{
				group.push(toolBarItem);
			}
		}
		
		//if an item with the same uid has been found, and a level has been defined,
		//rearrange the found item place in the group
		else if(data.level != null)
		{
			//stores the matching group
			var toolBarItem:ToolBarItem = group[flagGroup];
			toolBarItem.level = data.level;
			
			
			//loop in the group array, looking for the first item whose
			//level is superior to the defined item
			for (var j:Number = 0; j <group.length; j++)
			{
				//if a match is found
				if (group[j].level > toolBarItem.level)
				{
					if (j >= flagGroup)
					{
						group.splice(flagGroup, 1);
						group.splice(j-1, 0, toolBarItem);
					}
					
					else
					{
						group.splice(flagGroup, 1);
						group.splice(j, 0, toolBarItem);
					}
					
					break;
				}
			}
			
			//refresh all of the toolBarItem data
			//with the newly sent data
			var key:String;
			for (key in data)
			{
				toolBarItem[key] = data[key];
			}
			
		}
		signalDataChanged();
	}

	

	
	/**
	 * return the groups matching the containerUids parameter
	 * or return them all if it is left undefined
	 * */
	public function getData(containerUids:Array):Array{
		
		var ret:Array = new Array();
		
		if (containerUids != undefined)
		{
			var idxGroup:Number;
			for (idxGroup = 0; idxGroup < _groups.length; idxGroup++)
			{
				var idxContainerUids:Number;
				for (idxContainerUids = 0; idxContainerUids < containerUids.length; idxContainerUids++)
				{
					if (_groups[idxGroup][0].groupUid == containerUids[idxContainerUids])
					{
						ret.push(_groups[idxGroup]);
					}
				}
			}
		}
		
		else
		{
			ret = _groups;
		}
		
		
		return ret;
	}
}
