//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.Tracer;
import mx.screens.Screen;

/**
 * ScreenAccommodator manages a Media component inside a screen.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.ScreenAccommodator
{
	/**
	 * The Media Component that might be contained in a screen
	 */
	private var containee:MovieClip;
	/**
	 * The screen that holds the media component
	 */
	private var container:Screen;
	/**
	 * True if it was already disabled before the screen was hidden
	 */
	private var wasAlreadyDisabled:Boolean;

	private var initId:Number;

	/** Has it been initialized yet? */
	private var beforeInit:Boolean;

	/**
	 * What action should be performed at initialization? hide, reveal, or nothing
	 */
	private var initAction:String = "nothing";

	/**
	 * Constructor
	 */
	public function ScreenAccommodator(aContainee:MovieClip)
	{
		containee = aContainee;
		container = getContainingScreen();
		if (container != null)
		{
			// This is inside a screen
			var isEnabled:Boolean = container.visible;

			// Listen to the screen to know when it is hidden or revealed
			beforeInit = false;
			container.addEventListener("hide", this);
			container.addEventListener("reveal", this);
			if (!isEnabled)
			{
				beforeInit = true;
				initId = setInterval(this, "disableContainee", 50);
			}
		}
	}

	/**
	 * Disable the containee, unless a "reveal" event has fired before this 
	 * runs.
	 */
	public function disableContainee():Void
	{
		if ( (initAction == "nothing") || (initAction == "hide") )
		{
			Tracer.trace("ScreenAccommodator.disableContainee: disabling " + containee);
			containee.enabled = false;
		}
		clearInterval(initId);
		beforeInit = false;
	}

	/**
	 * @return The first containing screen of this component.
	 */
	private function getContainingScreen():Screen
	{
		var scr:Screen = null;
		var cur:MovieClip = this.containee._parent;
		while ( (scr == null) && (cur != _root) )
		{
			if (cur instanceof Screen)
			{
				scr = Screen(cur);
			}
			else
			{
				cur = cur._parent;
			}
		}
		return scr;
	}

	/**
	 * Handle events received from the screen
	 */
	public function handleEvent(ev:Object):Void
	{
		Tracer.trace("ScreenAccommodator.handleEvent: " + ev.type + " for " + containee);
		if (ev.type == "hide")
		{
			if (beforeInit)
			{
				initAction = "hide";
			}
			else
			{
				// The containing screen was hidden
				if (containee.enabled)
				{
					wasAlreadyDisabled = false;
					containee.enabled = false;
				}
				else
				{
					wasAlreadyDisabled = true;
				}
			}
		}
		else if (ev.type == "reveal")
		{
			if (beforeInit)
			{
				initAction = "reveal";
			}
			else
			{
				// The containing screen was revealed
				if (!wasAlreadyDisabled && containee.visible)
				{
					containee.enabled = true;
				}
			}
		}
	}

}
