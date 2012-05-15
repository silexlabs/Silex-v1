/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.oof.DataIo;
import org.oof.OofBase;
import org.oof.DataUser;
import mx.utils.Delegate;
import org.oof.DataContainer;
import org.oof.dataConnectors.IContentConnector;
import org.silex.core.Utils;

// tags to use (see http://livedocs.adobe.com/flash/9.0/main/wwhelp/wwhimpl/common/html/wwhelp.htm?context=LiveDocs_Parts&file=00002497.html)
// [Inspectable(name="",defaultValue="",category="")]
// [Bindable]
// [ChangeEvent("change1", "change2", "change3")]
// 18x18 pixel icon: [IconFile("component_name.png")]

/*
  Class: org.oof.dataUsers.DataSelector
  The selector component is a visual interface used to select records in a databased using the connector component.
  
  - 1. At start, a first request is fired to retrieve the minimum needed data of a big number of records satisfying a certain condition.
  
  - 2. Then the io interacts with this data and may select one of the record.
  
  - 3. The complete data concerning the selected record is then retrieved and placed into the desired object.
  
  - 4. The process can be repeated from any of the preceding points and the parameters may change.
 
 To use this component you need a connector through which it can load data, and a list to show it to
 the user. You will also need some outputs(a text field, a display...) where selected data
 can be shown. These can be configured in connectorPath, listBoxPath, and outputFormats respectively 
  
  
  Author: 
  
  Alexandre Hoyau
 */

/////////////////////////////////////////
// events
// available for use in
// * ActionScript (event listeners or callbacks)
// * SILEX (commands)
/////////////////////////////////////////

[Event("onResult")]
[Event("onSingleResult")]
[Event("onError")]
[Event("onRollOver")]
[Event("onRollOut")]
[Event("onRelease")]
[Event("onClear")]

class org.oof.dataUsers.DataSelector extends DataUser{

	
	/////////////////////////////////////////
	// public callback functions
	// corresponding to the events
	/////////////////////////////////////////
/** Group: Events / Callbacks
 * */
/**
 * Event: onResult
 * called when the items that will be shown in the list have been loaded
 * */
	var onResult:Function;
/**
 * Event: onSingleResult
 * called when the item that the user has chosen has been loaded
 * */
	var onSingleResult:Function;
/**
 * Event: onError
 * called when there is an error
 * */
	var onError:Function;
/**
 * Event: onRollOver
 * called when the user has rolled over an item in the list.
 * */
	var onRollOver:Function;
/**
 * Event: onRollOut
 * called when the user has rolled out from an item in the list.
 * */
	var onRollOut:Function;
/**
 * Event: onRelease
 * called when the user has clicked an item in the list. 
 * This is called before loading, whereas onSingleResult is called after loading 
 * */
	var onRelease:Function;
/**
 * Event: onClear
 * called when the list is cleared. For example if the list is already loaded, and you call
 * getRecords, the list will be cleared before reloading
 * */
	var onClear:Function;
	
	
	/////////////////////////////////////////
	// parameters
	// public attributes
	// parameters in Flash IDE
	// available properties in SILEX (=> editable in properties tool box)
	/////////////////////////////////////////
/** Group: Inspectable Properties
 * */	
	/**
	 * listBoxPath
	 * Path to the list component used to display the selection of items that the user can choose from
	 */
	[Inspectable(name="list",defaultValue="",category="none")]
	var listBoxPath:String;
	
	/** 
	 * whereClause
	 * This variable contains the whole where clause of the mySQL query. It indicates the conditions that rows must satisfy to be selected.
	 * Used in the first request, before the io has chosen an item.
	 */
	[Inspectable(name="condition",defaultValue="1",category="parameters")]
	 var whereClause:String;
	
	 /** 
	 * selectedFieldNames
	 * Array of strings used in the SQL select clause. Indicates the columns that you want to retrieve.
	 * Used in the first request, before the io has chosen an item.
	 */
	[Inspectable(name="fields",category="parameters",defaultValue="*")]
	var selectedFieldNames:Array

	/** 
	 * orderBy
	 * Array of strings used in the mySQL order by clause.
	 * Used in the first request, before the io has chosen an item.
	 */
	[Inspectable(name="order by",defaultValue="label",category="parameters")]
	var orderBy:Array;
	
