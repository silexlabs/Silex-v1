/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.publication;

#if neko
import neko.io.File;
#end
#if php
import php.io.File;
#end

/**
*  This class represents the structure of a publication.
*/
class PublicationStructureModel
{
	/**
	*  The list of pages making the publication
	*/
	public var pages : Array<PageModel>;
	public var hasCover(default, setHasCover) : Bool;
	public var hasDoublePages(default, setHasDoublePages) : Bool;


	/**
	*  Setter for hasCover
	*/
	public function setHasCover(value : Bool)
	{
		hasCover = value;
		recalculatePagesNumbers();
		return hasCover;
	}
	
	/**
	*  Setter for hasDoublePages
	*/
	public function setHasDoublePages(value : Bool)
	{
		hasDoublePages = value;
		recalculatePagesNumbers();
		return hasDoublePages;
	}
	
	/**
	*  This function recalculates pages' number.<br/>
	*  It is automatically called after changing hasCover and hasDoublePages<br/>
	*  It reflects changes in every page's pageLeftNumber and pageRightNumber fields.<br/>
	*  You should call it after adding or removing pages and also after changing pages'order in order for those changes to be reflected.
	*/
	public function recalculatePagesNumbers()
	{
		if(!hasDoublePages)
		{
			var counter = 0;
			for(p in pages)
			{
				counter++;
				p.pageLeftNumber = counter;
				p.pageRightNumber = counter;
			}
		} else
		{
			var counter = 0;
			if(hasCover)
			{
				counter = -1;
			}
			for(p in pages)
			{
				p.pageLeftNumber = ++counter;
				p.pageRightNumber = ++counter;
			}
		}
	}
	
	/**
	*  Returns a PageModel that either has pageLeftNumber == pageNumber or
	*  pageRightNumber == pageNumber<br/>
	*  Returns null if no Page responding to this constraint exists.
	*/
	public function getPageNumber(pageNumber : Int) : Null<PageModel>
	{
		for(p in pages)
		{
			if(p.pageLeftNumber == pageNumber || p.pageRightNumber == pageNumber)
			{
				return p;
			}
		}
		
		return null;
	}
	
#if (neko || php)
	/**
	*  Saves the PublicationStructure on disk.<br/>
	*  @arg basePath The path to the publication's content directory (ex: content/myPublication) 
	*/
	public function save(basePath : String) : Bool
	{
		try
		{
			var path : String = basePath + "/structure.xml";
			var fileOut = File.write(path, false);
			fileOut.writeString(PublicationStructureParser.ps2XML(this).toString());
			fileOut.close();

			return true;
		} catch(e: Dynamic)
		{
			return false;
		}
	}
#end

#if (neko || php)
	/**
	*  Loads the PublicationStructure from disk.<br/>
	*  @arg basePath The path to the publication's content directory (ex: content/myPublication)
	*/
	public static function load(basePath : String) : PublicationStructureModel
	{
		var path : String = basePath + "/structure.xml";
		var tmpPS : PublicationStructureModel = PublicationStructureParser.xml2PS(Xml.parse(File.getContent(path)));
	
		return tmpPS;
	}
#end
	
	public function new()
	{
		pages = new Array<PageModel>();
		hasCover = true;
		hasDoublePages = true;
	}
}