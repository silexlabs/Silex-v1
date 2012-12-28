/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * the silex list model for tools
 * */
 
import org.silex.adminApi.listedObjects.ToolBar;
import org.silex.adminApi.listModels.ListModelBase;

class org.silex.adminApi.listModels.ToolBars extends ListModelBase
{
	/**
	 * An array storing all of the tools data
	 */
	private var _toolBars:Array;
	
	public function ToolBars()
	{
		super();
		_objectName = "toolBars";
		_toolBars = new Array();
	}
	
	
	/**
	 * Add a new Toolbar or update it's info if the toolbar already existed.
	 * @param	data the data of the item to add
	 */
	public function addItem(data:Object):Void
	{
		
		var flagToolBar:Boolean = false;
		//search for a matching toolbar to replace
		for (var i:Number = 0; i < _toolBars.length; i++)
		{
			if (_toolBars[i].uid == data.uid)
			{
				var retrievedToolBar:ToolBar = _toolBars[i];
				
				//we update the retrieved toolbar properties
				var key:String;
				for (key in data)
				{
					retrievedToolBar[key] = data[key];
				}
				
				flagToolBar = true;
			}
		}	
		
		//if no tool was found, 
		//add one
		if (flagToolBar == false)
		{
			var toolBar:ToolBar = new ToolBar();
		
			toolBar.uid = data.uid;
			toolBar.description = data.description;
			toolBar.label = data.label;
			toolBar.name = data.name;
			
			_toolBars.push(toolBar);
		}
		
		signalDataChanged();
	}
	
	/**
	 * return the selected tools data or all of the tools data
	 * if no uids was defined
	 * @param containerUids the uids of the requested tools
	 * */
	public function getData(containerUids:Array):Array{
		
		var ret:Array = new Array();
		
		if (containerUids != null)
		{
			for (var i:Number = 0; i < _toolBars.length; i++)
			{
				for (var j:Number = 0; j < containerUids.length; j++)
				{
					if (_toolBars[i].uid == containerUids[j])
					{
						ret.push(_toolBars[i]);
					}
				}
			}
		}
		
		else
		{
			for (var i:Number = 0; i < _toolBars.length; i++)
			{
				ret.push(_toolBars[i]);
			}
		}
		
		return new Array(ret);
	}
}
