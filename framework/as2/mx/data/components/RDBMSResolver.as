/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/
//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************


import mx.data.binding.ComponentMixins;
import mx.data.binding.DataType;
import mx.data.binding.FieldAccessor;
import mx.data.binding.TypedValue;
import mx.data.components.datasetclasses.Delta;
import mx.data.components.datasetclasses.DeltaImpl;
import mx.data.components.datasetclasses.DeltaItem;
import mx.data.components.datasetclasses.DeltaPacket;
import mx.data.components.datasetclasses.DeltaPacketConsts;
import mx.data.components.datasetclasses.DeltaPacketImpl;
import mx.data.components.resclasses.FieldInfoItem;
import mx.events.EventDispatcher;
import mx.utils.Collection;
import mx.utils.Iterator;


/**
  The Firefly resolver components provide developers with an easy and flexible method 
  of saving data back to any supported data source, including XML, Remoting recordsets, 
  and SQL Server. The resolver components offer a significant advantage over similar 
  technologies by creating a level of abstraction between the developer and the data 
  source. Using this architecture, you can easily add new functionality to your existing
  applications by simply swapping one resolver for another without having to rewrite any
  ActionScript code. The resolver is bound to a dataset's DeltaPacket property, and each 
  different type of resolver translates it from the generic DeltaPacket format into a 
  specific format (DiffGrams, UpdateGrams, XUpdate, etc.)
*/

//---------------------------------------------------------------------------------------
//                                        Events
//---------------------------------------------------------------------------------------
/**
	This event is fired before the updates are applied to the server.  This is a good place to put
	code that will add custom XML data to the update packet to be interpreted by the server.
	
	@event	beforeApplyUpdates
	@helpid 1451
	@tiptext Fired immediately before the updatePacket is sent to the server
	@example
		on (beforeApplyUpdates) {
			 // add user authentication data
			 var userInfo = new XML( "<user_auth><user_id>"+getUserId()+ "</user_id><password>"+getPassword()+"</password></user_auth>" );
			 event.updatePacket.firstChild.appendChild( userInfo );
		 }
*/
[Event("beforeApplyUpdates")]


/**
	The reconcileResults & reconcileUpdates events are fired when results have been received from the server after 
	applying the updates from a deltaPacket. A single updateResults packet can contain both results of operations that were
	in the deltaPacket, and information about updates that were performed by other clients. When a new updatePacket is received,
	the operation results and database updates are split out into 2 separate deltaPackets which are placed into the deltaPacket 
	property separately.
	
	The reconcileResults event is fired just before the deltaPacket containing the operation results are sent via databinding.
	
	@event	reconcileResults
	@helpid 1452
	@tiptext Fired immediately before operation results are sent to the dataset
	@example
		 on (reconcileResults) {
			 // examine results
			 if( examine( updateResults ))
			   myDataset.purgeUpdates();
			 else
				displayErrors( results );
		 }
*/
[Event("reconcileResults")]
	

/**
	The reconcileResults & reconcileUpdates events are fired when results have been received from the server after 
	applying the updates from a deltaPacket. A single updateResults packet can contain both results of operations that were
	in the deltaPacket, and information about updates that were performed by other clients. When a new updatePacket is received,
	the operation results and database updates are split out into 2 separate deltaPackets which are placed into the deltaPacket 
	property separately.
	
	The reconcileUpdates event is fired just before the deltaPacket containing any database updates is sent via databinding
	
	@event	reconcileUpdates
	@helpid 1453
	@tiptext Fired immediately before database updates are sent to the dataset
	@example
		 on (reconcileUpdates) {
			 // examine results
			 if( examine( updateResults ))
			   myDataset.purgeUpdates();
			 else
				displayErrors( results );
		 }
*/
[Event("reconcileUpdates")]


/**
  The RDBMSResolver is a resolver implementation that translates the DeltaPacket
  into an XML document that can be easily translated into SQL statements.
  
	@class RDBMSResolver
	@tiptext Converts deltapackets to DB formatted XML
	@helpid 1454
	@author Jason Williams & Mark Rausch
*/
[RequiresDataBinding(true)]
[IconFile("RDBMSResolver.png")]
class mx.data.components.RDBMSResolver extends MovieClip {
	//---------------------------------------------------------------------------------------
	//                                   Static Constants
	//---------------------------------------------------------------------------------------
	public static var umUsingKey:String = "umUsingKey";
	public static var umUsingModified:String = "umUsingModified";
	public static var umUsingAll:String = "umUsingAll";
	
	
	//---------------------------------------------------------------------------------------
	//                                Component Parameters
	//---------------------------------------------------------------------------------------
	/**
		The tableName property stores the table name that is placed into the updatePacket so that
		the server can tell which table should be updated.
	  
		@property tableName
		@tiptext DB table name put in the XML updatePacket
		@helpid 1455
		@author Mark Rausch
	*/
	[Inspectable (defaultValue="")]
	public function get tableName():String { return __tableName; }
	public function set tableName(newValue:String):Void { __tableName = newValue; }
	
