/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.addComponents.componentsButtons
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxApi.event.ToolBoxAPIEvent;
	
	/**
	 * this class is a base class for the buttons appearing in the addComponent toolbox
	 * which add a component to the stage when clicked
	 */ 
	public class AddComponentButtonBase extends MovieClip
	{
		/**
		 * the constant of the default action which simply add a component to the silex.
		 * It is used for abstract component like the XMLConnector and component that don't require
		 * initialisation
		 */
		public static const ACTION_ADD_COMPONENT:String = "addComponent";
		
		/**
		 * the constant for the action which adds a media component to the stage. It is used for visual component
		 * like the Image component to initialise it's "url" property value. It opens the wysiwyg library to search for a media
		 */
		public static const ACTION_ADD_MEDIA_COMPONENT:String = "addMediaComponent";
		
		/**
		 * the constant for the adding a skinnable component to silex. It opens a panel listing all the skins
		 * that can be added and allow the user to browse the library for more skins
		 */ 
		public static const ACTION_ADD_SKINNABLE_COMPONENT:String = "addSkinnableComponent";
		
		/**
		 * the constant for adding a legacy component. It adds a component the old way but 
		 * requires editable properties on the added component
		 */ 
		public static const ACTION_ADD_LEGACY_COMPONENT:String = "addLegacyComponent";
		
		/**
		 * the button added to the stage of the FLA
		 */ 
		public var button:MaskedSimpleButton;
		
		/**
		 * a reference to the mask movieClip of the button
		 */ 
		private var _buttonMask:MovieClip;
		
		/**
		 * an object containing all the parameters of a button. The parameters
		 * vary based on the type of action of the button
		 */ 
		private var _params:Object;
		

		public function AddComponentButtonBase()
		{
			super();
			
			_buttonMask = button.maskedClip;
		}
		
		/**
		 * on click, lauch the add component process based on the type of action of the button
		 * 
		 * @param event the trigerred MouseEvent
		 */ 
		protected function onButtonClick(event:MouseEvent):void
		{
			//we switch the action of the button
			switch (this._params.action)
			{
				//if it is addComponent, we simply add the new component using the toolbox api.
				//this extra abstraction allow the toolbox api to regulate which button is selected.
				//For instance when we use this method, all the button selection is lost whereas when we
				//add a skinnable component, the skinnable component button is selected
				case ACTION_ADD_COMPONENT:
				ToolBoxAPIController.getInstance().loadComponent(_params);
				break;
				
				//we use the toolbox api if it is a media component. The called method will open
				//the library in the wysiwyg
				case ACTION_ADD_MEDIA_COMPONENT:
					ToolBoxAPIController.getInstance().loadLibrary(_params);
				break;
				
				//we use the toolbox api if it is a skinnable component. The called method will open
				//the skin panel
				case ACTION_ADD_SKINNABLE_COMPONENT:
					ToolBoxAPIController.getInstance().loadSkinnableComponent(_params);
				break;	
				
				//we use the toolbox api to add the legacy component. The called method will
				//open the library of the wysiwyg
				case ACTION_ADD_LEGACY_COMPONENT:
					ToolBoxAPIController.getInstance().loadLegacyComponent(_params);
				break;	
				
				//if no action has been defined, we do nothing and display an error
				default:
					SilexAdminApi.getInstance().messages.addItem({title:"unknown button action",text:"this button doesn't have any action",
						time:10000, status:Messages.STATUS_ERROR});
				break;	
					
			}
			
		}
		
		/**
		 * initialise the parameters of the objects, add a listener on it
		 * then load the icon
		 * 
		 * @param data the parameters of the button
		 */ 
		public function initButtonAction(data:Object):void
		{
			this._params = data;
			button.addEventListener(MouseEvent.MOUSE_UP, onButtonClick);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_SKINNABLE_COMPONENT, onComponentButtonSelectionChanged);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_COMPONENT, onComponentButtonSelectionChanged);
			ToolBoxAPIController.getInstance().addEventListener(ToolBoxAPIEvent.LOAD_LIBRARY, onComponentButtonSelectionChanged);
			loadIcon(_params.iconUrl);
		}
		
		/**
		 * loads the custom icon of the button
		 * 
		 * @param url the url of the custom icon
		 */ 
		private function loadIcon(url:String):void
		{
			var loader:Loader = new Loader();
			loader.load(new URLRequest(url));
			_buttonMask.addChild(loader);
		}
		
		/**
		 * When the user selects one of the button to add a component, we check if the selected button
		 * is this one using it's url and set the right toggle state accordingly
		 * 
		 * @param event the event sent by the ToolBoxApi that triggerred the check
		 */ 
		private function onComponentButtonSelectionChanged(event:ToolBoxAPIEvent):void
		{
			if (ToolBoxAPIController.getInstance().selectedAddButtonUid == this._params.uid)
			{
				button.toggle = true;
			}
			
			else
			{
				button.toggle = false;
			}
		}
		
		
		
		
		
		
	}
}