//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.data.binding.DataAccessor;
import mx.data.binding.DataType;
import mx.data.binding.FieldAccessor;
import mx.data.binding.TypedValue;
import mx.data.components.datasetclasses.Delta;
import mx.data.components.datasetclasses.DeltaImpl;
import mx.data.components.datasetclasses.DeltaItem;
import mx.data.components.datasetclasses.DeltaPacket;
import mx.data.components.datasetclasses.DeltaPacketConsts;
import mx.data.components.datasetclasses.DeltaPacketImpl;
import mx.utils.Iterator;
import mx.utils.StringTokenParser;
import mx.xpath.XPathAPI;


/**
  An encoder that encodes a deltapacket from a dataset into a deltapacket that can be used by the XUpdateResolver
*/
class mx.data.encoders.DatasetDeltaToXUpdateDelta extends DataAccessor {	
	//static var XPathInfo:String = XMLtoDataSetItems.XPathInfo;
	
	var rowNodeKey:String;

	//---------------------------------------------------------------------------------------
	//                                    Public methods
	//---------------------------------------------------------------------------------------
	function getTypedValue( requestedType:String ):TypedValue {
		var returnValue: mx.data.binding.TypedValue = null;
		if ((requestedType == "DeltaPacket") || (requestedType== "Object") || (requestedType == null)){
			returnValue = this.dataAccessor.getTypedValue();
		}
		return returnValue;
	}

	
	function getGettableTypes():Array {
		return["DeltaPacket"];
	}

	
	/*
		Creates a new deltaPacket and populates it with a modified version of the incoming one. These modifications 
		are necessary so that it can be used by the XUpdateResolver. Modifications are as follows:
		-Each delta item for each update operation will be split out into it's own delta
		-Each update or delete delta will have the getSource() set to the XPath string that identifies the node
		-Each append delta will will have the getSource() set to an anonymous object that has the following properties:
			+ xpath: XPath that identifies the parent node.
			+ node: XMLNode object containing the node to be added.
	*/
	function setTypedValue( newValue: TypedValue ):Array {
  		if(( newValue.typeName == "DeltaPacket" ) || ( newValue.typeName == "Object" )) {
			var origDeltaPacket:DeltaPacket = newValue.value;
			
			//Setup the field value object that will be used for encoding later
			this.component._fieldValueObj = new Object();
			this.component._fieldValueObj.__schema = this.component.getLocalSchema( origDeltaPacket.getConfigInfo().elements[0].type );
			mx.data.binding.ComponentMixins.initComponent( this.component._fieldValueObj );	

			//Now transmogrify the deltapacket into the needed form
			var deltaList:Array = getNewDeltaList(origDeltaPacket);
			var resultDP:DeltaPacket = DeltaPacket(new DeltaPacketImpl(Object(origDeltaPacket.getSource()), 
																	   origDeltaPacket.getTransactionId(), 
																	   null, 
																	   origDeltaPacket.logChanges(), 
																	   origDeltaPacket.getConfigInfo()));
			for (var i:Number= 0; i<deltaList.length; i++)
				resultDP.addItem(deltaList[i]);
			return( dataAccessor.setTypedValue( new TypedValue( resultDP, "DeltaPacket" )));
		}
		else {
			return([ DataAccessor.conversionFailed( newValue, "DeltaPacket" )]);
		}
	}
	
	function getSettableTypes():Array {
		return ["DeltaPacket"];
	}