	/**
		The updateMode property helps to determine which fields in the updatePacket are marked as key fields. Setting this mode allows the programmer
		to determine how to handle conflicts when updating records that have also been modified by other users.
	  
		@property updateMode
		@tiptext Determines which fields are set as key fields in the updatePacket
		@helpid 1456
		@author Mark Rausch
	*/
	[Inspectable (enumeration="umUsingKey,umUsingModified,umUsingAll", defaultValue="umUsingKey")]
	public function get updateMode():String { return __updateMode; }
	public function set updateMode(newValue:String):Void { __updateMode = newValue; }

	/**
		The nullValue property lets the user set a string which will be put into the updatePacket to signify when a field's value is null.
	  
		@property nullValue
		@tiptext String used to indicate a null value for a field
		@helpid 1457
		@author Mark Rausch
	*/
	[Inspectable (defaultValue="{_NULL_}")]
	public function get nullValue():String { return __nullValue; }
	public function set nullValue(newValue:String):Void { __nullValue = newValue; }
	
	/**
		A collection property that allows the programmer to specify which fields are key fields and which fields should not be included 
		in the update packet.
	  
		@property fieldInfo
		@tiptext Specifies key fields and non-updatable fields
		@helpid 1458
		@author Mark Rausch
	*/
	[Collection(name="fieldInfo", variable="__fieldInfo", collectionClass="mx.utils.CollectionImpl", collectionItem="mx.data.components.resclasses.FieldInfoItem", identifier="fieldName")]
	//var fieldInfo:mx.utils.Collection;
	public function get fieldInfo():Collection { return __fieldInfo; }


	//---------------------------------------------------------------------------------------
	//                                Bindable Properties
	//---------------------------------------------------------------------------------------
	/**
		Property that receives a deltaPacket it can be translated into an updatePacket, and gets the deltaPacket from the updateResults
		so it can be sent back to the dataset.
	  
		@property deltaPacket
		@tiptext Object that describes a set of changes to a dataset
		@helpid 1459
		@author Mark Rausch
	*/
	[Bindable(type="DeltaPacket")]
	[ChangeEvent("deltaPacketChanged")]
	public function get deltaPacket():DeltaPacket { 
		return __deltaPacket; 
	}
	public function set deltaPacket( dp:DeltaPacket ):Void { 
		//Create the pseudo-dataset object for doing translations
		_fieldValueObj = new Object();
		_fieldValueObj.__schema = getLocalSchema( dp.getConfigInfo().elements[0].type );
		mx.data.binding.ComponentMixins.initComponent( _fieldValueObj );	
		
		__deltaPacket = dp; 
		if ((dp != null) && (dp!= undefined)) {
			__unresolvedDeltas[dp.getTransactionId()] = dp;
			createUpdatePacketFromDelta(); 
		}
	}

	/**
		Property that is set with an updatePacket created by this component so that it can be transmitted out to a server.
	  
		@property updatePacket
		@tiptext XML translation of the DeltaPacket that can be sent to a server
		@helpid 1460
		@author Mark Rausch
	*/
	[Bindable]
	[ChangeEvent("updatePacketChanged")]
	public function get updatePacket():XML { return __updatePacket; }

	/**
		Property that receives a results packet from the server so that it can be translated to a deltaPacket
	  
		@property updateResults
		@tiptext Receives packet of server results for translation into a deltaPacket
		@helpid 1461
		@author Mark Rausch
	*/
	[Bindable]
	[ChangeEvent("updateResultsChanged")]
	public function get updateResults():XML { 
		return __updateResults; 
	}
	public function set updateResults( results:XML ):Void { 
		__updateResults = results;
		updateResultsToDataset();
	}


	//---------------------------------------------------------------------------------------
	//                                Standard Properties
	//---------------------------------------------------------------------------------------
	/**
		This array property holds a list of all updatePackets which have been sent back but for which
		no updateResults have been received. When updateResults are received back, the corresponding
		updatePacket is immediately removed from this list. 
		
		This allows the user to determine which updatePackets have perhaps been lost. Any of them can
		be resent by using the resendPacket() function.

		tiptext List of packets for which results have not been returned
	*/
	public function get unresolvedPackets():Array { return __unresolvedPackets; }
	
	
	//---------------------------------------------------------------------------------------
	//                                    Public methods
	//---------------------------------------------------------------------------------------
	/**
	  Class constructor
	*/
	public function RDBMSResolver() {
		super();
		//Create the opNumber array. The items in this array must be kept in sync with the values in
		//DeltaPacketConsts.as so that string operation names can be translated correctly into op numbers
		_opNumber= new Array();
		_opNumber.length = 3;
		_opNumber["insert"]= DeltaPacketConsts.Added;
		_opNumber["delete"]= DeltaPacketConsts.Removed;
		_opNumber["update"]= DeltaPacketConsts.Modified;
		
		__tableName = __tableName == undefined ? "": __tableName;
		__nullValue = __nullValue == undefined ? "{_NULL_}" : __nullValue;
		__updateMode = __updateMode == undefined ? umUsingKey : __updateMode;
		__updateResults = null;
		
		__unresolvedPackets = new Array();
		__unresolvedDeltas = new Array();
		
		//Add the mix-in class for databinding
		ComponentMixins.initComponent( this );
		//Add the mix-in class for events
		EventDispatcher.initialize(this); //Adds dispatchEvent(), addEventListener(), etc.
	} //RDBMSResolver constructor


