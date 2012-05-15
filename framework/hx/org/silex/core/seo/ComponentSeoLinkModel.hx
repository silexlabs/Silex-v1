/*This file is part of Silex - see http://projects.silexlabs.org/?/silex
Silex is © 2010-2011 Silex Labs and is released under the GPL License:
This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/

/**
 * Typedef to anonymous type used to store all components of a specific layer & deeplink. Accessors should be kept as is.
 * 
 * @author	Raphael Harmel
 * @version 1.0
 * @date   2011-05-25
 */

package org.silex.core.seo;

typedef ComponentSeoLinkModel =
{
	// link title which can be html formatted
	public var title:String;
	// link corresponds to layer's name
	public var link:String;
	// link deeplink
	public var deeplink:String;
	// link description which is copied from icon component's description or from list description (in case it is a dataselector)
	public var description:String;
}
