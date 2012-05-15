package org.silex.wysiwyg.ui.library
{
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.containers.Box;
	import mx.containers.Canvas;
	import mx.containers.HDividedBox;
	import mx.controls.List;
	import mx.controls.scrollClasses.ScrollBar;
	import mx.core.ClassFactory;
	import mx.core.UIComponent;
	import mx.events.ListEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.ui.WysiwygList;
	import org.silex.wysiwyg.ui.library.components.LibraryFinderListItemRenderer;
	import org.silex.wysiwyg.ui.library.Preview.WysiwygLibraryListPreview;
	import org.silex.wysiwyg.ui.library.components.WysiwygLibraryList;
	
	public class WysiwygLibraryView extends Canvas
	{

		/**
		 * the container for the lists
		 */ 
		private var _panelsContainer:HDividedBox;
		
		public function WysiwygLibraryView()
		{
			super();
			this.percentHeight = 100;
			this.percentWidth = 100;
			
			this.setStyle("disabledOverlayAlpha", 0);

			_panelsContainer = new HDividedBox();
			_panelsContainer.percentHeight = 100;
			
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			
			addChild(_panelsContainer);
		}
		
		/**
		 * checks the data sent by the controller and sets, add and remove lists accordingly
		 * 
		 * @param value the list object sent
		 */  
		override public function set data(value:Object):void
		{
			//if the data is not null
			if (value)
			{
				
				
				//extract the dataProvider from the value object
				var dataArray:Array = value.dataProviderArray as Array;
				
				//extracts the length of the dataArray and the number of displayed panels
				var dataArrayLength:int = dataArray.length;
				var listArrayLength:int = _panelsContainer.numChildren;
				
				// if there are more items in the dataArray than displayed (each item represents a panel)
				if (dataArrayLength > listArrayLength)
				{
					//we first refresh the data of the existing panels
					for (var i:int = 0; i<listArrayLength; i++)
					{
						dataArray[i] = removeEmptyObject(dataArray[i]);
						var panel:Object = _panelsContainer.getChildAt(i);
						refreshPanel(panel, dataArray[i], i);
						
					}
					
					//then add all the missing lists to the display lists and sets
					//their data with the corresponding dataArray item
					for (i = listArrayLength ; i < dataArrayLength; i++)
					{
						//clean the data array from empty folder
						dataArray[i] = removeEmptyObject(dataArray[i]);
						//method that add a new list
						addNewPanel(dataArray[i], i);
					}			
					
				}
					
					//if they are as many items in the dataArray as list in the listArray
				else if (dataArrayLength == listArrayLength)
				{
					//loop in all the dataArray
					for ( i = 0;i <listArrayLength; i++)
					{
						//clean the dataArray from empty folder
						dataArray[i] = removeEmptyObject(dataArray[i]);
						panel = _panelsContainer.getChildAt(i);
						
						refreshPanel(panel, dataArray[i], i);
						
					}
					
				}
					
					//else if they are less item in the dataArray than list in the list array
				else if (dataArrayLength < listArrayLength)
				{
					
					//loop in all dataArray to determine where the data differs
					for ( var k:int = 0; k < dataArrayLength; k++)
					{
						dataArray[k] = removeEmptyObject(dataArray[k]);
						panel = _panelsContainer.getChildAt(k);
						refreshPanel(panel, dataArray[k], k);
						
						
						
					}
					
					// removes all lists items that differs
					for (var j:int = dataArrayLength; j < listArrayLength; j++)
					{
						removePanel(_panelsContainer.getChildAt(_panelsContainer.numChildren - 1) as UIComponent);
					}
					
					
					dispatchEvent(new PluginEvent(PluginEvent.UPDATE_LIBRARY_PATH, value.targetPath, true));
					
				}
				
				reconstructPath(value);
			}
				
			// if the data is null,
			//resets the library
			else
			{
				var listLength:int = _panelsContainer.numChildren;
				for (var l:int = 0; l< listLength ; l++)
				{
					removePanel(_panelsContainer.getChildAt(_panelsContainer.numChildren - 1) as UIComponent);
				}
				
			}
		}
		
		/**
		 * reconstruct the user selection in each list if the user refresh the
		 * library
		 */ 
		private function reconstructPath(value:Object):void
		{
			var targetArray:Array = value.targetPath.split("/");
			targetArray.shift();
			
			for (var i:int=0; i<targetArray.length; i++)
			{
				value.dataProviderArray[i] = removeEmptyObject(value.dataProviderArray[i]);
				for(var k:int = 0; k<value.dataProviderArray[i].length; k++)
				{	
					if (value.dataProviderArray[i][k])
					{
						if (value.dataProviderArray[i][k]['item name'] == targetArray[i])
						{
							
							if (_panelsContainer.getChildAt(i) is List)
							{
								(_panelsContainer.getChildAt(i) as List).selectedIndex = k;
							}
							
						}
					}
					
				}
			}
		}
		
		/**
		 * adds a new list to the list Array and to the displayList
		 * 
		 * @param dataProvider the dataProvider to be set on the new list
		 */ 
		private function addNewPanel(dataProvider:Array, position:int):void
		{
			var newPanel:UIComponent;
			switch (checkFileType(dataProvider))
			{
				case "folder":
				newPanel = new WysiwygLibraryList();
				(newPanel as WysiwygLibraryList).data = dataProvider;
				break;
				
				case "file":
				newPanel = new WysiwygLibraryListPreview();
				(newPanel as WysiwygLibraryListPreview).data = dataProvider;
				break;
		
			}
			newPanel.addEventListener(PluginEvent.UPDATE_LIBRARY_PATH, onUpdateLibraryPath);
			newPanel.addEventListener(PluginEvent.SELECT_LIBRARY_ITEM, onSelectLibraryItem);
			
			_panelsContainer.addChildAt(newPanel, position);
		}
		
		private function refreshPanel(panel:Object, data:Array, position:int):void
		{
			
			var panelFileType:String = checkFileType(panel.data);
			var dataFileType:String = checkFileType(data)
			if (panelFileType != dataFileType)
			{
				removePanel(panel as UIComponent);
				addNewPanel(data, position);
			}
			
			else
			{
				panel.data = data;
			}
		}
		
		private function onSelectLibraryItem(event:PluginEvent):void
		{
			dispatchEvent(new PluginEvent(PluginEvent.SELECT_LIBRARY_ITEM, event.data));
		}
		
		
		private function onUpdateLibraryPath(event:PluginEvent):void
		{
			dispatchEvent(new PluginEvent(PluginEvent.UPDATE_LIBRARY_PATH, event.data));
		}
		
		private function checkFileType(data:Object):String
		{
			var ret:String;
			switch (data["item type"])
			{
				case "file":
					ret =  "file";
					break;
				
				case "folder":
					ret =  "folder";
					break;
			}
			return ret;
		}
		
		/**
		 * removes a list from the display list
		 * 
		 * @param list the List to be removed
		 */ 
		private function removePanel(panel:UIComponent):void
		{
			panel.removeEventListener(PluginEvent.UPDATE_LIBRARY_PATH, onUpdateLibraryPath);
			panel.removeEventListener(PluginEvent.SELECT_LIBRARY_ITEM, onSelectLibraryItem);
			_panelsContainer.removeChild(panel);
		}
		
		
		/**
		 * removes all the empty objects from the dataProvider
		 * 
		 * @param dataProvider the dataProvider to filter
		 */ 
		private function removeEmptyObject(dataProvider:Array):Array
		{
			var dataProviderLength:int = dataProvider.length;
			
			while (dataProviderLength >= 0)
			{
				if (! dataProvider[dataProviderLength])
				{
					dataProvider.splice(dataProviderLength, 1);
				}
				
				dataProviderLength--;
			}
			
			return dataProvider;
		}
		
		
		/**
		 * override the default scrollbars behaviour to resize the list container
		 * height when a scrollbar appears
		 */ 
		override public function set horizontalScrollBar(value:ScrollBar):void
		{
			super.horizontalScrollBar = value;
			
			if (value == null) {
				// the scroll-bar is being removed, reset height to original values
				_panelsContainer.percentHeight = 100;
			} else {
				// scroll bar is being enabled, adjust height to include it
				_panelsContainer.height = this.height - ScrollBar.THICKNESS;
			}
		}
	}
}