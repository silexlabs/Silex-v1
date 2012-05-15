//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;

/**
* Class for managing the depth (z-order) of objects.
*
* @helpid 3297
* @tiptext
*/
class mx.managers.DepthManager
{
	// highest allowed depth is reserved for tooltips and cursors
	static var reservedDepth:Number = 1048575;
	// highest depth for all other objects
	static var highestDepth:Number = 1048574;
	// lowest allowed depth
	static var lowestDepth:Number = -16383;
	// lowest depth plus this number of layers is reserved
	// for statically placed content
	static var numberOfAuthortimeLayers:Number = 383;

/**
* constant used in calls to createClassObjectAtDepth/createObjectAtDepth
*
* @tiptext used as parameter to request placement in cursor depths
* @helpid 3298
*/
	static var kCursor:Number	=	101;
/**
* constant used in calls to createClassObjectAtDepth/createObjectAtDepth
*
* @tiptext used as parameter to request placement in tooltip depths
* @helpid 3299
*/
	static var kTooltip:Number	=	102;

/**
* constant used in calls to createClassChildtAtDepth/createChildAtDepth
*
* @tiptext used as parameter to request placement on top of other content
* but below kTopMost content
* @helpid 3300
*/
	static var kTop:Number		=	201;
/**
* constant used in calls to createClassChildtAtDepth/createChildAtDepth
*
* @tiptext used as parameter to request placement on bottom of other content
* @helpid 3301
*/
	static var kBottom:Number	=	202;
/**
* constant used in calls to createClassChildtAtDepth/createChildAtDepth
*
* @tiptext used as parameter to request placement on top of other content
* even above kTop objects
* @helpid 3302
*/
	static var kTopmost:Number	=	203;
/**
* constant used in calls to createClassChildtAtDepth/createChildAtDepth
*
* @tiptext used as parameter to request removal from the topmost layer
* @helpid 3303
*/
	static var kNotopmost:Number	=	204;

	// reserve the topmost layer for ourselves
	private static var holder:MovieClip = _root.createEmptyMovieClip("reserved", DepthManager.reservedDepth);

	// sort the depths in the array of depths.  we don't need an equality test since depths can never be the same
	static function sortFunction(a:MovieClip, b:MovieClip):Number
	{
		if (a.getDepth() > b.getDepth())
			return 1;
		return -1;
	}

	// true if it is the reserved depth
	static function test(depth:Number):Boolean
	{
		if (depth == DepthManager.reservedDepth) return false;
		else return true;
	}

/**
* create an instance of a class at a depth relative to other content
*
* @param className the name of the class
* @param depthSpace either kCursor or kTooltip
* @param initObj object containing initialization properties
* @return	reference to object
*
* @tiptext
* @helpid 3304
*/
	static function createClassObjectAtDepth(className:Object, depthSpace:Number, initObj:Object):UIObject
	{
		var o:UIObject = undefined;
		switch (depthSpace)
		{
			case (DepthManager.kCursor):
				o = DepthManager.holder.createClassChildAtDepth( className, DepthManager.kTopmost, initObj );
				break;
			case (DepthManager.kTooltip):
				o = DepthManager.holder.createClassChildAtDepth( className, DepthManager.kTop, initObj );
				break;
			default:
				break;
		}
		return o;
	}

/**
* create an instance of a symbol at a depth relative to other content
*
* @param linkageName the linkage name of the symbol in the library
* @param depthSpace either kCursor or kTooltip
* @param initObj object containing initialization properties
* @return	reference to object
*
* @tiptext
* @helpid 3305
*/
	static function createObjectAtDepth(linkageName:String, depthSpace:Number, initObj:Object):MovieClip
	{
		var o:MovieClip = undefined;
		switch (depthSpace)
		{
			case (DepthManager.kCursor):
				o = DepthManager.holder.createChildAtDepth( linkageName, DepthManager.kTopmost, initObj );
				break;
			case (DepthManager.kTooltip):
				o = DepthManager.holder.createChildAtDepth( linkageName, DepthManager.kTop, initObj );
				break;
			default:
				break;
		}
		return o;
	}

/* the rest of these methods are added to UIObject */

