/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.serverApi;

import org.silex.serverApi.externs.FileSystemToolsExtern;

class FileSystemTools
{
	public static var writeAction(getWriteAction, never) : String;
	public static var readAction(getReadAction, never) : String;
	public static var adminRole(getAdminRole, never) : String;
	public static var userRole(getUserRole, never) : String;
	
	public static function getWriteAction() : String
	{
		return untyped __php__("file_system_tools::WRITE_ACTION");
	}
	
	public static function getReadAction() : String
	{
		return untyped __php__("file_system_tools::READ_ACTION");
	}
	
	public static function getAdminRole() : String
	{
		return untyped __php__("file_system_tools::ADMIN_ROLE");
	}
	
	public static function getUserRole() : String
	{
		return untyped __php__("file_system_tools::USER_ROLE");
	}

	var fileSystemToolsExtern : FileSystemToolsExtern;
	
	public function new()
	{
		fileSystemToolsExtern = new FileSystemToolsExtern();
	}
	
	/**
	*  Sanitizes an absolute path.
	*/
	public function sanitize(filePath : String, ?allowNotExistingFiles : Bool) : String
	{
		return fileSystemToolsExtern.sanitize(filePath, allowNotExistingFiles);
	}
	
	/**
	*  Returns true if filePath designates a path that is in the folder corresponding to folderName.
	*/
	public function isInFolder(filePath : String, folderName : String) : Bool
	{
		return fileSystemToolsExtern.isInFolder(filePath, folderName);
	}
	
	/**
	*  Writes xmlData in xmlFileName.
	*/
	public function writeToFile(xmlFileName : String, xmlData : String) : String
	{
		return fileSystemToolsExtern.writeToFile(xmlFileName, xmlData);
	}
	
	/**
	*  Converts a size into human-readable format.<br/>
	*  size has to be in bytes.
	*/
	public function readableFormatFileSize(size : Int, ?round : Int) : String
	{
		return fileSystemToolsExtern.readableFormatFileSize(size, round);
	}
	
	/**
	*  Gets size informations about the size of a directory.<br/>
	*  Returns a Hash with the following keys: size, count, dircount.
	*/
	public function get_dir_size_info(path : String) : Hash<Int>
	{
		var res = new Hash<Int>();
		var tmp = php.Lib.hashOfAssociativeArray(fileSystemToolsExtern.get_dir_size_info(path));
		res.set("size", Std.parseInt(tmp.get("size")));
		res.set("count", Std.parseInt(tmp.get("count")));
		res.set("dircount", Std.parseInt(tmp.get("dircount")));
		return res;
	}
	
	/**
	*  Returns the size of folder in human-readable format.
	*/
	public function getFolderSize(folder : String) : String
	{
		return fileSystemToolsExtern.getFolderSize(folder);
	}
	
	
	private function getFtpPath(folder : String) : String
	{
		return untyped fileSystemToolsExtern.getFtpPath(folder);
	}
	
	/**
	*  Creates a folder inside the FTP folder.
	*/
	public function createFtpFolder(folder : String, name : String) : String
	{
		return fileSystemToolsExtern.createFtpFolder(folder, name);
	}
	
	/**
	*  Renames an item in the FTP folder.
	*/
	public function renameFtpItem(folder : String, oldItemName : String, newItemName : String) : String
	{
		return fileSystemToolsExtern.renameFtpItem(folder, oldItemName, newItemName);
	}
	
	/**
	*  Removes an item from the FTP folder.
	*/
	public function deleteFtpItem(folder : String, name : String) : String
	{
		return fileSystemToolsExtern.deleteFtpItem(folder, name);
	}
	
	/**
	*  Uploads an item to the FTP folder. Data are taken from $_FILES["Filedata"].
	*/
	public function uploadFtpItem(folder : String, name : String, ?session_id : String) : String
	{
		return fileSystemToolsExtern.uploadFtpItem(folder, name, session_id);
	}
	
	/**
	*  Uploads an item to the server. Data are taken from $_FILES["Filedata"].
	*/
	public function uploadItem(folder : String, name : String, ?session_id : String) : String
	{
		return fileSystemToolsExtern.uploadItem(folder, name, session_id);
	}
	
	/**
	*  Lists the content of folder.
	*/
	public function listFolderContent(folder : String, ?isRecursive : Bool, ?filter : Array<String>, ?orderBy : String, ?reverseOrder : Bool) : Array<FileSystemItem>
	{
		var nFilter : Dynamic;
		if(filter != null)
			nFilter = php.Lib.toPhpArray(filter);
		else
			nFilter = filter;
		return FileSystemItem.parseFolderContent(fileSystemToolsExtern.listFolderContent(folder, isRecursive, nFilter, orderBy, reverseOrder));
	}
	
	/**
	*  Returns the absolute path of path.
	*/
	public function getAbsolutePath(path : String) : String
	{
		return fileSystemToolsExtern.getAbsolutePath(path);
	}
	
	/**
	*  Tells if the user is allowed to take the action specified on the specified folder.
	*/
	public function isAllowed(folder : String, action : String, ?allowNotExistingFiles : Bool) : Bool
	{
		return fileSystemToolsExtern.isAllowed(folder, action, allowNotExistingFiles);
	}
	
	/**
	*  Tells if an user having the specified role can take the specified action on the designated file.
	*/
	public function checkRights(filepath : String, usertype : String, action : String) : Bool
	{
		return fileSystemToolsExtern.checkRights(filepath, usertype, action);
	}	
}
