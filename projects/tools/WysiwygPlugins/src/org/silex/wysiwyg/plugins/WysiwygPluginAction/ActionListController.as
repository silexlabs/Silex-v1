/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginAction
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.toolboxApi.interfaces.IAction;
	import org.silex.wysiwyg.toolboxApi.interfaces.IActionArray;
	import org.silex.wysiwyg.ui.WysiwygButton;
	
	public class ActionListController extends EventDispatcher
	{
		private var _actionList:ActionList;
		
		public function ActionListController(target:IEventDispatcher=null)
		{
			super(target);
			
			_actionList = new ActionList();
			_actionList.addEventListener(PluginEvent.ACTION_DATA_CHANGED, onActionDataChanged);
		}
		
		public function set data(value:Object):void
		{
			var tempArray:Array = new Array();
			
			for (var i:int = 0; i< (value as Array).length; i++)
			{
				tempArray.push(actionWrapperToString((value as Array)[i] as IActionArray) );
			}

			if (tempArray.length > 1)
			{
				_actionList.multipleSelection = true;
			}
			
			else
			{
				_actionList.multipleSelection = false;
			}
			
			_actionList.data = tempArray;
			
		}
		
		public function get actionList():ActionList
		{
			return _actionList;
		}
		
		private function actionWrapperToString(actionArrayWrapper:IActionArray):IActionArray
		{
			var actionString:String = "";
			
			for (var i:int = 0; i<actionArrayWrapper.actionArray.length; i++)
			{
				actionString += (actionArrayWrapper.actionArray[i] as IAction).modifier
					+ " " + (actionArrayWrapper.actionArray[i] as IAction).functionName;
					
				if ((actionArrayWrapper.actionArray[i] as IAction).parameters.length > 0)
				{
					actionString += ":" + (actionArrayWrapper.actionArray[i] as IAction).parameters.join(",");
				}
			
				actionString +="\r";
			}
			
			actionArrayWrapper.actionString = actionString;
			
			return actionArrayWrapper;
		}
		
		private function updateActionWrapperWithString(actionArrayWrapper:IActionArray):IActionArray
		{
			
			var commands_array:Array= actionArrayWrapper.actionString.split("\r");
			// result variable
			var res_array:Array=new Array();
			
			// for each command line
			for (var idx:int=0;idx<commands_array.length;idx++){
				var commandLine_str:String=commands_array[idx];
				if (commandLine_str!=""){
					// reult vars
					var specifier_str:String;
					var functionName_str:String;
					var parameters_array:Array;
					// useful vars
					var idxSpecifierSpace:int=commandLine_str.indexOf(" ");
					var equalOperatorIndex:int=commandLine_str.indexOf("=");
					var idxSemiCol:int=commandLine_str.indexOf(":");
					
					// operator '='
					// if there is "=" and no ":"
					// or a "=" before any ":"
					if ((equalOperatorIndex>=0 && idxSemiCol<0) || (equalOperatorIndex>0 && equalOperatorIndex<idxSemiCol)){
						// it is "=" operator
						specifier_str=commandLine_str.slice(0,idxSpecifierSpace);
						
						// command
						functionName_str=commandLine_str.slice(idxSpecifierSpace+1);
						
						// params
						parameters_array=[];
					}
					else{
						// if idxSpecifierSpace is not before semicolun, there is no specifier
						if (idxSemiCol>-1 && idxSpecifierSpace>idxSemiCol)
							idxSpecifierSpace=-1;
						// specifier
						if (idxSpecifierSpace>-1)
							specifier_str=commandLine_str.slice(0,idxSpecifierSpace);
						else idxSpecifierSpace=-1;
						
						// command
						if (idxSemiCol>0)
							functionName_str=commandLine_str.slice(idxSpecifierSpace+1,idxSemiCol);
						else{
							// no semi column => to the end
							functionName_str=commandLine_str.slice(idxSpecifierSpace+1);
						}
						
						// params
						if (idxSemiCol>-1)
						{
							parameters_array=commandLine_str.slice(idxSemiCol+1).split(",");
							if (parameters_array.length == 1 && parameters_array[0] == "")
							{
								parameters_array=[];
							}
						}
							
						
						else parameters_array=[];
					}
						// result in an object
						res_array.push({modifier:specifier_str, functionName:functionName_str, parameters:parameters_array});
					
				}
			}
	//		return res_array;
			
			
			actionArrayWrapper.newActionArray = res_array;
			return actionArrayWrapper;
		}		
		
		private function onActionDataChanged(event:PluginEvent):void
		{
			event.stopPropagation();
			dispatchEvent(new PluginEvent(PluginEvent.ACTION_DATA_CHANGED, updateActionWrapperWithString(event.data as IActionArray)));
		}
	}
}