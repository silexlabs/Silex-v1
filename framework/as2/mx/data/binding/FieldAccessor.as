/*
   Title:       FieldAccessor.as
   Description: defines the class "mx.data.binding.FieldAccessor"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/

/**
	An object that gives access to a specific field of a data structure.
	
  @class FieldAccessor
*/
class mx.data.binding.FieldAccessor
{
	// -----------------------------------------------------------------------------------------
	// 
	// Published Functions
	//
	// -----------------------------------------------------------------------------------------

	/**
	  Fetches the current data value of the field.  
  
	  @method	getValue
	*/
	public function getValue() : Object
	{
		//Debug.trace("mx.data.binding.FieldAccessor.getvalue enter");
		var obj = this.getFieldData();
		
		// use the default value if we don't have one
		if(( obj == null ) && ( this.type.value != undefined )) {
			// The default value is stored as a string, but we want to convert it
			// to the appropriate native type. We do this by just setting the 
			// string value into the field, and then grabbing the result of that.
			// We set "getDefault" to true to indicate that we don't really want
			// to set the value, we just want to fetch the value that would have been set. 
			var typedValue:mx.data.binding.TypedValue = new mx.data.binding.TypedValue( this.type.value, "String" );
			typedValue.getDefault = true;
			this.component.getField( this.fieldName ).setAnyTypedValue( typedValue );
			obj = typedValue.value;
		}
		//Debug.trace("mx.data.binding.FieldAccessor.getvalue", obj);
		if (isXML(obj) && (obj.childNodes.length == 1) && (obj.firstChild.nodeType == 3))
		{
			// do an extra dereference if we have a child node which is text.
			return obj.firstChild.nodeValue;
		}
		else
		{
			//Debug.trace("mx.data.binding.FieldAccessor.getValue ", obj);
			return obj;
		}
	}
	
	/**
		Sets the field to contain a new data value.  
  
	  @method	setValue
	*/
	public function setValue(newValue : Object, newTypedValue: mx.data.binding.TypedValue)
	{			
		// default the value if we don't have one
		if( newTypedValue.getDefault ) 
			newTypedValue.value= newValue;
		else {
			//Debug.trace("mx.data.binding.FieldAccessor.setValue", this.component, this.property, newTypedValue.type);
			if (this.xpath != null)
			{
				var obj = this.getFieldData();
				if (obj != null)
				{
					mx.data.binding.FieldAccessor.setXMLData(obj, newValue);
				}
				else
				{
					_global.__dataLogger.logData(this.component, 
						"Can't assign to '<property>:<xpath>' because there is no element at the given path", this);
				}
			}
			else if (isXML(this.parentObj))
			{
				if (this.type.category == "attribute")
				{		
					this.parentObj.attributes[this.fieldName] = newValue;
				}
				else if (this.type.category == "array")
				{
					// !!@ do something !!
				}
				else 
				{
					var obj = this.getOrCreateFieldData();
					mx.data.binding.FieldAccessor.setXMLData(obj, newValue);
				}
			}
			else
			{
				//var oldValue = this.getFieldData();
				//if ((typeof(oldValue) == typeof(newValue)) && 
				//	(typeof(oldValue) == "object"))
				//{
				//	for (var i in newValue)
				//	{
				//		//trace("OLD: " + oldValue[i] + ", NEW: " + newValue[i]);
				//		oldValue[i] = newValue[i];
				//	}
				//}
				//else
				{
					if (this.parentObj == null)
					{
						_global.__dataLogger.logData(this.component, 
							"Can't set field '<property>/<location>' because the field doesn't exist", this);
					}
					
					this.parentObj[this.fieldName] = newValue;
				}
			}
			this.component.propertyModified(this.property, (this.xpath == null) && (this.parentObj == this.component), newTypedValue.type );
			
			//trace("SetValue(" + this.component + "," + this.property + "," + this.m_location + "). " + 
			//	mx.data.binding.ObjectDumper.toString(this.component[this.property]));
		} // if not defaulting
	}

