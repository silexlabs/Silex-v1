/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/* 
*************************************************
    SILEX API 2004-2005
**************************************************
   Title:       Filter.as
   Description: filter SILEX accessors

   Copyright:   Copyright (c) 2004
   Author:      Alex. H. lex@silex.tv
   Version:     1
*/
/**
 * This class is used to filter SILEX accessors. It is a singleton pattern.
 */
//import org.silex.core.Utils;
class org.silex.core.Filter
{
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;
	/**
	 * Constructor.
	 * @param	api	reference to silex main Api object (org.silex.core.Api)
	 */
	function Filter(api:org.silex.core.Api) {
		// api reference
		silex_ptr=api;
		
	}
	/**
	 * test if a filter exists
	 * @param	filter_name_str
	 * @return
	 */
	function filterExist(filter_name_str:String,value_to_filter,parameters_array:Array,initial_source_mc:Object):Boolean 
	{
		silex_ptr.config.test="";
		
		if (this[filter_name_str] || initial_source_mc[filter_name_str] || value_to_filter[filter_name_str] || silex_ptr.interpreter[filter_name_str])
			return true;
		else
			return false;
	}
	/**
	 * Call the method corresponding to the desired filter.
	 * @param filter_name_str	name of the filter
	 * @param value_to_filter	value which has to be filtered
	 * @param parameters_array	optionnal parameters
	 * @param initial_source_mc	optionnal source object
	 * @return	null if an error occured or the filter value
	 */
    function exec(filter_name_str:String,value_to_filter,parameters_array:Array,initial_source_mc:Object)
    {
//    	return "exec("+filter_name_str+","+value_to_filter+","+parameters_array+","+initial_source_mc;
		// non optionnal value
		if (value_to_filter==undefined){
			// error: no value specified
            return null;
		}
		
		// non optionnal value
        if (filter_name_str==undefined || filter_name_str == "") {
			// error: no filter specified
            return null;
		}
		
		// parameters_array is optionnal
        if (parameters_array==undefined)
			parameters_array = new Array;
			
		// initial_source_mc is optionnal
        if (initial_source_mc==undefined)
			initial_source_mc = this;

		
		// call the method
		if (this[filter_name_str]!=undefined){
			// add the value_to_filter as the 1st argument
			parameters_array.unshift(value_to_filter);
			return this[filter_name_str].apply(this,parameters_array)
		}
		else if(initial_source_mc[filter_name_str]!=undefined)
		{
			// call the method on the source object
			return initial_source_mc[filter_name_str].apply(initial_source_mc,parameters_array)

		}
		else if(value_to_filter[filter_name_str]!=undefined)
		{
			// call the method on the source object
			return value_to_filter[filter_name_str].apply(value_to_filter,parameters_array)

		}
		else if(silex_ptr.interpreter[filter_name_str]!=undefined)
		{
			// call the method on the interpreter
			return silex_ptr.interpreter[filter_name_str].apply(initial_source_mc,parameters_array)
		}
		
		// error: filter does not exist
		return null;
    }

