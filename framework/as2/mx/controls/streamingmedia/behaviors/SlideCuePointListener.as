//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.ICuePointHolder;
import mx.controls.streamingmedia.Tracer;
import mx.screens.Slide;

/**
 * This class is a listener for cuePoint events that will move the playhead
 * of the specified clip to a named frame with the same name as the cuePoint.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.behaviors.SlideCuePointListener
{
	private var _targetSlide:Slide;


	/**
	 * Create a listener on the specified cue point holder.
	 *
	 * @param holder The holder of cue points
	 * @param aTarget The intended target of the listener
	 */
	public static function initializeListener(holder:ICuePointHolder, aTarget:Slide)
	{
		if (aTarget == null)
		{
			// If no target is specified, assume the holder is a movie clip
			// and use the parent of the slide that contains it.
			var dad:Slide = Slide(MovieClip(holder)._parent);

			var curSlide:Slide = dad.currentSlide;
			aTarget = dad;
			Tracer.trace("Finding the target slide: holder=" + holder +
				", holder's parent=" + dad + ", curSlide=" + curSlide +
				", target=" + aTarget);
		}
		// Create the listener object
		var listener:SlideCuePointListener = new SlideCuePointListener(aTarget);
		// Have the listener listen for cuePoint events
		holder["addEventListener"]("cuePoint", listener);
	}

	/**
	 * Constructor.
	 *
	 * @param aTarget The clip which has the named frames corresponding to the
	 * cuePoint names.
	 * @param shouldStop If true, then gotoAndStop will be called; otherwise
	 * gotoAndPlay will.
	 */
	public function SlideCuePointListener(aTarget:Slide)
	{
		_targetSlide = aTarget;
	}

	/**
	 * Listen for cuePoint events and move the playhead to the frame
	 * with the same name as the cuePoint.
	 */
	public function handleEvent(ev:Object):Void
	{
		Tracer.trace("SlideCuePointListener.handleEvent: type=" + ev.type + ", target=" + ev.target);
		if (ev.type == "cuePoint")
		{
			Tracer.trace("cuePoint event! targetSlide=" + _targetSlide +
				" with " + _targetSlide.numChildSlides + " kids");

			var kid:Slide;
			for (var ix:Number = 0; ix < _targetSlide.numChildSlides; ix++)
			{
				kid = _targetSlide.getChildSlide(ix);
				Tracer.trace("child" + ix + "=" + kid + "=" + kid._name);
				if (kid._name == ev.cuePointName)
				{
					Tracer.trace("found the right slide: " + kid._name);
					_targetSlide.gotoSlide(kid);
					break;
				}
			}
		}
		else
		{
			Tracer.trace("Event other than cuePoint event. Ignore it.");
		}
	}

}