	/** 
	 * limit
	 * Limit clause of the first mySQL query. Specifies the maximum number of rows to return.
	 * Used in the first request, before the io has chosen an item.
	 */
	[Inspectable(name="number of results",defaultValue=50,category="parameters")]
	var limit:Number;
	
	/** 
	 * offset
	 * Offset of the limit clause of the first mySQL query. Specifies the offset of the first row to return.
	 * Used in the first request, before the io has chosen an item.
	 */
	[Inspectable(name="offset",defaultValue=0,category="parameters")]
	var offset:Number;

	/** 
	 * cellFormat
	 * description
	 * This is an html representation of a cell. Each cell use this string as a content after replacing accessors by their values.
	 */
	[Inspectable(name="cell format",defaultValue="",category="parameters")]
	var cellFormat:String;

	/** 
	 * deeplinkFormat
	 * The representation of the deeplink name of a cell. Each cell use this string as a deeplink name after replacing accessors by their values.
	 */
	[Inspectable(name="deeplink format",defaultValue="",category="parameters")]
	var deeplinkFormat:String;

	/** 
	 * iconFieldName
	 * This is the name of the field where the selector will find the url of the images to show in the list. For example in a RSS feed, this would be link
	 */
	[Inspectable(name="icon field",defaultValue="",category="parameters")]
	var iconFieldName:String;
	
	/** 
	 * idField
	 * name of the field containing the records id in the 1st request
	 * it is the only data passed in in the 2d request
	 */
	[Inspectable(name="id field",defaultValue="id",category="parameters")]
	var idField:String;
	

	/** 
	 * resultArray
	 * object used to store the Array resulting from the first query
	 */
	[Bindable]
	[ChangeEvent("onResult")]
	var resultArray:Array = null;//not used at the moment
	/////////////////////////////////////////
	// private attributes
	/////////////////////////////////////////

/** Group: Private Attributes(internal)
 * */	
	/** _connector
	 * description
	 * data connector used by this selector
	 * 
	 */
	private var _connector:IContentConnector = null;
	/** _list
	 * list component used to display the first querry result
	 */
	private var _list:Object = null;
	private var _idRecord:Number = undefined; 
	private var _formName:String = null;
	private var _outputFormats:Array = null;
//	private var _outputFormatsResolved:Array = null;
	private var _listFilterCallback:Function = null;//must return true to show, false to hide
	private var _getRecordsOnLoad:Boolean = true;
	private var _getIndividualRecordsOnClick:Boolean = false;

	var _listResult:Array = null; //stores the Array for the list
	private var _selectedIndexWhenNoList:Number = undefined;
	private var _listDp:Array = null;
	// true if waiting for a response after a getResult or a getSingleResult request
	private var _operationPending:Boolean=false;
	/**
	 * lastOpenIconOnDeeplinkEvent_obj
	 * last event not catched yet because the list was not found yet
	 */
	var lastOpenIconOnDeeplinkEvent_obj:Object;
	
	//we need a separate result container for rollover. Not optimal, but necessary for now
	private var _rollOverResultContainerPath:String = null;
	private var _rollOverResultContainer:Object;
		
	/** Group: Internal Callbacks. (internal)
	 *  The DataSelector class is a listener of List class and therefore has these callbacks.
	 * 	 They all start by placing the cell data in the <<resultContainer>> object.
	 * */
	 
	/** 
	 * function: change
	 * listener for the list component
	 * Start the second request by a call to _connector.getIndividualRecordss
	 * dispatch the event onRelease
	 */
	function change(eventObject:Object){
		var individualRecordIds:Array = copySelectedItemsToResultContainer();
		if (_getIndividualRecordsOnClick == true)
		{
			getIndividualRecords(individualRecordIds);
		}
		else
		{
			// execute actions of the _outputFormats array
			executeOutputFormats();
		}
		
		// events
		dispatch({type:"onRelease",target:this})
		// call onRelease callback
		if (onRelease) onRelease();
		
	}
	/** 
	 * function: onErrorCallback
	*@returns void
	* call parent error function
	*/
	function onErrorCallback(errorMessage:String){
		// set the flag meaning that we are waiting for a response
		_operationPending=false;
		
		// select first item if the selector is set as the default icon 
		if (iconIsDefault==true && selectedIndex == undefined)
			selectedIndex = 0;
		
		// a deep link object is pending (openIconOnDeeplink was called dring operation)
		if (lastOpenIconOnDeeplinkEvent_obj)
			openIconOnDeeplink(lastOpenIconOnDeeplinkEvent_obj);
		
		// call parent error function
		super.onErrorCallback(errorMessage);
	}
	
