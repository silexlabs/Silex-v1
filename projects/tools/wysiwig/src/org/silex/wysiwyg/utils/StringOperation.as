/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.utils
{
	import nl.demonsters.debugger.MonsterDebugger;
	
	import org.silex.adminApi.listModels.adding.ComponentAddInfo;
	
	/**
	 * A utility class for string operation
	 */ 
	public class StringOperation
	{
		public function StringOperation()
		{
		}
		
		/**
		 * extract an extension from an url
		 * 
		 * @param value the string to parse
		 */ 
		public static function extractExtension(value:String):String
		{
			var temp_value:String = value.slice(value.lastIndexOf(".")+1);
			
			var componentType:String;
			
			switch (temp_value)
			{
				case "jpg"  :
					componentType = ComponentAddInfo.TYPE_IMAGE;
					break;
				
				case "gif"  :
					componentType = ComponentAddInfo.TYPE_IMAGE;
					break;
				
				case "png"  :
					componentType = ComponentAddInfo.TYPE_IMAGE;
					break;
				
				case "swf" :
					if (isOofComponent(value))
					{
						componentType = ComponentAddInfo.TYPE_COMPONENT;
					}
					else
					{
						componentType = ComponentAddInfo.TYPE_IMAGE;
					}
					break;	
				
				case "flv" : 
					componentType = ComponentAddInfo.TYPE_VIDEO;
					break;
				
				case "mp3" : 
					componentType = ComponentAddInfo.TYPE_AUDIO;
					break;
				
				case "cpm.swf" : 
					componentType = ComponentAddInfo.TYPE_COMPONENT;
					break;
				
				default :
					componentType = null
			}
			return componentType;
		}
		
		/**
		 * checks if the url is a oof component
		 * 
		 * @param value the url to parse
		 */ 
		private static function isOofComponent(value:String):Boolean
		{
			value = value.slice(value.lastIndexOf(".")-3);
			
			if (value == "cmp.swf")
			{
				return true;
			}
			else
			{
				return false;
			}
		}
		
		/**
		 * returns the name of the item from an URL
		 * 
		 * @param value the string to parse
		 */ 
		public static function extractItemName(value:String):String
		{
			value = value.slice(value.lastIndexOf("/")+1);
			
			if (StringOperation.isOofComponent(value))
			{
				value = value.slice(0, value.lastIndexOf("."));
			}
				
			value = value.slice(0, value.lastIndexOf("."));
			
			value = StringOperation.replace(value, " ", "");
			value = StringOperation.replace(value, "/", "");
			value = StringOperation.replace(value, ",", "");
			value = StringOperation.replace(value, ".", "");
			value = StringOperation.replace(value, "-", "");
			value = StringOperation.replace(value, "+", "");
			value = StringOperation.replace(value, "<", "");
			value = StringOperation.replace(value, ">", "");
			
			
			return value;
		}
		
		/**
		 * utility method replacing characters in a string
		 * @param	org the string whick will be parsed
		 * @param	fnd the characters that need to be replaced
		 * @param	rpl the replacing characther
		 */
		public static function replace(org:String, fnd:String, rpl:String):String
		{
			return org.split(fnd).join(rpl);
		}
	}
}