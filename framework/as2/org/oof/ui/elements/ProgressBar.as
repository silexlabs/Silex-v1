/*
This file is part of Oof - see http://projects.silexlabs.org/?/oof

Oof is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
import mx.utils.Delegate;
/** a progress bar.
 * @author not sure, Alex or Ariel. 
 * */
class org.oof.ui.elements.ProgressBar extends MovieClip
{
	var bar_mc:MovieClip;
	var _source;

	function ProgressBar ()
	{
	}
	
	function setProgress (completed:Number, Total:Number)
	{

		bar_mc._xscale = (completed / Total) * 100;
	}

	function startPreload ()
	{
		this.onEnterFrame = Delegate.create (this, preload);
	}
	function preload ()
	{
		var loaded = _source.getBytesLoaded ();
		var total = _source.getBytesTotal ();
		if (loaded != total)
		{
			setProgress (loaded,total);
		}
		else
		{
			delete bar_mc.onEnterFrame;
		}
	}
	function set source (val)
	{
		_source = val;
		startPreload ();
	}
	function get source ()
	{
		return _source;
	}
}