	/** 
	 * function: itemRollOut
	 * use evt_obj.index 
	 * listener for the list component
	 * dispatch the event onRollOut
	 */
	function itemRollOut(eventObject:Object){
		// dispatch the event end executes commands (for SILEX)
		dispatch({type:"onRollOut",target:this})
		// call onRollOut callback
		if (onRollOut) onRollOut();
	}
	/** 
	 * function: itemRollOver
	 * listener for the list component
	 * use evt_obj.index 
	 * dispatch the event onRollOver 
	 */
	function itemRollOver(eventObject:Object) {
		// copy item to the result container
		var item = _list.dataProvider[eventObject.index];
		var selectedItem_obj:Object;
		if (item.data && typeof(item.data)=="object"){
			// using AS to add data (data exists and is an array (or object))
			selectedItem_obj=item.data;
		}else{
			// using property inspector to add data
			selectedItem_obj=item;
		}

		// copy the item data in resultContainer (for SILEX) or _resultContainer (for AS)
		for(var idx:String in selectedItem_obj){
			_rollOverResultContainer[idx]=selectedItem_obj[idx];
		}
		
		// dispatch the event end execute commands (for SILEX)
		dispatch({type:"onRollOver",target:this});
		// call onRollOver callback
		if (onRollOver) onRollOver();
	}

	
	/** 
	 * function: onResultCallback 
	*@returns void
	* Called by the connector in return of a request. Passed as the callbackFunction parameter in a call to connector.getRecords
	* Display the records in the list component
	* Dispatch the onResult event
	*/
	function onResultCallback(re:Array){
		_listResult = re;		
		refreshList();
		
		// dispatch the onResult event
		
		dispatch({type:"onResult",target:this});

		// call onResult callback
		if (onResult) onResult();
		
		// set the flag meaning that we are waiting for a response
		_operationPending=false;

		// select first item if the selector is set as the default icon 
		if (iconIsDefault==true && selectedIndex == undefined)
			selectedIndex = 0;
		
		// a deep link object is pending (openIconOnDeeplink was called dring operation)
		if (lastOpenIconOnDeeplinkEvent_obj)
			openIconOnDeeplink(lastOpenIconOnDeeplinkEvent_obj);

	}
	
	/** 
	 * function: onSingleResultCallback
	 * Called by the connector in return of a request. Passed as the callbackFunction parameter in a call to connector.getIndividualRecords
	 * Dispatch the onSingleResult event
	 *@params re	the Object
	 */
	function onSingleResultCallback(re:Object){
// in some cases this goes into infinite loop with rss. so commented. 

		
		_idRecord = re[idField];
		// copy the result in resultContainer 
		//if multiple selection allowed, copy it as is. If no, copy first element, for simpler access
		if(!_list.multipleSelection){
			for(var idx:String in re[0]){
				_resultContainer[idx] = re[0][idx];
			}
		}else{
			for(var idx:String in re){
				_resultContainer[idx]=re[idx];
			}
		}
		// dispatch the onSingleResult event
		dispatch({type:"onSingleResult",target:this});
		
		// execute actions of the _outputFormats array
		executeOutputFormats();
		
		// call onSingleResult callback
		if (onSingleResult) 
			onSingleResult();
			
		// set the flag meaning that we are waiting for a response
		_operationPending=false;
		
		
		// a deep link object is pending (openIconOnDeeplink was called dring operation)
		if (lastOpenIconOnDeeplinkEvent_obj)
			openIconOnDeeplink(lastOpenIconOnDeeplinkEvent_obj);

	}
	/**
	 * execute actions of the _outputFormats array
	 */
	function executeOutputFormats()
	{
		var len = _outputFormats.length;
		for(var i = 0; i < len; i++){
			try{
				// for each output format string
				var outputFormat = _outputFormats[i];
				// resolve the accessors in the output format string
				outputFormat = silexPtr.utils.revealAccessors(outputFormat, _resultContainer, "/");
				// execute the command
				silexPtr.interpreter.exec(outputFormat, this._parent);
				
			} catch (myError:Error) { 
			}
		}
		
	}
	