	//---------------------------------------------------------------------------------------
	//                                   Private methods
	//---------------------------------------------------------------------------------------
	private function addDeltaItemToDelta(di:DeltaItem, delta:Delta):Void {
		//Pull the properties the old deltaItem into an object that will be used to initialize the new deltaItem
		var initObj = new Object();
		initObj.oldValue = di.oldValue;
		initObj.newValue = di.newValue;
		initObj.curValue = di.curValue;
		initObj.argList = di.argList;
		initObj.message = di.message;
		
		//Now create the new deltaItem (which will add itself to the owner passed in as the last param)
		var newItem:DeltaItem = new DeltaItem(di.kind, di.name, initObj, Object(delta));
	}
	
	
	private function addNewNodeData(xmlDoc:XML, deltaObj:Delta):Void {
		var ds:Object = Object(deltaObj).deltaPacket.getSource();
		var fieldList:Object = Object(deltaObj).deltaPacket.getSource().properties;
		var fld:DataType = null;
		var fldValue:String = null;
		var fldPath:String = null;
		var fldNode:XMLNode = xmlDoc.firstChild;
		var evalStr:String = null;
		var strParser:StringTokenParser = null;
		for( var fieldName in fieldList ) {
			fldValue = encodeFieldValue(fieldName, deltaObj.getSource()[fieldName]);
			fld = ds.getField(fieldName);
			fldPath = fldNode.nodeName + getXPathToField(deltaObj, fieldName);
			strParser = new StringTokenParser(fldPath);
			strParser.nextToken();//Skip the row node creation since we already have that context (xmlDoc.firstChild)
			//Create the child nodes to store the field data based on the field's xpath
			if( fldValue != null ) {
				while (strParser.getPos() < fldPath.length)
					createXMLElementRecursePath(xmlDoc, fldNode, strParser);
				//Now store the field data there
				XPathAPI.setNodeValue(xmlDoc.firstChild, fldPath, mx.utils.XMLString.unescape( fldValue ));
			} // if not null field value
		}
	}
	
	
	private function createXMLElementFromXPath(xmlDoc:XML, xpath:String):XMLNode {
		var strParser:StringTokenParser = new StringTokenParser(xpath);
		var tokType:Number = strParser.nextToken();
		var tokVal:String = strParser.token;
		var newElement:XMLNode = xmlDoc.createElement(tokVal);
		while (strParser.getPos() < xpath.length)
			createXMLElementRecursePath(xmlDoc, newElement, strParser);
		return newElement;
	}
	
	
	private function createXMLNode(deltaObj:Delta):XMLNode {
		//Get the name of the new node to create
		var pathIndex:String = rowNodeKey;
		pathIndex = replacePathIndexParameters(pathIndex, deltaObj);
		var slashPos:Number = pathIndex.lastIndexOf("/");
		var rowPath:String = "";
		if (slashPos > -1)
			rowPath = pathIndex.substring(slashPos+1, pathIndex.length);

		var xmlDoc:XML = new XML();
		//Create the appended node from the xpath
		xmlDoc.appendChild(createXMLElementFromXPath(xmlDoc, rowPath)); 
		//Now add all of the attributes and child nodes containing values from the delta
		addNewNodeData(xmlDoc, deltaObj);

		return xmlDoc.firstChild;
	}
	
	
	private function createXMLElementRecursePath(xmlDoc:XML, contextNode:XMLNode, strParser:StringTokenParser):Number{
		var ctxNode:XMLNode = contextNode; //Protect the higher level context from getting changed
		var branchDone:Boolean = false;
		var tokType:Number = strParser.nextToken();
		while((!branchDone) && (tokType != StringTokenParser.tkEOF)){
			var tokVal:String = strParser.token;
			if (tokType == StringTokenParser.tkSymbol) {
				switch(tokVal.toUpperCase()){
					case "@":
						//Create a new attribute on ctxNode
						strParser.nextToken();
						var attrName:String = strParser.token;
						var attrVal:String = "";
						tokType = strParser.nextToken();
						if (strParser.token == "=") {
							tokType = strParser.nextToken(); //Move to the attribute value
							attrVal = strParser.token;
							tokType = null;
						}
						ctxNode.attributes[attrName] = attrVal;
					break;

					case "/":
						//Go recurse another level passing in the local ctxNode
						tokType = createXMLElementRecursePath(xmlDoc, ctxNode, strParser);
					break;

					case "[":
						//Go recurse another level passing in the *local* ctxNode
						while((tokType != StringTokenParser.tkEOF) && (tokVal != "]")){
							tokType = createXMLElementRecursePath(xmlDoc, ctxNode, strParser);
							tokVal = strParser.token;
						}
						//tokType = null;
						branchDone = true;
					break;

					case "]":
					case "AND":
					case "OR":
						//Got a symbol that signifies we won't be going further down this branch of the tree
						//so stop looping and head back to the previous level of recursion
						branchDone = true;
					break;

					default:
						//See if the child node already exists. It may already have been created by higher level predicates
						if (getChildNodeByName(ctxNode, tokVal) == null) {
							//Create a new child node on ctxNode
							var newChild:XMLNode = xmlDoc.createElement(tokVal);
							ctxNode.appendChild(newChild);
							ctxNode = newChild; //Make the new child the context
							//Now set the value for the node
							tokType = strParser.nextToken();
							if (strParser.token == "=") {
								tokType = strParser.nextToken(); //Move to the node value
								var nodeVal:XMLNode = xmlDoc.createTextNode(strParser.token);
								ctxNode.appendChild(nodeVal);
								tokType = null;
							}
						}
						else {
							//Make use of the existing child
							ctxNode = getChildNodeByName(ctxNode, tokVal);
							//Now set the value for the node
							tokType = strParser.nextToken();
							if (strParser.token == "=") {
								tokType = strParser.nextToken(); //Skip the node value (since it's already been set)
							}
						}
					break;
				}
			}
			else {
				trace("***ERROR:tokVal="+tokVal);
			}
			if (tokType == null) tokType = strParser.nextToken();
		}
		return tokType;
	}
	
	
	private function encodeFieldValue(fieldName:String, value:Object):String {
		var result:String = this.component.encodeFieldValue(fieldName, value);
		return result;
	}


