/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** This is the base class for components that want to use remoting. All components that should be derived from it
 * are not done yet, so work in progress.
 * .
 * @author Ariel Sommeria-klein
 **/

import mx.remoting.Service;
import mx.utils.Delegate;
//import mx.services.Log;
import org.oof.OofBase;
class org.oof.dataConnectors.RemotingConnector extends OofBase{
	static private var EVENT_SUCCESS:String = "onSuccess";
	static private var EVENT_ERROR:String = "onError";

	private var _serviceName:String = null;
	private var _gatewayUrl:String;
	private var _service:Service = null;
	
    /**
	 * constructor
	 * @return void
	 */
	function RemotingConnector(){
		super();
		_className = "org.oof.dataConnectors.RemotingConnector";
     	// inheritance
     	typeArray.push(_className);
	}

	/** function _initAfterRegister
	 * @returns void
	 */
	public function _initAfterRegister(){		
		super._initAfterRegister();
		if (silexPtr.isSilexServer && (!_gatewayUrl || _gatewayUrl == ""))
		{
			// take the same one as silex by default
			_gatewayUrl = silexPtr.com.gatewayUrl;
		}
		
/*		uncomment to use logging
		var myWebSrvcLog = new Log();
		myWebSrvcLog.onLog = function(message : String) : Void
		{
		}
		_service = new Service(_gatewayUrl, myWebSrvcLog,serviceName );
*/		
		_service = new Service(_gatewayUrl, null, _serviceName );
	 }
	
	
/////////////////////////////////
//Property Accessors
/////////////////////////////////
	
	/** 
	 * property: gatewayUrl 
	 * the url where your the connector can access your remoting service gateway.
	 * example: http://yourserver/yourapp/cgi/gateway.php.
	 * Use in Flash only, in Silex this will be set for you automatically.
	 * */
	[Inspectable(type=String)]
	public function set gatewayUrl(val:String){
		_gatewayUrl = val;
		if(silexPtr.isSilexServer){
			//ignore the configurated one and just take he same one as silex
			_gatewayUrl = silexPtr.com.gatewayUrl;
		}
	}

	public function get gatewayUrl():String{
		return _gatewayUrl;
	}	
	

	/** function set serviceName
	* @param val(String)
	* @returns void
	*/
	[Inspectable(type=String)] //define default value in derived class
	public function set serviceName(val:String){
		_serviceName = val;
	}
	
	/** function get serviceName
	* @returns String
	*/
	
	public function get serviceName():String{
		return _serviceName;
	}	


	
}