	/**
		Adds a new item to the fieldInfo collection. This method can be used by programmers who need to set
		up a resolver dynamically at runtime, rather than via the component inspector in the authoring environment.

		@function addFieldInfo
		@param	fieldName String value containing the name of the field this info object describes
		@param	ownerName String value containing the name of the table this field is "owned" by. May be left blank
							if it is the same as the resolver instance's tablename property.
		@param	isKey Boolean value indicating whether this field is a key field
		@author	Mark Rausch
		@helpid 1462
		@tiptext Adds a new fieldInfo collection item
		@example
			var myResolver:RDBMSResolver = new RDBMSResolver();
			myResolver.tableName = "Customers";
			//Set up the id field as a key field and the personTypeName field so it won't be updated.
			myResolver.addFieldInfo("id", "", true);
			myResolver.addFieldInfo("personTypeName", "JoinedField", false);
			//Now set up the data bindings
			//...
	*/
	public function addFieldInfo(fieldName:String, ownerName:String, isKey:Boolean):Void {
		fieldInfo.addItem(new FieldInfoItem(fieldName, ownerName, isKey));
	} //addFieldInfo function
	
	
	/**
		Causes the specified packet in the unresolvedPackets list to be resent thru the updatePacket property. This
		can be used when packets have been sent but no response received back from the server, indicating that the 
		server did not receive it. If the specified packet does not exist, this function returns false, otherwise it
		returns true.
		
		NOTE: The "at" helpid symbol has been removed so that this method will not appear in the environment for the time being

		function resendPacket
		param	transID The transaction ID for the updatePacket which should be resent
		author	Mark Rausch
		tiptext Resends an unresolvedPacket
		example
			//Resend all unresolvedPackets
			for (var transID in res.unresolvedPackets) {
				resendPacket(transID);
			}
	*/
	public function resendPacket(transID:String):Boolean {
		var oldUpdatePacket:XML = __unresolvedPackets[transID].updatePacket;
		if ((oldUpdatePacket != null) && (oldUpdatePacket != undefined)) {
			__updatePacket = oldUpdatePacket;
			//Dispatch the updatePacketChanged event notification so that databinding will know that it should deal with it
			dispatchEvent({ target:this, type:"updatePacketChanged" }); 
			return true;
		}
		return false;
	} //resendPacket function


	//---------------------------------------------------------------------------------------
	//                                    Private methods
	//---------------------------------------------------------------------------------------
	/**
		Returns a string containing the XML for the field being passed in
		
		@private
		@param	field Pointer to the field object (for the name and data type)
		@param	chgItem DeltaItem object that describe the changes that were made to this field (may be null)
		@param	isKey Boolean value that determines whether or not this field's key attribute should be true or false.
		@author	Mark Rausch
		@example
			The general format for the returned string is as follows:
				<field name="id" type="numeric" oldValue="{_NULL_}" newValue="20" key="true"/>
	*/
	private function buildFieldTag( deltaObj:Delta, field:Object, isKey:Boolean ):String {
		var	chgItem:DeltaItem = deltaObj.getItemByName(field.name);
		var result:String= "<field name=\"" + field.name + "\" type=\"" + field.type.name + "\"";
		var oldValue:String;
		var newValue:String;
		if (deltaObj.getOperation() != DeltaPacketConsts.Added) {
			oldValue = (chgItem != null ? (chgItem.oldValue != null ? encodeFieldValue(field.name, chgItem.oldValue) : __nullValue) : encodeFieldValue(field.name, deltaObj.getSource()[field.name]));
			newValue = (chgItem.newValue != null ? encodeFieldValue(field.name, chgItem.newValue) : __nullValue);
			result+= " oldValue=\""  + oldValue + "\"";
			result+= chgItem != null ? " newValue=\"" + newValue + "\"" : "";
			result+= " key=\"" + isKey.toString() + "\" />";
		}
		else {
			result+= " newValue=\"" +encodeFieldValue(field.name,  deltaObj.getSource()[field.name]) + "\"";
			result+= " key=\"" + isKey.toString() + "\" />";
		}
		return result;
	} //buildFieldTag function
	
	
	/**
		This method gets fired when a new delta packet gets assigned to this component. It translates the delta packet into
		XML, fires an event to allow the user a chance to view/modify the XML, assigns it to the UpdatePacket, and fires the event
		that triggers the databinding mechanism.
		
		@private
		@author	Mark Rausch
	*/
	private function createUpdatePacketFromDelta() {
		__updatePacket = getDeltaAsXML(__deltaPacket);

		//Dispatch the beforeApplyUpdates event so the user can make any adjustments before it is applied
		dispatchEvent({ target:this, type:"beforeApplyUpdates", updatePacket: __updatePacket }); //dispatchEvent was dynamically added to this class using the EventDispatcher mixin class
		
		//Store the final update packet into the __unresolvedPackets list for possible re-use later
		//The packets are stored indexed by transID
		__unresolvedPackets[__deltaPacket.getTransactionId()] = {timestamp:__deltaPacket.getTimestamp(), updatePacket:__updatePacket};

		//Dispatch the updatePacketChanged event notification so that databinding will 
		//know that it should deal with it
		dispatchEvent({ target:this, type:"updatePacketChanged" }); 
	}


