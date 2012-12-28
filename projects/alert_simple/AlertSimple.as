/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.AdminApiEvent;
import org.silex.adminApi.listedObjects.Message;
import org.silex.adminApi.listModels.Messages;
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.T;
import org.silex.core.Api;
import org.silex.core.Utils;

/**
 * this classe displays an alert in Silex, with different display
 * for each alert type
 * @author yannick Dominguez yannick.dominguez@gmail.com
 */
class AlertSimple extends MovieClip
{
	//////////////////////////////////////////
	// CONSTANT
	/////////////////////////////////////////
	
	/**
	 * an event called when the Stage is resized
	 */
	private static var STAGE_RESIZE_EVENT:String = "resize";
	
	/**
	 * the identifier of the alertsimple graphical asset found in the Flash
	 * library. The asset comes from the FLA used to compile the class
	 */
	private static var ALERT_SIMPLE_ALERT_IDENTIFIER:String = "alertSimple";
	
	/**
	 * The start of the ID of the movieClips displaying the messages.
	 * Completed with a random number
	 */
	private static var ALERT_SIMPLE_MC_NAME:String = "message_";
	
	//////////////////////////////////////////
	// ATTRIBUTES
	/////////////////////////////////////////
	
	/**
	 * Stores all the messages currently displayed
	 */
	private var _displayedMessages:Array;
	
	/**
	 * a reference to silex API
	 */
	private var _silexPtr:Api;
	
	//////////////////////////////////////////
	// CONSTRUCTOR
	/////////////////////////////////////////
	
	/**
	 * initialise the displayed message array, set listener to Stage resize to redraw
	 * the component when it happens, then add a callback for an init method that will be called on next frame
	 */
	public function AlertSimple() 
	{
		_displayedMessages = new Array();
		_silexPtr = _global.getSilex();
		_silexPtr.application.addEventListener(STAGE_RESIZE_EVENT, Utils.createDelegate(this, onResize));
		_silexPtr.sequencer.doInNextFrame(Utils.createDelegate(this, onCreationComplete));
		
	}
	
	//////////////////////////////////////////
	// PRIVATE METHODS
	/////////////////////////////////////////
	
	/**
	 * When this callback is called, Silex is done initialising the SilexAdminApi, so we
	 * set a listener on the event signaling a new message, then we display all the message that were sent
	 * at startup
	 */
	private function onCreationComplete():Void
	{
		Utils.removeDelegate(this, onCreationComplete);
		SilexAdminApi.getInstance().messages.addEventListener(AdminApiEvent.EVENT_DATA_CHANGED, Utils.createDelegate(this, onMessagesDataChanged));
		
		//we retrieve all the message that have already been stored but not displayed
		var messageArray:Array = SilexAdminApi.getInstance().messages.getData()[0];
		for (var i:Number = 0; i < messageArray.length; i++)
		{
			//and we display them
			displayMessage(messageArray[i]);
		}
	}
	
	/**
	 * When the messages data changed on the SilexAdminApi, we retrieve all the
	 * new messages then display them
	 * @param	event the event sent by SilexAdminApi signaling a data change
	 */
	private function onMessagesDataChanged(event:AdminApiEvent):Void
	{
		var messageArray:Array = SilexAdminApi.getInstance().messages.getData()[0];
		displayMessage(messageArray[messageArray.length - 1]);
	}
	
	/**
	 * When the Stage is resize, we replace all the
	 * currently displayed messages
	 */
	private function onResize():Void
	{
		this.placeMessages();
	}
	
	/**
	 * The method actually displaying the messages. Instantiate the graphical asset that will display
	 * the message, then set it's display using the message object parameters
	 * @param	message the message object containing the message text, title, display duration...
	 */
	private function displayMessage(message:Message):Void
	{
		//we need a unique name for the movieClip of the message we will display, as we may display
		//multiple messages at once
		var aleaName:String = ALERT_SIMPLE_MC_NAME + String(Math.round(Math.random() * 1000));
		//we attach a new movieClip using an asset from the library
		var messageMc:MovieClip = this.attachMovie(ALERT_SIMPLE_ALERT_IDENTIFIER, aleaName, this.getNextHighestDepth());
		
		//The graphical asset of the alert simple has multiple frames, each one
		//containing the graphics for a type of message. We look here for the right frame to display
		var displayedFrame:Number;
		
		//switch the message status to find which frame to display
		switch(message.status)
		{
			case Messages.STATUS_INFO:
			displayedFrame = 1;
			break;
			
			case Messages.STATUS_WARNING:
			displayedFrame = 2;
			break;
			
			case Messages.STATUS_ERROR:
			displayedFrame = 3;
			break;
			
			case Messages.STATUS_DEBUG:
			displayedFrame = 4;
			break;
			
			default:
			displayedFrame = 1;
			break;
			
		}
		
		//retrieve the textFiled form the alertSimple movieClip of the library
		var messageText:TextField = messageMc.messageText;
		
		//go to the right frmae to display the right graphics
		messageMc.gotoAndStop(displayedFrame);
		//set the displayed text
		messageText.htmlText = message.text;
		
		//we retrieve the length of time where the messsage will be display
		//and fall back to a default if not provided
		var displayTime:Number;
		if (! message.time)
		{
			displayTime  = _silexPtr.config.commonAlertDuration;
		}
		
		else
		{
			displayTime = parseInt(message.time);
		}
		
		
		//we set an interval to destroy the message movieClip when the time is elapsed
		var intervalID = setInterval(Utils.createDelegate(this, deleteMessage, messageMc), displayTime);
		
		//we pass the interval ro the messageMc so we can clear it when elapsed
		messageMc.intervalID = intervalID;
		
		//we store the newly created message
		_displayedMessages.push(messageMc);
		
		//we position the message movieClip
		placeMessages();
	}
	
	/**
	 * When a message display duration reach it's end, it is unloaded and
	 * the interval is cleared
	 * @param	messageMc the movieClip displaying the message that must be unloaded
	 */
	private function deleteMessage(messageMc:MovieClip):Void
	{
		//we remove this movieClip form the currently displayed message array
		for (var i:Number = 0; i < _displayedMessages.length; i++)
		{
			if (messageMc == _displayedMessages[i])
			{
				_displayedMessages.splice(i, 1);
			}
		}
		
		//clear the interval, unload the clip, and replace all the remaining
		//message, as the removed message was most likely at the botoom of the pile
		clearInterval(messageMc.intervalID);
		Utils.removeDelegate(this, deleteMessage, messageMc);
		//makes sure that message is hidden, sometimes they are ot removed
		messageMc._visible = false;
		messageMc.unloadMovie();
		placeMessages();
	}
	
	/**
	 * Place all the currently displayed messages to the border of the scresn and set their width to the
	 * Stage width
	 */
	private function placeMessages():Void
	{
		var addedHeight:Number = 0;
		for (var i:Number = 0; i < _displayedMessages.length; i++)
		{
			var messageMc:MovieClip = _displayedMessages[i];
			var messageText:TextField = messageMc.messageText;
			
			
			addedHeight += messageMc._height;
			messageMc._x  = _silexPtr.application.stageRect.left;
			messageMc._y  = _silexPtr.application.stageRect.bottom - addedHeight;
			
			messageMc._width = Stage.width;
		}
	}
	
}