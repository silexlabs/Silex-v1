/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.core.Utils;
import mx.events.EventDispatcher;
//import mx.remoting.*;
//import mx.rpc.*;

/*
 * events
 */
[Event("loginSuccess")]
[Event("loginKeepAliveSuccess")]
[Event("logout")]
[Event("loginError")]

/**
 * This class is used to authenticate users
 * it uses amfphp
 * in the repository : /trunk/core/Authentication.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-30
 * @mail	lex@silex.tv
 */
class org.silex.core.Authentication extends mx.core.UIObject{

	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * Store user login.
	 */
	var currentLogin:String="";
	/**
	 * Store user password.
	 */
	var currentPassword:String="";

	/**
	 * id of the timer used to keep php session active
	 * >=0 when logged in
	 */
	var phpSessionTimerId:Number=-1;
	/**
	 * Constructor.
	 * Initialize context menu to display the about item.
	 * @param	api		reference to silex main Api object (org.silex.core.Api)
	 */
	function Authentication(api:org.silex.core.Api)
	{
		// store Api reference
		silex_ptr=api;

		//eventDispatcher
		EventDispatcher.initialize(this);
	}
	/**
	 * Is the user logged in?
	 * @return	true if the user is logged in, false otherwise
	 */
	function isLoggedIn():Boolean
	{
		return currentLogin != "";
	}
	/**
	 * Login the user to allow access to administration functionalities.
	 * Called by org.silex.core.Application loginCallback.
	 * @param	login_str	The login provided by the user 
	 * @param	pass_str	The password provided by the user 
	 * @param	callback	A callback function called when the operation is done. This function must have 1 parameter which is a boolean and has the value of the success state.
	 */
	function login(login_str:String, pass_str:String, callback/*:Function*/, rememberLogin/*:Boolean*/) 
	{
		// default value for rememberLogin
		if (rememberLogin == undefined && rememberLogin!="false" && rememberLogin!=false) 
			rememberLogin = true;
		else
			rememberLogin = false;
		// credentials
//		silex_ptr.com.dataExchange_service.connection.setCredentials(login_str,pass_str);
//		silex_ptr.com.connection.setCredentials(login_str,pass_str);
		silex_ptr.com.connection.addHeader("Credentials", false, {userid: login_str, password: pass_str});
		
		// store login and password
		currentLogin=login_str;
		currentPassword=pass_str;

		// amf php call
		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback && typeof(this.callback)=="function") this.callback(re);
			//Set shared object to not retype login and password each time
			var storedLoginInfo = SharedObject.getLocal(this.silex_ptr.config.SHARED_OBJECT_NAME);
			if(storedLoginInfo.data.loginArray == null)
				storedLoginInfo.data.loginArray = new Array();
			if (rememberLogin == true)
			{
				var info:Object = new Object();
				info.url = _level0._url;
				info.login_str = login_str;
				info.pass_str = pass_str;
				storedLoginInfo.data.loginArray.push(info);
				storedLoginInfo.data.isLoggedIn = true;
				storedLoginInfo.flush();
			}
			//silex_ptr.application.refreshLoginMenuState();

			// start auto login timer to keep session active
			if (this.silex_ptr.authentication.phpSessionTimerId == -1)
			{
				this.silex_ptr.authentication.dispatchEvent( { type:"loginSuccess", target:this.silex_ptr.authentication } );
				this.silex_ptr.com.silexOnStatus({ type:"loginSuccess",login:login_str});
				this.silex_ptr.authentication.phpSessionTimerId = setInterval(Utils.createDelegate(this.silex_ptr.authentication, this.silex_ptr.authentication.wakeUpPhpSession), this.silex_ptr.config.PHP_SESSION_WAKE_UP_INTERVAL);
			}
			else
			{
				this.silex_ptr.authentication.dispatchEvent( { type:"loginKeepAliveSuccess", target:this.silex_ptr.authentication } );
				this.silex_ptr.com.silexOnStatus({ type:"loginKeepAliveSuccess",login:login_str});
			}
		};
		responder_obj.onError = function( fault:Object )
		{
			this.silex_ptr.utils.alert(this.silex_ptr.config.MESSAGE_AUTH_FAILD);
			// reset login and password
			//currentLogin="";
			this.silex_ptr.authentication.currentPassword="";
			if (this.callback) this.callback(null);
			this.silex_ptr.authentication.dispatchEvent({type:"loginError",target:this.silex_ptr.authentication});
			this.silex_ptr.com.silexOnStatus({ type:"loginError",fault:fault.fault.faultstring,message:this.silex_ptr.config.MESSAGE_AUTH_FAILD});
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;
		responder_obj.pass_str = pass_str;
		responder_obj.login_str = login_str; 
		responder_obj.rememberLogin = rememberLogin;
								  
//		var pc:PendingCall = silex_ptr.com.dataExchange_service.doLogin();
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		//silex_ptr.com.connection.onStatus = Utils.createDelegate(responder_obj,responder_obj.onError);
		silex_ptr.com.connection.call( silex_ptr.config.DataExchangeServiceName+".doLogin", responder_obj);
	}
	/**
	 * wake up php session
	 */
	function wakeUpPhpSession()
	{
		if (currentLogin && currentPassword)
		{
			login(currentLogin, currentPassword, null, false);
		}
	}
	/**
	 * Logout the user to prevent access to administration functionalities.
	 * @param	callback	A callback function called when the operation is done. This function must have 1 parameter which is a boolean and has the value of the success state.
	 */
	function logout(callback:Function) 
	{

		//logout shared object
		var storedLoginInfo = SharedObject.getLocal(silex_ptr.config.SHARED_OBJECT_NAME);
		storedLoginInfo.data.isLoggedIn = false;
		storedLoginInfo.flush();

		// reset login and password
		currentLogin="";
		currentPassword="";

		// stop timer for php session
		if (phpSessionTimerId >= 0)
			clearInterval(phpSessionTimerId);
		phpSessionTimerId = -1;
		
		// amf php call
		var responder_obj:Object=new Object;
		responder_obj.onResult = function(re:Object)
		{
			this.silex_ptr.application.refreshLoginMenuState();
			

			if (this.callback) this.callback(re);
			this.silex_ptr.authentication.dispatchEvent({type:"logout",target:this.silex_ptr.authentication});
			this.silex_ptr.com.silexOnStatus({type:"logout"});
		};
		responder_obj.onError = function( fault:Object )
		{
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,fault));
			if (this.callback) this.callback(null);
			this.silex_ptr.authentication.dispatchEvent({type:"logout",target:this.silex_ptr.authentication});
			this.silex_ptr.com.silexOnStatus({type:"logout"});
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

//		var pc:PendingCall = silex_ptr.com.dataExchange_service.doLogout();
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		//silex_ptr.com.connection.onStatus = Utils.createDelegate(responder_obj,responder_obj.onError);
		silex_ptr.com.connection.call( silex_ptr.config.DataExchangeServiceName+".doLogout", responder_obj);
	}
}