	static function isActionScriptPath(str: String) : Boolean
	{
		// This must match the pattern \w+(\.\w+)*
		// for example "foo", "foo.bar22", "foo.bar.abc_def"
		
		// The following code matches the more general pattern (\w|\.)*
		// which is close enough.(I hope).
		var s : String = str.toLowerCase();
		var okChars : String = "0123456789abcdefghijklmnopqrstuvwxyz_.";
		for (var i = 0; i < s.length; i++)
		{
			if (-1 == okChars.indexOf(s.charAt(i)))
			{
				return false;
			}
		}
		
		return true;
	}
	
	/**
	  Creates a FieldAccessor object.  
  
	  @method	createFieldAccessor
	  @param	component		which component contains the data field you want to access
	  @param	property		which property of the component contains the data
	  @param	location		[optional] the location within the data structure of the field.
								If omitted, you get an accessor for the entire data of the 
								component property. If the component property contains XML data,
								the location may be either an XPath (as a string), or a generic
								path (as an Array of strings). If the component property contains
								ActionScript data, the location can only be a generic path.
      @param	type			[optional] a DataSchema object for the component property
      @param	mustExist		[optional] if this boolean is true, then we generate warning messages to the log
								if the field does not exist, or is null
      @return					a FieldAccessor object
	*/
	public static function createFieldAccessor(component : Object, 
		property : String, location : Object, type : Object, mustExist : Boolean) : mx.data.binding.FieldAccessor
	{
		//trace("FieldAccessor.createFieldAccessor() - " + component + ", " + property + ", " + location);
		if (mustExist && (component[property] == null))
		{
			_global.__dataLogger.logData(component, 
				"Warning: property '<property>' does not exist",
				{property: property});
			return null;
		}
		
		var field = new mx.data.binding.FieldAccessor(component, property, component, property, type, null, null);
	
		if (location == null)
		{
			return field;
		}
		
		var indices : Object = null;
		if (location.indices != null)
		{
			indices = location.indices;
			location = location.path; 
		}
		
		if (typeof(location) == "string")
		{
			if (indices != null)
			{
				_global.__dataLogger.logData(component, 
					"Warning: ignoring index values for property '<property>', path '<location>'", 
					{property: property, location: location});
			}
			if (isActionScriptPath(String(location)))
			{
				// this is a Actionscript path,
				// turn it into an array
				location = location.split(".");
			}
			else
			{
				// this is an XPath
				field.xpath = location;
				return field;
			}
		}
		//Debug.trace("FieldAccessor.createFieldAccessor", component, property, location);
		if (location instanceof Array)
		{
			// it's an Actionscript path

			//trace("TOKENS: " + tokens.length + "," + tokens);
			var i : Number;
			var indexNum : Number = 0;
			for (i = 0; i < location.length; i ++)
			{	
				var index = null;
				var childName = location[i];
				if (childName == "[n]")
				{
					if (indices == null)
					{
						_global.__dataLogger.logData(component, 
							"Error: indices for <property>:<location> are null, but [n] appears in the location.",
							{property: property, location: location});
							
						return null;
					}
					index = indices[indexNum++];
					if (index == null)
					{
						_global.__dataLogger.logData(component, 
							"Error: not enough index values for <property>:<location>",
							{property: property, location: location});
							
						return null;
					}
				}

				field = field.getChild(childName, index, mustExist); // !!@ should use goToChild
			}
			if (mustExist && (field.getValue() == null))
			{
				_global.__dataLogger.logData(component, 
					"Warning: field <property>:<m_location> does not exist, or is null", field);
			}
			
			//Debug.trace("CFA", String(field.component), field.property, 
			//	field.fieldName, field.m_location, field.type, field.index);
			return field;			
		}
		else
		{
			// !!@ error
			trace("unrecognized location: " + mx.data.binding.ObjectDumper.toString(location));
			return null;
		}
	}
		
	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Functions
	//
	// -----------------------------------------------------------------------------------------

