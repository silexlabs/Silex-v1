/*
   Title:       EndPoint.as
   Description: defines the class "mx.data.binding.EndPoint"
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc.
   Author:      Mark Shepherd
   Version:     1.0
*/


/**
	Defines the source or destination of a Binding. In other words
	this object defines a place from which you can get data, or a place to which you can 
	assign data. This can be either a constant value, or a certain field 
	of a certain property of a certain component.
	
	For examples, see the documentation for class "Binding".

  @class EndPoint
  @tiptext A description of one EndPoint of a Binding
  @helpid 1566
*/
class mx.data.binding.EndPoint
{
	// -----------------------------------------------------------------------------------------
	// 
	// Properties
	//
	// -----------------------------------------------------------------------------------------

	/**
	  A constant value. This field can only appear in EndPoints which are the source of a Binding.
	  It can be any datatype that is compatible with the destination of the Binding. The 
	  other EndPoint fields are ignored if 'constant' is specified.
  
	  @property constant
      @tiptext A constant data value (for source EndPoints only)
      @helpid 1567
	*/
	public var constant : Object;

	/**
	  A reference to a component instance. This is the component which contains the data.
  
	  @property component
	  @tiptext The component or object containing the data
	  @helpid 1568
	*/
	public var component : Object;

	/**
	  The name of a property of the component instance. This is the property which contains the data.
  
	  @property property
	  @tiptext Which property of the component holds the data
	  @helpid 1569
	*/
	public var property : String;

	/**
	  The location of a data field within the property of the component instance. There are 3 ways to 
	  specify a location:
	    
 	  <dl>
		<dt>"any-string"</dt><dd>the string is an XPath expression that represents a field, or an array of fields.
		XPath expressions may only be used when the data is an XML object.</dd>
		<dt>["string1", "string2", ...]</dt><dd>the strings represent a path into a nested object structure.
		Each string is a field name that drills down to the next level of nesting. This type of location can be applied
		to either XML or ActionScript data.</dd>
		<dt>{path: ["string1", "string2", ...], indices: [<endpoint>, <endpoint>, ...]}</dt>
		<dd>The path part is the same as above, except that 1 or more of the stringN may be
		the special token "[n]". For each occurence of this token in "path", there must be a corresponding
		index item in "indices". As the path is being evaluated, the indices are used to index into
		arrays. The index item can be any EndPoint. This type of location can be applied
		to ActionScript data only (not XML).</dd>
	  </dl>
	  <p>It is an error if the path does not correspond to the actual data structure: i.e. if the field
	  names cannot be found in the object, or if [n] is specified when the data is not an array.
	  <p>When the source or destination endpoint of a binding contains indices, the binding is re-executed
	  anytime any of the index endpoints signals a "changed" event. If you want this to happen, be sure
	  to include the "endpoint" property in your index endpoints.
	  @property location
	  @tiptext A path into the property that identifies a nested data field
	  @helpid 1570
	*/
	public var location : Object;

	/**
	  The name of an event that the component instance will emit when the data changes. This is
	  the event that a Binding will listen for, so it knows when to execute.
  
	  @property event
	  @tiptext The name of an event that the component emits when the data changes
	  @helpid 1571
	*/
	public var event : String;


}; // class mx.data.binding.EndPoint