	/** Group: class methods (internal)
	 * */
	
	function DataSelector(){
		super();
		typeArray.push("org.oof.dataUsers.DataSelector");
	}
		
	//an outputformat string should look like this [objName].[varName]=valString
	//example : addressIo.value=<<address>> -> outputPath = address. varName = value. valString = <<address>>

	/** 
	 * function: _initAfterRegister
	* @returns void
	*/
	public function _initAfterRegister(){
		super._initAfterRegister();
		_rollOverResultContainer = new Object(); ///used if _rollOver resultContainer not set, or  rollOver container not found
		var splitted = _rollOverResultContainerPath.split(".");
		tryToLinkWith(splitted[0], Delegate.create(this, doOnRollOverResultContainerFound));		
		if (listBoxPath!="") tryToLinkWith(listBoxPath, Delegate.create(this, doOnListFound));
		
	}	
	
	 /** function doOnRollOverResultContainerFound
	*@returns void
	*/
	function doOnRollOverResultContainerFound(oofComp:OofBase){
		var objName = _rollOverResultContainerPath.split(".")[1];
		if(objName != null){
			var container = DataContainer(oofComp);
			_rollOverResultContainer = container.getContainer(objName);
		}
	}
		
	
	/** 
	 * function: copySelectedItemsToResultContainer
	* copies selectedItem(s) data to resultContainer
	* returns an array with their id fields, eventually to be used for 
	* further requests
	*/
	function copySelectedItemsToResultContainer():Array{
		// empty _resultContainer
		for(var propName:String in _resultContainer){
			_resultContainer[propName] = undefined;
		}
	
		var individualRecordIds:Array = new Array();
		if(!_list.multipleSelection){
			var item = _list.selectedItem;
	
			var selectedItem_obj:Object;
			if (item.data && typeof(item.data)=="object"){
				// using AS to add data (data exists and is an array (or object))
				selectedItem_obj=item.data;
			}else{
				// using property inspector to add data
				selectedItem_obj=item;
			}
			
			// copy the item data in resultContainer (for SILEX) or _resultContainer (for AS)
			for(var idx:String in selectedItem_obj){
				_resultContainer[idx]=selectedItem_obj[idx];
			}
			individualRecordIds.push(item.data[idField]);
		}else{
			var items = _list.selectedItems;
			var len = items.length;
			for(var i = 0; i < len; i++){
				var item = items[i];
				
				var selectedItem_obj:Object;
				if (items[i].data && typeof(item.data)=="object")
					// using AS to add data (data exists and is an array (or object))
					selectedItem_obj=item.data;
				else
					// using property inspector to add data
					selectedItem_obj=item;
		
				// copy the item data in resultContainer (for SILEX) or _resultContainer (for AS)
				_resultContainer[i] = new Object();
				for(var idx:String in selectedItem_obj){
					_resultContainer[i][idx]=selectedItem_obj[idx];
				}
				individualRecordIds.push(item.data[idField]);
			}
		}
		return individualRecordIds;
		
	}

	/**
	 * workaround bug "doOnConnectorFound called twice"
	 */
	var hasFoundConnector:Boolean = false;
	/** 
	 * function: doOnConnectorFound
	 *@returns void
	 */
	function doOnConnectorFound(oofComp:OofBase) {
		if (!hasFoundConnector) {
			hasFoundConnector = true;
			//super.doOnConnectorFound(oofComp); //this makes a really weird bug if left in. somehow the code
			//in this function is executed twice and getRecords is called twice.
			_connector = IContentConnector(oofComp);
			if(_getRecordsOnLoad){
				getRecords();
			}
		}
	}
	