	// the methods use the following properties and methods on UIObject.
	var _childCounter:Number;
	var _topmost:Boolean;
	var createClassObject:Function;
	var createObject:Function;
	var swapDepths:Function;
	var getDepth:Function;
	var _parent:MovieClip;

/**
* create an instance of a class at a depth relative to other content
*
* @param className the name of the class
* @param depthSpace one of kTop, kBottom, kTopmost, kNoTopmost
* @param initObj object containing initialization properties
* @return	reference to object
*
* @tiptext
* @helpid 3306
*/
	function createClassChildAtDepth( className:Function, depthFlag:Number, initObj:Object ):UIObject
	{
		if (_childCounter == undefined) _childCounter = 0;
		var dt:Array = buildDepthTable();
		var depth:Number = getDepthByFlag( depthFlag, dt );
		//trace("createClassChildAtDepth " + depth);

		var shuffleDir:String = "down";
		if( depthFlag == mx.managers.DepthManager.kBottom) shuffleDir = "up";
		var desiredDepth:Number = undefined;
		if (dt[depth] != undefined)
		{
			desiredDepth = depth;
			depth = findNextAvailableDepth( depth, dt, shuffleDir );
		}
		//trace("createClassChildAtDepth " + depth);

		var o:UIObject = createClassObject(className, "depthChild" + _childCounter++, depth, initObj);
		//trace("createClassChildAtDepth created " + o);
		if (desiredDepth != undefined)
		{
			dt[depth] = o;
			shuffleDepths( o, desiredDepth, dt, shuffleDir );
		}
		if ( depthFlag == mx.managers.DepthManager.kTopmost) o._topmost = true;
		//trace("createClassChildAtDepth " + depthFlag + " created " + o + " at " + depth);
		return o;
	}

/**
* create an instance of a symbol at a depth relative to other content
*
* @param linkageName the linkage name of the symbol in the library
* @param depthSpace one of kTop, kBottom, kTopmost, kNoTopmost
* @param initObj object containing initialization properties
* @return	reference to object
*
* @tiptext
* @helpid 3307
*/
	function createChildAtDepth( linkageName:String, depthFlag:Number, initObj:Object ):MovieClip
	{
		//trace("createChildAtDepth");
		if (_childCounter == undefined) _childCounter = 0;
		var dt:Array = buildDepthTable();
		var depth:Number = getDepthByFlag( depthFlag, dt );

		var shuffleDir:String = "down";
		if( depthFlag == mx.managers.DepthManager.kBottom) shuffleDir = "up";
		var desiredDepth:Number = undefined;
		if (dt[depth] != undefined)
		{
			desiredDepth = depth;
			depth = findNextAvailableDepth( depth, dt, shuffleDir );
		}

		var o:MovieClip = createObject(linkageName, "depthChild" + _childCounter++, depth, initObj);
		if (desiredDepth != undefined)
		{
			dt[depth] = o;
			shuffleDepths( o, desiredDepth, dt, shuffleDir );
		}
		if ( depthFlag == mx.managers.DepthManager.kTopmost) o._topmost = true;
		//trace("createChildAtDepth " + depthFlag + " created " + o + " at " + depth);
		return o;
	}

/**
* set this object at a particular depth, moving other objects to make room if needed
*
* @param depthFlag the desired depth
*
* @tiptext
* @helpid 3308
*/
	function setDepthTo( depthFlag:Number ):Void
	{
		var dt:Array = _parent.buildDepthTable();
		var depth:Number = _parent.getDepthByFlag( depthFlag, dt );
		//trace("setDepthTo got depth by flag = " + depth);

		/* Shuffle is designed for relative
		   movement like in setDepthAbove/Below.  In this case we don't
		   know what to do with something occupying the target slot.
		   Do we move it up or down to make room?  For now we just
		   move it depending on its position relative to the target
		   depth
		*/
		if (dt[depth] != undefined)
		{
			shuffleDepths( MovieClip(this), depth, dt, undefined);
		}
		else
		{
			swapDepths( depth );
		}
		//trace("setDepthTo put " + this + " at " + depth);

		if ( depthFlag == mx.managers.DepthManager.kTopmost) _topmost = true;
		else delete _topmost;
	}

/**
* set this object above the target object, moving other objects including the target object to make room if needed
*
* @param targetInstance the target object
*
* @tiptext
* @helpid 3309
*/
	function setDepthAbove( targetInstance:MovieClip ):Void
	{
		if (targetInstance._parent != _parent) return;
		// try to put it above
		var targetDepth:Number = targetInstance.getDepth() + 1;
		var dt:Array = _parent.buildDepthTable();
		// if slot above is taken and we're coming from below, just
		// push the target down to make room for the source
		if (dt[targetDepth] != undefined && getDepth() < targetDepth)
			targetDepth -= 1;

		if (targetDepth > mx.managers.DepthManager.highestDepth)
			targetDepth = mx.managers.DepthManager.highestDepth;

		//trace("setDepthAbove wants to put " + this + " at " + targetDepth);
		if (targetDepth == mx.managers.DepthManager.highestDepth)
			_parent.shuffleDepths( this, targetDepth, dt, "down" );
		else if (dt[targetDepth] != undefined)
			_parent.shuffleDepths( this, targetDepth, dt, undefined );
		else
			swapDepths(targetDepth);
		//trace("setDepthAbove put " + this + " at " + targetDepth);
	}

/**
* set this object below the target object, moving other objects including the target object to make room if needed
*
* @param targetInstance the target object
*
* @tiptext
* @helpid 3310
*/
	function setDepthBelow( targetInstance:MovieClip ):Void
	{
		if (targetInstance._parent != _parent) return;
		// try to put it above
		var targetDepth:Number = targetInstance.getDepth() - 1;
		var dt:Array = _parent.buildDepthTable();
		// if slot below is taken and we're coming from above, just
		// shove the target up to make room for the source
		if (dt[targetDepth] != undefined && getDepth() > targetDepth)
			targetDepth += 1;

		var lowestDepth:Number = mx.managers.DepthManager.lowestDepth + mx.managers.DepthManager.numberOfAuthortimeLayers;
		// authortime shapes on layers don't show up in the depth table
		// we require that all shapes go below the components
		var i:String;
		for (i in dt)
		{
			var x = dt[i];
			if (x._parent != undefined)
				lowestDepth = Math.min(lowestDepth, x.getDepth());
		}
		if (targetDepth < lowestDepth)
			targetDepth = lowestDepth;

		//trace("setDepthBelow wants to put " + this + " at " + targetDepth);
		if (targetDepth == lowestDepth)
			_parent.shuffleDepths( this, targetDepth, dt, "up" );
		else if (dt[targetDepth] != undefined)
			_parent.shuffleDepths( this, targetDepth, dt, undefined );
		else
			swapDepths(targetDepth);
		//trace("setDepthBelow put " + this + " at " + targetDepth);
	}

/**
* @private
* calculate the correct value to use for the new depth
*
* @param targetDepth desired depth
* @param depthTable generated by call to buildDepthTable
* @param direction "up" - look up if something occupies that depth, or "down"
* @return Number next available depth
*/
	function findNextAvailableDepth( targetDepth:Number, depthTable:Array, direction:String ):Number
	{
		var highestAuthoringDepth:Number = mx.managers.DepthManager.lowestDepth + mx.managers.DepthManager.numberOfAuthortimeLayers;
		// don't stick things into the authoring depths
		// static text and other content may be there.
		if (targetDepth < highestAuthoringDepth)
			targetDepth = highestAuthoringDepth;

		if (depthTable[targetDepth] == undefined) return targetDepth; // undefined;
		//trace("findNextAvailableDepth starting at " + targetDepth + " and packing stuff " + direction);
		var nextFreeAbove:Number = targetDepth;
		var nextFreeBelow:Number = targetDepth;
		if (direction == "down")
		{
			while(depthTable[nextFreeBelow] != undefined) {
				nextFreeBelow--;
			}
			return nextFreeBelow;
		}

		while(depthTable[nextFreeAbove] != undefined) {
			nextFreeAbove++;
		}
		return nextFreeAbove;
	}

/**
* @private
* move objects to different depths in order to make room for subject at the targetDepth
*
* @param subject the object we want to move
* @param targetDepth desired depth
* @param depthTable generated by call to buildDepthTable
* @param direction "up" - look up if something occupies that depth, or "down" or undefined - use best judgement
*/
	function shuffleDepths( subject:MovieClip, targetDepth:Number, depthTable:Array, direction:String ):Void
	{
		// we have to take a movieclip and use it to give new depths to other clips and
		// textfields because textfields don't have depth swapping calls but can be
		// given new depths when swapped with a movie clip

		//trace("DepthManager:shuffleDepths");
		var lowestDepth:Number = mx.managers.DepthManager.lowestDepth + mx.managers.DepthManager.numberOfAuthortimeLayers;
		var highestAuthoringDepth:Number = lowestDepth;
		// see note in first use of "lowestDepth++"
		var i:String;
		for (i in depthTable)
		{
			var x = depthTable[i];
			if (x._parent != undefined)
				lowestDepth = Math.min(lowestDepth, x.getDepth());
		}

		if (direction == undefined) {
			if (subject.getDepth() > targetDepth)
				direction = "up";
			else
				direction = "down";
		}

		// pack the array.  Using shift on depthTable doesn't work because
		// shift and pop generate undefined for each hole in the array
		var dt:Array = new Array();
		for (i in depthTable)
		{
			var x = depthTable[i];
			if (x._parent != undefined)
				dt.push(x);
		}
		// sort the array by depth, [0] being the lowest.  We can't count on the array being in order
		// even though the clip tells you about them in z-order.  Additional
		// references to the clips can cause the array to be out of order
		dt.sort(mx.managers.DepthManager.sortFunction);

		if (direction == "up") {
			var a:Object = undefined;
			var lastd:Number;
			// pull things off the depth table until we find the subject
			while (dt.length > 0)
			{
				a = dt.pop();
				// trace(a + " " + a.getDepth());
				if (a == subject)
				{
					break;
				}
			}
			// move the rest of the array
			while (dt.length > 0)
			{
				lastd = subject.getDepth();
				a = dt.pop();
				var d:Number = a.getDepth();
				// if there's a gap in the z order between the subject and the
				// current clip, move the subject just on top of the current
				// clip
				// trace(a + " is at " + d + " subject is at " + lastd);
				// don't do this if we're working with authoring content
				if (lastd > d + 1)
				{
					if (d >= 0)
					{
						subject.swapDepths(d+1);
					}
					else if (lastd > highestAuthoringDepth && d < highestAuthoringDepth)
					{
						subject.swapDepths(highestAuthoringDepth);
					}
					//trace("preswap put subject at " + subject.getDepth());
				}
				// swap the subject below the current clip
				subject.swapDepths(a);
				// trace("swap put subject at " + subject.getDepth());
				if (d == targetDepth)
					break;
			}
		}
		else if (direction == "down") {
			var a:Object = undefined;
			var lastd:Number;
			// pull things off the depth table until we find the subject
			while (dt.length > 0)
			{
				a = dt.shift();
				if (a == subject)
				{
					break;
				}
			}
			// move the rest of the array
			while (dt.length > 0)
			{
				lastd = a.getDepth();
				a = dt.shift();
				var d:Number = a.getDepth();
				// if there's a gap in the z order between the subject and the
				// current clip, move the subject just on top of the current
				// clip
				if ((lastd < d - 1) && (d > 0))
				{
					subject.swapDepths(d - 1);
				}
				// swap the subject below the current clip
				subject.swapDepths(a);
				if (d == targetDepth)
					break;
			}
		}
	}

/**
* @private
* calculate the correct depth based on the depthFlag.  Does not guarantee that it
* will be free -- you must test the depth and then shuffleDepths if necessary
*
* @param depthFlag either kTop, kBotton, kTopmost or kNoTopmost
* @param depthTable generated by call to buildDepthTable
* @return Number a good depth to start with
*/
	function getDepthByFlag( depthFlag:Number, depthTable:Array ):Number
	{
		var depth:Number = 0;
		if ( depthFlag == mx.managers.DepthManager.kTop ||
			 depthFlag == mx.managers.DepthManager.kNotopmost)
		{
			var lowestTopmost:Number = 0;
			var anyTopmost:Boolean = false;
			var j:String;
			for (j in depthTable)
			{
				var i:Object = depthTable[j];
				var t:String = typeof(i);
				if (t == "movieclip" || (t == "object" && i.__getTextFormat != undefined))
				if (i.getDepth()<=DepthManager.highestDepth) {
					if (!i._topmost) {
						depth = Math.max(depth, i.getDepth());
					}
					else {
						if (!anyTopmost) {
							lowestTopmost = i.getDepth();
							anyTopmost = true;
						}
						else lowestTopmost = Math.min(lowestTopmost, i.getDepth());
					}
				}
			}
			depth += 20;
			if (anyTopmost)
				if (depth >= lowestTopmost) depth = lowestTopmost -1;
		}
		else if (depthFlag == mx.managers.DepthManager.kBottom)
		{
			var j:String;
			for (j in depthTable)
			{
				var i:Object = depthTable[j];
				var t:String = typeof(i);
				if (t == "movieclip" || (t == "object" && i.__getTextFormat != undefined))
				if (i.getDepth()<=DepthManager.highestDepth) {
					depth = Math.min(depth, i.getDepth());
				}
			}
			depth -= 20;
		}
		else if (depthFlag == mx.managers.DepthManager.kTopmost)
		{
			var j:String;
			for (j in depthTable)
			{
				var i:Object = depthTable[j];
				var t:String = typeof(i);
				if (t == "movieclip" || (t == "object" && i.__getTextFormat != undefined))
				if (i.getDepth()<=DepthManager.highestDepth) {
					depth = Math.max(depth, i.getDepth());
				}
			}
			depth += 100;
		}
		if (depth >= mx.managers.DepthManager.highestDepth) depth = mx.managers.DepthManager.highestDepth;
		// see note in first use of "lowestDepth++"
		var lowestDepth:Number = mx.managers.DepthManager.lowestDepth + mx.managers.DepthManager.numberOfAuthortimeLayers;
		var i:String;
		for (i in depthTable)
		{
			var x:Object = depthTable[i];
			if (x._parent != undefined)
				lowestDepth = Math.min(lowestDepth, x.getDepth());
		}
		if (depth <= lowestDepth) depth = lowestDepth;
		return depth;
	}

/**
* @private
* find all the children and build a table of their depths
*
* @return Array a table of the depths of the child objects
*/
	function buildDepthTable(Void):Array
	{
		//trace("DepthManager:buildDepthTable");
		var depthTable:Array = new Array();
		var j:String;
		for (j in this)
		{
			var i = this[j];
			var t:String = typeof(i);
			if (t == "movieclip" || (t == "object" && i.__getTextFormat != undefined))
				if (i._parent == this) {
					depthTable[i.getDepth()] = i;
				}
		}
		return depthTable;
	}