	function getFieldAccessor()
	{
		return this;
	}
	
	public function FieldAccessor(component, property, parentObj, fieldName, type, index, parentField)
	{
		//Debug.trace("new FieldAccessor:", component, property, parentObj, fieldName, type, index, parentField);
		//trace("FieldAccessor.FieldAccessor() - " + component + ", " + property + ", " + 
		//	parentObj + "," + fieldName + "," + 
		//	mx.data.binding.ObjectDumper.toString(type));
		
		this.component = component;
		this.property = property;
		this.parentObj = parentObj;
		this.fieldName = fieldName;
		if (component == parentObj)
			this.m_location = undefined;
		else if (parentField.m_location == undefined)
			this.m_location = fieldName;
		else
			this.m_location = parentField.m_location + "." + fieldName;
			
		//trace("FieldAccessor constructor() - " + component + ", " + property + ", " + 
		//	mx.data.binding.ObjectDumper.toString(parentObj) + "," + fieldName + "," + this.m_location);
		
		this.type = type;
		this.index = index;

		//trace("xx:" + mx.data.binding.ObjectDumper.toString(parentObj));
		//trace("FieldAccessor.FieldAccessor(" + component + ", " + property + ", " + 
		//		parentObj + "," + fieldName + "," + this.m_location + ")");
	}
		
	private function getChild (childName: String, index, mustExist: Boolean)
	{
		//trace("FieldAccessor.getChild() - " + childName + ", " + this.parentObj + ", " + this.fieldName);

		if (childName == ".") return this;
		var obj = this.getOrCreateFieldData(mustExist);
		if (obj == null) return null;
		var childType = mx.data.binding.FieldAccessor.findElementType(this.type, childName);
		return new mx.data.binding.FieldAccessor (this.component, this.property, obj, childName, childType, index, this);
	}
	
	// same as getChild but doesn't create a new object
	/*
	private function goToChild (childName: String, index, mustExist: Boolean)
	{
		if (childName == ".") return this;
		var obj = this.getOrCreateFieldData(mustExist);
		if (obj == null) return null;
		var childType = mx.data.binding.FieldAccessor.findElementType(this.type, childName);
		//return new mx.data.binding.FieldAccessor (this.component, this.property, obj, childName, childType, index, this);

		this.parentObj = obj;
		this.fieldName = childName;
		if (component == parentObj)
			this.m_location = undefined;
		else if (this.m_location == undefined)
			this.m_location = fieldName;
		else
			this.m_location = this.m_location + "." + fieldName;
		
		this.type = childType;
		this.index = index;
	}
	*/
	
	private function getOrCreateFieldData(mustExist: Boolean) : Object
	{
		var obj = this.getFieldData();
		
		if (obj == null)
		{
			if (mustExist)
			{
				_global.__dataLogger.logData(this.component, 
					"Warning: field <property>:<m_location> does not exist", this); 
			}
			else
			{
				setupComplexField();
				obj = this.getFieldData();
			}
		}
		return obj;
	}
	
