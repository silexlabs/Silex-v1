/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for toolItems
 * */
 
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.ExternalInterfaceController;
import org.silex.adminApi.listedObjects.ToolBarGroup;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.adminApi.util.T;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.Serialization;
import flash.external.ExternalInterface;

class org.silex.adminApi.listModels.ToolBarGroups extends ListModelBase
{
	/**
	 * the array containing the groups of toolbar group
	 */
	private var _toolBars:Array;
	
	/**
	 * add two callback to the silex JS object, so that
	 * plugins can register groups and items via JavascriptScript
	 */
	public function ToolBarGroups()
	{
		super();
		
		_objectName = "toolBarGroups";
		_selectedObjectIds = new Array();
		_toolBars = new Array();
		
	}
	
	/**
	 * called when a plugin wants to add a group. Creates the group if it does'nt exist and
	 * arrange it in the groups array acoording to it's level. If the group already exists, may
	 * change it's place in the groups array if a level has been send
	 * @param	dataArr the object containg all the data of the group to add
	 */
	public function addItem(data:Object):Void
	{
		//will store the groups of a given toolbar
		var groups:Array;
		
		//the first step is to determine to which toolbar this group
		//must be added to
		var toolBarIdx:Number;
		for (toolBarIdx = 0; toolBarIdx < _toolBars.length; toolBarIdx++)
		{
			//in all the toolbars array, we look for the groups
			//who have the same toolUid as the provided data
			if (data.toolUid == _toolBars[toolBarIdx][0].toolUid)
			{
				//when a match is found
				//we will add our new group among
				//those
				groups = _toolBars[toolBarIdx];
			}
		}
		
		//if no groups has been found
		//add a new item on the toolBars array
		//corresponding to a new toolbar
		if (groups == undefined)
		{
			groups = new Array();
			SilexAdminApi.getInstance().toolBars.addItem( {
				uid:data.toolUid
			});
			_toolBars.push(groups);
		}
		
		
		var flagGroup:Number;
		
		//search in the group array if a group with the same uid already exists
		for (var i:Number = 0; i < groups.length; i++)
		{
			//if a match is found, stores it's index in the flagGroup var
			if (groups[i].uid == data.uid)
			{
				flagGroup = i;
				
				//update the retrieved group values
				var retrievedGroup:ToolBarGroup = groups[i];
				var key:String;
				for (key in data)
				{
					retrievedGroup[key] = data[key];
				}
				
			}
		}
		
		//if no match was found
		if (flagGroup == undefined)
		{
			
			//create a new group and set it up with
			//the sent data
			var group:ToolBarGroup = new ToolBarGroup();
			group.name = data.name;
			group.level = data.level;
			group.toolUid = data.toolUid;
			group.uid = data.uid;
			group.label = data.label;
			group.description = data.description;
			
			//then loop in the groups array looking
			//for the place where the new group must be added
			var flagLevel:Number;
			
			//if the groups array already contains other groups
			if (groups.length > 0)
			{
				//and if a level has been defined for the new group
				if (group.level != null)
				{
					//search in the groups array for the first item
					//which level is superior to the new group level
					for (var i:Number = 0; i < groups.length; i++)
					{
						//if an item is found with a superior level
						if (groups[i].level > group.level)
						{
							//store it's index then break the loop
							flagLevel = i;
							break;
						}
					}
					
					//if the flagLevel was set, add the new group to the flag index
					//in the groups array
					if (flagLevel != undefined)
					{
						groups.splice(flagLevel, 0, group);
					}
					
					//else if the flagLevel was not set, it means that the new group level
					//is superior to every item's level in the array, and so it is added to the
					//end of the array
					else
					{
						groups.push(group);
					}
					
				}
				
				//if no level was defined for the new group, add it to the end of the array
				//and gives a level superior to the last item in the array
				else
				{
					group.level = groups[groups.length -1].level + 1;
					groups.push(group);
				}
			}
			
			//if no groups has already been added to the groups array, just add the new group
			else
			{
				groups.push(group);
			}
		}
		
		//if a group with the same name has been found, and a level has been defined,
		//rearrange the found group place in the groups array
		else if(data.level != null)
		{
			//stores the matching group
			var group:ToolBarGroup = groups[flagGroup];
			group.level = data.level;
			
			
			//loop in the groups array, looking for the first item whose
			//level is superior to the defined group
			for (var j:Number = 0; j <groups.length; j++)
			{
				//if a match is found
				if (groups[j].level > group.level)
				{
					if (j >= flagGroup)
					{
						groups.splice(flagGroup, 1);
						groups.splice(j-1, 0, group);
					}
					
					else
					{
						groups.splice(flagGroup, 1);
						groups.splice(j, 0, group);
					}
					
					break;
				}
			}
			
		}
		
		signalDataChanged();
	}

