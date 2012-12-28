/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/** This component is for logging in and out. The connector used must be the Login connector.
 * With this, you can protect a part of your website in silex. If the login is successful, the icon is opened. You can also store the login 
 * as a shared object(the flash equivalent of a cookie). If someone tries to access the protected
 * area by setting the url, the component will check if the login is stored and login automatically.
 * If not access will be denied.  
 * 
* @author Ariel Sommeria-klein
 * */
import org.oof.OofBase;
import org.oof.DataUser;
import org.oof.security.PersistantLogin;
import mx.utils.Delegate;
import org.oof.dataConnectors.remoting.LoginConnector;
import org.oof.dataIos.stringIos.TextFieldIo;
class org.oof.dataUsers.LockedIcon extends DataUser{
	public static var EVENT_LOGIN:String = "onLogin";
	public static var EVENT_LOGOUT:String = "onLogout";
	/** 
	 * group: internal
	 * */
	private var _connector:LoginConnector = null;
	private var _redirectionPage:String = null;
	
	/** 
	 * group: events/callbacks
	 * */
	public var onLogin:Function = null;
	public var onLogout:Function = null;
	
	/** 
	 * group: internal
	 * */
	public function LockedIcon(){
		super();
		_className = "org.oof.dataUsers.LockedIcon";
		typeArray.push(_className);
	}
	
	 /** function doOnConnectorFound
	*@returns void
	*/
	private function doOnConnectorFound(oofComp:OofBase):Void{
		super.doOnConnectorFound(oofComp);
		_connector = LoginConnector(oofComp);
	}

	/**
	 * openIconOnDeeplink
	 * check if the deeplink corresponds to this icon
	 * - core.Layout::onDeeplink event
	 */ 
	private function openIconOnDeeplink(ev):Void {
		//disable this function here. the opening is handled in "onLoginCallback", and must not be done here
		redirect();
	}
	
	private function redirect():Void{
		return;
		if(_redirectionPage){
			// clean section
			var sectionName_str:String = silexPtr.utils.cleanID(_redirectionPage);
			
			// relative path <=> do not begin with a '/' or a start
			if (sectionName_str.indexOf("/") != 0 && sectionName_str.indexOf(silexPtr.config.CONFIG_START_SECTION) != 0){
				var layout/*:org.silex.core.Layout*/ = silexPtr.application.getLayout(this);
				sectionName_str = silexPtr.deeplink.getLayoutPath(layout)+"/"+sectionName_str;
			}
	
			if (sectionName_str.indexOf("/") == 0) sectionName_str=sectionName_str.substr(1);
			silexPtr.deeplink.setHash(sectionName_str);
			silexPtr.deeplink.currentPath=sectionName_str;
		}
	}
	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** function onLoginCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the loginSuccess event
	*/
	private function onLoginCallback(accountObj:Object):Void{
		// dispatch the loginSuccess event

		// copy the item data in resultContainer 
		for(var key:String in accountObj){
			_resultContainer[key] = accountObj[key];
		}
		
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_DEEPLINK, target:this });

		// do open
		openIcon();
		dispatch({type:EVENT_LOGIN,target:this});
		// call onLogin callback
		if (onLogin) onLogin();
			
	}
	
	/** function onLogoutCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the logoutSuccess event
	*/
	private function onLogoutCallback():Void{
		for(var key:String in _resultContainer){
			_resultContainer[key] = null;
		}
		dispatch({type:EVENT_LOGOUT,target:this});
		// call onLogout callback
		if (onLogout) onLogout();
		
		//redirect();
			
	}
	
	/** 
	 * group: public functions
	 * */
	
	/** 
	 * function: login
	 */
	public function login(userName:String, pass:String):Void{
	 	_connector.login(Delegate.create(this, onLoginCallback), Delegate.create(this, onErrorCallback), userName, pass); 
	}


	/** 
	 * function: logout
	 * called by logout button
	 */
	public function logout():Void{
	 	_connector.logout(Delegate.create(this, onLogoutCallback), Delegate.create(this, onErrorCallback)); 
		
	 }

	/**
	 * group: inspectable properties
	 * */

	/**
	 * property: redirectionPage
	 * When a user logs out, redirect to this page. Also used when a user tries access reserved space with a deeplink
	 * example: start/logout
	 * */
	[Inspectable(type=String)]
	public function set redirectionPage(val:String):Void{
		_redirectionPage = val;
	}
	
	public function get redirectionPage():String{
		return _redirectionPage;
	}			

		
}