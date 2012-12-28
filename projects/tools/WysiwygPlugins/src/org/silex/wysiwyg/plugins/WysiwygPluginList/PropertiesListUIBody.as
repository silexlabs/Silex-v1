/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.plugins.WysiwygPluginList
{
	import flash.display.DisplayObject;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	
	import flashx.textLayout.container.ScrollPolicy;
	
	import mx.collections.ArrayCollection;
	import mx.containers.Canvas;
	import mx.containers.HBox;
	import mx.controls.List;
	import mx.controls.TileList;
	import mx.controls.listClasses.IListItemRenderer;
	import mx.core.ClassFactory;
	import mx.events.ListEvent;
	import mx.events.ScrollEvent;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.wysiwyg.event.PluginEvent;
	
	public class PropertiesListUIBody extends Canvas
	{
		private var _list:TileList;
		
		
		public function PropertiesListUIBody()
		{
			
			super();
			
			
			_list = new NoKeyBoardList();
			_list.percentHeight = 100;
			_list.percentWidth = 100;
			_list.columnCount = 3;
			_list.styleName="listEditorItem";
			_list.selectable = false;
			
			_list.itemRenderer = new ClassFactory(PropertiesListUIBodyIteemRenderer);
			

			addChild(_list);
		}
		
		override public function set data(value:Object):void
		{
			_list.dataProvider = new ArrayCollection(value as Array);
		}
	}
}