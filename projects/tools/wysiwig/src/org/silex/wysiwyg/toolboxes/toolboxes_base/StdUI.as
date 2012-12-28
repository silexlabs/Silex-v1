/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.toolboxes_base
{

	import flash.display.DisplayObject;
	import flash.errors.IllegalOperationError;
	
	import mx.controls.Label;
	import mx.core.ClassFactory;
	import mx.core.IFactory;
	import mx.core.ScrollPolicy;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.silex.wysiwyg.toolboxes.layouts.LayoutsUIHeader;
	
	/**
	 * The Base Class for standard tool box. Compose standard tool box with header, body and footer classes defined in subClasses
	 * 
	 * @author Yannick
	 */ 
	public class StdUI extends ToolUIBase
	{
		/**
		 * defines the toolBoxHeader class
		 */ 
		protected var _toolBoxHeaderClass:Class;
		
		/**
		 * a reference to the toolBoxHeader
		 */ 
		protected var _toolBoxHeader:StdUIHeader;

		/**
		 * defines the toolBoxFooter class
		 */ 
		protected var _toolBoxFooterClass:Class;
		
		/**
		 * a reference to the toolBoxFooter
		 */ 
		protected var _toolBoxFooter:StdUIFooter;

		/**
		 * defines the toolBoxBody class
		 */ 
		protected var _toolBoxBodyClass:Class;
		
		/**
		 * a reference to the toolBoxBody
		 */ 
		protected var _toolBoxBody:StdUIBody;
		

		
		public function StdUI()
		{
			super();
			this.clipContent = false;
			this.percentHeight = 100;
			this.percentWidth = 100;
			this.verticalScrollPolicy = ScrollPolicy.OFF;
			this.horizontalScrollPolicy = ScrollPolicy.OFF;
		}
		
		/**
		 * An override of the Flex method. Instantiates tool box parts with class define by the<br>
		 * subclasses and adds them to the displayList.
		 */ 
		override protected function createChildren():void
		{
			super.createChildren();
			
			_toolBoxHeader = new _toolBoxHeaderClass();
			_toolBoxHeader.percentWidth = 100;
			_toolBoxHeader.height = 30;
			_toolBoxHeader.styleName = "ToolBoxHeader";
			
			_toolBoxBody = new _toolBoxBodyClass();
			_toolBoxBody.percentHeight = 100;
			_toolBoxBody.percentWidth = 100;
			_toolBoxBody.styleName = "ToolBoxBody";
			
			_toolBoxFooter  = new _toolBoxFooterClass();
			_toolBoxFooter.percentWidth = 100;
			_toolBoxFooter.height = 24;
			_toolBoxFooter.styleName = "ToolBoxFooter";	
			
			this.addChild(_toolBoxHeader);
			this.addChild(_toolBoxBody);
			this.addChild(_toolBoxFooter);
		}
		
		/**
		 * An override of the set data method setting the data on the toolBoxBody part
		 * 
		 * @param value The Object containing the data to set
		 */
		override public function set data(value:Object):void
		{
			super.data =  value;
			_toolBoxBody.data = value;
		}
	}
}