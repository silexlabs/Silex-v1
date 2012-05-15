/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package  org.silex.adminApi.listedObjects
{
	/**
	 * a strongly type tool item
	 */
	public dynamic class ToolBarItem extends ListedObjectBase
	{
		/**
		 * path to the ui SWF
		 * */
		public var url:String;
		
		/**
		 * label of the item
		 */
		public var label:String;
		
		/**
		 * Place at which he wants to appear
		 * in the ToolItemGroup
		 */
		public var level:Number;
		
		/**
		 * The Uid of the ToolItemGroup to which
		 * he belongs
		 */
		public var groupUid:String;
		
		/**
		 * The Uid of the Tool to which
		 * he belongs
		 */
		public var toolUid:String;
		
		/**
		 * A description for the ToolItem
		 */
		public var description:String;
		
		/**
		 * Wheter or not it should use the standard background
		 * for items
		 */
		public var hasBackground:Boolean;
		
		public function ToolBarItem() 
		{
			
		}
		
	}

}