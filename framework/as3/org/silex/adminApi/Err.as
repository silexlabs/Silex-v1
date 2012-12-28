/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.adminApi
{
	import flash.text.TextField;

	/**
	 * static debug class. Use for showing error messages. sends a message to trace, and to a textfield if initialised with it
	 * could be made a singleton, but typing has to be fast
	 * 
	 * */
	public class Err
	{
		/**
		 * the text field used for visual output
		 * */
		private static var _tf:TextField;
		
		/**
		 * constructor
		 * */
		public function Err()
		{
		}
		
		/**
		 * set the text field
		 * */
		public static function setTextField(tf:TextField):void{
			_tf = tf;
		}
		
		/**
		 * call to trace/display error message
		 * */
		public static function err(message:String):void{
			if(!message){
				return;
			}
			trace(message);
			if(_tf){
				_tf.appendText(message + "\r");
			}
		}
		
	}
}