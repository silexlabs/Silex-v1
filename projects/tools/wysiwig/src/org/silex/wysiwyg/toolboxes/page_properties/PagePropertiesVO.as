/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.page_properties
{
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.adminApi.listedObjects.Layout;
	import org.silex.adminApi.listedObjects.Property;
	
	/**
	 * A value object used to transfer data between the toolbox and the ToolController
	 */ 
	public class PagePropertiesVO
	{
		/**
		 * an array listing all the available layouts
		 */ 
		private var _layoutsList:Array;
		
		/**
		 * the currently selected Layout object
		 */ 
		private var _selectedLayout:Layout;
		
		/**
		 * an array listing all the selected layout components
		 */ 
		private var _componentsList:Array;
		
		/**
		 * the currently selected component
		 */ 
		private var _selectedComponent:Component;
		
		/**
		 * an object containing all the properties where the key is the name of the property
		 */ 
		private var _propertiesList:Object;
		
		/**
		 * specifiy wether the current layout already has a defaul icon
		 */ 
		private var _hasDefaultIcon:Boolean;
	
		/**
		 * a reference to the new page name value
		 */ 
		private var _newPageName:String;
		
		/**
		 * a reference to the icone is default property value
		 */ 
		private var _newIsIconeDefault:Boolean;
		
		/**
		 * a reference to the new page deep link value
		 */ 
		private var _newPageDeepLink:String;
		
		/**
		 * a reference to the new gabarit name
		 */ 
		private var _newGabarit:String;
		
		public function PagePropertiesVO()
		{
		}
		
		public function getIsDefaultIcon():Property
		{
			return _propertiesList["iconIsDefault"];
		}
		
		public function getGabarit():Property
		{
			return _propertiesList["iconLayoutName"];
		}
		
		public function getPageName():Property
		{
			return _propertiesList["iconPageName"];
		}
		
		public function getPageDeepLink():Property
		{
			return _propertiesList["iconDeeplinkName"];
		}
		
		public function set newGabarit(value:String):void
		{
			_newGabarit = value;
		}
		
		public function get newGabarit():String
		{
			return _newGabarit;
		}
		
		public function get newPageName():String
		{
			return _newPageName;
		}
		
		public function set newPageName(value:String):void
		{
			_newPageName = value;
		}
		
		public function get newIsIconeDefault():Boolean
		{
			return _newIsIconeDefault;
		}
		
		public function set newIsIconeDefault(value:Boolean):void
		{
			_newIsIconeDefault = value;
		}
		
		public function set newPageDeepLink(value:String):void
		{
			_newPageDeepLink = value;
		}
		
		public function get newPageDeepLink():String
		{
			return _newPageDeepLink;
		}
		
		public function get layoutList():Array
		{
			return _layoutsList;
		}
		
		public function set layoutList(value:Array):void
		{
			_layoutsList = value;
		}
		
		public function get selectedLayout():Layout
		{
			return _selectedLayout;
		}
		
		public function set selectedLayout(value:Layout):void
		{
			_selectedLayout = value;
		}
		
		public function get componentsList():Array
		{
			return _componentsList;
		}
		
		public function set componentsList(value:Array):void
		{
			_componentsList = value;
		}
		
		public function set hasDefaultIcon(value:Boolean):void
		{
			_hasDefaultIcon = value;
		}
		
		public function get hasDefaultIcon():Boolean
		{
			return _hasDefaultIcon;
		}

		
		public function set selectedComponent(value:Component):void
		{
			_selectedComponent = value;
		}
		
		public function get selectedComponent():Component
		{
			return _selectedComponent;
		}
		
		public function set propertiesList(value:Object):void
		{
			_propertiesList = value;
		}
		
		public function get propertiesList():Object
		{
			return _propertiesList;
		}
	}
}