	private function evaluateSubPath(obj, type)
	{
		var path: String = type.path;
		//Debug.trace("<<<< evaluateSubPath", path);
		
		if (isActionScriptPath(path))
		{
			//Debug.trace(1);
			var tokens: Array = path.split(".");
			for (var i : Number = 0; i < tokens.length; i++)
			{
				var token = tokens[i];
				if (isXML(obj))
				{
					//Debug.trace(2, token);
					// note -- you can't use AS paths to extract arrays or attributes from XML data, only complex and simple
					obj = obj.firstChild;
					while (obj != null)
					{
						if (toLocalName(obj.nodeName) == token) break;
						obj = obj.nextSibling;
					}
				}
				else // it's an actionscript obj
				{
					//Debug.trace(3, obj,	this.property, this.m_location, path, token);
					obj = obj[token];
				}
				
				if (obj == null)
				{
					_global.__dataLogger.logData(this.component, 
						"Warning: path '<path>' evaluates to null, at '<token>' in <t.property>:<t.m_location>", 
						{path: path, token: token, t: this});
					break;
				}
			}
		}
		else // it's an Xpath
		{
			if (isXML(obj))
			{
				if (path.charAt(0) != "/") path = "/" + path;
				if (obj.nodeName == null)
					obj = obj.firstChild;
				else
					path = toLocalName(obj.nodeName) + path;

				var category : String = (type.category != null) 
					? type.category 
					: ((type.elements.length > 0) ? "complex" : "simple");
				//Debug.trace(4, path, category);
				if ((category == "simple") || (category == "attribute"))
				{
					obj = eval("obj" + mx.xpath.XPathAPI.getEvalString(obj, path));
					//Debug.trace("obj.childNodes.0.attributes.foo=", obj.childNodes[0].attributes.foo);
					//var xxx = "obj.childNodes.0.attributes.foo";
					//Debug.trace("eval(" + xxx + ")=", eval(xxx));
					//Debug.trace(5, s, path, obj);
					//Debug.trace(5.5, obj);
				}
				else if (category == "complex")
				{
					//Debug.trace(6);
					obj = mx.xpath.XPathAPI.selectSingleNode(obj, path);
				}
				else if (category == "array")
				{
					//Debug.trace(7);
					obj = mx.xpath.XPathAPI.selectNodeList(obj, path);
				}
				else
				{
					//Debug.trace(8);
					// hmmmm...
				}
			}
			else // it's an actionscript obj
			{
				_global.__dataLogger.logData(this.component, 
					"Error: path '<path>' is an XPath. It cannot be applied to non-XML data <t.property>:<t.m_location>", 
					{path: path, t: this});
			}
		}
		
		//Debug.trace("evaluateSubPath >>>>", path, obj)
		return obj;
	}
	
	private function getFieldData() : Object
	{
		//trace("getFieldData 001");
		if (this.xpath != null)
		{
			//trace("getFieldData 001a");
			var xmlnode = this.parentObj[this.fieldName].firstChild;
			while ((xmlnode != null) && (xmlnode.nodeType != 1)) xmlnode = xmlnode.nextSibling;
			var xpathResult = mx.xpath.XPathAPI.selectSingleNode(xmlnode, this.xpath);
			
			// !!@ need to handle arrays
			
			//_global.__dataLogger.logData(this.component, 
			//	"'<fa.property>' XPath '<fa.xpath>' evaluates to '<xpathResult>'",
			//	{fa: this, xpathResult: xpathResult});

			return xpathResult;
		}
		else if (isXML(this.parentObj))
		{			
			if (this.type.path != null)
			{
				//Debug.trace("getFieldData", this.property, this.m_location, "this.type.path=", this.type.path);
				return evaluateSubPath(this.parentObj, this.type);
			}
			
			//trace("getFieldData 001b");
			if (this.type.category == "attribute")
			{
				//return this.parentObj.attributes[this.fieldName];
				var attrs = this.parentObj.attributes;
				for (var i in attrs)
				{
					if (toLocalName(i) == this.fieldName)
						return attrs[i];
				}
				return undefined;
			}
			else
			{
				var child = this.parentObj.firstChild;
				if (this.type.category == "array") 
				{
					var arrayValue = new Array();
					while (child != null)
					{
						if (toLocalName(child.nodeName) == this.fieldName)
						{
							arrayValue.push(child);
						}
						child = child.nextSibling;
					}
					return arrayValue;
				}
				else
				{
					while (child != null)
					{
						if (toLocalName(child.nodeName) == this.fieldName)
						{
							//trace("returning ---- " + mx.data.binding.ObjectDumper.toString(child));
							return child;
						}
						child = child.nextSibling;
					}
				}
				return null;
			}
		}
		else
		{
			//trace("getFieldData 001c");
			//trace("RETURNING: " + mx.data.binding.ObjectDumper.toString(this.parentObj[this.fieldName]));
			if (this.fieldName == "[n]")
			{
				var rawIndex;
				if (this.index.component != null)
				{
					var indexAccessor : mx.data.binding.DataAccessor = this.index.component.getField(this.index.property, this.index.location); /* mustexist true*/
					rawIndex = indexAccessor.getAnyTypedValue(["Number"]);
					//Debug.trace("rawIndex", rawIndex);
					rawIndex = rawIndex.value;
				}
				else
				{
					rawIndex = this.index.constant;
				}
				var index: Number = Number(rawIndex); 
				if (typeof(rawIndex) == "undefined")
				{
					// no index value was given
					_global.__dataLogger.logData(this.component, 
						"Error: index specification '<index>' was not supplied, or incorrect, for <t.property>:<t.m_location>", 
						{index: index, t: this});
					return null;
				}
				else if (index.toString() == "NaN")
				{
					// the index value is "Not a Number"
					_global.__dataLogger.logData(this.component, 
						"Error: index value '<index>' for <t.property>:<t.m_location> is not a number", 
						{index: index, t: this});
					return null;
				}
				else if (!(this.parentObj instanceof Array))
				{
					_global.__dataLogger.logData(this.component, 
						"Error: indexed field <property>:<m_location> is not an array", this);
					return null;
				}
				else if ((index < 0) || (index >= this.parentObj.length))
				{
					_global.__dataLogger.logData(this.component, 
						"Error: index '<index>' for <t.property>:<t.m_location> is out of bounds", 
						{index: index, t: this});
					return null;
				}
				else
				{
					_global.__dataLogger.logData(this.component, 
						"Accessing item [<index>] of <t.property>:<t.m_location>", 
						{index: index, t: this});
					return this.parentObj[index];
				}
			}
			else
			{
				if (this.type.path != null)
				{
					return evaluateSubPath(this.parentObj, this.type);
				}
				//trace("getFieldData 002");
				return this.parentObj[this.fieldName];
			}
		}
	}

