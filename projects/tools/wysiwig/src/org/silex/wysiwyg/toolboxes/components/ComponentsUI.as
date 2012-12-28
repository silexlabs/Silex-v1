/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.components
{
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.event.ToolsItemRendererEvent;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUI;
	import org.silex.wysiwyg.toolboxes.toolboxes_base.StdUIHeader;
	import org.silex.wysiwyg.utils.ComponentCopier;
	
	
	/**
	 * Acts as a wrapper for the Components ToolBox UI. Composes the Components ToolBox with a reference to each part (header, body, footer)<br>
	 * Listens for events on each part of the ToolBox
	 * 
	 * @author Yannick
	 */
	public class ComponentsUI extends StdUI
	{
		
		public static const REFRESH_COMPONENTS_NAME:String = "refreshComponentsName";
		
		public static const GET_SELECTED_COMPONENTS_NAMES:String = "getSelectedComponentsNames";
		
		/**
		 * Defines the header, body and footer class
		 */ 
		public function ComponentsUI()
		{
			_toolBoxHeaderClass = ComponentsUIHeader;
			_toolBoxBodyClass = ComponentsUIBody;
			_toolBoxFooterClass = ComponentsUIFooter;
			
			this.addEventListener(FlexEvent.CREATION_COMPLETE, onCreationComplete);
			
			
			super();
		}
		
		/**
		 * override the default toolbox style to add a higher footer
		 */ 
		override protected function createChildren():void
		{
			super.createChildren();
			_toolBoxFooter.height = 47;
			_toolBoxFooter.styleName = "";	
		}
		
		/**
		 * Sets the listeners on each Components ToolBox part
		 * 
		 * @param event The FlexEvent dispatched on creation complete
		 */
		private function onCreationComplete(event:FlexEvent):void
		{
			_toolBoxBody.addEventListener(ToolsEvent.LIST_CHANGE, onListChange);
			_toolBoxFooter.addEventListener(ToolsEvent.SWAP_ITEM_DOWN, onSwapItems);
			_toolBoxFooter.addEventListener(ToolsEvent.SWAP_ITEM_UP, onSwapItems);
			_toolBoxFooter.addEventListener(ToolsEvent.SWAP_ITEM_TO_TOP, onSwapItems);
			_toolBoxFooter.addEventListener(ToolsEvent.SWAP_ITEM_TO_BOTTOM, onSwapItems);
			_toolBoxBody.addEventListener(ToolsEvent.CHANGE_ORDER, onChangeOrder);
			_toolBoxFooter.addEventListener(ToolsEvent.DELETE_ITEM, onDeleteItem);
			_toolBoxFooter.addEventListener(ToolsEvent.ADD_ITEM, onAddItem);
			_toolBoxFooter.addEventListener(ToolsEvent.COPY_ITEM, onCopyItem);
			_toolBoxFooter.addEventListener(ToolsEvent.PASTE_ITEM, onPasteItem);
			_toolBoxBody.addEventListener(ToolsEvent.REFRESH_TOOLBOX, onRefreshToolBox);
			_toolBoxBody.addEventListener(ToolsEvent.COMPONENT_LIST_ROLL_OVER, onListRollOver);
		}
		
		/**
		 * When the user swaps component, get each component uid and sends it the<br>
		 * ToolController
		 * 
		 * @param the triggered ToolsEvent
		 */ 
		private function onSwapItems(event:ToolsEvent):void
		{
			
			var currentIndex:int;
			var currentSelectedItemUid:String;
			
			//Extract the uid's from the component lists dataProvider
			var uidArray:Array = getUidArray(_toolBoxBody.data);
			
			//Search for the index of the selected components
			for (var i:int = 0; i < uidArray.length; i++)
			{
				if (uidArray[i] === (_toolBoxBody.currentSelection as Array)[0].uid)
				{
					currentIndex = i;
					break;
				}
			}
			
			currentSelectedItemUid = uidArray[currentIndex];
			
			
			//get the second components uid based on the event type
			switch (event.type)
			{
				// on SWAP_ITEM_UP, the second'uid is the one before the current index
				case ToolsEvent.SWAP_ITEM_UP:

					
					var tempUidArray:Array = uidArray.splice(currentIndex);
					var tempUid:String = uidArray.pop();
					uidArray.push(tempUidArray.shift());
					uidArray.push(tempUid);
					uidArray = uidArray.concat(tempUidArray);
					

				break;
				
				// on SWAP_ITEM_DOWN, the second'uid is the one after the current index
				case ToolsEvent.SWAP_ITEM_DOWN:
					
					tempUidArray= uidArray.splice(currentIndex + 1);
					tempUid= uidArray.pop();
					uidArray.push(tempUidArray.shift());
					uidArray.push(tempUid);
					uidArray = uidArray.concat(tempUidArray);
					
					
					
				break;
				
				// on SWAP_ITEM_TO_BOTTOM, the second'uid is the last one of the uid's list
				case ToolsEvent.SWAP_ITEM_TO_BOTTOM:
					
					tempUid = uidArray.splice(currentIndex, 1);
					uidArray.push(tempUid);
					
				break;
				
				// on SWAP_ITEM_TO_TOP, the second'uid is the first one of the uid's list
				case ToolsEvent.SWAP_ITEM_TO_TOP:

					tempUid = uidArray.splice(currentIndex, 1);
					uidArray.unshift(tempUid);
					
				break;	
			}
			
			var dataObject:Object = new Object();
			dataObject.uidArray = uidArray;
			dataObject.currentSelectedItemUid = [currentSelectedItemUid];
			
			//the uid's are sent to the controller in an Array
			//the first item in the array will appear on top of the second item
			dispatchEvent(new ToolsEvent(ToolsEvent.CHANGE_ORDER, dataObject));
		}
		
		/**
		 * Forward the component list item roll over event
		 * @param event the triggered tools event, contains the uid of
		 * the rolled over component item
		 */ 
		private function onListRollOver(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.COMPONENT_LIST_ROLL_OVER, event.data));
		}
		
		/**
		 * forward the request to copy the selected components
		 * 
		 * @param event the trigerred event
		 */ 
		private function onCopyItem(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.COPY_ITEM));
			setButtonDisplay();
		}
		
		/**
		 * forward the request to paste the selected components
		 * 
		 * @param event the trigerred event
		 */ 
		private function onPasteItem(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.PASTE_ITEM));
		}
		
		/**
		 * update the toolbox display
		 * 
		 * @param event the trigerred event
		 */ 
		private function onRefreshToolBox(event:ToolsEvent):void
		{
			setButtonDisplay();
		}
		
		/**
		 * enables/disable buttons based on the currently selected item
		 */ 
		private function setButtonDisplay():void
		{
			//cast the components list data
			var dataArray:Array = _toolBoxBody.data as Array;
			
			//if data is set on the toolbox list
			if (dataArray)
			{
				//the open library button is enabled
				(_toolBoxFooter as ComponentsUIFooter).isLibraryButtonEnabled = true;
				//Checks if an item is selected and only one item
				if (_toolBoxBody.currentSelection && (_toolBoxBody.currentSelection as Array).length == 1)
				{
					//if only one item is selected, the delete and copy buttons are enabled
					(_toolBoxFooter as ComponentsUIFooter).isDeleteButtonEnabled = true;
					(_toolBoxFooter as ComponentsUIFooter).isCopyButtonEnabled = true;
					//we check if items are already been copied to see if it is necessary to activate the paste button
					(_toolBoxFooter as ComponentsUIFooter).isPasteButtonEnabled = ComponentCopier.getInstance().areItemsCopied();
					
					//Enable/disable the swap buttons based on the selected item
					for (var i:int = 0; i<dataArray.length; i++)
					{
						if (dataArray[i] === _toolBoxBody.currentSelection[0])
						{
							//if the first item of the list is selected, the swap up and swap top buttons are disabled 
							//and the down and bottom buttons are enabled
							if ( i == 0)
							{
								(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = false;
								(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = true;
							}
								//if the last item of the list is selected, the swap down and swap bottom buttons are disabled 
								//and the up and top buttons are enabled
							else if (i == dataArray.length - 1)
							{
								(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = false;
								(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = true;
							}
								//else all the swap buttons are enabled
							else
							{
								(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = true;
								(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = true;
							}
						}
					}
				}
				
				//if multiple items are selected, the swap buttons are disabled and the delete and copy buttons are enabled
				else if (_toolBoxBody.currentSelection && (_toolBoxBody.currentSelection as Array).length > 1)
				{
					(_toolBoxFooter as ComponentsUIFooter).isDeleteButtonEnabled = true;
					(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = false;
					(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = false;
					(_toolBoxFooter as ComponentsUIFooter).isCopyButtonEnabled = true;
					//we check if items are already been copied to see if it is necessary to activate the paste button
					(_toolBoxFooter as ComponentsUIFooter).isPasteButtonEnabled = ComponentCopier.getInstance().areItemsCopied();
				}
				//if no items are selected, the delete, copy and swap buttons are disabled
				else
				{
					(_toolBoxFooter as ComponentsUIFooter).isDeleteButtonEnabled = false;
					(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = false;
					(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = false;
					(_toolBoxFooter as ComponentsUIFooter).isCopyButtonEnabled = false;
					//we check if items are already been copied to see if it is necessary to activate the paste button
					(_toolBoxFooter as ComponentsUIFooter).isPasteButtonEnabled = ComponentCopier.getInstance().areItemsCopied();
				}
			}
			
			//if there are no data in the list
			else
			{
				//disable all the toolbox buttons
				(_toolBoxFooter as ComponentsUIFooter).isDeleteButtonEnabled = false;
				(_toolBoxFooter as ComponentsUIFooter).areUpButtonsEnabled = false;
				(_toolBoxFooter as ComponentsUIFooter).areDownButtonsEnabled = false;
				(_toolBoxFooter as ComponentsUIFooter).isLibraryButtonEnabled = false;
				(_toolBoxFooter as ComponentsUIFooter).isCopyButtonEnabled = false;
				//we check if items are already been copied to see if it is necessary to activate the paste button
				(_toolBoxFooter as ComponentsUIFooter).isPasteButtonEnabled = ComponentCopier.getInstance().areItemsCopied();
			}
		}
		
		/**
		 * When the Component's body list sends a change event, the buttons of the list<br>
		 * are enabled/disabled depending on the item selected. The selection is then<br>
		 * sent to the ToolController
		 * 
		 * @param event the trigerred event
		 */ 
		private function onListChange(event:ToolsEvent):void
		{
			setButtonDisplay();
			dispatchEvent(new ToolsEvent(ToolsEvent.LIST_CHANGE, event.data));
		}
		
		/**
		 * A utility method extracting the components uid from an array and<br>
		 * and sending an array back
		 * 
		 * @param selectionArray The array to be parsed
		 */ 
		private function getUidArray(selectionArray:Object):Array
		{
			var uidArray:Array = new Array();
			
			for (var i:int =0; i<(selectionArray as Array).length; i++)
			{
				uidArray.push((selectionArray as Array)[i].uid);
			}
			return uidArray; 
		}
		
		/**
		 * Sends the new components order to the ComponentsTool after a user's valid Drag'n'Drop
		 * 
		 * @param event The triggered event
		 */
		private function onChangeOrder(event:ToolsEvent):void
		{	
			var objectData:Object = new Object();
			objectData.uidArray = getUidArray(event.data.uidArray);
			objectData.currentSelectedItemUid = getUidArray(event.data.currentSelectedItemUid);
			
			dispatchEvent(new ToolsEvent(ToolsEvent.CHANGE_ORDER, objectData));
		}
		
		/**
		 * Sends the ADD_ITEM event to the ComponentsTool after the user's click on the footer's plus button
		 * 
		 * @param event the triggered event
		 */ 
		private function onAddItem(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.ADD_ITEM, event.data));
		}
		
		/**
		 * Sends the DELETE_ITEM event to the ComponentsTool with the components's data<br>
		 * after the user's click on the footer's delete button
		 * 
		 * @param event the triggered event
		 */ 
		private function onDeleteItem(event:ToolsEvent):void
		{
			dispatchEvent(new ToolsEvent(ToolsEvent.DELETE_ITEM, _toolBoxBody.currentSelection));
		}
		
		/**
		 * sets the selected item on the Components ToolBox's list
		 * 
		 * @param value the data to be set
		 */ 
		override public function select(value:Vector.<String>):void
		{
			//a reference to all the component to select uid
			var componentsUid:Vector.<String> = value;
			
			//if the data object isn't null
			if (value)
			{
				//an Array to be filled with the selected components
				var selectedItems:Array = new Array();
				
				//if no components needs to be selected 
				if (componentsUid.length == 0)
				{
					//unselect all the items in the components list
					_toolBoxBody.selectListItem(null);
				}
				
				//else if components need to be selected and the component list is not empty
				else if (_toolBoxBody.data != null)
				{
					//a reference to all the components in the component list
					var components:Vector.<Component> = Vector.<Component>(_toolBoxBody.data);
					
					//loop in all the components and adds them in an array
					//if their uid matches one of the uid in the uid array
					var componentsLength:int = components.length;
					for (var i:int = 0; i< componentsLength; i++)
					{
						var componentsUidLength:int = componentsUid.length;
						for (var j:int = 0; j<componentsUidLength; j++)
						{
							if (components[i].uid === componentsUid[j])
							{
								selectedItems[selectedItems.length] = components[i];
							}
						}
					}	
					//sets all the selected components in the list
					_toolBoxBody.selectListItem(selectedItems);
				}
				
			}
				
			//sets the buttons state
			setButtonDisplay();
		}
		
		/**
		 * Sets the Components ToolBox's list dataProvider's data.
		 * Disable all the swaps and delete buttons then checks the new data<br>
		 * for the previously selected item
		 * 
		 * @param value the data to be set
		 */ 
		override public function set data(value:Object):void
		{
			_toolBoxBody.data = value;
			setButtonDisplay();	
		}
		
		/**
		 * refresh the names of the components in the list
		 */  
		public function refreshComponentsName(arguments:Object):void
		{
			(_toolBoxBody as ComponentsUIBody).refreshComponentsName(arguments);
		}
		
		/**
		 * Retrieve the selected components in the list and returns a string with 
		 * their name
		 */ 
		public function getSelectedComponentsNames(arguments:Object):String
		{
			var selectedComponents:Array = (_toolBoxBody as ComponentsUIBody).componentList.selectedItems;
			var ret:String = " - ";
			for (var i:int = 0; i<selectedComponents.length; i++)
			{
				ret+= (selectedComponents[i] as Component).name;
				if (i < selectedComponents.length - 1)
				{
					ret+= ", ";
				}
			}
			return ret;
		}
	}
}
		