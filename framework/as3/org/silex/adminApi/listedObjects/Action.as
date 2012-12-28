/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.listedObjects
{
	import org.silex.adminApi.ExternalInterfaceController;

	/**
	 * an action in silex. An action is a way of creating an event listener on a silex component. 
	 * a Silex component has a n array of actions
	 * an example representation in silex:
	 * onRelease imagePlayer.playMedia:'test.mp3'
	 * Here it is represented with a separation between he event, the target, the function and the function parameters
	 * 
	 * */
	public class Action extends ListedObjectBase
	{
		public var functionName:String;
		public var modifier:String;
		public var parameters:Array;

		public function Action()
		{
			super();
		}
		
		/**
		 * send an update command through the api to silex 
		 * */
		public function update(functionName:String, modifier:String, parameters:Array):void
		{
			this.functionName = functionName;
			this.modifier = modifier;
			this.parameters = parameters;
			ExternalInterfaceController.getInstance().updateAction(uid, functionName, modifier, parameters);
		}
		
		
	}
}