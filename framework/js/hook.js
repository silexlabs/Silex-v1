/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * Name space for silex tool boxes
 */
var silexNS;
if(!silexNS)
	silexNS = new Object;
	
/**
 * HookManager class
 * Class which handles javascript hooks on the silex API. It is a singleton patern
 */
silexNS.HookManagerClass = function()
{
	this.HookManagerClass();
};
silexNS.HookManagerClass.prototype =
{
	hooks : null,
	/**
	 * Constructor
	 */
	HookManagerClass : function ()
	{
		if (!this.hooks)
		{
			this.hooks = new Array();
		}
	},
	/**
	 * This method is called by the plugins to add a hook on a given method of a given Silex core class. 
	 * When a plugin makes a call to this method, it should always make the corresponding removeHook call.
	 * @example	add a hook on the silex javascript API "loginSuccess" event		silexNS.HookManager.addHook("loginSuccess",openTextEditorTool,null);
	 * @example	here is the callback prototype	function openTextEditorTool(event,args)
	 */
	addHook : function(hookUID, handlerCallback, hookParams)
	{
		if (!this.hooks[hookUID]) this.hooks[hookUID] = new Array();
		this.hooks[hookUID].push({handlerCallback : handlerCallback,hookParams : hookParams});
	},
	/**
	 * This method is called by the plugins to remove a hook which was added by a call to addHook
	 * NEVER TESTED YET !!!
	 */
	removeHook : function(hookUID, handlerCallback)
	{
		if (this.hooks[hookUID] && this.hooks[hookUID].length > 0)
		{
			// loop on the hook objects
			for (hookIdx = 0; hookIdx < this.hooks[hookUID].length; hookIdx++)
			{
				// remove this element if it is the one 
				if (this.hooks[hookUID][hookIdx].handlerCallback == handlerCallback)
				{
					this.hooks[hookUID].splice(hookIdx,1);
					return;
				}
			}
		}
	},
	/**
	 * call all the registered hooks for a given event type
	 * @example silexNS.HookManager.callHooks({type:"loginSuccess",user:"einstein"});
	 */
	callHooks : function(event)
	{
		if (this.hooks[event.type] && this.hooks[event.type].length > 0)
		{
			// store the array of hook objects 
			var hooksArray = this.hooks[event.type];

			// loop on the hook objects
			var hookIdx;
			for (hookIdx = 0; hookIdx < hooksArray.length; hookIdx++)
			{
				// store the hook object
				var hookObject = hooksArray[hookIdx];
				// call the callback with the event and the params
				hookObject.handlerCallback(event, hookObject.hookParams);
			}
		}
	}
};
// initialize
silexNS.HookManager = new silexNS.HookManagerClass();
//if (silexNS.SilexAPI) silexNS.SilexAPI.hookManagerReadyCallback();

/**
 * Hook callback for silex API
 * This is called by Silex AS side
 */
silexOnStatus = function (event)
{
//	alert("silexOnStatus "+event);
//	alert("silexOnStatus "+event.type);
	silexNS.HookManager.callHooks(event);
	return "";
}
