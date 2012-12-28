/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * this is only for transmission to JS. Don't use locally in AS2, as it has no reference to target. If you do, then you can't transmit it as serialization fails
 * */
class org.silex.adminApi.AdminApiEvent
{
	/**
	 * data changed event
	 * */
	public static var EVENT_DATA_CHANGED:String = "EVENT_DATA_CHANGED";
	
	/**
	 * selection changed event
	 * */
	public static var EVENT_SELECTION_CHANGED:String = "EVENT_SELECTION_CHANGED";
	
	/**
	 * save layout ok event
	 * data: data.uid is the uid of the layout
	 * */
	public static var EVENT_SAVE_LAYOUT_OK:String = "EVENT_SAVE_LAYOUT_OK";
	
	/**
	 * save layout error event
	 * data: data.uid is the uid of the layout. data.errorMessage is the error message
	 * */
	public static var EVENT_SAVE_LAYOUT_ERROR:String = "EVENT_SAVE_LAYOUT_ERROR";
	
	/**
	 * dispatched when a shortcut input is detected
	 */
	public static var SHORTCUT_EVENT:String = "SHORTCUT_EVENT";
	
	/**
	 * type of the event. SELECTION_CHANGED, for example
	 * */
	public var type:String;
	/**
	 * name of the target. layouts, for example
	 * */
	public var targetName:String;
	/**
	 * optional data field, to be used as necessary
	 * */
	public var data:Object;
	
	public function AdminApiEvent(eventType:String, eventTargetName:String, eventData:Object) 
	{
		this.type = eventType;
		this.targetName = eventTargetName;
		this.data = eventData;
	}
	
}