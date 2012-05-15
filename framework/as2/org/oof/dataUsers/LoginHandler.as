/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component is for logging in and out. The connector used must be the Login connector.
 * With this, you can protect a part of your website in silex, by using this component as 
 * an icon. If the login is successful, the icon is opened. You can also store the login 
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
import org.oof.dataConnectors.LoginWebServiceConnector;
import org.oof.dataIos.stringIos.TextFieldIo;
class org.oof.dataUsers.LoginHandler extends DataUser{
	
	/** 
	 * group: internal
	 * */
	private var _pseudoIoPath:String = null;
	private var _passwordIoPath:String = null;
	private var _connector:LoginWebServiceConnector = null;
	private var _pseudo:String = null;
	private var _password:String = null;
	private var _passwordIo:TextFieldIo = null;
	private var _pseudoIo:TextFieldIo = null;
	private var _persistantLogin:PersistantLogin = null;
	private var _sharedObjectName:String = null; 
	private var _rememberOnComputer:Boolean = false;
	private var _isAuto:Boolean = false;
	
	/** 
	 * group: events/callbacks
	 * */
	var onLoginSuccess:Function = null;
	var onLogoutSuccess:Function = null;
	
	/** 
	 * group: internal
	 * */
	public function LoginHandler(){
		super();
		_className = "org.oof.dataUsers.LoginHandler";
		typeArray.push(_className);
	}
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
		_persistantLogin = new PersistantLogin(_sharedObjectName);
	 	super._initAfterRegister();
		tabChildren = true;
		tryToLinkWith(_pseudoIoPath, Delegate.create(this, doOnPseudoIoFound));
		tryToLinkWith(_passwordIoPath, Delegate.create(this, doOnPasswordIoFound));
		
	 }

	 /** function doOnConnectorFound
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		_connector = LoginWebServiceConnector(oofComp);
		if(_persistantLogin.isAvailable()){
			//try automatic login
			_isAuto = true;
		_pseudo = _persistantLogin.getPseudo();
		_password = _persistantLogin.getPassword();
	 	_connector.doLogin(Delegate.create(this, onDoLoginCallback), Delegate.create(this, onErrorCallback), _pseudo, _password); 
		}
	}

	 /** function doOnPseudoIoFound
	*@returns void
	*/
	function doOnPseudoIoFound(oofComp:OofBase){
		_pseudoIo = TextFieldIo(oofComp);
	}
	
	 /** function doOnPasswordIoFound
	*@returns void
	*/
	function doOnPasswordIoFound(oofComp:OofBase){
		_passwordIo = TextFieldIo(oofComp);
	}
	/**
	 * openIconOnDeeplink
	 * check if the deeplink corresponds to this icon
	 * - core.Layout::onDeeplink event
	 */ 
	function openIconOnDeeplink(ev) {
		//disable this function here. the opening is handled in "onDoLoginCallback", and must not be done here
	}
	
	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** function onDoLoginCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the loginSuccess event
	*/
	function onDoLoginCallback(id:Number){
		// dispatch the loginSuccess event

		if((_rememberOnComputer) && (!_isAuto)){
			_persistantLogin.setCredentials(_pseudo, _password);
		}
		_resultContainer["pseudo"] = _pseudo;
		_resultContainer["password"] = _password;
		_resultContainer["id"] = id;
		//dispatch
		this.dispatch({type: silexInstance.config.UI_PLAYERS_EVENT_DEEPLINK, target:this });

		// do open
		openIcon();
		dispatch({type:"onLoginSuccess",target:this});
		// call onLoginSuccess callback
		if (onLoginSuccess) onLoginSuccess();
			
	}
	
	/** function onLogoutCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the logoutSuccess event
	*/
	function onLogoutCallback(){
		// call onLogoutSuccess callback
		if (onLogoutSuccess) onLogoutSuccess();
		_persistantLogin.unsetCredentials();
		_resultContainer["pseudo"] = null;
		_resultContainer["password"] = null;
		_resultContainer["id"] = null;
		dispatch({type:"onLogoutSuccess",target:this});
			
	}
	
	/** 
	 * group: public functions
	 * */
	
	/** 
	 * function: manualLogin
	 * called by Login button. This is called manualLogin because
	 * logging in can also be automatic.
	 */
	function manualLogin(){
		_isAuto = false;
		_pseudo = _pseudoIo.value;
		_password = _passwordIo.value;
	 	_connector.doLogin(Delegate.create(this, onDoLoginCallback), Delegate.create(this, onErrorCallback), _pseudo, _password); 
	}


	/** 
	 * function: logout
	 * called by logout button
	 */
	public function logout(){
	 	_connector.doLogout(Delegate.create(this, onLogoutCallback), Delegate.create(this, onErrorCallback)); 
		
	 }
	 
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	/** 
	 * group: inspectable properties
	 * */
	/**
	 * property: rememberOnComputer
	 * set this to true if you want to store the login 
	 * information on the user's computer.
	 * You can allow the user to set this himself with a toggle component
	 * */	
	[Inspectable(type = Boolean, default = false)]
	public function set rememberOnComputer(val:Boolean){
		_rememberOnComputer = val;
	}
	
	public function get rememberOnComputer():Boolean{
		return _rememberOnComputer;
	}		

	/**
	 * property: sharedObjectName
	 * the name of the shared object where you will store the login information
	 * example : yourSiteLoginInfo
	 * */
	[Inspectable(type = String, default = "siteLoginSharedObject")]
	public function set sharedObjectName(val:String){
		_sharedObjectName = val;
	}
	

	public function get sharedObjectName():String{
		return _sharedObjectName;
	}		

	/** 
	 * property: pseudoIoPath
	 * the path to the io (textfieldio component, for example) where
	 * the user can type his pseudonym (login)
	 * */
	[Inspectable(type=String, defaultValue="pseudoIo")]
	public function set pseudoIoPath(val:String){
		_pseudoIoPath = val;
	}

	
	public function get pseudoIoPath():String{
		return _pseudoIoPath;
	}	
	
	/** 
	 * property: passwordIoPath
	 * the path to the io (textfieldio component, for example) where
	 * the user can type his password
	 * */
	[Inspectable(type=String, defaultValue="passwordIo")]
	public function set passwordIoPath(val:String){
		_passwordIoPath = val;
	}
	

	public function get passwordIoPath():String{
		return _passwordIoPath;
	}	
	
	

		
}