	private var listFoundFlag:Boolean = false;
	 /** 
	 * function: doOnListFound
	*@returns void
	*/
	function doOnListFound(oofComp:OofBase){
		if (listFoundFlag) return;
		listFoundFlag = true;
		
		_list = oofComp;
		
		if(_listDp != null){
			_list.dataProvider = _listDp;
		}
		if(idRecord != undefined){
			_list.selectedIndex = idRecord;
		}
		
		_list.addEventListener("change", Utils.createDelegate(this, change));
		_list.addEventListener("itemRollOut", Utils.createDelegate(this, itemRollOut));
		_list.addEventListener("itemRollOver", Utils.createDelegate(this, itemRollOver));

		
		// a deep link object is pending (openIconOnDeeplink was called before the list was found
		if (lastOpenIconOnDeeplinkEvent_obj)
			openIconOnDeeplink(lastOpenIconOnDeeplinkEvent_obj);
	}
	function onUnload()
	{
		super.onUnload();
		_list.removeEventListener("change", Utils.removeDelegate(this, change));
		_list.removeEventListener("itemRollOut", Utils.removeDelegate(this, itemRollOut));
		_list.removeEventListener("itemRollOver", Utils.removeDelegate(this, itemRollOver));
	}

	/** 
	 * function: refreshList
	*@returns void
	* Called by the selector when receiving a result(not single), or by a filterUi to rerender the list with a new filter function
	*/
	function refreshList(){
		// ** ** **
		// Display the records in the list component
		
		var len = _listResult.length;
		_listDp = new Array();
		for(var i = 0; i < len; i++){
			var itemForProvider =  new Object();
			var itemFromDb = _listResult[i];
			if((_listFilterCallback == null) || (_listFilterCallback(itemFromDb) == true)){
				itemForProvider["label"] = silexPtr.utils.revealAccessors(cellFormat,itemFromDb, "/");//getObjAtPath(itemFromRecordSet, labelString);//
				itemForProvider["data"] = itemFromDb;
				itemForProvider["icon"] = getObjAtPath(itemFromDb, silexPtr.utils.revealAccessors(iconFieldName,itemFromDb, "."));
				// if icon is undefined but not the label, let'use the label as a URL
				if (itemForProvider["icon"]==undefined || itemForProvider["icon"]=="")
					itemForProvider["icon"]=itemForProvider["label"];
				// add the item  to the dataProvider
				_listDp.push(itemForProvider);
			}
		}
		
		if(_list != null){
			_list.dataProvider = _listDp;
		}
	}
	
	/** Group: public functions
	 * */
	 	
	/** 
	 * property: selectedItem
	 * returns the item selected by the user
	 * */
	function get selectedItem(){
		return _resultContainer;
	}
	
	/**
	 * property: selectedIndex
	 * the index of the item in the list. 
	 * between 0 and listlength - 1.
	 * */
	function get selectedIndex():Number{
		if(_list){
			return _list.selectedIndex;
		}else{
			return _selectedIndexWhenNoList;
		}
		
	}
	
	function set selectedIndex(val:Number){
		
		if (typeof(val) != "number")
			val = parseInt(val.toString());
		
		if(_list){
			_list.selectedIndex = val;
		}else{
			//no list, so do without
			_selectedIndexWhenNoList = val;

			if (_getIndividualRecordsOnClick == true)
			{
				var ids:Array = new Array();
				ids.push(_listResult[val][idField]);
				getIndividualRecords(ids);
			}
			else
			{
				// execute actions of the _outputFormats array
				executeOutputFormats();
			}
		}
	}
	
	/** 
	 * function: chooseItem
	 * a method to help find an item without its index.
	 *  
	 * parameters: 
	 * 
	 * key - the attribute in the item that will be looked for
	 * val - the value that the attribute must have to match.
	 * 
	 * so if item[key] == val, the item matches and will be selected in the list   
	 * 
	* @returns void
	*/
	function chooseItem(key:String, val:Object){
		var len = _listResult.length;
		for(var i = 0; i < len; i++){
			if(_listResult[i][key] == val){
				selectedIndex = i;
				break;
			}
		}
	}

	/** 
	 * function: doClear 
	* not called clear because reserved by flash. clears the list.
	* */
	function doClear(){
		_list.removeAll();
		dispatch({type:"onClear"});
		
		if(onClear) onClear();
	}
	
	/** 
	 * function: getIndividualRecords.
	 * called when the user clicks an item
	 *
	 */
	