	private function getChildNodeByName(node:XMLNode, nodeName:String):XMLNode {
		var result:XMLNode;
		var childNodes:Array = node.childNodes;
		for( var i:Number=0; i<childNodes.length; i++ ) {
			result = childNodes[i];
			if( result.nodeName == nodeName )
				return( result );
		} // for
		return( null );
	} //function getChildNodeByName
	
	
	private function getDelta(deltaObj:Delta, xpathInfo:Object):DeltaImpl {
		return new DeltaImpl(deltaObj.getId(), {deltaSource:deltaObj.getSource(), encoderInfo:xpathInfo}, deltaObj.getOperation(), deltaObj.getMessage(), false);
	}
	
	
	private function getNewDeltaList(dp:DeltaPacket):Array {
		var dpCursor:Iterator = dp.getIterator();
		var origDelta:Delta = null;
		var newDelta:Delta = null;
		var resultList:Array = new Array();

		while ( dpCursor.hasNext() ) {
			origDelta = Delta(dpCursor.next());
			Object(origDelta).deltaPacket = dp; //Add a pointer to the deltaPacket to the delta

			switch( origDelta.getOperation() ) {
				case DeltaPacketConsts.Removed:
					resultList.push(getDelta(origDelta, Object(getXPathToRow(origDelta))));
				break; //Added

				case DeltaPacketConsts.Added:
					resultList.push(getDelta(origDelta, Object({xpath:getXPathToParent(origDelta), node:createXMLNode(origDelta)})));
				break; //Removed
				
				case DeltaPacketConsts.Modified:
					var chgList:Array = origDelta.getChangeList();
					for(var i:Number = 0; i < chgList.length; i++) {
						//Go thru the list of deltaItems and create a new delta as parent to each
						newDelta = getDelta(origDelta, Object(getFullXPathToField(origDelta, DeltaItem(chgList[i]).name)));
						addDeltaItemToDelta(chgList[i], newDelta);
						resultList.push( Object( newDelta ));
					}
				break; //Modified
			} // switch
		} // while
		return resultList;
	} //getNewDeltaList
	
	
	private function getFullXPathToField(deltaObj:Delta, fieldName:String):String {
		var rowPath:String = getXPathToRow(deltaObj);
		var fldPath:String = getXPathToField(deltaObj, fieldName);
		return String(rowPath + fldPath);
	}
	
	
	private function getXPathToField(deltaObj:Delta, fieldName:String):String {
		var ds:Object = Object(deltaObj).deltaPacket.getSource();
		var fld:DataType = ds.getField(fieldName);

		var schema:Object = Object(deltaObj).deltaPacket.getConfigInfo();
		var fldSchema:Object = FieldAccessor.findElementType(schema.elements[0].type, fieldName);
		var fldPath:String;
		if (fldSchema.path != undefined) {
			fldPath = fldSchema.path;
			fldPath = fldPath.substring(fldPath.indexOf("/"), fldPath.length); //Yank off the initial row node name portion since we'll get that from elsewhere
		}
		else
			fldPath = "/" + (fldSchema.category == "attribute" ? "@" : "") + fieldName;
		return String(fldPath);
	}
	
	
	private function getXPathToParent(deltaObj:Delta):String {
		var xpath:String = getXPathToRow(deltaObj);
		var slashPos:Number = xpath.lastIndexOf("/");
		if ((slashPos > -1) && (xpath.charAt(slashPos-1) != "/"))
			xpath = xpath.substring(0, slashPos);
		return xpath;
	}
	
	
	private function getXPathToRow(deltaObj:Delta):String {
		//var pathIndex:String = String(Object(deltaObj).deltaPacket.getSource()[XPathInfo]);
		var pathIndex:String = rowNodeKey;
		pathIndex = replacePathIndexParameters(pathIndex, deltaObj);
		if (pathIndex.charAt(0) != "/") 
			pathIndex = "/" + pathIndex;
		return pathIndex;
	}
	
	
	private function replacePathIndexParameters(pathIndex:String, deltaObj:Delta):String {
		var resultStr:String = "";
		var parser:StringTokenParser = new StringTokenParser(pathIndex);
		var tokType:Number = parser.nextToken();
		while (tokType != StringTokenParser.tkEOF) {
			if (tokType == StringTokenParser.tkString){
				if (parser.token.charAt(0) == "?") {
					resultStr += "'" + getParamValue(parser.token.substring(1, parser.token.length), deltaObj) + "' ";
				}
				else {
					resultStr += "'" + parser.token + "' ";
				}
			}
			else {
				resultStr += parser.token;
				if ((parser.token.toUpperCase() == "AND") || (parser.token.toUpperCase() == "OR"))
				 	resultStr += " ";
			}
			tokType = parser.nextToken();
		}
		return resultStr;
	}
	
	
	private function getParamValue(param:String, deltaObj:Delta):String {
		var chgItem:DeltaItem = deltaObj.getItemByName(param);
		if (chgItem != null)
			return encodeFieldValue(param, chgItem.oldValue);
		else
			return encodeFieldValue(param, deltaObj.getSource()[param]); 
	}
}