	/**
		Decode the field value from a string representation into the native datatype we are using to store it. Use the data pipeline to
		do the translation.
	*/
	public function decodeFieldValue(fieldName:String, value:String):Object {
		//Get the field object from the pseudo-dataset
		var fld:DataType = _fieldValueObj.getField( fieldName );
		//Set the value as a string
		_fieldValueObj[fieldName] = value;
		//Now use the data pipeline to get translate that value into the internal type
		return fld.getTypedValue( FieldAccessor.findElementType( _fieldValueObj.__schema, fieldName ).type.name ).value;
	}
	
	
	/**
		Encode the field value from it's internal representation to a string representation . Use the data pipeline to
		do the translation.
	*/
	public function encodeFieldValue(fieldName:String, value:Object):String {
		//Get the type information for the field from the schema
		var typeInfo:Object = FieldAccessor.findElementType( _fieldValueObj.__schema, fieldName );
		if( typeInfo != null ) {
			//Get the field object from the pseudo-dataset
			var fld:DataType = _fieldValueObj.getField( fieldName );
			//Set the value as specific type (date, boolean, etc)
			fld.setTypedValue( new TypedValue( value, typeInfo.name, typeInfo ));
			//Now return the value translated into a string by the data pipeline
			// added escape function for bug#72701  
			return( mx.utils.XMLString.escape( String( _fieldValueObj[fieldName] )));
		}
		else
			return( mx.utils.XMLString.escape( String( value )));
	}

	
	/**
		Creates an XML packet to be assigned to the UpdatePacket property.
		
		@private
		@param	deltaPacket reference to an instance of an IDeltaPacket interface that contains a list of all changed
							rows and which fields were changed in them.
		@return	reference to a new XML object containing the translation of the deltapacket to our XML format
		@author	Jason Williams & Mark Rausch
		@example
			The general format for the XML is as follows:
				<update_packet tableName="customers" nullValue="{_NULL_}" transID="transID="46386292065:Wed Jun 25 15:52:34 GMT-0700 2003"">
				
					<delete id="11295627479">
						<field name="id" type="numeric" oldValue="10" newValue="10" key="true"/>
					</delete>
				
					<insert id="02938027477">
						<field name="id" type="numeric" newValue="20" key="true"/>
						<field name="firstName" type="string" newValue="Davey" key="false"/>
						<field name="lastName" type="string" newValue="Jones" key="false"/>
					</insert>
				
					<update id="2345423457">
						<field name="id" type="numeric" oldValue="30" newValue="30" key="true"/>
						<field name="firstName" type="string" oldValue="Peter" newValue="Mickey" key="false"/>
						<field name="lastName" type="string" oldValue="Tork" newValue="Dolenz" key="false"/>
					</update>
				
				</update_packet>					
	*/
	private function getDeltaAsXML( deltaPacket:DeltaPacket ):XML {
		var dpCursor:Iterator = deltaPacket.getIterator();
		var deltaObj:Delta = null;
		var xmlStr:String = "<?xml version=\"1.0\"?> <update_packet tableName=\"" + __tableName + "\" nullValue=\"" + __nullValue + "\" transID=\"" + deltaPacket.getTransactionId() + "\">";
		while ( dpCursor.hasNext() ) {
			deltaObj = Delta(dpCursor.next());
			switch( deltaObj.getOperation() ) {
				case DeltaPacketConsts.Removed:
					xmlStr += "<delete id=\"" + deltaObj.getId() + "\">";
					if ((__updateMode == umUsingKey) ||
						(__updateMode == umUsingAll)) {
							xmlStr += getFieldList(deltaObj, __updateMode, false);
					}
					else {
						//umUsingModified: For a delete, we count ALL fields as modified, so switch to umUsingAll
						xmlStr += getFieldList(deltaObj, umUsingAll, false);
					} //if
					xmlStr += "</delete>";
				break;
				
				case DeltaPacketConsts.Added:
					xmlStr += "<insert id=\"" + deltaObj.getId() + "\">";
					xmlStr += getFieldList(deltaObj, umUsingKey, true);
					xmlStr += "</insert>";
				break;
				
				case DeltaPacketConsts.Modified:
					xmlStr += "<update id=\"" + deltaObj.getId() + "\">";
					xmlStr += getFieldList(deltaObj, __updateMode, true);
					xmlStr += "</update>";
				break;
			} // switch
		} // while
		xmlStr += "</update_packet>";
		var result:XML = new XML();
		result.ignoreWhite= true;
		result.parseXML(xmlStr);
		return result;
	} //getDeltaAsXML function
	
	
	/**
		Finds and returns the field info collection item that matches the field name passed in.

		@private
		@author	Jason Williams & Mark Rausch
	*/
	private function getFieldInfo(fieldName:String):FieldInfoItem {
		var fieldInfoItem: FieldInfoItem = null;	
		var fieldInfoIterator:Iterator = fieldInfo.getIterator();
		while (fieldInfoIterator.hasNext()) {
			fieldInfoItem = FieldInfoItem(fieldInfoIterator.next());
			if (fieldInfoItem.fieldName == fieldName)
			 	return fieldInfoItem;
		}
		return null;
	}
	
	
	/**
		Creates an the field portion of the XML packet.
		
		@private
		@param	deltaObj reference to an Delta object which contains a description of changes made to a single row.
		@param  keyFieldMode Numeric representation of the 3 updateMode values (umUsingKey, umUsingModified, and umUsingAll)
							 that specifies which fields should be included and marked as key fields for the Delta object which was
							 passed in. 
							 Note that this may not be the same as this component's UpdateMode parameter. E.g. For an inserted
							 record, it is not necessary to mark any fields as keys except key fields, regardless of the __updateMode
							 setting for this component
		@return	String containing the XML formatted field list. The fields will include all "key" fields and all 
						modified fields.
		@author	Jason Williams & Mark Rausch
		@example
			The general format for the returned string is as follows:
				<field name="id" type="numeric" oldValue="null" newValue="20" key="true"/>
				<field name="firstName" type="string" oldValue="null" newValue="Davey" key="false"/>
				...
				<field name="lastName" type="string" oldValue="null" newValue="Jones" key="false"/>
	*/
	private function getFieldList(deltaObj:Delta, keyFieldMode:String, listModified:Boolean):String {
		var fieldXML:String = "";
		var field:Object = null;
		var chgItem:DeltaItem = null;

		var fieldList:Object = __deltaPacket.getSource().getResolverFieldList();
		//Go thru a list of all the fields (not just modified ones) and determine which need to be included
		for( var fieldName in fieldList ) {
			field = fieldList[fieldName];
			chgItem = deltaObj.getItemByName(fieldName);
			if (includeField(deltaObj, field, keyFieldMode, listModified)) {
				fieldXML += buildFieldTag(deltaObj, field, isKey(field, chgItem, keyFieldMode));
			}
		}
		return fieldXML;
	} //getFieldList function
	
	
	/**
		Determines whether a field should be included in the list of fields for a delta. This determination is based on 
		the fieldinfo, the updatemode, and whether or not the field was modified.
		
		@private
		@param	fld The dataset's field object for the field being asked about
		@param  chgItem The deltapacket's DeltaItem for the row/field being asked about
		@param  keyFieldMode Numeric representation of the 3 updateMode values (umUsingKey, umUsingModified, and umUsingAll)
		@param  includeModified Boolean. True if this method should return modified fields as included
		@return	Boolean indicating if the field should be included or not
		@author	Jason Williams & Mark Rausch
	*/
	private function includeField( deltaObj:Delta, fld:Object, keyFieldMode:String, includeModified:Boolean ):Boolean {
		var fieldItem:FieldInfoItem = getFieldInfo(fld.name);
		if ((fieldItem == null) || (fieldItem.ownerName == "") || (fieldItem.ownerName == __tableName)) {
			var	chgItem:DeltaItem = deltaObj.getItemByName(fld.name);
			return isKey(fld, chgItem, keyFieldMode) || 
				   ((chgItem != null) && includeModified) || 
				   ((deltaObj.getOperation() == DeltaPacketConsts.Added) && (deltaObj.getSource()[fld.name] != null));
		}
		else 
			return false;
	} //includeField function
	
	
	/**
		Return a boolean indicating whether the field passed in should be marked as a key field. The field does not have to be
		listed as a key field in the component parameters for this method to return true. True will be returned depending on the 
		keyFieldMode parameter passed in:
			If using all fields as keys, 
			or if using modified fields as keys, 
			or if it has been marked as a key field, return true

		@private
		@param	deltaItem reference to an Delta object which contains a description of changes made to a single row.
		@param  keyFieldMode Numeric representation of the 3 updateMode values (umUsingKey, umUsingModified, and umUsingAll)
							 that specifies which fields should be included and marked as key fields for the Delta object which was
							 passed in. 
							 Note that this may not be the same as this component's UpdateMode parameter. E.g. For an inserted
							 record, it is not necessary to mark any fields as keys except key fields, regardless of the __updateMode
							 setting for this component
		@return	String containing the XML formatted field list. The fields will include all "key" fields and all 
						modified fields.
		@author	Jason Williams & Mark Rausch
	*/
	private function isKey( fld:Object, chgItem:DeltaItem, keyFieldMode:String ):Boolean {
		return ((keyFieldMode == umUsingAll) || 							//If using all fields as keys
				((keyFieldMode == umUsingModified) && (chgItem != null)) ||	//or if using modified fields as keys
				((getFieldInfo(fld.name) != null) && (getFieldInfo(fld.name).isKey))); 						//or if it has been marked as a key field, return true
	} //isKey function