	function getIndividualRecords(ids:Array){
		if (hasFoundConnector){
			var rcb = Delegate.create(this, onSingleResultCallback);
			var ecb = Delegate.create(this, onErrorCallback);
	
			// set the flag meaning that we are waiting for a response
			_operationPending=true;
	
			// reveal accessors in formName, useful for rss connector with params in formName (GET)
			var finalformName:String=silexPtr.utils.revealAccessors (_formName,this);
			//var where = idField + " IN (" + ids.join(", ") + ")";		
	//		_connector.getRecords(rcb, ecb, finalformName, ["*"], where ,orderBy.join(","),0 ,0);
			_connector.getIndividualRecords(rcb, ecb, finalformName, ids);
		}
	}
	/** 
	 * function: getRecords.
	 * called at load if getRecordsOnLoad set. Call this yourself if needed. 
	 * calls doClear before getting records.
 	 * */
	
	function getRecords(){
		
		if (hasFoundConnector){
			doClear();
			var condition:String = whereClause;
	
			
			condition = silexPtr.utils.revealAccessors (condition,this);
			condition = silexPtr.utils.revealWikiSyntax(condition);
			var rcb = Delegate.create(this, onResultCallback);
			var ecb = Delegate.create(this, onErrorCallback);
	
			// reveal accessors in formName, useful for rss connector with params in formName (GET)
			var finalformName:String=silexPtr.utils.revealAccessors (_formName,this);
	
			_connector.getRecords(rcb, ecb, finalformName, selectedFieldNames,condition,orderBy.join(","),limit,offset);
			
			// set the flag meaning that we are waiting for a response
			_operationPending=true;
		}
	}
		
	/** Group: More Inspectable properties
	 * */
	 
	/** 
	 * property: outputFormats
	 * 
	 * commands to execute  when the user selects an item.
	 * example:
	 * if you have 2 fields in your data name and address, and 2 textfields nameIo and addressIo
	 * you want to show them in:
	 * (start code)
	 * nameIo.value=<<name>>
	 * addressIo.value=<<address>>
	 * (end)
	 * */
	[Inspectable(name = "outputFormats", type = Array)]
	public function set outputFormats(val:Array){
		_outputFormats = val;
	}

	public function get outputFormats():Array{
		return _outputFormats;
	}	
	
	/** property: formName
	 * if you are connecting to an rss feed, this is added to the connector's base url
	 * parameter to create the address from which to load the feed.
	 * if you are connecting to a database, this is the name of the table.
	 * */
	
	[Inspectable(name="data feed", type=String, defaultValue="")]
	public function set formName(val:String){
		_formName = val;
	}

	public function get formName():String{
		return _formName;
	}
	
	/**
	 * property: listFilterCallback
	 * experimental, you should probably leave this empty
	 * */	
	public function set listFilterCallback(val:Function){
		_listFilterCallback = val;
	}
	
	public function get listFilterCallback():Function{
		return _listFilterCallback;
	}	
	
	/** 
	 * property: getRecordsOnLoad
	 * when the DataSelector loads, it will load data into the list if this is set to true.
	 * */
	[Inspectable(name = "get records on load", type = Boolean, defaultValue = true)]
	public function set getRecordsOnLoad(val:Boolean){
		_getRecordsOnLoad = val;
	}
	
	
	public function get getRecordsOnLoad():Boolean{
		return _getRecordsOnLoad;
	}	

	/** 
	 * property: getIndividualRecordsOnClick
	 * when the user clicks an item in the list, it will load data for this item
	 * if this is set to true.
	 * */
	[Inspectable(name = "get single record on click", type = Boolean, defaultValue = false)]
	public function set getIndividualRecordsOnClick(val:Boolean){
		_getIndividualRecordsOnClick = val;
	}
	

	public function get getIndividualRecordsOnClick():Boolean{
		return _getIndividualRecordsOnClick;
	}	
	
	
	/** 
	 * property: rollOverResultContainerPath
	 * the path to a data container.
	 * if this is left empty, the data user will store data 
	 * internally. otherwise it will store data here
	 *  
	 * */	 
	[Inspectable(type=String,defaultValue="",category="parameters")]
	function set rollOverResultContainerPath(val:String){
		_rollOverResultContainerPath = val;
	}	
	
	function get rollOverResultContainerPath():String{
		return _rollOverResultContainerPath;
	}	
	/** 
	 * property: list
	 * gets the list found at listBoxPath
	 * */
	
	public function get list():Object{
		return _list;
	}	
	
	/** 
	 * property: idRecord
	 * gets the id of the item chosen by the user.
	 * */
	
	public function get idRecord():Number{
		return _idRecord;
	}

