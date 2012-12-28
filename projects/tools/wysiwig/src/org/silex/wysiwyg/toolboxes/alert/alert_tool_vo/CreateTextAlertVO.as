/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.wysiwyg.toolboxes.alert.alert_tool_vo
{
	public class CreateTextAlertVO extends AlertToolVO
	{
		
		/**
		 * the label for the YES button
		 */ 
		private var _alertYesLabel:String;
		
		/**
		 * the label for the NO button
		 */ 
		private var _alertNoLabel:String;
		
		
		public function CreateTextAlertVO(title:String, alertMsg:String, alertYesLabel:String, alertNoLabel:String)
		{
			super(title, alertMsg);
			this._alertNoLabel = alertNoLabel;
			this._alertYesLabel = alertYesLabel;
		}
		
		public function get alertYesLabel():String
		{
			return _alertYesLabel;
		}
		
		public function get alertNoLabel():String
		{
			return _alertNoLabel;
		}
	}
}