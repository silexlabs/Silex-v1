/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import org.silex.adminApi.SilexAdminApi;
import org.silex.adminApi.util.T;

/**
 * This class lists an array of utility method to deal with SilexAdminApi 
 */
class org.silex.adminApi.Helper
{
	
	public function Helper() 
	{
		
	}
	
	/**
	 * returns all the currently displayed components name in
	 * an array
	 * 
	 * @param	filter filters the components by type. ex:org.silex.ui.UiBase
	 * @return the array of components proxy
	 */
	public function getAllComponents(filter:String):Array
	{
		var layouts:Array = SilexAdminApi.getInstance().layouts.getData()[0];
				var layers:Array = new Array();
				var components:Array = new Array();
				
				var i:Number;
				var j:Number;
				
				for (i = 0; i<layouts.length; i++)
				{
					var tempLayer:Array = SilexAdminApi.getInstance().layers.getData([(layouts[i]).uid])[0];
					for ( j= 0; j<tempLayer.length; j++)
					{
						layers.push(tempLayer[j]);
					}
				}
				
				//T.y(SilexAdminApi.getInstance().layouts.getData());
				for (i = 0; i < layers.length; i++)
				{
					var tempComponent:Array = SilexAdminApi.getInstance().components.getData([(layers[i]).uid])[0];
					for (j=0; j<tempComponent.length; j++)
					{
						components.push(tempComponent[j]);
					}
					
				}
				var res:Array = new Array();
				for (i=0; i<components.length; i++)
				{
					for (j=0; j<(components[i]).getComponent().typeArray.length; j++)
					{
						
						if ((components[i]).getComponent().typeArray[j] == filter)
						{
							res.push((components[i]).name);
						}
					}
					
					
				}
				
				
				
				return res;
	}
	
}