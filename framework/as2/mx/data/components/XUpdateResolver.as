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
import mx.events.EventDispatcher;
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

  The XUpdateResolver is a specific resolver implementation that translates the DeltaPacket
  into XUpdate, usable by any server or database that understands the language. The XUpdate
  language spec can be found at http://www.xmldb.org/xupdate/xupdate-wd.html
  
	@class XUpdateResolver
	@tiptext Converts deltapackets into XUpdate statements
	@helpid 1463
	@author Jason Williams & Mark Rausch
    @codehint _xrs    

*/
//---------------------------------------------------------------------------------------
//                                        Events
//---------------------------------------------------------------------------------------
/**
	This event is fired before the updates are applied to the server.  This is a good place to put
	code that will add custom XML data to the update packet to be interpreted by the server.
	
	@event	beforeApplyUpdates
	@helpid 1464
	@tiptext Fired before the XupdatePacket property is updated
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
	@helpid 1465
	@tiptext Fired before operation results are sent via databinding
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
	
	The reconcileUpdates event is fired just before the deltaPacket containing the updates is sent via databinding
	
	event	reconcileUpdates
	helpid 1466
	@tiptext Fired before server updates are sent via databinding
	@example
		 on (reconcileUpdates) {
			 // examine results
			 if( examine( updateResults ))
			   myDataset.purgeUpdates();
			 else
				displayErrors( results );
		 }
*/
//[Event("reconcileUpdates")]
	
[RequiresDataBinding(true)]
[IconFile("XUpdateResolver.png")]
class mx.data.components.XUpdateResolver extends MovieClip {
	//---------------------------------------------------------------------------------------
	//                                Component Parameters
	//---------------------------------------------------------------------------------------

	/** 
	  @tiptext Set to true to include additional deltapacket info
	  @helpid 1467
	*/
	[Inspectable (defaultValue="false")]
	public function get includeDeltaPacketInfo():Boolean { return __includeDPInfo; }
	public function set includeDeltaPacketInfo(newValue:Boolean):Void { __includeDPInfo = newValue; }
	
	
	//---------------------------------------------------------------------------------------
	//                                Bindable Properties
	//---------------------------------------------------------------------------------------

	/** 
	  @tiptext Log of changes to the DataSet
	  @helpid 1468
	*/
	[Bindable(type="DeltaPacket")]
	[ChangeEvent("deltaPacketChanged")]
	public function get deltaPacket():DeltaPacket { return __deltaPacket; }
	public function set deltaPacket( dp:DeltaPacket ):Void { 
		__deltaPacket = dp; 
		if (dp != null) {
			__unresolvedDeltas[dp.getTransactionId()] = dp;
			createXUpdatePacketFromDelta(dp); 
		}
	}
	

	/** 
	  @tiptext Log of changes to a DataSet in XUpdate format
	  @helpid 1469
	*/
	[Bindable]
	[ChangeEvent("xupdatePacketChanged")]
	public function get xupdatePacket():XML { return __xupdatePacket; }

	
	/** 
	  @tiptext Result packet returned from the server
	  @helpid 1470
	*/
	[Bindable]
	[ChangeEvent("updateResultsChanged")]
	public function get updateResults():XML { return __updateResults; }
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

		@property unresolvedPackets
		@author	Mark Rausch
		tiptext List of packets for which results have not been returned
		help 1471
		@example
			//Resend all unresolvedPackets
			for (var transID in res.unresolvedPackets) {
				resendPacket(transID);
			}
	*/
	public function get unresolvedPackets():Array { return __unresolvedPackets; }
	
	
	//---------------------------------------------------------------------------------------
	//                                    Public methods
	//---------------------------------------------------------------------------------------
	/**
	  Class constructor
	*/
	function XUpdateResolver() {
		super();
		
		//Create the opNumber array. The items in this array must be kept in sync with the values in
		//DeltaPacketConsts.as so that string operation names can be translated correctly into op numbers
		_opNumber= new Array();
		_opNumber.length = 3;
		_opNumber["append"]= DeltaPacketConsts.Added;
		_opNumber["remove"]= DeltaPacketConsts.Removed;
		_opNumber["update"]= DeltaPacketConsts.Modified;
		
		__unresolvedDeltas = new Array();
		__unresolvedPackets = new Array();
		
		//Add the mix-in class for databinding
		ComponentMixins.initComponent( this );
		//Add the mix-in class for events
		EventDispatcher.initialize(this); //Adds dispatchEvent(), addEventListener(), etc.
	} //XUpdateResolver constructor


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
		//Get the field object from the pseudo-dataset
		var fld:DataType = _fieldValueObj.getField( fieldName );
		//Set the value as specific type (date, boolean, etc)
		fld.setTypedValue( new TypedValue( value, typeInfo.name, typeInfo ));
		//Now return the value translated into a string by the data pipeline
		// make sure the XML string is valid, fix for bug#72701
		value =_fieldValueObj[fieldName];
		// if we have a string and it is null encoding it should produce ""
		if(( typeInfo.name == "String" ) && ( value == null ))
			value = "";
			
