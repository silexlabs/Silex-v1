/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/** this is an oof CookieComponent. This plugin is a oof component very close to the oof DataContainer component (see http://oof.sourceforge.net/api-v1/ ). You give it the name of the SharedObject and the name of the data you want to store. At start it loads the SharedObject and put the data into slots. When you modify a slot, it stores the value in the SharedObject.
 * @author ZHAO QIAN
 * */
import org.oof.OofBase;

class org.oof.util.CookieComponent extends OofBase{
	private var cookie_so:SharedObject;
	/**
	*cookieName
	**/	
	private var _cookieName:String;
	
	/**
	*the name of table in the sharedObject
	**/
	private var _dataNames:Array = null;
	
	/**
	*auto save value
	**/
	private var _autoSave:Boolean;
	
	/**
	*validityPeriod in seconde
	**/
	private var _validityPeriod:Number;
    /**
    *event onLoadCreate
    **/
	private var CREATE_EVENT:String = "onLoadCreate";
	/**
	*event onLoadExist
	**/
	private var EXIST_EVENT:String = "onLoadExist";
	/**
	*event onSaveSuccess
	**/
	private var SAVE_EVENT_SUCCESS:String = "onSaveSuccess";
	/**
	*event onSaveError
	**/	
	private var SAVE_EVENT_ERROR:String = "onSaveError";
	/**
	*event onDateExpired
	**/	
	private var DATEEXPIRED_EVENT:String = "onDateExpired";
	/**
	*event deleCookie success
	**/
	private var DELETEDATA_SUCCESS:String = "onDeleteCookieSuccess";
	/**
	*function listene to event "allPlayersLoaded"
	**/
	private var allPlayersLoadedDelegate: Function;
	
	function CookieComponent(){
		super();
		typeArray.push("org.oof.util.CookieComponent");
	}
	
	/** 
	 * function _initAfterRegister
	 *decalre names at array dataNames as arrays
	 *declare sharedObject and check this sharedObject esxisted or not
	 */
	 public function _initAfterRegister(){
	 	super._initAfterRegister();
	 	
	 	cookie_so = SharedObject.getLocal(_cookieName);
	 	 
	 	if(silexInstance.isSilexServer == true)
	 	{
		 	allPlayersLoadedDelegate = mx.utils.Delegate.create(this,allPlayersLoadedCallback);
		 	
		 	layerInstance.addEventListener("allPlayersLoaded",allPlayersLoadedDelegate);	 		
	 	}else
	 	{
	 		doInit();
	 	}
		
	 }
	 
	 /**
	 *function listene to event "allPlayersLoaded", in order to delay CookieComposant initialisation  
	 **/
	private function allPlayersLoadedCallback()
	{
		// workground text fields refresh after a while
		silexInstance.sequencer.doInNFrames(10,mx.utils.Delegate.create(this,doInit));
		// remove the event
		layerInstance.removeEventListener("allPlayersLoaded",allPlayersLoadedDelegate);
	}
	
	/**
	* CookieComposant initialisation
	**/
	private function doInit()
	{
		
		for (var i = 0; i < _dataNames.length; i++) {
			if(cookie_so.data[_dataNames[i]] == undefined)
			{
				 this[_dataNames[i]] = new Object();
				dispatch({type:CREATE_EVENT+_dataNames[i], target:this}); 
			}else
			{
				 loadExist(_dataNames[i]);
				 dispatch({type:EXIST_EVENT+_dataNames[i], target:this}); 
			}
		}
		dateExpired();
	}
	
	/**
	*onLoadExist for the first and the seconde time
	*update existed table  for example this["userdata"] at the composant
	**/	
	public function loadExist(val:String):Void
	{
		this[val] = cookie_so.data[val] ;			
		
	}
	
	/**
	*event to save the chagement, to dispatche un erreur
	*save table for example this["userdata"] in sharedObject
	**/
	public function save():Void
	{

	   var currentDate:Date=new Date();	
 
	   for(var i = 0; i<_dataNames.length; i++)
	   {
	   		//check checkbox state 			
			if(this[_dataNames[i]].state == "true" || this[_dataNames[i]].state == true)	
			{
	            cookie_so.data[_dataNames[i]] = this[_dataNames[i]] ;	            

			}else
			{
				deleteObject(_dataNames[i]);
			}

	   } 
	   
	   /**
	   *set the currentDate as the lastSavedDate attribute of cookie
	   **/
	   cookie_so.data.lastSavedDate = currentDate;	
	   
	   var result = cookie_so.flush(1000);   
		switch (result) {
			case true :
			case "pending":
			    dispatch({type:SAVE_EVENT_SUCCESS, target:this});
			    break;
			default :
			    dispatch({type:SAVE_EVENT_ERROR, target:this});
			    break;
			
		}
		
	}
	
	/**
	*function to check the expireDate
	**/
	public function dateExpired():Void
	{

		if(_validityPeriod != "")
		{
			if(cookie_so.data.lastSavedDate !=undefined)
			{
				var lastSavedDate:Date = new Date(cookie_so.data.lastSavedDate);
				var WillExpiredDate:Number = lastSavedDate.getTime()/1000+_validityPeriod;
				var currentDate:Date=new Date();
		 		var currentDateSeconde:Number = currentDate.getTime()/1000;
		 		if (currentDateSeconde>WillExpiredDate)
				{
					dispatch({type:DATEEXPIRED_EVENT, target:this});
				   	deleteData();
				 }else
				 {
				 }				
			}
		}
	}
	
	/**
	* delete a existed table in the sharedObject
	**/
	public function deleteObject(dataName:String):Void
	{   

		if( cookie_so.data[dataName] != undefined)
		{		
	     	cookie_so.data[dataName] = undefined;	 			
		}
    		
	}
	
	/**
	* deletData() to delete a existed Cookie
	**/
	public function deleteData():Void
	{
		dispatch({type:DELETEDATA_SUCCESS, target:this});
		cookie_so.clear();
	}
	
	/** function set dataNames
	* @param val(Array)
	* @returns void
	*/
	[Inspectable(name="data names", type=Array, defaultValue="")]
	public function set dataNames(val:Array){
		_dataNames = val;
	}
	
	/** function get dataNames
	* @returns Array
	*/	
	public function get dataNames():Array{
		return _dataNames;
	}
	
	/** function set cookieNames
	* @param val(String)
	* @returns void
	*/
	[Inspectable(name="cookie names", type=String, defaultValue="")]
	public function set cookieName(val:String){
		_cookieName = val;
	}
	
	/** function get cookieName
	* @returns String
	*/
	
	public function get cookieName():String{
		return _cookieName;
	}
	
	/** function set autosave
	* @param val(Boolean)
	* @returns void
	*/
	[Inspectable(name="auto save", type=Boolean, defaultValue=true)]
	public function set autoSave(val:Boolean){
		_autoSave = val;
	}
	
	/** function get autoSave
	* @returns Boolean
	*/	
	public function get autoSave():Boolean{
		return _autoSave;
	}	
	
	/** function set validityPeriod
	* @param val(Number)
	* @returns void
	*/
	[Inspectable(name="validityPeriod", type=Number, defaultValue="")]
	public function set validityPeriod(val:Number){
		_validityPeriod = val;
	}
	
	/** function get validityPeriod
	* @returns Number
	*/	
	public function get validityPeriod():Number{
		return _validityPeriod;
	}			
	 	



}