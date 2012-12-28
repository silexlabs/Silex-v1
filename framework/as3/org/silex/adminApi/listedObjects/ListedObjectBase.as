/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listedObjects
{
	import flash.events.EventDispatcher;

	/**
	 * each silex listed object has some common functionality, described here. These are not event dispatchers, as there is no guarantee that 
	 * because this object exists that the AS2 equivalent still exists. So AS2 doesn't send events through this, but rather through the containing list
	 * */
	public class ListedObjectBase extends EventDispatcher
	{
		public var uid:String;
		
		public var name:String;
		
		public function ListedObjectBase()
		{
		}

	}
}