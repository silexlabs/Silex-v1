/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is a class for stocking login information in a shared object on the
 * user's computer. used by login handler.
 * @author Ariel Sommeria-klein
 * */
class org.oof.security.PersistantLogin{
	private var _storedLoginInfo:SharedObject = null;

	private var _loginInfo:Object = null; 
	//sharedObject used to store the login. 
	private var _sharedObjectName:String = null; 
	private var _indexInLoginArray:Number = undefined;

	function PersistantLogin(sharedObjectName:String){
		super();
		_sharedObjectName = sharedObjectName;
		_storedLoginInfo = SharedObject.getLocal(_sharedObjectName); 
		if(_storedLoginInfo.data.loginArray){
			var len = _storedLoginInfo.data.loginArray.length;
			for(var i = 0; i < len; i++){
				var info = _storedLoginInfo.data.loginArray[i];
				if(info.url == _level0._url){
					_loginInfo = info;
					_indexInLoginArray = i;
					break;
				}
			}
		}
	}
	function getCredentials():Object{
		return _loginInfo;
	}

	function setCredentials(pseudoStr:String, passwordStr:String){
		if((pseudoStr == null) || (pseudoStr == undefined) || (pseudoStr == '')){
			throw new Error("login invalid : " + pseudoStr);
		}

		if((passwordStr == null) || (passwordStr == undefined) || (passwordStr == '')){
			throw new Error("password invalid : " + passwordStr);
		}
		
		//set shared object with login info 
		if(_storedLoginInfo.data.loginArray == null){
			_storedLoginInfo.data.loginArray = new Array();
		}
		var info:Object = new Object();
		info.url = _level0._url;
		info.pseudoStr = pseudoStr;
		info.passwordStr = passwordStr;
		if(_indexInLoginArray != undefined){
			//replace old login object
			_storedLoginInfo.data.loginArray[_indexInLoginArray] = info;
		}else{
			//add new login object to existing
			_storedLoginInfo.data.loginArray.push(info);
			_indexInLoginArray = _storedLoginInfo.data.loginArray.length - 1;
		}
		
		_loginInfo = info;
		_storedLoginInfo.flush();
	}
	
	function unsetCredentials(){
		if(_indexInLoginArray != undefined){
			//get rid of old login object
			_storedLoginInfo.data.loginArray.splice(_indexInLoginArray, 1);
		}
		
	}
	
	function getPseudo():String{
		return _loginInfo.pseudoStr;
	}
	
	function setPseudo(val:String){
		_loginInfo.pseudoStr = val;
	}
	
	function getPassword():String{
		return _loginInfo.passwordStr;
	}
	
	function setPassword(val:String){
		_loginInfo.passwordStr = val;
	}

	function isAvailable():Boolean{
		return (_loginInfo != null);
	}

	
	
}