	/** Group: functions for SILEX (internal)
	 * */
	 	
	/**
	 * function: openIconOnDeeplink
	 * check if the deeplink corresponds to this icon
	 * - core.Layout::onDeeplink event
	 */ 
	function openIconOnDeeplink(ev) {
		//trace('openIconOnDeeplink called');
		if (_list && _operationPending==false && onLoadEventOccurred){

			lastOpenIconOnDeeplinkEvent_obj=undefined;

			// look for the deep link in the list
			for (var itemIdx:Number=0;itemIdx<_list.length;itemIdx++){
				//if (!selectedItem_obj) selectedItem_obj=_list.selectedItem;
				var selectedItem_obj:Object;
				if (_list.getItemAt(itemIdx).data && typeof(_list.getItemAt(itemIdx).data)=="object")
					// using AS to add data (data exists and is an array (or object))
					selectedItem_obj=_list.getItemAt(itemIdx).data;
				else
					// using property inspector to add data
					selectedItem_obj=_list.getItemAt(itemIdx);

				var deeplink_str = getDeeplink(selectedItem_obj);
				trace('openIconOnDeeplink called - deeplink = ' + deeplink_str);
				
				// if deeplink_str is empty, set it to undefined (so org.silex.core.Layout can use page name instead)
				if (deeplink_str == '')
				{
					deeplink_str = undefined;
				}
			
				// does the deeplink corresponds to this icon?
				if (deeplink_str && ev.cleanSectionName.toLowerCase() == silexPtr.utils.cleanID(deeplink_str).toLowerCase())
				{
					// stores the item
					//lastOpenIconOnDeeplinkItem_obj=selectedItem_obj;

					//dispatch
					this.dispatch({type: silexPtr.config.UI_PLAYERS_EVENT_DEEPLINK, target:this });

					// do open
					//openIcon();
					
					// select item in the list
					// it will dispatch the change event which will result in a call to this.openIcon();
					_list.selectedIndex=itemIdx;
					
					// stop looking for the deeplink
					break;
				}
			}

		}
		else{
			lastOpenIconOnDeeplinkEvent_obj=ev;
		}
	}
	/**
	 * function: doOpenIcon
	 * open the page associated with this icon
	 * - media::onRelease event
	 * - core.Layout::onDeeplink event
	 */ 
	function doOpenIcon(){
		
		trace('doOpenIcon');
		// wait for the data if we have qsked for it
		if (_operationPending==true)
			return;
		
		// here, we need "if (_list || listBoxPath=="") " because the default icon can be opened before the list was found
		if (_list || listBoxPath=="")
		{
			if (_list.selectedIndex==undefined || _list.selectedIndex<0) _list.selectedIndex=0;
			//if (!selectedItem_obj) selectedItem_obj=_list.selectedItem;
			var selectedItem_obj:Object;
			if (_list.selectedItem.data && typeof(_list.selectedItem.data)=="object")
				// using AS to add data (data exists and is an array (or object))
				selectedItem_obj=_list.selectedItem.data;
			else
				// using property inspector to add data
				selectedItem_obj=_list.selectedItem;
	
			var deeplink_str = getDeeplink(selectedItem_obj);
			
			// if deeplink_str is empty, use resolved iconPageName instead 
			if (deeplink_str == '')
			{
				deeplink_str = silexPtr.utils.revealAccessors(iconPageName, selectedItem_obj);
			}
			
			// open the page with the cell deep link
			if (iconPageName && iconLayoutName && layoutInstance)
				silexPtr.application.openSection(silexPtr.utils.revealAccessors(iconPageName,selectedItem_obj),silexPtr.utils.revealAccessors(iconLayoutName,selectedItem_obj),layoutInstance,deeplink_str);
			
			// unselect selected icon of the layout
			if(layoutInstance.selectedIcon)
				layoutInstance.selectedIcon.selectIcon(false);
	
			// store selected icon in layout
			layoutInstance.selectedIcon=this;
			
			// call selectIcon for derived classes
			selectIcon(true);
		}
	}
	
