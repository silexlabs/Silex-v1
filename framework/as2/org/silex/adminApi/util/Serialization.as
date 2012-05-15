/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.util.T;
import org.silex.link.HaxeLink;
/**
 * helps with recovering data coming through JS
 * */
class org.silex.adminApi.util.Serialization
{	
	/**
	 * this function is used intensively, so store a static pointer to it for performance
	 * */
	private static var base64EncodeFunction:Function = HaxeLink.getHxContext().haxe.BaseCode.encode;
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
	 * 
	 * this is different from its AS3 equivalent, because there is no "is" keyword and the typeof operator doens't work the same.
	 * So here an array is detected with typeof = "object" and only numerical keys
	 * and there is no "as" keyword and Array(...) doesn't work because it is interpreted as a constructor, so we need a top level unmangleArray function to be able to return an array
	 * 
	 * */	
	
	public static function unmangleArray(obj:Object):Array{
		var ret:Array = new Array();
		for (var key:String in obj) {
			//T.y("unmangleArray", obj, key, obj[key], unmangle(obj[key]));
			ret.push(unmangle(obj[key]));
		}
		
		//for each somehow takes members in reverse order (2,1,0 for example). So do it backwards
		ret.reverse();
		return ret;
	
	}
	
	public static function unmangle(obj:Object):Object {
	
		if(obj == "null"){
			return null;
		}
		
		if(obj == null){
			return null;
		}
		
		//eliminate primitive types
		if(typeof(obj) != "object"){
			return obj;
		}
		
		
		//either object or array is left. If empty, consider it an empty array 
		var shouldBeArray:Boolean = true;
		var key:String;
		var subObj:Object;

		//T.y("test shouldBeArray. obj : ", obj);
		for(key in obj){
		//	T.y("unmangle 1", obj, key, obj[key], unmangle(obj[key]));		
		//	T.y("test shouldBeArray. key : ", key); 
			if(isNaN(parseInt(key))){
				//the key is not numerical. Therefore the object is not intended to be an array
				shouldBeArray = false;
				break;
			}
		}
				
		//T.y("shouldBeArray  : ", shouldBeArray);
		if(shouldBeArray){
			var retArray:Array = new Array();
			for (key in obj) {

				//T.y("unmangle", obj, key, obj[key], unmangle(obj[key]));					
				subObj = obj[key];
				retArray.push(unmangle(subObj));
			}

			//for each somehow takes members in reverse order (2,1,0 for example). So do it backwards
			retArray.reverse();			
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
	
	public static function encodeString(obj:Object):Object
	{
		
		if(obj == "null"){
			return null;
		}
		
		if(obj == null){
			return null;
		}
		
		if (typeof(obj) != "object" && typeof(obj) != "string")
		{
			return obj;
		}
		
		//eliminate primitive types
		if(typeof(obj) == "string"){
			return base64EncodeFunction(obj, "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
		}
		
		
		//either object or array is left. If empty, consider it an empty array 
		var key:String;
		var subObj:Object;

		
		
		//finally Object(associative array)
		var retObj:Object = new Object();
		for(key in obj){
			subObj = obj[key];
			retObj[key] = encodeString(subObj);
		}
		return retObj;
		
		
	}
}
