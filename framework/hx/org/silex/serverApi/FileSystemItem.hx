/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

/**
*  This class is haXe specific. It wasn't present in SILEX vanilla-PHP.
*  It represents a FileSystem item such as a file or a folder.
*/
class FileSystemItem
{
	/**
	*  The name of the item.
	*/
	public var itemName : String;
	/**
	*  The name of the item without extension. If name has several extension, only the last one is removed.
	*/
	public var itemNameNoExtension : String;
	/**
	*  Date and time of last modification.
	*/
	public var itemLastModificationDate : String;
	/**
	*  The size of the item.
	*/
	public var itemSize : Int;
	/**
	*  The size, in human-readable format, of the item.
	*/
	public var itemReadableSize : String;
	/**
	*  The type of the item (either file or folder).
	*/
	public var itemType : FileSystemItemType;
	/**
	*  The Width of the image.
	*/
	public var itemWidth : Int;
	/**
	*  The Height of the image.
	*/
	public var itemHeight : Int;
	/**
	*  The mime-type of the image.
	*/
	public var imageType : String;
	/**
	*  The extension of the file. If file's name has several extension, only returns the last one.
	*/
	public var ext : String;
	/**
	*  Null if item is not a folder
	*/
	public var itemContent : Null<Array<FileSystemItem>>;
	
	public function new()
	{	
	}
	
	/**
	*  Parses an item from a php.NativeArray. Links between low (externs) and high-level APIs.
	*/
	public static function parseItem(fileNative : php.NativeArray) : FileSystemItem
	{
		var res = new FileSystemItem();
		var file : Hash<Dynamic> = php.Lib.hashOfAssociativeArray(fileNative);
		res.itemName = file.get("item name");
		res.itemType = if(file.get("item type")=="folder") FileSystemItemType.folder else FileSystemItemType.file;


		switch(res.itemType)
		{
			case FileSystemItemType.file:
				res.itemNameNoExtension = file.get("item name no extension");
				res.itemLastModificationDate = file.get("item last modification date");
				res.itemSize = file.get("item size");
				res.itemReadableSize = file.get("item readable size");
				res.itemWidth = file.get("item width");
				res.itemHeight = file.get("item height");
				res.imageType = file.get("item type");
				res.ext = file.get("ext");
			case FileSystemItemType.folder:
				res.itemContent = parseFolderContent(file.get("itemContent"));
		}

		
		return res;
	}
	
	/**
	*  Parses the content of a folder from a php.NativeArray. Links between low (externs) and high-level APIs.
	*/
	public static function parseFolderContent(folderContent : php.NativeArray) : Array<FileSystemItem>
	{
		var res = new Array<FileSystemItem>();
		var folderContent = untyped __call__("array_values", folderContent);
		var hxFolderContent = php.Lib.toHaxeArray(folderContent);
		for(item in hxFolderContent)
		{
			res.push(parseItem(item));
		}
		return res;
	}
}

/**
*  Enum representing the different kinds of FFileSystemItem.
*/
enum FileSystemItemType
{
	file;
	folder;
}
