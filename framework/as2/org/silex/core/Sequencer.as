/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
// imports
import mx.core.UIObject;
import mx.events.EventDispatcher;
import org.silex.core.Utils;

//////////////////////////////
// Group: events
/////////////////////////////
[Event("stop")]
[Event("play")]
[Event("pause")]
[Event("start")]
[Event("end")]
[Event("change")]
[Event("onEnterFrame")] // onEnterFrame: to be used by all classes (no need to overide MovieClip class)

/**
 * Sequencer class is a sequencer for SILEX sequences. Each sequence starts when the previous one has ended.
 * At the end of a sequence, the corresponding callback function is called and the next sequence starts.
 * If an item was added to the sequencer with no sequence specifyed, the callback is called immediately after start and the next sequence starts.
 * in the repository : /trunk/core/Sequencer.as
 * @author	Alexandre Hoyau
 * @version	1
 * @date	2007-10-16
 * @mail : lex@silex.tv
 */
class org.silex.core.Sequencer extends UIObject {
	/**
	 * Reference to silex main Api object (org.silex.core.Api).
	 */
	private var silex_ptr:org.silex.core.Api;

	/**
	 * Number of elements in elements_array + the _currentItem if any.
	 * Read only.
	 */
	function get length():Number {
		// variable to store the result
		var res:Number=0;
		
		// items in the array
		if (elements_array)
			res = elements_array.length;
		
		// the current item
		if (_currentItem!=null)
			res++;
		
		// return result
		return res;
	}
	/**
	 * Item representing the sequence being played.
	 * Has target, callback and autoEndDetection attributes.
	 * Read only.
	 */
	private var _currentItem:Object;
	function get currentItem():Object {
		return _currentItem;
	}

	/**
	 * State of the sequencer.
	 * State values are defined in silex_ptr.config class:
	 * - SEQUENCER_STATE_PLAY
	 * - SEQUENCER_STATE_PAUSE
	 * - SEQUENCER_STATE_STOP
	 * @see	org.silex.core.Constants
	 */
	var state:String;

	/**
	 * Stores the sequences and callbacks. elements_array is made of objects with these properties:
	 * - target:MovieClip, the sequence
	 * - callback:Function, the callback function
	 * - autoEndDetection:Boolean, automatically detect the end of the sequence (last frame of target is reached)
	 */
	var elements_array:Array;
	
	/**
	 * stores the current frame number of the Flash movie
	 */
	var currentFrame:Number = 0;
	
	/**
	 * Store the actions to be done on next frame.
	 */
	var doInNextFrames_array:Array;

	/** 
	 * Constructor.
	 */
	function Sequencer(api:org.silex.core.Api) {
		// api reference
		silex_ptr=api;

		state=silex_ptr.config.SEQUENCER_STATE_STOP;

		EventDispatcher.initialize(this);
		elements_array=new Array;
		doInNextFrames_array=new Array;
		_currentItem=null;
		
		_root.createEmptyMovieClip("silexSequencerOnEnterFrameEventDispatcher_mc",_root.getNextHighestDepth());
		_root.silexSequencerOnEnterFrameEventDispatcher_mc.onEnterFrame=Utils.createDelegate(this,onEnterFrame);
//		_root.silexSequencerOnEnterFrameEventDispatcher_mc.sequencerRef=this;
//		_root.silexSequencerOnEnterFrameEventDispatcher_mc.onEnterFrame=function(){this.sequencerRef.onEnterFrame()};
	}

	/** 
	 * Remove all elements except the sequence which is curently running.
	 */
	function removeAll() {
		while (elements_array.length>0)
			elements_array.shift();
		//_currentItem=null;
	}
	/**
	 * Adds an item to elements_array and starts the process (i.e. calls play()) if it was stopped (i.e. if elements_array was empty / state is set to silex_ptr.config.SEQUENCER_STATE_STOP).
	 * @param item		the sequence to be added
	 * @param callback	the function to call at the end
	 */
	function addItem(item:MovieClip, callback:Function, startCallback:Function, autoEndDetection:Boolean, animationName : String) {
		// default values
		if (item==undefined) item=null;
		if (callback==undefined) callback=null;
		if (startCallback==undefined) startCallback=null;
		if (autoEndDetection==undefined) autoEndDetection=true;
		if (animationName==undefined) animationName = "(not named)";
		
		// add the new element
		elements_array.push({target:item,callback:callback,startCallback:startCallback,autoEndDetection:autoEndDetection, animationName : animationName});
		
		// starts the process (i.e. calls play()) if it was stopped
		if (state==silex_ptr.config.SEQUENCER_STATE_STOP){
			playSequence();
		}
	}
	/**
	 * Starts the process.
	 * Change state.
	 * Dispatch start event.
	 */
	function playSequence() {
		// if we are allready playing, do nothing
		if (state==silex_ptr.config.SEQUENCER_STATE_PLAY)
			return;
		
		// play again or start (depending on the state <=> depending on _currentItem)
		if (_currentItem==null){
			// dispatch start event
			dispatchEvent({type:"start",target:this});
			
			// starts the process
			nextSequence();
		}
		else{
			// dispatch play event
			dispatchEvent({type:"play",target:this});
			
			// starts the process
			_currentItem.target.play();
		}

		// change state
		state=silex_ptr.config.SEQUENCER_STATE_PLAY;
	}

