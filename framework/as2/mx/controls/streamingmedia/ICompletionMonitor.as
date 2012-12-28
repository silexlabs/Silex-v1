/**
 * This interface defines how one interacts with a progress bar that tracks
 * progress from 0 to 100 percent.
 *
 * @author Andrew Guldman
 */
interface mx.controls.streamingmedia.ICompletionMonitor
{
	function getCompletionPercentage():Number;
	function setCompletionPercentage(aPercentage:Number):Void;
}
