/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.sequencer.state_classes 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.Alert;
	
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.AdminApiEvent;
	import org.silex.adminApi.SilexAdminApi;
	import org.silex.adminApi.listModels.Components;
	import org.silex.adminApi.listModels.Messages;
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	import org.silex.adminApi.listedObjects.Component;
	import org.silex.wysiwyg.ToolCommunication;
	import org.silex.wysiwyg.ToolController;
	import org.silex.wysiwyg.event.CommunicationEvent;
	import org.silex.wysiwyg.event.PluginEvent;
	import org.silex.wysiwyg.event.StateEvent;
	import org.silex.wysiwyg.event.ToolsEvent;
	import org.silex.wysiwyg.io.ToolConfig;
	import org.silex.wysiwyg.sequencer.StateBase;
	import org.silex.wysiwyg.sequencer.StateBaseAddComponent;
	import org.silex.wysiwyg.sequencer.StateBaseShortcut;
	import org.silex.wysiwyg.toolboxApi.ToolBoxAPIController;
	import org.silex.wysiwyg.toolboxes.addComponents.AddComponentsUI;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.AlertToolVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateItemAlertVO;
	import org.silex.wysiwyg.toolboxes.alert.alert_tool_vo.CreateTextAlertVO;
	import org.silex.wysiwyg.utils.StringOperation;
	
	/**
	 * a state designed to add a media component. Display the library to browse the media folder
	 */
	public class AddComponentLibraryState extends StateBaseAddComponent
	{

		/**
		 * displays the component library toolbox and set it's filters (the allowed file extensions that will be displayed)
		 */
		public function AddComponentLibraryState(silexAdminApi:SilexAdminApi, toolCommunication:ToolCommunication, data:Object) 
		{
			super(silexAdminApi, toolCommunication);		
			
			_toolCommunication.show(ToolCommunication.ADD_COMPONENTS_LIBRARY_TOOLBOX);
			_toolCommunication.addEventListener(PluginEvent.SELECT_AS3_LIBRARY_ITEM, onChooseAS3LibraryMedia);
			_toolCommunication.setData(ToolCommunication.ADD_COMPONENTS_LIBRARY_TOOLBOX, ToolBoxAPIController.getInstance().libraryParams);
			
		}
		
		/**
		 * Add the component that the user selected, using the url selected in the library as an 
		 * initObj that will override the default value of the initProperty of the component
		 * (ex: for an Image component, it override the "url" property value
		 * 
		 * @param event the event containing the selected url from the library
		 */ 
		override protected function onChooseLibraryMedia(event:CommunicationEvent):void
		{
			var libraryParams:Object = ToolBoxAPIController.getInstance().libraryParams;
			
			var initObj:Object= new Object();
			 initObj[libraryParams.initPropertyName] = event.data;
			
			SilexAdminApi.getInstance().components.addItem({
				playerName:StringOperation.extractItemName(event.data as String),
				type:ComponentAddInfo.TYPE_COMPONENT,
				metaData:libraryParams.componentUrl,
				className:libraryParams.className,
				initObj:initObj
			});
		}
		
		/**
		 * a hack used when the user wants to add an as3 swf. we add an embeddedObject
		 * frame instead and set the embedded url to the url of the chosen swf
		 */ 
		private function onChooseAS3LibraryMedia(event:PluginEvent):void
		{
			
			var initObj:Object= new Object();
			initObj[ToolConfig.getInstance().embeddedObjectProperty] = ToolConfig.getInstance().rootUrl + event.data;
			
			SilexAdminApi.getInstance().components.addItem({
				playerName:StringOperation.extractItemName(event.data as String),
				type:ComponentAddInfo.TYPE_COMPONENT,
				metaData:ToolConfig.getInstance().embeddedObjectAS2Url,
				className:ToolConfig.getInstance().embeddedObjectClassName,
				initObj:initObj
			});
		}
		
		
		/**
		 * hides the library toolbox
		 * 
		 * @param	event the trigerred Communication event
		 */
		override public function destroy():void
		{			
			super.destroy();
			_toolCommunication.hide(ToolCommunication.ADD_COMPONENTS_LIBRARY_TOOLBOX);
			_toolCommunication.removeEventListener(PluginEvent.SELECT_AS3_LIBRARY_ITEM, onChooseAS3LibraryMedia);
		
		}
	}

}