	/**
	 * Select a toolItem within a group. Only one item can be selected for a group and
	 * each group can have a selected item
	 * @param	objectIds the uid of the items to select
	 * @param	data an optionnal data object
	 */
	public function select(objectIds:Array, data:Object):Void
	{
		//only one item can be selected at a time
		//else we stop
		if (objectIds.length > 1)
		{
			return;
		}
		
		//we loop in the objects ids (only one for now)
		for (var i:Number = 0; i < objectIds.length; i++)
		{
			//we look for the group owning the toolItem thanks to the 
			//given toolItem uid
			var parentGroup:ToolBarGroup;
			//we will also store the toolItems of the parent group
			var parentGroupToolItems:Array;
			
			//we loop in all the toolbars, each containing one or many group(s)
			for (var j:Number = 0; j < _toolBars.length; j++)
			{
				//for eaxch toolbar, we loop in it's group
				for (var k:Number = 0; k < _toolBars[j].length; k++)
				{
					//we store the current group and it's items, retrieved with the group uid
					var currentGroup:ToolBarGroup = _toolBars[j][k];
					var currentGroupToolItems:Array = SilexAdminApi.getInstance().toolBarItems.getData([currentGroup.uid])[0];
					
					//we loop in all of the current group items
					for (var l:Number = 0; l < currentGroupToolItems.length; l++)
					{
						//if one of the items has the same uid as the toolItem we want to select
						//the current group is the parent group of the tool item we want to select
						if (currentGroupToolItems[l].uid == objectIds[i])
						{
							parentGroup = currentGroup;
							parentGroupToolItems = currentGroupToolItems;
						}
					}
				}
				
			}
			
			//if no parent group was found we do nothing
			if (parentGroup == undefined)
			{
				trace("parent group undefined : "+objectIds[i]);
			}
			
			//else if a parent group has been found, we look in the group to see if an item is already selected
			//If we found one, it will be replaced by the one we want to select, else we will just add the one we want
			//to select
			else
			{
				//a flag, true if an item is already selected in this group
				var flagGroupAlreadyHasSelectedItem:Boolean = false;
				
				//we loop in all the group tool items
				for (var m:Number = 0; m < parentGroupToolItems.length; m++)
				{
					//we loop in all the currently selected tool items
					for (var n:Number = 0; n < _selectedObjectIds.length; n++)
					{
						//if there is a match, we replace the tool item uid by the one we want to select
						//and break the loop
						if (_selectedObjectIds[n] == parentGroupToolItems[m].uid)
						{
							flagGroupAlreadyHasSelectedItem = true;
							_selectedObjectIds[n] = objectIds[i];
							break;
						}
					}
				}
				
				//if no item was selected, we just add the item to the selection
				if (flagGroupAlreadyHasSelectedItem == false)
				{
					_selectedObjectIds.push(objectIds[i]);
				}
			}
					
				
			
		}
		
		//we dispatch an event to signal the selection change
		var eventForLocal:Object = {target:this, type:AdminApiEvent.EVENT_SELECTION_CHANGED, data:_selectedObjectIds};
		dispatchEvent(eventForLocal);
		var eventForTransmission:AdminApiEvent = new AdminApiEvent(AdminApiEvent.EVENT_SELECTION_CHANGED, _objectName, _selectedObjectIds);
		ExternalInterfaceController.getInstance().dispatchEvent(eventForTransmission);
		signalDependantListsDataChanged();
	}
	
	/**
	 * return the groups matching the containerUids parameter
	 * or return them all if it is left undefined
	 * */
	public function getData(containerUids:Array):Array{
		
		var ret:Array = new Array();
		
		if (containerUids != undefined)
		{
			var idxToolBars:Number;
			for (idxToolBars = 0; idxToolBars < _toolBars.length; idxToolBars++)
			{
				var idxContainerUids:Number;
				for (idxContainerUids = 0; idxContainerUids < containerUids.length; idxContainerUids++)
				{
					if (_toolBars[idxToolBars][0].toolUid == containerUids[idxContainerUids])
					{
						ret.push(_toolBars[idxToolBars]);
					}
				}
			}
		}
		
		else
		{
			ret = _toolBars;
		}
		
		
		return ret;
	}
}
