/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.addComponents.toolbar
{
	import flash.display.Sprite;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.controls.TileList;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	import mx.events.ListEvent;
	
	/**
	 * This component is a custom TileList used to display all the row of component
	 * icon at once without Flex virtualisation which caused refresh troubles
	 */ 
	public class AddComponentTileList extends TileList
	{
		/**
		 * parametrise the list with a custom itemRenderer and set it's visual style
		 */ 
		public function AddComponentTileList()
		{
			super();
			this.itemRenderer = new ClassFactory(AddComponentToolItemViewItemRenderer);
			this.percentWidth = 100;
			this.percentHeight = 100;
			this.columnCount = 5;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
			
			this.addEventListener(FlexEvent.UPDATE_COMPLETE, onUpdateComplete);
			this.styleName = "AddComponentList";
		}
		
		/**
		 * when the list data is updated, we deduce the number of row that the list must have to display
		 * every items based on the length of the dataProvider. It allows the list to display all the 
		 * icons at once preventing refresh bug when scrolling rapidly through the list
		 */ 
		private function onUpdateComplete(event:FlexEvent):void
		{
			var rc: int = Math.ceil(this.dataProvider.source.length / this.columnCount);
			if (this.rowCount!=rc) this.rowCount = rc ;
		}
		
		/**
		 * override to delete the highlight indicator of the list
		 */ 
		override protected function drawHighlightIndicator(
			indicator:Sprite, x:Number, y:Number,
			width:Number, height:Number, color:uint,
			itemRenderer:IListItemRenderer):void
		{				
			
		}
		
		/**
		 * override to delete the selection indicator of the list
		 */ 
		override protected function drawSelectionIndicator(
			indicator:Sprite, x:Number, y:Number,
			width:Number, height:Number, color:uint,
			itemRenderer:IListItemRenderer):void
		{
			
		}
	}
}