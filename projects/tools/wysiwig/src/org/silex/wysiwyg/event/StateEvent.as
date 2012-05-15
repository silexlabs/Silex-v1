/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.event
{
	import flash.events.Event;
	
	public class StateEvent extends Event
	{
		/**
		 * the class of the state to enter
		 */ 
		private var _targetState:Object;
		
		/**
		 * the event custom data object
		 */ 
		private var _data:Object;
		
		/**
		 * Sent when the state of the application needs to be changed
		 */ 
		public static const CHANGE_STATE:String = "changeState";
		
		public function StateEvent(type:String, targetState:Object, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_targetState = targetState
			_data = data;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function get targetState():Object
		{
			return _targetState;
		}
	}
}