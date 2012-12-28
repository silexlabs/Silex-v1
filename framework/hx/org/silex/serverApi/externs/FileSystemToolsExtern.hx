/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi.externs;

@:native("file_system_tools") extern class FileSystemToolsExtern
{
	private static function __init__() : Void
	{
		untyped __call__("require_once", "cgi/includes/file_system_tools.php");
		null;
	}
	
	public function new() : Void;
	
	/**
	*  Sanitizes an absolute path.
	*/
	public function sanitize(filePath : String, ?allowNotExistingFiles : Bool) : String;
	/**
	*  Returns true if filePath designates a path that is in the folder corresponding to folderName.
	*/
	public function isInFolder(filePath : String, folderName : String) : Bool;
	/**
	*  Writes xmlData in xmlFileName.
	*/
	public function writeToFile(xmlFileName : String, xmlData : String) : String;
	/**
	*  Converts a size into human-readable format.<br/>
	*  size has to be in bytes.
	*/
	public function readableFormatFileSize(size : Int, ?round : Int) : String;
	/**
	*  Gets size informations about the size of a directory.<br/>
	*  Returns an array with the following keys: size, count, dircount.
	*/
	public function get_dir_size_info(path : String) : php.NativeArray;
	/**
	*  Returns the size of folder in human-readable format.
	*/
	public function getFolderSize(folder : String) : String;
	
	private function getFtpPath(folder : String) : String;
	/**
	*  Creates a folder inside the FTP folder.
	*/
	public function createFtpFolder(folder : String, name : String) : String;
	/**
	*  Renames an item in the FTP folder.
	*/
	public function renameFtpItem(folder : String, oldItemName : String, newItemName : String) : String;
	/**
	*  Removes an item from the FTP folder.
	*/
	public function deleteFtpItem(folder : String, name : String) : String;
	/**
	*  Uploads an item to the FTP folder. Data are taken from $_FILES["Filedata"].
	*/
	public function uploadFtpItem(folder : String, name : String, ?session_id : String) : String;
	/**
	*  Uploads an item to the server. Data are taken from $_FILES["Filedata"].
	*/
	public function uploadItem(folder : String, name : String, ?session_id : String) : String;
	/**
	*  Lists the content of folder.
	*/
	public function listFolderContent(folder : String, ?isRecursive : Bool, ?filter : php.NativeArray, ?orderBy : String, ?reverseOrder : Bool) : php.NativeArray;
	/**
	*  Returns the absolute path of path.
	*/
	public function getAbsolutePath(path : String) : String;
	/**
	*  Tells if the user is allowed to take the action specified on the specified folder.
	*/
	public function isAllowed(folder : String, action : String, ?allowNotExistingFiles : Bool) : Bool;
	/**
	*  Tells if an user having the specified role can take the specified action on the designated file.
	*/
	public function checkRights(filepath : String, usertype : String, action : String) : Bool;
}