	private static function setXMLData(obj, newValue)
	{
		while (obj.hasChildNodes())
		{
			obj.firstChild.removeNode();
		}
		// !!@ should handle objects and arrays !!
		var newTextNode = xmlNodeFactory.createTextNode(newValue);
		obj.appendChild(newTextNode);
	}
	
	private function setupComplexField()
	{
		var newObject;
		
		if (isXML(this.parentObj))
		{
			newObject = xmlNodeFactory.createElement(this.fieldName);
			//trace("xmlNodeFactory.createElement: " + newObject);
			this.parentObj.appendChild(newObject);
		}
		else
		{
			if (dataIsXML())
			{
				this.parentObj[this.fieldName] = new XML();
			}
			else
			{
				this.parentObj[this.fieldName] = new Object();
			}
		}
	}
	
	public static function findElementType (type, name)
	{
		//Debug.trace("findElementType", type, name);
		for (var i = 0; i < type.elements.length; i++)
		{
			if (type.elements[i].name == name) return type.elements[i].type;
		}
		return null;
	}
	
	private function isXML (obj)
	{
		return (obj instanceof XMLNode);
	}
	
	private function dataIsXML() : Boolean
	{
		return this.type.name == "XML";
	}

	private static function accessField (component, fieldName, desiredTypes)
	{
		var desiredType;
		desiredType = desiredTypes[fieldName];
		if (desiredType == null) desiredType = desiredTypes.dflt;
		if (desiredType == null) desiredType = desiredTypes;
		// if it's still null, that's ok		
 
		var field = component.createField("data", [fieldName]);
		//Debug.trace("<<<<<<< accessField", fieldName, desiredTypes);
		//Debug.trace("field instanceof mx.data.binding.DataType",  field instanceof mx.data.binding.DataType);
		var value = field.getAnyTypedValue([desiredType]);
		//Debug.trace("accessField >>>>>", desiredType, fieldName, value);
		return value.value;
	}

