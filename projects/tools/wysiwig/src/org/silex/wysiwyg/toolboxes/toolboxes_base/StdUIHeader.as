/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

package org.silex.wysiwyg.toolboxes.toolboxes_base
{
	import mx.containers.HBox;
	import mx.controls.Label;

	/**
	 * The standard tool box UI header class
	 * 
	 * @author Yannick
	 */
	public class StdUIHeader extends HBox
	{
		/**
		 * A reference to the tool box title defined by subclasses
		 */ 
		protected var _title:String;
		
		/**
		 * A reference to the tool box sub title defined by subclasses
		 */ 
		protected var _subTitle:String;
		
		/**
		 * The label for the toolbox title
		 */ 
		protected var _toolBoxTitle:Label;
		
		/**
		 * The label for the toolbox sub title
		 */ 
		protected var _toolBoxSubTitle:Label;
		
		/**
		 * Instanciates the Title label, sets it's style and adds it to the displayList
		 */ 
		public function StdUIHeader()
		{
			super();
			
			
			_toolBoxTitle = new Label();
			_toolBoxTitle.styleName = "ToolBoxName";
			
			_toolBoxSubTitle = new Label();
			_toolBoxSubTitle.styleName = "ToolBoxSubName";

			
			addChild(_toolBoxTitle);
			addChild(_toolBoxSubTitle);
			
		}
		
		/**
		 * sets the ToolBox's title
		 * 
		 * @param value the title to be set
		 */ 
		public function set title(value:String):void
		{
			_title = value;
			_toolBoxTitle.text = _title;
			
		}
		
		/**
		 * returns the title of the Toolbox
		 */ 
		public function get title():String
		{
			return _title;
		}
		
		/**
		 * sets the ToolBox's sub title
		 * 
		 * @param value the title to be set
		 */ 
		public function set subTitle(value:String):void
		{
			_subTitle = value;
			_toolBoxSubTitle.text = _subTitle;
			
		}
		
		/**
		 * returns the sub title of the Toolbox
		 */ 
		public function get subTitle():String
		{
			return _subTitle;
		}
		
		
	}
}