	/**
	 * gets the deeplink and store it in selectedItem_obj._oofListDeeplink 
	 * 
	 * @return the deeplink
	 */
	function getDeeplink(selectedItem_obj):String
	{
		// compute the name of the deeplink corresponding to the cell (and store it in _oofListDeeplink in order to compute it only once)
		
		// if _oofListDeeplink exists, return it
		if (selectedItem_obj._oofListDeeplink)
		{
			return selectedItem_obj._oofListDeeplink;
		}
		// if not, resolve deeplinkFormat
		else
		{
			var revealedDeeplink:String = silexPtr.utils.revealAccessors(deeplinkFormat, selectedItem_obj);
			return revealedDeeplink;
		}
	}

	/** 
	 * function: getSeoData
	 * return the seo data to be associated with this player
	 * to be overriden in derived class :
	 * @return	object with text (string), tags (array), description (string), links (object with link, title and description), htmlEquivalent (string), context (array)
	 */
	function getSeoData(url_str:String):Object {
		// do not use parent's method : var res_obj:Object=super.getSeoData(url_str);
		// but creates an empty result object instead:
		var res_obj:Object=new Object;

		// keywords
		//res_obj.text="test";
		
		// name
		res_obj.playerName = playerName;
		
		// class Name
		_className = typeArray[typeArray.length - 1];
		res_obj.className = _className;
		
		// tags
		if (tags)
			res_obj.tags=tags;
		
		// description
		if (descriptionText)
			res_obj.description=descriptionText;
		
		// html equivalent
		// res_obj.htmlEquivalent=descriptionText;
		
		// context
		res_obj.context = getUiContext();

		// links
		if (iconIsIcon){
			// gets components seo properties
			//res_obj.className = _className;
			//res_obj.playerName = playerName;
			res_obj.iconIsIcon = 'true';
			res_obj.iconPageName = iconPageName;
			res_obj.iconDeeplinkName = iconDeeplinkName;
			res_obj.deeplinkFormat = deeplinkFormat;
			//res_obj.connectorPath = connectorPath;
			res_obj.connectorName = connectorPath;
			res_obj.formName = formName;
			res_obj.cellFormat = cellFormat;
			
			// Database connector specific => to be moved there
			// script class name 
			/*if (_connector && _connector["_formServiceName"]){
				res_obj.className=_connector["_formServiceName"];
				
				// getRecords parameters
				res_obj.componentParams=new Object;
				res_obj.componentParams.formName=formName;
				res_obj.componentParams.selectedFieldNames=selectedFieldNames;
				res_obj.componentParams.whereClause=whereClause;
				res_obj.componentParams.orderBy=orderBy.join(",");
				res_obj.componentParams.limit=limit;
				res_obj.componentParams.offset=offset;
				res_obj.componentParams.idField=idField;
				res_obj.componentParams.dataContainer=_resultContainerPath;
				res_obj.componentParams.template=silexPtr.utils.cleanID(iconPageName);
				res_obj.componentParams.deeplinkFormat = deeplinkFormat;
				
			}
			else{*/
				if (_list && _list.length>0){
					res_obj.links=new Array;
					for (var idx:Number=0;idx<_list.length;idx++){
						// compute the name of the deeplink corresponding to the cell (and store it in _oofListDeeplink in order to compute it only once)
						var deeplink_str:String=undefined;
						var selectedItem_obj:Object=_list.getItemAt(idx);
						
						// handles the case of a dataprovider with data and label objects
						if (selectedItem_obj.data) selectedItem_obj = selectedItem_obj.data;
						
						if (selectedItem_obj._oofListDeeplink) deeplink_str=selectedItem_obj._oofListDeeplink;
						else deeplink_str=selectedItem_obj._oofListDeeplink=silexPtr.utils.revealAccessors(deeplinkFormat,selectedItem_obj);
						
						if (deeplink_str && deeplink_str!=""){
							// link elements
							var desc:String=_list.getItemAt(idx).description;
							if (desc==undefined) desc=descriptionText;
							
							var link_str:String=silexPtr.utils.revealAccessors(iconPageName,selectedItem_obj);
							if (!link_str || link_str==""){
								link_str=deeplink_str;
							}
							
							// build the result object's deep links
							res_obj.links.push( { link:silexPtr.utils.cleanID(link_str),
								deeplink:silexPtr.utils.cleanID(deeplink_str),
								title:_list.getItemAt(idx).label,
								description:desc});
						}
					}
				}
			//}
		}
		else
		{
			res_obj.iconIsIcon = 'false';
		}


		return res_obj;
	}
	
}