	/**
		Removes the specified packet from the unresolvedPackets list.

		@function removeUnresolvedPacket
		@private
		@param	transID The transaction ID for the updatePacket which should be removed
		@author	Mark Rausch
		@helpid 0000
	*/
	private function removeUnresolvedPacket(transID:String):Void {
		__unresolvedPackets[transID] = null;
		__unresolvedDeltas[transID] = null;
	}
	
	
	/**
		This method gets called when results come back to this component. It translates the results, fires 
		an event to allow the user a chance to view/modify the it, assigns it to the DeltaPacket property, 
		and then fires the event that triggers the databinding mechanism.
		
		@private
		@author	Mark Rausch
		@example
			The general format for the XML in the results packet is as follows:
				<results_packet nullValue="{_NULL_}" transID="46386292065:Wed Jun 25 15:52:34 GMT-0700 2003">
					<operation op="delete" id="11295627479" msg="The record could not be found" />
				
					<delete>
						<field name="id" oldValue="1000" key="true" />
					</delete>
				
					<insert>
						<field name="id" newValue="20"/>
						<field name="firstName" newValue="Davey"/>
						<field name="lastName" newValue="Jones"/>
					</insert>
				
		            <operation op="update" id="02938027477" msg="Couldn't update employee.">
						<field name="id" curValue="105" msg="Invalid field value" />
					</operation>
					
					<update>
						<field name="id" oldValue="30" newValue="30" key="true" />
						<field name="firstName" oldValue="Peter" newValue="Mickey"/>
						<field name="lastName" oldValue="Tork" newValue="Dolenz"/>
					</update>
				
				</results_packet>					
	*/
	private function updateResultsToDataset():Void {
		//Get the operations from the __updateResults XML, and transform it into a an array of deltas
		var resultsList:Array = new Array(); //List of deltas that provide messages about results of our update
		var updatesList:Array = new Array(); //List of deltas that provide information about changes that were made to the server data by others
		var opNodeList:Array = __updateResults.firstChild.childNodes;
		var opNode:XMLNode = null;

		var transID:String = __updateResults.firstChild.attributes["transID"];
		//Setup the field value object that will be used for decoding later
		_fieldValueObj = new Object();
		_fieldValueObj.__schema = getLocalSchema( DeltaPacket(__unresolvedDeltas[transID]).getConfigInfo().elements[0].type );
		mx.data.binding.ComponentMixins.initComponent( _fieldValueObj );	

		for (var i:Number = 0; i<opNodeList.length; i++) {
			opNode = opNodeList[i];
			if (opNode.nodeName.toLowerCase() == "operation") {
				resultsList.push( Object( updateResultNodeToDelta( transID, opNode )));
			}
			else {
				updatesList.push( Object( updateResultNodeToDelta( transID, opNode )));
			}
		} //for

		//Now put the results array of deltas into a deltapacket and send them out
		if( transID == undefined )
			transID = new Date().toString();
  		__deltaPacket = new DeltaPacketImpl(this, transID );
		for (var i:Number = 0; i < resultsList.length; i++)
			__deltaPacket.addItem(resultsList[i]);
		removeUnresolvedPacket(transID);
		//Dispatch the reconcileResults event with a dynamic property that contains the deltaPacket
		dispatchEvent({ target:this, type:"reconcileResults", deltaPacket: __deltaPacket }); //dispatchEvent was dynamically added using the EventDispatcher mixin class
		//Dispatch the deltaPacketChanged event notification so that databinding will know about it
		dispatchEvent({ target:this, type:"deltaPacketChanged"});

		if (updatesList.length > 0) {
			//Put the updates array of deltas into a deltapacket and send them out
 			__deltaPacket = new DeltaPacketImpl(this, new Date().toString() );
			for (var i:Number = 0; i < updatesList.length; i++)
				__deltaPacket.addItem(updatesList[i]);
			dispatchEvent({ target:this, type:"reconcileUpdates", deltaPacket: __deltaPacket }); //dispatchEvent was dynamically added using the EventDispatcher mixin class
			dispatchEvent({ target:this, type:"deltaPacketChanged"});
		} //if (resultsList.length > 0)
	} //updateResultsToDataset
	
	
	/**
		This method translates an individual result node into an instance of the DeltaImpl class
		
		@private
		@return	reference to a new Delta instance
		@author	Mark Rausch
		@example
			The general format for the XML in the results packet is as follows:
				<results_packet nullValue="{_NULL_}" transID="46386292065:Wed Jun 25 15:52:34 GMT-0700 2003">
					<operation op="delete" id="11295627479" msg="The record could not be found" />
				
					<delete>
						<field name="id" oldValue="1000" key="true" />
					</delete>
				
					<insert>
						<field name="id" newValue="20"/>
						<field name="firstName" newValue="Davey"/>
						<field name="lastName" newValue="Jones"/>
					</insert>
				
		            <operation op="update" id="02938027477" msg="Couldn't update employee.">
						<field name="id" curValue="105" msg="Invalid field value" />
					</operation>
					
					<update>
						<field name="id" oldValue="30" newValue="30" key="true" />
						<field name="firstName" oldValue="Peter" newValue="Mickey"/>
						<field name="lastName" oldValue="Tork" newValue="Dolenz"/>
					</update>
				
				</results_packet>					
	*/
	private function updateResultNodeToDelta(transID:String, node:XMLNode):Delta {
		//Determine the operation type, id number, and source object properties
		var op:Number = -1;
		var id:String = "";
		var source:Object = null;
		var msg:String = "";
		var createDeltaItems:Boolean = false;
		switch (node.nodeName.toLowerCase()) {
			case "insert":
				op = _opNumber[node.nodeName];
				source = updateResultGetSourceObject(node, true);
				break;
			case "delete":
				op = _opNumber[node.nodeName];
				source = updateResultGetSourceObject(node, false);
				break;
			case "update":
				op = _opNumber[node.nodeName];
				source = updateResultGetSourceObject(node, false);
				createDeltaItems= true;
				break;
			case "operation":
				op = _opNumber[node.attributes["op"]];
				if (! ((op>=0) && (op<_opNumber.length)))
					throw new Error( "Operation '" + node.attributes["op"]+ "' does not exist.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
				id = node.attributes["id"];
				source = getDeltaSource(transID, id);
				if (node.attributes["msg"] != null)
					msg = node.attributes["msg"];
				createDeltaItems= true;
				break;
			default:
				throw new Error( "Unknown node type '" + node.nodeName + "'.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
				break;
		} //switch
		
		//Create the delta from the information gathered, then add the deltaItems to it
		var result:Delta = new DeltaImpl(id, source, op, msg, true);
		if (createDeltaItems)
			updateResultsAddDeltaItems(node, result);
		
		return result;
	} //updateResultNodeToDelta
	
	
	private function getDeltaSource(transID:String, opID:String):Object{
		var dp:DeltaPacket = DeltaPacket(__unresolvedDeltas[transID]);
		if (dp != null) {
			var deltaObj:Delta;
			var dpCursor:Iterator = dp.getIterator();
			while ( dpCursor.hasNext() ) {
				deltaObj = Delta(dpCursor.next());
				if (deltaObj.getId() == opID) {
					return deltaObj.getSource();
				}
			}
		}
		return null;
	}
	
	/**
	  This method will return a local schema object that includes any overrides that have been made on
	  this resolver to the associated connector schema, that is passed through the delta packet.
	  
	  @param	extSch Object containing the schema from the external source, provided via the deltapacket
	  @return	Object containing either the same schema or one that has been modified to include any overriden
	  			values.
	*/
	private function getLocalSchema( extSch:Object ):Object {
		var locSch:Object = null;
		if( extSch != null ) {
			var locEls:Array = __schema.elements;
			var extEls:Array = extSch.elements;
			for( var i:Number=0; i<locEls.length; i++ ) {
				//trace( "looking at.... "+ locEls[i].name+ " -"+locEls[i].type.original );
				if( locEls[i].type.original == false ) {
					if( locSch == null )
						locSch = mx.utils.ObjectCopy.copy( extSch );
					//trace( "checking... "+locEls[i].name );
					var found:Boolean = false;
					var j:Number = 0;
					var name:String = locEls[i].name;
					// check to see if this is an override
					while( !found && ( j<extEls.length )) {
						//trace( "looking at external... "+extEls[j].name );
						found = extEls[j].name == name;
						j++;
					} // while
					// did we find any
					if( found ) {
						//trace( "found '"+locEls[i].name+"' in schema" );
						locSch.elements[j-1]=locEls[i]; // override ext schema 
					}
					else {
						if( locSch.elements == null )
							locSch.elements = new Array();
						locSch.elements.push( locEls[i] ); // add it in
						//trace( "not found so adding '"+locEls[i].name+"' in schema" );
					}
				} // if
			} // for
			// if we didn't find anything to do, use what we have
			if( locSch == null )
				locSch = extSch;
		} // if have external schema
		else
			locSch = __schema;
		//trace( mx.data.binding.ObjectDumper.toString( locSch ));
		return( locSch );
	}
	
	/**
		This method iterates thru the field nodes for an operation result or change node and adds them as DeltaItems
		to the Delta which is passed in.
		
		@private
		@param node The operation result or change node under which to look for field nodes
		@param delta The Delta object which will hold the DeltaItems
		@author	Mark Rausch
		@example
			The some examples of the field nodes are as follows:
					<field name="id" oldValue="1000" key="true" />
					
					<field name="id" newValue="20"/>
					<field name="firstName" newValue="Davey"/>
					<field name="lastName" newValue="Jones"/>
					
					<field name="id" curValue="105" msg="Invalid field value" />
					
					<field name="id" oldValue="30" newValue="30" key="true" />
					<field name="firstName" oldValue="Peter" newValue="Mickey"/>
					<field name="lastName" oldValue="Tork" newValue="Dolenz"/>
	*/
	private function updateResultsAddDeltaItems(node:XMLNode, delta:Delta):Void {
		var fieldNodeList:Array = node.childNodes;
		var fieldNode:XMLNode = null;
		var fieldName:String = null;
		for (var i:Number = 0; i < fieldNodeList.length; i++) {
			fieldNode = fieldNodeList[i];
			if (fieldNode.nodeType != 3) {
				var initObj = new Object();
				fieldName = fieldNode.attributes["name"];
				if (fieldNode.attributes["oldValue"] != undefined)
					initObj.oldValue = decodeFieldValue(fieldName, fieldNode.attributes["oldValue"]);
				if (fieldNode.attributes["newValue"] != undefined)
					initObj.newValue = decodeFieldValue(fieldName, fieldNode.attributes["newValue"]);
				if (fieldNode.attributes["curValue"] != undefined)
					initObj.curValue = decodeFieldValue(fieldName, fieldNode.attributes["curValue"]);
				initObj.message = fieldNode.attributes["msg"];
				//Create a new deltaItem. It automatically adds itself to the delta
				new DeltaItem(DeltaItem.Property, fieldName, initObj, Object(delta)); 
			} //if
		} //for
	} //updateResultsAddDeltaItems
	
	
	/**
		This method returns the "source" object which is used by the Delta object. The source object is used to locate the record
		to be updated or deleted, or for an insert it contains all the field values for the insert operation. It's properties
		get set from the field nodes for an operation result or change node.
		
		@private
		@param node The operation result or change node under which to look for field nodes
		@param isInsert A boolean value that determines if all fields or only key fields will be used, and whether to use newValue or oldValue
		@return An anonymous object with properties named by field and whose value is set from either the old or new value attributes
		@author	Mark Rausch
		@example
			The some examples of the field nodes are as follows:
					<field name="id" oldValue="1000" key="true" />
					
					<field name="id" newValue="20"/>
					<field name="firstName" newValue="Davey"/>
					<field name="lastName" newValue="Jones"/>
					
					<field name="id" curValue="105" msg="Invalid field value" />
					
					<field name="id" oldValue="30" newValue="30" key="true" />
					<field name="firstName" oldValue="Peter" newValue="Mickey"/>
					<field name="lastName" oldValue="Tork" newValue="Dolenz"/>
	*/
	private function updateResultGetSourceObject(node:XMLNode, isInsert:Boolean):Object {
		var fieldNodeList:Array = node.childNodes;
		var fieldNode:XMLNode = null;
		var result:Object = new Object();
		
		for (var i:Number = 0; i < fieldNodeList.length; i++) {
			fieldNode = fieldNodeList[i];
			if (isInsert) {
				if (fieldNode.attributes["newValue"] != undefined)
					result[fieldNode.attributes["name"]] = decodeFieldValue(fieldNode.attributes["name"], fieldNode.attributes["newValue"]);
				else
					throw new Error( "Field " + fieldNode.attributes["name"] + "in Insert operation node does not have a 'newValue' attribute.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
			}
			else if (fieldNode.attributes["key"]=="true") {
				if (fieldNode.attributes["oldValue"] != undefined)
					result[fieldNode.attributes["name"]] = decodeFieldValue(fieldNode.attributes["name"], fieldNode.attributes["oldValue"]);
				else
					throw new Error( "Field " + fieldNode.attributes["name"] + "is a key field but does not have an 'oldValue' attribute.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
			} //if
		} //for
		return result;
	} //updateResultGetSourceObject
	
	
	//---------------------------------------------------------------------------------------
	//                                 Private member variables
	//---------------------------------------------------------------------------------------
	private var __fieldInfo:Collection;
	private var __nullValue:String;
	private var __tableName:String;
	private var __updateMode:String;
	private var __schema:Object; // added by the component mixins class
	
	private var __deltaPacket:DeltaPacket;
	private var __updatePacket:XML;
	private var __updateResults:XML;
	
	private var __unresolvedPackets	:Array;
	private var __unresolvedDeltas:Array;
	
	private var _opNumber:Array;
	private var _fieldValueObj:Object;

	//add reference to the collection item class to force compiler to include it as a dependency within the swc
	private var collClass:mx.utils.CollectionImpl;
	private var collItem:mx.data.components.resclasses.FieldInfoItem;
	
	
	//---------------------------------------------------------------------------------------
	//                                 Mixin methods/variables
	//---------------------------------------------------------------------------------------
	/**
	* @private
	* @see mx.events.EventDispatcher
	*/
	var dispatchEvent:Function;

	/**
	* @see mx.events.EventDispatcher
	* @tiptext Adds a listener for an event
	* @helpid 3958
	*/
	var addEventListener:Function;

	/**
	* @see mx.events.EventDispatcher
	*/
	var removeEventListener:Function;

}
