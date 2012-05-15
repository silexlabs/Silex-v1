/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This component is for handing an account. This is obsolete, as account handling is now 
 * managed with the usual database components. Still, there is the captcha functionality that 
 * needs to be rethought and taken from here. This component does not work any more! 
 * 
* @author Ariel Sommeria-klein
 * */
import org.oof.OofBase;
import org.oof.DataUser;
import org.oof.security.PersistantLogin;
import mx.utils.Delegate;
import org.oof.dataConnectors.LoginWebServiceConnector;
import org.oof.dataIos.stringIos.TextFieldIo;
import org.oof.dataIos.displays.ImageDisplay;
class org.oof.dataUsers.AccountHandler extends DataUser{
	static private var className:String = "org.oof.dataUsers.AccountHandler";
	
	private var _pseudoIoPath:String = null;
	private var _passwordIoPath:String = null;
	private var _emailIoPath:String = null;
	private var _mobileIoPath:String = null;
	private var _captchaIoPath:String = null;
	private var _captchaDisplayPath:String = null;
	private var _captchaSourceUrl:String;

	private var _connector:LoginWebServiceConnector = null;
/*
	private var _pseudo:String = null;
	private var _password:String = null;
	private var _email:String = null;
	private var _mobile:String = null;
	private var _captcha:String = null;
*/
	private var _pseudoIo:TextFieldIo = null;
	private var _passwordIo:TextFieldIo = null;
	private var _emailIo:TextFieldIo = null;
	private var _mobileIo:TextFieldIo = null;
	private var _captchaIo:TextFieldIo = null;
	private var _captchaDisplay:ImageDisplay = null;
	
//callbacks
	var onCreateAccountSuccess:Function = null;
	var onUpdateAccountSuccess:Function = null;
	var onGetAccountSuccess:Function = null;
	var onTestUniqueOk:Function;
	var onTestUniqueKo:Function;
	
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
	 	super._initAfterRegister();
		tabChildren = true;
		tryToLinkWith(_pseudoIoPath, Delegate.create(this, doOnPseudoIoFound));
		tryToLinkWith(_passwordIoPath, Delegate.create(this, doOnPasswordIoFound));
		tryToLinkWith(_emailIoPath, Delegate.create(this, doOnEmailIoFound));
		tryToLinkWith(_mobileIoPath, Delegate.create(this, doOnMobileIoFound));
		tryToLinkWith(_captchaIoPath, Delegate.create(this, doOnCaptchaIoFound));
		tryToLinkWith(_captchaDisplayPath, Delegate.create(this, doOnCaptchaDisplayFound));
		
	 }

	 /** function doOnConnectorFound
	*@returns void
	*/
	function doOnConnectorFound(oofComp:OofBase){
		super.doOnConnectorFound(oofComp);
		_connector = LoginWebServiceConnector(oofComp);
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
	
	 /** function doOnEmailIoFound
	*@returns void
	*/
	function doOnEmailIoFound(oofComp:OofBase){
		_emailIo = TextFieldIo(oofComp);
	}
	
	 /** function doOnMobileIoFound
	*@returns void
	*/
	function doOnMobileIoFound(oofComp:OofBase){
		_mobileIo = TextFieldIo(oofComp);
	}
	
	 /** function doOnCaptchaIoFound
	*@returns void
	*/
	function doOnCaptchaIoFound(oofComp:OofBase){
		_captchaIo = TextFieldIo(oofComp);
	}
	
	 /** function doOnCaptchaDisplayFound
	*@returns void
	*/
	function doOnCaptchaDisplayFound(oofComp:OofBase){
		_captchaDisplay = ImageDisplay(oofComp);
	}
	
	/** function getCaptcha
	 */
	function getCaptcha(){
		_captchaDisplay.value = _captchaSourceUrl;

	}
		
	function testUnique(){
		var item:Array = new Array(new Array("pseudo", _pseudoIo.value), new Array("email", _emailIo.value), new Array("mobile",_mobileIo.value));
		_connector.testUnique(Delegate.create(this, onTestUniqueCallback), Delegate.create(this, onErrorCallback), item);
		
	}
	
	/** function createAccount
	 */
	function createAccount(){
	 	_connector.createAccount(Delegate.create(this, onCreateAccountCallback), Delegate.create(this, onErrorCallback), _pseudoIo.value, _passwordIo.value, _emailIo.value, _mobileIo.value, _captchaIo.value); 
	}

	/** function updateAccount
	 */
	function updateAccount(){
	 	_connector.updateAccount(Delegate.create(this, onUpdateAccountCallback), Delegate.create(this, onErrorCallback), _pseudoIo.value, _passwordIo.value, _emailIo.value, _mobileIo.value); 
	}

	/** function getAccount
	 */
	function getAccount(){
	 	_connector.getAccount(Delegate.create(this, onGetAccountCallback), Delegate.create(this, onErrorCallback)); 
	}

	/////////////////////////////////////////
	// class callbacks
	// dispatch events
	// result of the communication with the connector class
	/////////////////////////////////////////

	/** onTestUnique
	 * Called by the connector in return of a request to update or create a record. Passed as the callbackFunction parameter in a call to connector.updateRecord or createRecord
	 * Dispatch the onSetRecord event
	 *@params re	
	 */
	function onTestUniqueCallback(re:Boolean){
		
		// copy the result in resultContainer (for SILEX) or _resultContainer (for AS)
		for(var idx in re){
			_resultContainer[idx]=re[idx];
		}
			
		if(re){
			// dispatch the onTestUniqueOk event
			dispatch({type:"onTestUniqueOk",target:this});
			
			// call onTestUniqueOk callback
			if (onTestUniqueOk) onTestUniqueOk();
		}else{
			// dispatch the onTestUniqueKo event
			dispatch({type:"onTestUniqueKo",target:this});
			
			// call onTestUniqueKo callback
			if (onTestUniqueKo) onTestUniqueKo();
		}
	}
	
	
	/** function onGetAccountCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the onResult event
	*/
	function onGetAccountCallback(re:Object){
		// dispatch the GetAccountSuccess event
		dispatch({type:"onGetAccountSuccess",target:this});
		// call onGetAccountSuccess callback
		if (onGetAccountSuccess) onGetAccountSuccess();
		
		_pseudoIo.value = re.pseudo;
		_emailIo.value = re.email;
		_mobileIo.value = re.mobile;
		
		
	}	

	/** function onCreateAccountCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the onResult event
	*/
	function onCreateAccountCallback(){
		// dispatch the CreateAccountSuccess event
		dispatch({type:"onCreateAccountSuccess",target:this});
	
		// call onCreateAccountSuccess callback
		if (onCreateAccountSuccess) onCreateAccountSuccess();
	}
	
	/** function onUpdateAccountCallback 
	*@returns void
	* Called by the connector in return of a successful request.
	* Dispatch the onResult event
	*/
	function onUpdateAccountCallback(){
		// dispatch the UpdateAccountSuccess event
		dispatch({type:"UpdateAccountSuccess",target:this});

		// call onUpdateAccountSuccess callback
		if (onUpdateAccountSuccess) onUpdateAccountSuccess();
	}	
	
	
	///////////////////////////////////////
	//property accessors
	///////////////////////////////////////
	
	/** function set pseudoIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="pseudoIo")]
	public function set pseudoIoPath(val:String){
		_pseudoIoPath = val;
	}
	
	/** function get pseudoIoPath
	* @returns String
	*/
	
	public function get pseudoIoPath():String{
		return _pseudoIoPath;
	}	
	
	/** function set passwordIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="passwordIo")]
	public function set passwordIoPath(val:String){
		_passwordIoPath = val;
	}
	
	/** function get passwordIoPath
	* @returns String
	*/
	
	public function get passwordIoPath():String{
		return _passwordIoPath;
	}	
	
	/** function set emailIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="emailIo")]
	public function set emailIoPath(val:String){
		_emailIoPath = val;
	}
	
	/** function get emailIoPath
	* @returns String
	*/
	
	public function get emailIoPath():String{
		return _emailIoPath;
	}	
	
	/** function set mobileIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="mobileIo")]
	public function set mobileIoPath(val:String){
		_mobileIoPath = val;
	}
	
	/** function get mobileIoPath
	* @returns String
	*/
	
	public function get mobileIoPath():String{
		return _mobileIoPath;
	}	
	
	/** function set captchaIoPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="captchaIo")]
	public function set captchaIoPath(val:String){
		_captchaIoPath = val;
	}
	
	/** function get captchaIoPath
	* @returns String
	*/
	
	public function get captchaIoPath():String{
		return _captchaIoPath;
	}	
	
	/** function set captchaDisplayPath
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="captchaDisplay")]
	public function set captchaDisplayPath(val:String){
		_captchaDisplayPath = val;
	}
	
	/** function get captchaDisplayPath
	* @returns String
	*/
	
	public function get captchaDisplayPath():String{
		return _captchaDisplayPath;
	}	
	
	/** function set captchaSourceUrl
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String, defaultValue="http://yourserver/yourapp/cgi/captcha.php")]
	public function set captchaSourceUrl(val:String){
		_captchaSourceUrl = val;
	}
	
	/** function get captchaSourceUrl
	* @returns String
	*/
	
	public function get captchaSourceUrl():String{
		return _captchaSourceUrl;
	}		

		
}