	// Only one depth manager is needed.  When created it adds the methods to the
	// base classes
	function DepthManager()
	{
		MovieClip.prototype.createClassChildAtDepth = createClassChildAtDepth;
		MovieClip.prototype.createChildAtDepth = createChildAtDepth;
		MovieClip.prototype.setDepthTo = setDepthTo;
		MovieClip.prototype.setDepthAbove = setDepthAbove;
		MovieClip.prototype.setDepthBelow = setDepthBelow;
		MovieClip.prototype.findNextAvailableDepth = findNextAvailableDepth;
		MovieClip.prototype.shuffleDepths = shuffleDepths;
		MovieClip.prototype.getDepthByFlag = getDepthByFlag;
		MovieClip.prototype.buildDepthTable = buildDepthTable;
		
		_global.ASSetPropFlags(MovieClip.prototype, "createClassChildAtDepth",1);
		_global.ASSetPropFlags(MovieClip.prototype, "createChildAtDepth",1);
		_global.ASSetPropFlags(MovieClip.prototype, "setDepthTo",1);
		_global.ASSetPropFlags(MovieClip.prototype, "setDepthAbove",1);
		_global.ASSetPropFlags(MovieClip.prototype, "setDepthBelow",1);
		_global.ASSetPropFlags(MovieClip.prototype, "findNextAvailableDepth",1);
		_global.ASSetPropFlags(MovieClip.prototype, "shuffleDepths",1);
		_global.ASSetPropFlags(MovieClip.prototype, "getDepthByFlag",1);
		_global.ASSetPropFlags(MovieClip.prototype, "buildDepthTable",1);
		
		// applyDepthSpaceProtection();
	}
	// this technique guarantees that the depthManager is created and
	// adds to the base class when this package is included in a SWF
	static var __depthManager:DepthManager = new DepthManager();

