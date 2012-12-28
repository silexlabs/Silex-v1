/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

import org.oof.DataIo;
import org.oof.util.md5;
import mx.utils.Delegate;
import flash.net.FileReference;
/*
 This component is used to give to the user the possibility to upload a file to the server.
2 warnings: 
- Contrarily to the rest of OOF, this needs Flash 8.
- It seems there is a bug in the Flash player, that makes the second time this component is loaded fail.
So if you want to use with Silex, put it on the stage somewhere near the root and and make sure it never leaves
it, otherwise the file dialog won't appear.  

The uploader needs a server side script to which to upload the file. It generates a random
filename to avoid overwriting a file. You can also add a subdirectory. 
For example if your user chooses myfile.mp3, a random generated filename would be 
12345678SFSZF
You set subdirectory to /mp3/
You set serverUrl to http://yourserver.com/cgi/services/upload.php
The uploader will call 
http://yourserver.com/cgi/services/upload.php?finalName=/mp3/12345678SFSZF
and pass the file content as a POST parameter.

author:
 
 Ariel Sommeria-klein
*/
class org.oof.dataIos.upload.Uploader extends DataIo{
	/**
	 * group: internal variables
	 * */
	
	private var _fileRef:FileReference = null;
	private var _subDirectory:String;
	private var _serverUrl:String = null;
	private var _typeList:Array = [{description: "tous", extension: "*"}];
	private var _uploadedFileName:String = null;
	private var _originalFileName:String = null;
	private var _scrambleFileName:Boolean = false;
	private var _uploadPercentage:Number = 0;
	private var _forcedUploadedFileName:String = null;
	
	
	/**
	 * group: Events/Callbacks
	 * */
	 public static var EVENT_UPLOAD_SUCCESSFUL = "onUploadSuccessful";
	 public static var EVENT_PROGRESS = "onProgress";
 	 public var onUploadSuccessful:Function;
 	 public var onUploadProgress:Function;
	
	/**
	 * group: internal functions
	 * */
	
	/** function _initAfterRegister
	 * @returns void
	 */
	 public function _initAfterRegister(){
 		super._initAfterRegister();
		_className = "org.oof.dataIos.upload.Uploader";
		typeArray.push(_className);
		_fileRef = new FileReference();
		_fileRef.addListener(this);
	 }
	
	// Display the name of the file
	// call the PHP page for upload
	private function onSelect(){
		_originalFileName = _fileRef.name;
		if((_forcedUploadedFileName == null) ||(_forcedUploadedFileName == '')){
			if(_scrambleFileName){
				var m = new md5();
				_uploadedFileName = _subDirectory + "/" + m.hash(String(Math.random()));
			}else{
				_uploadedFileName = _originalFileName;
			}
		}else{
			_uploadedFileName = _forcedUploadedFileName;
		}
		
		var url:String = _serverUrl + "?finalName=" + _uploadedFileName;
		url = silexPtr.utils.revealAccessors (url,this);
		_fileRef.upload(url); 
	}
	// Action while uploading
	private function onProgress(file:FileReference, bytesLoaded:Number, bytesTotal:Number){
		_uploadPercentage = Math.round(bytesLoaded / bytesTotal * 100);
		dispatch({type:EVENT_PROGRESS, target:this});
		if(onUploadProgress){
			onUploadProgress();
		}
	}
	
	// Action when upload is finished
	private function onComplete(){
		dispatch({type:EVENT_UPLOAD_SUCCESSFUL, target:this});
		if(onUploadSuccessful){
			onUploadSuccessful();
		}
	}
	
	
	// Here is some handler function
	private function onCancel(){
	}
	
	private function onIOError(fileRef){
	}
	
	private function onSecurityError(fileRef, error){
	}
	
	private function onHTTPError(fileRef:FileReference, error:Number){
	}
	/**
	 * group: public functions
	 * */
	

	/** 
	 * function: browse
	 * opens file dialog
	 */
	 public function browse(){
		 if(_typeList == null)
		 	var formattedTypeList = [{description: "tous", extension: "*"}];
		else{
			formattedTypeList = new Array();
			for (var i in _typeList) {
				var split = _typeList[i].split(",");
				var desc:String = split[0];
				var ext:String = split[1];
				formattedTypeList.push( {description: desc, extension: ext});
			}
		}
	}
	
	/** 
	 * function: forceUploadedFileName
	 * forces the name of the file written to the server
	 * use this for example when you want to overwrite an existing file.
	 */
	public function forceUploadedFileName(val:String){
		_uploadedFileName = val;
	}	
	/**
	 * group: public properties
	 * */
/** 
 * property : uploadedFileName
 * 
 * you can read this to write in a database,
 * or set it before uploading when you want to overwrite an existing file
 * */
	
	public function get uploadedFileName():String{
		return _uploadedFileName;
	}
	
	/**
	 * property: originalFileName
	 * the name of the file that the user chose. 
	 * This is different from uploadedFileName,which can be generated.
	 * */
	
	public function get originalFileName():String{
		return _originalFileName;
	}
	
	public function get uploadPercentage():Number{
		return _uploadPercentage;
	}
	/**
	 * group: inspectable properties
	 * */

	/**
	 * property: serverUrl
	 * the url that is called by the uploader. See summary for info on 
	 * how the url is constructed.
	 * 
	 * example: http://silex/v1beta1/cgi/scripts/upload.cgi
	 * */
	[Inspectable(type=String, defaultValue="http://arielsommeria.com/cgi/scripts/upload.cgi")]
	public function set serverUrl(val:String){
		_serverUrl = val;
	}
	
	public function get serverUrl():String{
		return _serverUrl;
	}		

	/** 
	 * property: typeList
	 * the types of files that the user will be able to choose in the file dialog. This can be multiple.
	 * 
	 * examples : 
	 * 
	 * audio, *.mp3
	 * 
	 * all, *.*
	 * 
	 * */			
	[Inspectable(type=Array)]
	public function set typeList(val:Array){
		_typeList = val;
	}
	
	public function get typeList():Array{
		return _typeList;
	}	
	
	/**
	 * property: subDirectory
	 * subdirectory to the upload folder. 
	 * example: /mp3/ 
	 * */
	[Inspectable(type=String, defaultValue="")]
	public function set subDirectory(val:String){
		_subDirectory = val;
	}
	

	public function get subDirectory():String{
		return _subDirectory;
	}	
	

	/**
	 * property: scrambleFileName
	 * if set to false, the file will be written on the server with the same name as the uploaded file.
	 * if set to true, it will be scrambled to something like 102abe8fd3a9395f08a1b85939e8560d
	 * this is useful for avoiding overwriting and good for security, but you must then
	 * keep the relationship between uploadedFileName and originalFileName
	 * */
	[Inspectable(type=Boolean, defaultValue=false)]
	public function set scrambleFileName(val:Boolean){
		_scrambleFileName = val;
	}
	
	public function get scrambleFileName():Boolean{
		return _scrambleFileName;
	}			

}