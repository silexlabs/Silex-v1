/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/


/** this is the interface for content connectors
 * @author Ariel Sommeria-klein
 * */
interface org.oof.dataConnectors.IContentConnector{
	
	/** function getIndividualRecords. get all values for a form from the database
	*@param Number id. autoincremented id of the record in the database. stored for updateing
	* complete this in derived connector
	*@return void
	*/
	function getIndividualRecords(successCallback:Function, errorCallback:Function, formName:String, ids:Array);
	
	/** function getRecords. select data from a datasource
	*@return void
	*/
	function getRecords(successCallback:Function, errorCallback:Function, formName:String, selectedFieldNames:Array, whereClause:String, orderBy:String, count:Number, offset:Number);

	/** function updateRecord
	*@return void
	*/
	function updateRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object, idRecord:Number);
	
	/** function createRecord
	*@return void
	*/
	function createRecord(successCallback:Function, errorCallback:Function, formName:String, item:Object);

	/** function deleteRecord
	*@return void
	*/
	function deleteRecord(successCallback:Function, errorCallback:Function, formName:String, idRecord:Number);
	

	
	
	
}