	public static function ExpandRecord(obj, objectType, desiredTypes)
	{
		//Debug.trace("ExpandRecord", obj, objectType, desiredTypes);
		//Debug.trace("ExpandRecord", objectType);
		var component = new Object();
		mx.data.binding.ComponentMixins.initComponent(component);
		//component.findSchema = mx.data.binding.ComponentMixins.prototype.findSchema;
		//component.createField = mx.data.binding.ComponentMixins.prototype.createField;	
		//component.createFieldAccessor = mx.data.binding.ComponentMixins.prototype.createFieldAccessor;	
		component.data = obj;
		component.__schema = {elements: [{name: "data", type: objectType}]};
		var result = new Object();

		if (objectType.elements.length > 0)
		{
			for (var i = 0; i < objectType.elements.length; i ++)
			{
				var fieldName = objectType.elements[i].name;
				result[fieldName] = accessField (component, fieldName, desiredTypes);
			}	
		}
		else if ((obj instanceof XML) || (obj instanceof XMLNode))
		{
			if ((obj.childNodes.length == 1) && (obj.firstChild.nodeType == 3))
			{
				// this is simply a text string
				return obj.firstChild.nodeValue;
			}

			//trace("=======");
			// gather up all the elements...
			var field = obj.lastChild;
			while (field != null)
			{			
				var fieldName : String = toLocalName(field.nodeName);
				if ((fieldName != null) && (result[fieldName] == null))
				{
					result[fieldName] = accessField (component, fieldName, desiredTypes);
					//trace("***" + fieldName);
				}
				field = field.previousSibling;
			}
		
			// gather up all the attributes (these will override the value of any elements with the same name)
			for (var fieldName in obj.attributes)
			{
				if (result[fieldName] != null)
				{
					_global.__dataLogger.logData(null, 
						"Warning: attribute '<name>' has same name as an element, in XML object <obj>", 
						{name: fieldName, obj: obj});
				}
				result[fieldName] = accessField (component, fieldName, desiredTypes);
				//trace("***" + fieldName);
			}
		}
		else // it's not an xml node
		{
			if (typeof(obj) != "object") return obj;
		
			for (var fieldName in obj)
			{
				result[fieldName] = accessField (component, fieldName, desiredTypes);
			}	
		}
		
		return result;
	}

	public static function wrapArray(theArray, itemType, desiredTypes)
	{
		//Debug.trace("wrapArray", desiredTypes);
		//if (theArray[0] instanceof XMLNode)
		{
			//trace("wrapArray YES");
			// this appears to be an array of xml objects
			// make a read-only dataprovider for the array of data ...
			var dp = 
			{
				getItemAt: function(index : Number)
				{
					if ((index < 0) || (index >= this.data.length))
						return undefined;
					var xmlnode = this.data[index];
					if (xmlnode == undefined)
						return undefined;
					var result = mx.data.binding.FieldAccessor.ExpandRecord(xmlnode, this.type, desiredTypes);
					//var result = mx.data.binding.FieldAccessor.XMLObjectToASObject(xmlnode, this.type);
					//Debug.trace("GETITEMAT: ", index, this.data.length, xmlnode, result);
					return result;
				},
				getItemID: function (index : Number) : Number
				{
					return index;
				},
				data : theArray,
				type : itemType,
				length : theArray.length
			};
			return dp;
		}
		/*
		else
		{
			//trace("wrapArray NO");
			// it's already an array of AS object, no conversion required
			return theArray;
		}
		*/
	}

	static function toLocalName(nodeName)
	{
		var tokens = nodeName.split(":");
		var localName = tokens[tokens.length - 1];
		//trace(nodeName + "-->" + localName);
		return localName;
	}
	
	// -----------------------------------------------------------------------------------------
	// 
	// non-Published Properties
	//
	// -----------------------------------------------------------------------------------------

	private static var xmlNodeFactory : XML = new XML();	

	private var parentObj;
	private var fieldName;
	private var component;
	private var property;
	private var m_location;
	private var type;
	private var xpath;
	private var index;

} // class mx.data.binding.FieldAccessor