		if( value != null )
			return( mx.utils.XMLString.escape( String( value )));
		else
			return( null );
	}

	
	/**
		Causes the specified packet in the unresolvedPackets list to be resent thru the xupdatePacket property. This
		can be used when packets have been sent but no response received back from the server, indicating that the 
		server did not receive it. If the specified packet does not exist, this function returns false, otherwise it
		returns true.

		function resendPacket
		@private
		@param	transID The transaction ID for the updatePacket which should be resent
		@author	Mark Rausch
		tiptext Resends an unresolvedPacket
		help 1472
		@example
			//Resend all unresolvedPackets
			for (var transID in res.unresolvedPackets) {
				resendPacket(transID);
			}
	*/
	public function resendPacket(transID:String):Boolean {
		var oldUpdatePacket:XML = __unresolvedPackets[transID].updatePacket;
		if ((oldUpdatePacket != null) && (oldUpdatePacket != undefined)) {
			__xupdatePacket = oldUpdatePacket;
			//Dispatch the updatePacketChanged event notification so that databinding will know that it should deal with it
			dispatchEvent({ target:this, type:"xupdatePacketChanged" }); 
			return true;
		}
		return false;
	} //resendPacket


	//---------------------------------------------------------------------------------------
	//                                    Private methods
	//---------------------------------------------------------------------------------------
	/**
		Creates the xupdate DOM, puts it into the xupdatePacket property, and fires the databinding event.
		
		@author	Jason Williams & Mark Rausch
	*/
	private function createXUpdatePacketFromDelta(dp:DeltaPacket) {
		__xupdatePacket = getDeltaAsXML(dp);

		//Dispatch the beforeApplyUpdates event so the user can make any adjustments before it is applied
		dispatchEvent({ type:"beforeApplyUpdates", target:this, xupdatePacket:__xupdatePacket }); 
		
		//Store the final update packet into the __unresolvedPackets list for possible re-use later
		//The packets are stored indexed by transID
		__unresolvedPackets[__deltaPacket.getTransactionId()] = {timestamp:__deltaPacket.getTimestamp(), xupdatePacket:__xupdatePacket};

		//Dispatch the updatePacketChanged event notification so that databinding will 
		//know that it should deal with it
		dispatchEvent({ target:this, type:"xupdatePacketChanged" }); 
	} //createXUpdatePacketFromDelta

	
	/**
		Returns a string containing the name of the node or attribute at the end of the xpath input string
		
		@param	path string containing an XPath expression
		@author	Jason Williams & Mark Rausch
	*/
	private function getAttribute( path ):String {
		var indx:Number = path.lastIndexOf( "@" );
		if ( indx == -1 )
			return( "node=\""+ path.substring( path.lastIndexOf( "/" ) + 1 ) +"\"" );
		else
			return( "attribute=\""+ path.substring( indx + 1 )+ "\"" );
	} //getAttribute


	/**
	  Returns the first child node of the specified node found with the specified name.
		
		@param	node reference to the node object to search from
		@param	nodeName string containing the name of the desired child node
		@author	Jason Williams
	*/
	private function getChildNodeByName( node, nodeName ):XMLNode {
		var result:XMLNode;
		var childNodes:Array = node.childNodes;
		for ( var i:Number=0; i<childNodes.length; i++ ) {
			result = childNodes[i];
			if (result.nodeName == nodeName)
				return result;
		} // for
		return null;
	} //getChildNodeByName
	
	
	/**
		Uses the deltaPacket to create an XUpdate packet to be assigned to the XUpdatePacket property.
		
		@param	packetObj reference to an instance of an FxDeltaPacketClass.
		@return	reference to a new XML object containing the translation of the deltapacket to XUpdate
		@author	Jason Williams & Mark Rausch
		@example
			The format for the XUpdate is as follows:
				<xupdate:modifications version=\"1.0\" transID="Wed, July 30, 2003:ABCDEFGHI" xmlns:xupdate=\"http://www.xmldb.org/xupdate\">
					<xupdate:remove select="[x-path to node]" opID="1234567890"/>
					<xupdate:append select="[x-path to parent]">
						<xupdate:element name="[newnodename]">
							<xupdate:attribute name="[1st attr name]">[1st attr value]</xupdate:attribute>
							...
							<xupdate:attribute name="[Nth attr name]">[Nth attr value]</xupdate:attribute>
							<childnode1/>
							...
							<childnodeN/>
						</xupdate:element>
					</xupdate:append>
					<xupdate:insert-before select="[x-path to node]">
						<xupdate:element name="[newnodename]">
							<xupdate:attribute name="[1st attr name]">[1st attr value]</xupdate:attribute>
							...
							<xupdate:attribute name="[Nth attr name]">[Nth attr value]</xupdate:attribute>
							<childnode1/>
							...
							<childnodeN/>
						</xupdate:element>
					</xupdate:insert-before>
					<xupdate:update select="[x-path to node]">
						[New Attribute or node value]
					</xupdate:update>
				</xupdate:modifications>
	*/
	private function getDeltaAsXML( dp:DeltaPacket ):XML {
		var dpCursor:Iterator = dp.getIterator();
		var deltaObj:Delta = null;
		var xmlStr:String = "<?xml version=\"1.0\"?>" + 
		                    "<xupdate:modifications version=\"1.0\" xmlns:xupdate=\"http://www.xmldb.org/xupdate\" " + 
								(__includeDPInfo?("transID=\""+dp.getTransactionId()+"\" "):"") + ">";
		while ( dpCursor.hasNext() ) {
			deltaObj = Delta(dpCursor.next());
			this; //!!@@Remove this once the strange "this" bug is fixed (it causes the getXUpdateElementDef function to be uncallable)
			switch( deltaObj.getOperation() ) {
				case DeltaPacketConsts.Removed:
					var nodeXPath:String = String(deltaObj.getSource().encoderInfo);
//trace("Outputting nodeXPath: "+nodeXPath);
					xmlStr += "<xupdate:remove select=\"" + nodeXPath + "\" " + (__includeDPInfo?("opID=\""+deltaObj.getId()+"\" "):"") + "/>";
				break;
				
				case DeltaPacketConsts.Added:
					var nodeXPath:String = deltaObj.getSource().encoderInfo.xpath;
					var rowNode:XMLNode = deltaObj.getSource().encoderInfo.node;
//trace("Outputting nodeXPath: "+nodeXPath);
					xmlStr += "<xupdate:append select=\"" + nodeXPath + "\" " + 
								(__includeDPInfo?("opID=\""+deltaObj.getId()+"\" "):"") + ">" +
								getXUpdateElementDef(rowNode) + "</xupdate:append>";
				break;
				
				case DeltaPacketConsts.Modified:
					var changes:Array = deltaObj.getChangeList();
					var fieldName:String;
					var change:DeltaItem;
					var value:String;
					var updateStr = "";
					for ( var i in changes ) {
						change = changes[i];
						fieldName = change.name;
						value = encodeFieldValue(fieldName, change.newValue);
						// if the value has been set 
						if( value != null ) {
							var fldXPath:String = String(deltaObj.getSource().encoderInfo);
//trace("Outputting Field XPath: "+fldXPath);
							updateStr += "<xupdate:update select=\"" + fldXPath +"\" " + (__includeDPInfo?("opID=\""+deltaObj.getId()+"\" "):"") + ">" + value+ "</xupdate:update>";
						} // if value is set
					} // for
					xmlStr+= updateStr;
				break;
			} // switch
		} // while
		xmlStr += "</xupdate:modifications>";
		var result:XML = new XML();
		result.ignoreWhite= true;
		result.parseXML(xmlStr);
		return result;
	} //getDeltaAsXML
	
	
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
		Creates the following XUpdate structure for an inserted or appended node
					<xupdate:element name="[newnodename]">
						<xupdate:attribute name="[1st attr name]">[1st attr value]</xupdate:attribute>
						...
						<xupdate:attribute name="[Nth attr name]">[Nth attr value]</xupdate:attribute>
						<childnode1/>
						...
						<childnodeN/>
					</xupdate:element>
	*/
	private function getXUpdateElementDef(node:XMLNode):String {
		var element:String = "<xupdate:element name=\"" + node.nodeName + "\">";
		for (var attrName in node.attributes) {
			element += "<xupdate:attribute name=\"" + attrName + "\">" + node.attributes[attrName] + "</xupdate:attribute>";
		}//for each attribute
		for (var i:Number=0; i<node.childNodes.length; i++) {
			element += node.childNodes[i];
		}//for each child node
		element += "</xupdate:element>";
		return element;
	} //getXUpdateElementDef

	
	/**
		Removes the specified packet from the unresolvedPackets list.

		@function removeUnresolvedPacket
		@private
		@param	transID The transaction ID for the updatePacket which should be removed
		@author	Mark Rausch
	*/
	private function removeUnresolvedPacket(transID:String):Void {
		__unresolvedDeltas[transID] = null;
		__unresolvedPackets[transID] = null;
	} //removeUnresolvedPacket
	
	
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
				
		            <operation op="update" id="02938027477" msg="Couldn't update employee.">
						<field name="id" curValue="105" msg="Invalid field value" />
					</operation>
					
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
//trace("Adding a result delta");
//trace("Operation="+opNode.nodeName.toLowerCase());
			if (opNode.nodeName.toLowerCase() == "operation") {
				resultsList.push( Object( updateResultNodeToDelta( transID, opNode )));
			}
			else {
				//!!@@ NOTE: The following line is commented out because handling updates from the updateResults is currently a "B" feature
				//updatesList.push( updateResultNodeToDelta(opNode) );
			}
		} //for
		
		//Now put the results array of deltas into a deltapacket and send them out
  		if( transID == undefined )
  			transID = "";
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
 			__deltaPacket = new DeltaPacketImpl(this, "" );
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
				
		            <operation op="update" id="02938027477" msg="Couldn't update employee.">
						<field name="id" curValue="105" msg="Invalid field value" />
					</operation>
					
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
			/*
			//!!@@ "B" feature code commented out
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
			*/
			case "operation":
				op = _opNumber[node.attributes["op"]];
				if (! ((op>=0) && (op<_opNumber.length)))
					throw new Error( "Operation '" + node.attributes["op"]+ "' does not exist.  Error on XUpdateResolver '"+ Object( this )._name+ "'." );
				id = node.attributes["id"];
				source = getDeltaSource(transID, id);
				if (node.attributes["msg"] != null)
					msg = node.attributes["msg"];
				createDeltaItems= true;
				break;
			default:
				throw new Error( "Unknown node type '" + node.nodeName + "'.  Error on XUpdateResolver '"+ Object( this )._name+ "'." );
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
					return deltaObj.getSource().deltaSource;//Get the original source from the location the encoder placed it
				}
			}
		}
		return null;
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
		var fieldName:String = "";
		for (var i:Number = 0; i < fieldNodeList.length; i++) {
			fieldNode = fieldNodeList[i];
			if (fieldNode.nodeType != 3) {
				var initObj = new Object();
				fieldName = fieldNode.attributes["name"];
				//var typeInfo:Object = FieldAccessor.findElementType( _fieldValueObj.__schema, fieldName );
				//var datatype = typeInfo.name;
				
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
	/*
	//!!@@ "B" feature code commented out
	private function updateResultGetSourceObject(node:XMLNode, isInsert:Boolean):Object {
		var fieldNodeList:Array = node.childNodes;
		var fieldNode:XMLNode = null;
		var result:Object = new Object();
		
		for (var i:Number = 0; i < fieldNodeList.length; i++) {
			fieldNode = fieldNodeList[i];
			if (isInsert) {
				if (fieldNode.attributes["newValue"] != undefined)
					result[fieldNode.attributes["name"]] = fieldNode.attributes["newValue"]
				else
					throw new Error( "Field " + fieldNode.attributes["name"] + "in Insert operation node does not have a 'newValue' attribute.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
			}
			else if (fieldNode.attributes["key"]=="true") {
				if (fieldNode.attributes["oldValue"] != undefined)
					result[fieldNode.attributes["name"]] = fieldNode.attributes["oldValue"]
				else
					throw new Error( "Field " + fieldNode.attributes["name"] + "is a key field but does not have an 'oldValue' attribute.  Error on RDBMSResolver '"+ Object( this )._name+ "'." );
			} //if
		} //for
		return result;
	} //updateResultGetSourceObject
	*/
	
	
	//---------------------------------------------------------------------------------------
	//                                 Private member variables
	//---------------------------------------------------------------------------------------
	private var __deltaPacket:DeltaPacket;
	private var __xupdatePacket:XML;
	private var __updateResults:XML;
	private var __schema:Object; // added by the component mixin
	
	private var __unresolvedPackets:Array;
	private var __unresolvedDeltas:Array;
	private var __includeDPInfo:Boolean;

	private var _fieldValueObj:Object;
	private var _opNumber:Array;
	
	private var encoder:mx.data.encoders.DatasetDeltaToXUpdateDelta; //Force the encoder to be loaded into the SWC

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

