/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.publication;

/**
*  This class represents a page in a publication's structure.
*/
class PageModel
{
	public var name : String;
	public var title : String;
	public var description : String;
	public var deeplink : String;
	public var keywords : List<String>;
	public var tags : List<String>;
	public var pageLeftNumber : Int;
	public var pageRightNumber : Int;
	public var enabled : Bool;
	public var index : Int;
	
	public function new()
	{
		this.name = "";
		this.title = "";
		this.description = "";
		this.deeplink = "";
		this.keywords = new List<String>();
		this.tags = new List<String>();
		this.pageLeftNumber = 0;
		this.pageRightNumber = 0;
		this.enabled = false;
		this.index = 0;
	}
}