	///////////////////////////////////////////////////////////////////
	// begin optional section for protected attachment and
	// depth space tracking (implements getInstanceAtDepth)
	//
	// this would allow considerable performance improvements for
	// some of the above methods, but incurs overhead at every
	// attach, swap, etc.
	///////////////////////////////////////////////////////////////////
	/*
	function applyDepthSpaceProtection(Void):Void
	{
		MovieClip.prototype.attachProxy = MovieClip.prototype.attachMovie;
		MovieClip.prototype.swapProxy = MovieClip.prototype.swapDepths;
		// TBD:  protect all of these
		// MovieClip.prototype.createEmptyMovieClip
		// MovieClip.prototype.createTextField
		// MovieClip.prototype.removeMovieClip
		// MovieClip.prototype.unloadMovie
		// MovieClip.prototype.duplicateMovieClip

		MovieClip.prototype.highestDepth = MovieClip.prototype.lowestDepth = 0;
		MovieClip.prototype.attachMovie = attachMovie;
		MovieClip.prototype.swapDepths = swapDepths;
		MovieClip.prototype.getInstanceAtDepth = getInstanceAtDepth;
	}

	function attachMovie(linkage:String, refName:String, depth:Number, init:Object):MovieClip
	{
		if (depthTable == undefined) depthTable = new Object();
		var:Boolean doAttach = true;
		if (this == _level0) {
			doAttach = DepthManager.test(depth);
			//trace(refName + " will be attached " + doAttach);
		}
		if (doAttach) {
			// do the actual attachment
			var ref:MovieClip = attachProxy(linkage, refName, depth, init);
			depthTable[depth] = ref;
			highestDepth = Math.max(depth, MovieClip.highestDepth);
			lowestDepth = Math.min(depth, MovieClip.lowestDepth);
			return ref;
		}
		else return undefined;
	}

	function swapDepths(depthOrTarget):Void
	{
		if (depthTable == undefined) depthTable = new Object();
		var original:Number = getDepth();
		var doSwap:Boolean = true;
		var isInstance:Boolean = (typeof(depthOrTarget) == "movieclip");
		if (typeof(getInstanceAtDepth(depthOrTarget)) == "movieclip")
			isInstance = true;
		if (this == _level0) {
			if (isInstance)	doSwap = DepthManager.test(depthOrTarget);
			else doSwap = (depthOrTarget != DepthManager.holder);
		}
		if (doSwap) {
			swapProxy(depthOrTarget);

			if (isInstance) {
				var swapped:Number = depthOrTarget.getDepth();
				_parent.depthTable[swapped] = this;
				_parent.depthTable[original] = depthOrTarget;
			}
			else {
				highestDepth = Math.max(depthOrTarget, MovieClip.highestDepth);
				lowestDepth = Math.min(depthOrTarget, MovieClip.lowestDepth);
				_parent.depthTable[depthOrTarget] = this;
				_parent.depthTable[original] = undefined;
			}
		}
		else return;
	}

	function getInstanceAtDepth(depth:Number):Number
	{
		return depthTable[depth];
	}
	*/
	///////////////////////////////////////////////////////////////////
	// end optional section
	///////////////////////////////////////////////////////////////////

}

