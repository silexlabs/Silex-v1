/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.OofBase;
import mx.controls.Alert;
/** this is a static class for stocking login information. probably obsolete.
 * @author Ariel Sommeria-klein
 * */

class org.oof.security.Login extends OofBase{
	static private var _login:String = null;
	static private var _password:String = null;
	
	static function getCredentials():Object{
		if((_login != null) && (_password != null)){
			return {login:_login, password:_password};
		}else{
				return null;
		}
	}

	static function setCredentials(login:String, password:String){
		if((login != null) && (login != undefined) && (login != '')){
			_login = login;
		}else{
			throw new Error("login invalid : " + login);
		}

		if((password != null) && (password != undefined) && (password != '')){
			_password = password;
		}else{
			throw new Error("password invalid : " + password);
		}
	}
	
	
	static function getLogin():String{
		return _login;
	}
	
	static function setLogin(val:String){
		_login = val;
	}
	
	static function getPassword():String{
		return _password;
	}
	
	static function setPassword(val:String){
		_password = val;
	}

	static function get isLoggedIn():Boolean{
		return (_login != null);
	}

}