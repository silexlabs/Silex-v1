/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package  org.silex.wysiwyg.sequencer
{
	import flash.events.EventDispatcher;
	import flash.net.getClassByAlias;
	import flash.utils.getQualifiedClassName;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.sequencer.state_classes.AddLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.ChooseMediaState;

	import org.silex.wysiwyg.sequencer.state_classes.RemoveLayoutState;
	import org.silex.wysiwyg.sequencer.state_classes.UpdateComponentState;

	/**
	 * This class controls the wysiwyg state machine. It is in charge
	 * of instantiating and destroying the states
	 * @author Yannick DOMINGUEZ
	 */
	public class StatesController extends EventDispatcher
	{
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * a reference to the current state
		 */ 
		private var _currentState:StateBaseShortcut;
		
		/**
		 * a reference to the SilexAdminApi
		 */ 
		private var _silexAdminApi:SilexAdminApi;
		
		/**
		 * a reference to the ToolCommunication singleton
		 */ 
		private var _toolCommunication:ToolCommunication;
	
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// ATTRIBUTES
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		public function StatesController(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication ) 
		{
			_silexAdminApi = silexAdminApi;
			_toolCommunication = toolCommunication;
			
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PUBLIC METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * This methods is called on each state change
		 * controls the start and end of states and keeps a reference to the current state
		 * 
		 * @param currentState a reference to the current state
		 */ 		
		public function enterState(event:StateEvent):void
		{
			var targetStateClass:Class = event.targetState as Class;
			
			if (_currentState)
			{
				
				//if the new state is different from the current state
				if ( getQualifiedClassName(_currentState) != getQualifiedClassName(targetStateClass) )
				{
					trace("enter state : "+getQualifiedClassName(targetStateClass));
					_currentState.removeEventListener(StateEvent.CHANGE_STATE, onChangeState);
					_currentState.destroy();
					
					//the new state is instantiated
					_currentState = new targetStateClass(_silexAdminApi, _toolCommunication, event.data);
					_currentState.addEventListener(StateEvent.CHANGE_STATE, onChangeState);
					_currentState.enterState();
					
					
				}
			}
			
			else
			{
				_currentState = new targetStateClass(_silexAdminApi, _toolCommunication, event.data);
				_currentState.addEventListener(StateEvent.CHANGE_STATE, onChangeState);
				_currentState.enterState();
			}
			
			
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// PRIVATE METHODS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * relays State change event dispatched by the current state
		 */ 
		private function onChangeState(event:StateEvent):void
		{
			dispatchEvent(new StateEvent(StateEvent.CHANGE_STATE, event.targetState, event.data, event.bubbles, event.cancelable));
		}
		
		/////*/*/*/*/*/*/*/*/*/*/*/*/
		// GETTERS/SETTERS
		////*/*/*/*/*/*/*/*/*/*/*/*/
		
		/**
		 * returns the current state
		 */ 
		public function get currentState():StateBaseShortcut
		{
			return _currentState;
		}
		
	}

}