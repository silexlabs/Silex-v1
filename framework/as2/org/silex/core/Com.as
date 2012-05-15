/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
//import mx.remoting.*;
//import mx.rpc.*;
//import org.silex.core.Utils;
//import mx.remoting.debug.NetDebug;
/**
 * This class is the communication unit of SILEX : communication with php, javascript, mySql.
 * In the repository : /trunk/core/Com.as
 * @class Com
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-25
 * @mail	lex@silex.tv
 */
class org.silex.core.Com
{
	/**
	 * reference to silex main Api object (org.silex.core.Api)
	 */
	private var silex_ptr:org.silex.core.Api;
	
	/**
	 * the service object we use to call serverside php methods (with amfPhp)
	 */
//	public var dataExchange_service:Service;
	public var connection:NetConnection;
	
	/**
	 * URL of the amfPhp gateway.
	 * Read only
	 */
	function get gatewayUrl():String{
		return silex_ptr.utils.getRootUrl()+silex_ptr.config.gatewayRelativePath;//"http://localhost/Silex/trunk/cgi/gateway.php";
	}
	/**
	 * Is fscommand supported by the host?
	 * If not we use getURL("javascript:... 
	 */
	public var fscommandSupport_bool:Boolean=false;
	
	/**
	 * Constructor.
	 * @param	api	a reference to the api singleton
	 */
	function Com(api:org.silex.core.Api) {
		// api reference
		silex_ptr=api;
		
		// javascript
		initJsCom();

		//NetDebug.initialize();
		//dataExchange_service = new Service(gatewayUrl, null, silex_ptr.config.DataExchangeServiceName);
		connection = new NetConnection();
		connection.connect(gatewayUrl);
	}
	// *******************************
	// Php - sections management
	// *******************************
	/**
	 * Call getDynData webservice and returns these data:
	 *		- constants: langage, ...
	 *		- dynamic data from a module
	 *		- website data: layout, content folder, media folder
	 *		- files to preload
	 * @param	websiteInfo an object containing any properties to be passed to the webservice in order to retrieve the desired data. <b>websiteInfo has to contain at least "id_site" property set to the website name.</b>
	 * @param	filesList	an array of file names to be retrieved
	 * @param	callback	a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which is an array of objects, one object for each file which contains key/value pairs.
	 */
	public function getDynData(websiteInfo:Object, filesList:Array, callback:Function)
	{

		if (filesList && filesList.length > 0)
		{
			// listeners
			// var responder_obj:ComResponder=new ComResponder;
			var responder_obj:Object=new Object;
			responder_obj.onResult=function(re:Object){
				if (this.callback) this.callback(re);
			};
			responder_obj.onError=function( fault:Object ){
				// call callback function first so that app is initialized
				if (this.callback) this.callback(null);
				// display error message
				this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
				// in org.silex.core.Application: this.silex_ptr.utils.alertSimple("The website '<i>"+this.id_site+"</i>' does not exist. If you want to create it, please login and use the website tool.",silex_ptr.config.commonAlertDuration);
			};
			responder_obj.callback=callback;
			responder_obj.silex_ptr=silex_ptr;
			responder_obj.id_site=websiteInfo.id_site;
			
			// call webservice
//			var pc:PendingCall = dataExchange_service.getDynData(websiteInfo,filesList);
//			pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
			
			connection.call( silex_ptr.config.DataExchangeServiceName+".getDynData", responder_obj, websiteInfo, filesList);

		}
		else
		{
			var res_array:Array = new Array;
			for (var prop in websiteInfo)
				res_array.push(prop + "=" + escape(websiteInfo[prop]) + "&");
			
			callback([res_array]);
		}
	}
	/**
	 * Call writeWebsiteConfig webservice to write into a website config file or to create a website.
	 * @param	websiteInfo an object containing any properties to be passed to the webservice - if empty, delete the website from the server (move it in the trash/ folder ).
	 * @param	id_site		the website name.
	 * @param	callback	a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which is a boolean : the success state of the operation server side.
	 */
	public function writeWebsiteConfig(websiteInfo:Object,id_site:String,callback:Function){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// call callback function first so that app is initialized
			if (this.callback) this.callback(null);
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

//		var pc:PendingCall = dataExchange_service.writeWebsiteConfig(websiteInfo,id_site);
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".writeWebsiteConfig", responder_obj, websiteInfo,id_site);
	}
	/**
	 * Duplicates a website.
	 * The whole website folder is duplicated in contents/.
	 * @param	id_site		the website name.
	 * @param	newName_str	the new website name.
	 * @param	callback	a function which will be called once the operation is done. This function has to receive 1 parameter which a string : empty if everything is ok or the error message of the server side operation, or null if a network error occured.
	 */
	public function duplicateWebsite(id_site:String,newName_str:String,callback:Function){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function 
			if (this.callback) this.callback(null);
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

//		var pc:PendingCall = dataExchange_service.duplicateWebsite(id_site,silex_ptr.utils.cleanID(newName_str));
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".duplicateWebsite", responder_obj, id_site,silex_ptr.utils.cleanID(newName_str));
	}
	/**
	 * Called by org.silex.ui.ToolsManager.
	 * Lists the tools folder.
	 * @param	relativePath	the path of the folder to be listed, starting from the tools/ folder
	 * @param	callback		a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which an array of objects. Each object has the following properties :
	 * item type				a string, either file or folder
	 * item size				a number of bytes, result of the php function filesize
	 * item readable size		a string, formated file size (e.g. "50 Ko")
	 * item name				the file name
	 * item last modification date	last modification date of the file ("Y-m-d\H:i:s")
	 * item width				only if the file is a jpg image
	 * item height				only if the file is a jpg image
	 * itemContent				an array of objects of the same type: recursive process - only for folders (items with type set to "folder")
	 */
	function listToolsFolderContent(relativePath:String,callback:Function){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function
			if (this.callback) this.callback(null);
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

//		var pc:PendingCall = dataExchange_service.listToolsFolderContent(relativePath);
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".listToolsFolderContent", responder_obj, relativePath);
	}
	/**
	 * Called by toolbox.Library.
	 * @param	relativePath	the path of the folder to be listed, starting from the tools/ folder
	 * @param	callback		a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which an array of objects. Each object has the following properties :
	 * item type				a string, either file or folder
	 * item size				a number of bytes, result of the php function filesize
	 * item readable size		a string, formated file size (e.g. "50 Ko")
	 * item name				the file name
	 * item last modification date	last modification date of the file ("Y-m-d\H:i:s")
	 * item width				only if the file is a jpg image
	 * item height				only if the file is a jpg image
	 * itemContent				an array of objects of the same type: recursive process - only for folders (items with type set to "folder")
	 */
	function listFtpFolderContent(relativePath:String,callback:Function){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function
			if (this.callback) this.callback(null);
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

//		var pc:PendingCall = dataExchange_service.listFtpFolderContent(relativePath);
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".listFtpFolderContent", responder_obj, relativePath);
	}

	/**
	 * Called by org.silex.core.Application.save.
	 * Write data to a file - could be a db. The data corresponds to a section, i.e. a page with a deeplink.
	 * @param	xmlData			the data to be stored - if empty, delete the section from the server.
	 * @param	xmlFileName		the file name or record id, a clean version of sectionName
	 * @param	sectionName		the section name
	 * @param	seoData_obj		object with key/value pairs to be stored in the index, i.e. searchable data
	 * @param	callback		a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which is a string : empty if everything is ok or the error message of the server side operation
	 */
	function writeSectionData(xmlData:String, xmlFileName:String, sectionName:String, seoData_obj:Object,callback:Function,domObject:Object){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			this.silex_ptr.utils.alertSimple(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.MESSAGE_SAVE_PAGE_DONE,{xmlFileName:this.xmlFileName, sectionName:this.sectionName}),this.silex_ptr.config.commonAlertDuration);
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function
			if (this.callback) this.callback(null);
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;
		responder_obj.sectionName=sectionName;
		responder_obj.xmlFileName=xmlFileName;

