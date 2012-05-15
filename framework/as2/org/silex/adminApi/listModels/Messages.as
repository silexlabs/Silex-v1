/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.listedObjects.Message;
import org.silex.adminApi.listModels.ListModelBase;
import org.silex.core.Utils;

/**
 * ...
 * @author 
 */
class org.silex.adminApi.listModels.Messages extends ListModelBase
{
	public static var STATUS_INFO:String = "info";
	
	public static var STATUS_DEBUG:String = "debug";
	
	public static var STATUS_WARNING:String = "warning";
	
	public static var STATUS_ERROR:String = "error";
	
	
	/**
	 * an array containing all the received message objects
	 */
	private var _messages:Array;
	
	public function Messages() 
	{
		_objectName = "messages";
		
		_silexPtr.application.addEventListener("alertSimple", Utils.createDelegate(this, onSilexCoreAlertSimple));
		_messages = new Array();
	}
	
	public function addItem(data:Object):Void
	{
		var message:Message = new Message();
		message.text = data.text;
		message.time = data.time;
		message.title = data.title;
		message.status = data.status;
		
		_messages.push(message);
		
		signalDataChanged();
	}
	
	private function onSilexCoreAlertSimple(event:Object):Void
	{
		var data:Object = new Object();
		data.text = event.text;
		data.time = event.time;
		data.status = event.status;
		addItem(data);
	}
	
	public function getData():Array
	{
		return new Array(_messages);
	}
	
	/**
	 * Override to prevent setting a delayed callback, as when a delayed callback
	 * is set, if multiple messages are set simultaneously, like when multiple layout
	 * are saved at once, only the last message is displayed
	 * */
	public function signalDataChanged(data:Object):Void {
		
		selectedObjectIds = new Array();
	
		_objectsBuffer = null;
		
		delayedDataChangedEventCallBack(data);
		
	}
	
}