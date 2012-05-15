/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** * each silex state object has some common functionality, described here * */import org.silex.core.Api;class  org.silex.adminApi.listedObjects.ListedObjectBase{		static private var _silexPtr:Api = null;			/**	 * unique identifier of the object, on the silex side. Used to make sure a command sent to silex manipulates the right object.	 * */	public var uid:String;		/**	 * name of the state object. 	 * */	public var name:String;		/**	 * description of the state object. 	 * */	public var description:String;		public function ListedObjectBase()	{				if(!_silexPtr){			_silexPtr = _global.getSilex(this);		}			}		}