	/**
	 * Pauses the process.
	 * Stop sequence.
	 * Dispatch pause event.
	 */
	function pauseSequence() {
		// if we are allready paused, do nothing
		if (state==silex_ptr.config.SEQUENCER_STATE_PAUSE)
			return;

		// pauses the process
		if (_currentItem==null) // <=> if (state==silex_ptr.config.SEQUENCER_STATE_STOP);
			playSequence();
		
		elements_array[0].stop();

		// change state
		state=silex_ptr.config.SEQUENCER_STATE_PAUSE;
		
		// dispatch start event
		dispatchEvent({type:"pause",target:this});
	}
	
	/**
	 * Stops the process.
	 * Change state.
	 * Dispatch stop event.
	 */
	function stopSequence() {
		// if we are allready stoped, do nothing
		if (state==silex_ptr.config.SEQUENCER_STATE_STOP)
			return;

		// stops the process
		removeAll();
		_currentItem=null;

		// change state
		state=silex_ptr.config.SEQUENCER_STATE_STOP;
		
		// dispatch stop event
		dispatchEvent({type:"stop",target:this});
	}
	/**
	 * Skip to the next sequence.
	 * Call the callback function.
	 * Dispatch change.
	 * Remove the first element of elements_array.
	 * If elements_array is empty, stop the process (i.e. call stop()).
	 * Or else, start the next sequence (play it).
	 */
	function nextSequence() {
		// end the current sequence
		if (_currentItem!=null){
			// call the callback function
			if (_currentItem.callback)
				_currentItem.callback(_currentItem.target);
		}
		
		// if there is nothing after, end
		if (elements_array.length<=0){

			// clear _currentItem
			_currentItem=null;
			
			// change state
			state=silex_ptr.config.SEQUENCER_STATE_STOP;
			
			// dispatch end event
			dispatchEvent({type:"end",target:this});
		}
		else
		{
			// dispatch change event
			dispatchEvent({type:"change",target:this});

			// sets _currentItem to the new state
			_currentItem=elements_array.shift();
			
			// start callback
			if (_currentItem.startCallback)
				_currentItem.startCallback(_currentItem.target);

			// plays the sequence
			if (_currentItem.target){
				_currentItem.target.play();
				_currentItem.target._visible=true;
			}
		}
	}
	/**
	 * Dispatch onEnterFrame event.
	 * Check if the running anim is at the end.
	 * If yes, calls next().
	 */
	function onEnterFrame() {

		this.currentFrame++;
		
		// ** 
		// delayed actions
		if (doInNextFrames_array.length > 0)
		{
			// separate actions to do now from actions to do later
			var doItNow_array:Array = new Array;
			var doItLater_array = new Array;
			for (var actionIdx:Number = 0; actionIdx < doInNextFrames_array.length; actionIdx++)
			{
				// if delay is 0 or undefined, do the action
				if (!doInNextFrames_array[actionIdx].delay || doInNextFrames_array[actionIdx].delay<0)
				{
					doItNow_array.push(doInNextFrames_array[actionIdx]);
					doInNextFrames_array[actionIdx] = undefined;
				}
				else
				{
					doInNextFrames_array[actionIdx].delay--;
					doItLater_array.push(doInNextFrames_array[actionIdx]);
				}
			}
			
			// save the new array
			doInNextFrames_array = doItLater_array;
			doItLater_array = undefined;
			
			// do the actions
			while (doItNow_array.length > 0)
			{
				var action_obj:Object = doItNow_array.shift();
				action_obj.callback(action_obj.arguments);
			}
		}

		// dispatch onEnterFrame event
		dispatchEvent({type:"onEnterFrame",target:this});
		
		// if we are playing
		if (state==silex_ptr.config.SEQUENCER_STATE_PLAY){
			// if the current item has not a sequence or we autoEndDetect its end, call the callback function and go to next sequence
			if (!_currentItem.target || (_currentItem.autoEndDetection==true && _currentItem.target._currentFrame>=_currentItem.target._totalFrames)){
				nextSequence();
			}
		}
	}
	/**
	 * do an action in a certain number of frames
	 */
	function doInNFrames(nFrames:Number,callback:Function,arguments_obj:Object)
	{
		doInNextFrames_array.push({delay:nFrames,callback:callback,arguments:arguments_obj});
	}
	/**
	 * do an action in the next frame
	 */
	function doInNextFrame(callback:Function,arguments_obj:Object)
	{
		doInNFrames(1, callback, arguments_obj);
	}
}