    /////////////////////////////////////////////////
    // FILTERS
	// in these methods, "this" is the source object
	// the 1st argument is the value to filter
    /////////////////////////////////////////////////
	/**
	 * URLencode the string
	 * @example		<<urlencode silex.rootUrl>> returns the urlencoded version of the url of the server
	 */
    function urlencode(value_to_filter:String):String {
		return escape(value_to_filter);
    }
	/**
	 * URLdecode the string
	 * @example		<<urldecode _root.xxx>> returns the urldecoded version of the parameter (passed through flash vars)
	 */
    function urldecode(value_to_filter:String):String {
		return unescape(value_to_filter);
    }
	/**
	 * double URLencode the string
	 * @example		<<urlencode silex.rootUrl>> returns the 2x urlencoded version of the url of the server
	 */
    function urlencode2(value_to_filter:String):String {
		return escape(escape(value_to_filter));
    }
	/**
	 * array listArrayKeys returns an array containing the keys of an associative array
	 * @example		<<listArrayKeys silex.config.siteConfTxt>> returns an array containing the keys of an associative array
	 */
    function listArrayKeys(value_to_filter:Array):Array {
	
		var keys_array:Array = new Array;
		
		for (var key in value_to_filter) {
			keys_array.push(key);
		}
	
		return keys_array;
    }
	/**
	 * array listArrayValues returns an array containing the values of an associative array
	 * @example		<<listArrayValues silex.config.siteConfTxt>> returns an array containing the values of an associative array
	 */
    function listArrayValues(value_to_filter:Array):Array {
	
		var values_array:Array = new Array;
	
		for (var key in value_to_filter) {
			values_array.push(value_to_filter[key]);	
		}
		
		return values_array;
    }
    /**
     * parse a string and convert it into a number
     */
    function string2number(value_to_filter:String):Number {
		return parseInt(value_to_filter);
    }
    /**
     * convert a number into a string
     */
    function number2string(value_to_filter:Number):String {
		return value_to_filter.toString();
    }
    /**
     * clean up an array, i.e. remove empty items, undefined or ""
     * @example 	the following actions, put on a component in Silex, will alert "1 - 0" because the dirty array is [""] and the clean array is []
     * onRelease silex.config.testString=     * onRelease silex.config.testArrayDirty=<<split:@ silex.config.testString>>     * onRelease silex.config.testArrayClean=<<cleanupArray silex.config.testArrayDirty>>     * onRelease alert: (( <<silex.config.testArrayDirty.length>> )) - (( <<silex.config.testArrayClean.length>> )) 
     * @return empty array if array is not defined, and an array without any empty element or "" in the elements
     */
    function cleanupArray(value_to_filter:Array):Array {
		// empty array if array is not defined
    	if (value_to_filter==undefined)
    		return new Array;
    		
    	var len:Number = value_to_filter.length;
    	var idx:Number;
    	// starts from the end because we may remove elements from the array
    	for(idx = len-1; idx >= 0; idx--)
    		if (value_to_filter[idx] == undefined || value_to_filter[idx] == "")
    			value_to_filter.splice(idx,1);
    	// return the clean array
		return value_to_filter;
    }
	/**
	 *  Calculate simple arithmetic operations +, -, *, /, % and interpretes orders of precedence defined by brackets ()
	 *  This function is recursive and takes in inputs the String containing the operation to perform.
	 *  @author Thomas Fétiveau (Żabojad) http://tofee.fr
	 *  @example
	 *  onLoad silex.my_operation=((<<SlideMenu_projekty._y>>))+(0+((<<SlideMenu_projekty.selectedIndex>>))+1)*((<<SlideMenu_projekty.rowHeight>>))
	 *  onLoad alert:<<calculate silex.my_operation>>
	 *  @return a Number corresponding to the calculation's result or NaN if the operation is not valid (wrong syntax)
	 */
	function calculate(operation:String):Number
	{
trace("calculate("+operation+")");
		// The operations in their order of precedence
		var operationsOrder:Array = new Array("/", "%", "*", "-", "+");
		
		// we search for the last opening bracket in the operation
		var lastOpenBracketIndex:Number = operation.lastIndexOf("(");
		
		// if found, it means we have brackets precedence to solve
		if(lastOpenBracketIndex != -1)
		{
			// we search for the first closing bracket in the operation, starting for the index of the last opening bracket
			var firstClosedBracketIndex:Number = operation.indexOf(")", lastOpenBracketIndex);
			
			// if we do not have a closing bracket, the operation is not valid
			if(firstClosedBracketIndex == -1)
				return NaN;
			
			// we isolate the intermediate operation and solve it
			var intermediateOperation:String = operation.substring(lastOpenBracketIndex+1,firstClosedBracketIndex);
trace("intermediateOperation: "+intermediateOperation);
			var intermediateOperationResult:Number = _performOrderedOperations(operationsOrder, intermediateOperation);
trace("intermediateOperationResult: "+intermediateOperationResult);
			
			// Rewrite operation including intermediateOperationResult
			operation = operation.substring(0,lastOpenBracketIndex) + intermediateOperationResult + operation.substring(firstClosedBracketIndex+1,operation.length);
			trace("New operation: "+operation);
			return calculate(operation);
		}
		
		// if not bracket found, we simply return the result of the operation
		var result:Number = _performOrderedOperations(operationsOrder, operation);
trace("return "+result);
		return result;
	}
	/**
	 * Recursive function used by the calculate filter.
	 * Performs simple arithmetic operations by respecting operation's order of precedence but not brackets.
	 */
	private function _performOrderedOperations(operationsOrder:Array, operation:String):Number
	{
// trace("performOrderedOperations(["+operationsOrder+"], "+operation+")");
		// we pop the last operator as it should be the next one to interprete according to the operator's order of precedence defined by the positions of the operationsOrder array
		var operator:Object = operationsOrder.pop();
		// we split the operation's string to get the operands
		var aPotentialOperationMembers:Array = operation.split(operator.toString());
// trace("current operation:"+operator+" on: ["+aPotentialOperationMembers+"]   next operations: "+operationsOrder);
		for (var aPotentialOperationMembersIndex in aPotentialOperationMembers)
		{
			// for each operand found, we solve all the remaining operations it could contain
			if(operationsOrder.length > 0)
				aPotentialOperationMembers[aPotentialOperationMembersIndex] = _performOrderedOperations(operationsOrder, aPotentialOperationMembers[aPotentialOperationMembersIndex]);
		}
		// once our operands or Numbers, we perform our operation
		var result:Number = _solveOperation(operator.toString(), aPotentialOperationMembers);
		// trace("operation "+operator+" returned "+result);
		return result;
	}
	/**
	 * Solve elementary arithmetic operations.
	 * This function is used by the calculate filter.
	 */
	private function _solveOperation(operationType:String, members:Array):Number
	{
// trace("solveOperation("+operationType+", ["+members+"])");
		// the first operand goes directly to the result
		var result:Number = parseFloat(members[0]);
		
		// if the parsedFloat result is a Number, we perform the operation
		if(result != NaN)
		{
			var i:Number;
			for (i = 1; i < members.length; i++)
			{
				var revealedMember = parseFloat(members[i]);
				if(revealedMember != NaN)
				{
					// here we perform the operation
					switch (operationType)
					{
						case "+" :
							result += revealedMember;
							break;
						case "-" :
							result -= revealedMember;
							break;
						case "*" :
							result *= revealedMember;
							break;
						case "%" :
							result %= revealedMember;
							break;
						case "/" :
							result /= revealedMember;
							break;
						default :
							break;
					}
			
				} else {
// trace("return NaN");
					return NaN;
				}
			}
		}
// trace("return "+result);
		return result;
	}
}