//		var pc:PendingCall = dataExchange_service.writeSectionData(xmlData,xmlFileName,sectionName,silex_ptr.config.id_site,seoData_obj,domObject);
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".writeSectionData", responder_obj, xmlData,xmlFileName,sectionName,silex_ptr.config.id_site,seoData_obj,domObject);
	}
	/**
	 * Start the indexation process on the server.
	 * @param	callback		a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which is the number of media indexed.
	 */
	function regenerateWebsiteIndex(callback:Function){

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			this.silex_ptr.config.indexedPages=re;
			this.silex_ptr.utils.alertSimple(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.MESSAGE_REGENERATE_INDEX_DONE,this.silex_ptr.config),	this.silex_ptr.config.commonAlertDuration);
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function
			if (this.callback) this.callback(null);
		};
		responder_obj.silex_ptr=silex_ptr;
		responder_obj.callback=callback;

//		var pc:PendingCall = dataExchange_service.createWebsiteIndex(this.silex_ptr.config.id_site);
//		pc.responder = new RelayResponder(responder_obj, "onResult", "onError");
		connection.call( silex_ptr.config.DataExchangeServiceName+".createWebsiteIndex", silex_ptr.config.id_site);
	}
	/**
	 * Retrieve the last available version of SILEX.
	 * Called by tools manager.
	 * @param	callback		a function which will be called with the resulting data or null if an error occured. This function has to receive 1 parameter which is a string: the latest stable version available.
	 */
	 function getLatestSilexVersion(callback:Function) {
		 var _lv:LoadVars=new LoadVars;
		 _lv.callback=callback;
		 _lv.backlink=escape(this.silex_ptr.utils.getRootUrl()+silex_ptr.config.id_site+"/");
		 _lv.onLoad=function(success:Boolean){
			if(success){
				this.callback(this.version);
			}
			else{
				this.callback(null);
			}
		};
		 _lv.sendAndLoad(this.silex_ptr.constants.SCRIPT_LATEST_SILEX_VERSION,_lv,"_POST");
	}
	
	function getComponentDescriptors(callback:Function) {

		var responder_obj:Object=new Object;
		responder_obj.onResult=function(re:Object){
			if (this.callback) this.callback(re);
		};
		responder_obj.onError=function( fault:Object ){
			// display error message
			this.silex_ptr.utils.alert(this.silex_ptr.utils.revealAccessors(this.silex_ptr.config.ERROR_WEBSERVICE_ERROR,{fault:fault}));
			// call callback function
			if (this.callback) this.callback(null);
		};
		responder_obj.callback=callback;
		responder_obj.silex_ptr=silex_ptr;

		connection.call( silex_ptr.config.DataExchangeServiceName+".getComponentDescriptors", responder_obj, silex_ptr.config.id_site);
	}

	// *******************************
	// Javascript
	// *******************************
	/**
	 * fscommand support detection.
	 * Start the process to determine if fscommand is supported by the host.
	 */
	public function initJsCom(){
		// ****************************
		// retour de javascript 
		_root.silex_result_func=function (prop,ancien,nouv,dataz){
			//_root.result_str=nouv;
			if (nouv!="_no_value_"){
				_root.silex_result_obj.onResult(nouv);
				_root.silex_result_obj=null;
				_root.silex_result_str="_no_value_";
			}
			return "_no_value_";
		}
		_root.silex_result_str="_no_value_";
		_root.watch("silex_result_str",_root.silex_result_func);

		// commande SILEX depuis javascript
		_root.silex_exec_func=function (prop,ancien,nouv,silex_ptr){
			if (nouv && nouv!="" && nouv!="_no_value_"){
				silex_ptr.interpreter.exec(nouv,_root);
				//_root.silex_exec_str="_no_value_";
			}
			return "_no_value_";
		}
		_root.silex_exec_str="_no_value_";
		_root.watch("silex_exec_str",_root.silex_exec_func,silex_ptr);

		// FSCOMMAND SUPPORT DETECTION 
		_root.hasFscommandSupport=function (prop,ancien,nouv,dataz){
			if (nouv=="true")
				_global.getSilex().com.fscommandSupport_bool=true;
			return nouv;
		}
		_root.fscommandSupport="false";
		_root.watch("fscommandSupport",_root.hasFscommandSupport);

		//jsCall("alert('test')");
		//fscommand("test","--");
		fscommand("eval",escape("document.getElementById('silex').SetVariable('fscommandSupport','true')"));
		//fscommand("eval",escape("alert('test');"));
	}

	// ------------
	// javascript functions
	/**
	 * Call this function to execute javascript code.
	 * Do not forget to place your javascript instructions in void(...).
	 * @example jsCall("void(alert('test1'); alert('test2');)");
	 * @param	commande_str	the javascript command(s) you want to execute
	 */
	public function jsCall(commande_str){
		if(fscommandSupport_bool==true)
			fscommand("eval",escape(commande_str))
		else
			_root.getURL("javascript:"+commande_str);
	}
	/**
	 * Display something in the browser status bar.
	 * @param	etat_str	the string to be displayed in the browser status bar
	 */
	public function jsWindowStatus(etat_str:String){
		jsCall("void(window.status=unescape('"+escape(etat_str)+"'));");
	}
	/**
	 * Call the javascript onStatus
	 * loginSuccess		{ type:"loginSuccess",login:login_str}
	 * logout		
	 * loginError		{ type:"loginError",fault:fault.fault.faultstring,message:silex_ptr.config.MESSAGE_AUTH_FAILD}
	 */
	public function silexOnStatus(event:Object){
/*		var obj_str:String = "{";
		for (var propName in event)
			obj_str += propName + ":" + '"' + (event[propName]) + '",';
		obj_str += "}";
*/
		if (silex_ptr.config.widgetMode!="true")
			jsCall("void(silexOnStatus("+silex_ptr.utils.obj2json(event)+"))");
	}
}
