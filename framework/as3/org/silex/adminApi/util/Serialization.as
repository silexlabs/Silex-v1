/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi.util
{
	import flash.utils.ByteArray;
	import flash.utils.getQualifiedClassName;

	/**
	 * helps with recovering data coming through JS
	 * */	
	public class Serialization
	{
		
		/**
		 * use this when recovering an array from the api, its job is to fix the problems found with transmitting from AS2 to AS3 through JS.
		 * 1: when coming to popup, the array type is lost, so this function rebuilds an array from an object
		 * checks if object should be considered an array.
		 * eliminates all primitive types
		 * then considers the case of either a normal object with non-numerical keys for its members
		 * or an object with only numerical keys, that therefore should be converted back to an array
		 * For example we must attempt to convert this to an array: {"playerName":"remotelyCreatedTestImage","metaData":"media/logosilex.jpg","type":"Image"}
		 * or "hello", or 2
		 * but {0:"hi", 1:"bye"} should be ["hi", "bye"] 
		 * 
		 * 2: a null comes through as "null", and must be converted back. 
		 * */
		public static function unmangle(obj:Object):Object {
		

			
			if(obj == "null"){
				return null;
			}
			
			if(obj == null){
				return null;
			}
			

			//eliminate primitive types
			if((obj is Boolean) || (obj is int) || (obj is Number) || (obj is uint)){
				return obj;
			}
			
			if (obj is String)
			{
				try {
					var decoded:ByteArray = Base64.decode(obj as String); 
					decoded.position = 0;
					obj =  decoded.toString();
					return obj;
				}
				
				catch(e:Error)
				{
					trace("error decoding : "+e.toString());
					return obj;
				}
				
				
			}
			

			
			
			//either object or array is left. If empty, consider it an empty array 
			var shouldBeArray:Boolean = true;
			var key:String;
			var subObj:Object;
			
			for(key in obj){
				//trace("parseInt(prop)" + parseInt(prop));
				//trace("isNaN(parseInt(prop))" + isNaN(parseInt(prop)));
				if(isNaN(parseInt(key))){
					//the key is not numerical. Therefore the object is not intended to be an array
					shouldBeArray = false;
					break;
				}
			}
			
			
			if(shouldBeArray){
				var retArray:Array = new Array();
				for(key in obj){
					subObj = obj[key];
					retArray.push(unmangle(subObj));
				}
				return retArray;
			}
		
			//finally Object(associative array)
			var retObj:Object = new Object();
			for(key in obj){
				subObj = obj[key];
				retObj[key] = unmangle(subObj);
			}
			return retObj;
		}
		
	}
}