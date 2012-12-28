/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
/**
 * This class is used to store all silex constants default values which may be overriden by getDynData function or by values passed to FLash in index.php with SetVariable.
 * Use _global.getSilex().config to access these constants.
 * In the repository : /trunk/core/TranslatableConstants.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2008-04-14
 * @mail : lex@silex.tv
 */
class org.silex.core.TranslatableConstants {

	// Dates
	/////////////////////////////////////////////////
	// Group: months translations
	/////////////////////////////////////////////////
	var DATE_JANUARY:String="January";
	var DATE_FEBRUARY:String="February";
	var DATE_MARCH:String="March";
	var DATE_APRIL:String="April";
	var DATE_MAY:String="May";
	var DATE_JUNE:String="June";
	var DATE_JULY:String="July";
	var DATE_AUGUST:String="August";
	var DATE_SEPTEMBER:String="September";
	var DATE_OCTOBER:String="October";
	var DATE_NOVEMBER:String="November";
	var DATE_DECEMBER:String = "December";
	
	/////////////////////////////////////////////////
	// Group: days translations
	/////////////////////////////////////////////////
	var DATE_SUNDAY:String="Sunday";
	var DATE_MONDAY:String="Monday";
	var DATE_TUESDAY:String="Tuesday";
	var DATE_WEDNESDAY:String="Wednesday";
	var DATE_THURSDAY:String="Thursday";
	var DATE_FRIDAY:String="Friday";
	var DATE_SATURDAY:String="Saturday";
}