/*This file is part of Silex - see http://projects.silexlabs.org/?/silex

Silex is © 2010-2011 Silex Labs and is released under the GPL License:

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License (GPL) as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version. 

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

To read the license please visit http://www.gnu.org/copyleft/gpl.html
*/
package org.silex.animationLayouts;
import flash.MovieClip;
import flash.Lib;

class AnimationLayout
{
	/**
	*  The current MovieClip
	*/
	public var timeLine : MovieClip;
	/**
	*  Reference to the SILEX API. TODOWMT: Type it
	*/
	public var silex : Dynamic;
	/**
	*  Reference to the layout object. TODOWMT: Type it
	*/ 
	public var layout : Dynamic;
	
	/**
	*  Tells if Layout class should autolink animations (Layout.init)
	*/
	public var autoLinkAnimations : Bool;
	
	/**
	*  The sequencer
	*/
	public var sequencer : Dynamic;
	
	/**
	*  Initialize variables and calls registerLayoutContainer
	*/
	public function new()
	{
		autoLinkAnimations = false;
		
		this.timeLine = Lib.current;
		this.silex = Lib._global.getSilex();
		layout = silex.application.getLayout(this.timeLine);
		silex.application.layoutLoadedInit(this.timeLine);
		sequencer = flash.Lib._global.getSilex().sequencer;
		//layout.registerLayoutContainer(this.timeLine);
	}
	
	/**
	*  Allows registering a MovieClip as a sublayer
	*/
	public function registerSubLayer(mv : MovieClip, name : String)
	{
		layout.registerLayerContainer(mv, name);
	}
	
	/**
	*  Registers an Animation.
	*  Throws "NotIAnimationEndDetectable" if autoEndDetection is true and animation doesn't implement 
	*  IAnimationEndDetectable
	*  @throws "EndOfAnimationNotDetectable"
	*/
	public function addAnimation(animation : Animation, animationType : AnimationType, ?autoEndDetection : Bool, ?autoRemoveLayoutAtEnd : Bool)
	{
		if(autoEndDetection == null)
			autoEndDetection = false;
		if(autoRemoveLayoutAtEnd == null)
			autoRemoveLayoutAtEnd = false;

		if(!animation.endDetectable && autoEndDetection==true)
			throw "EndOfAnimationNotDetectable";
		
		layout.registerAnim(animation, animationTypeToConstant(animationType), autoEndDetection, autoRemoveLayoutAtEnd);
	}
	
	public inline function animationTypeToConstant(animationType : AnimationType) : String
	{
		return	switch(animationType)
				{
					case ANIM_NAME_PRELOAD:
						this.silex.config.ANIM_NAME_PRELOAD;
					case ANIM_NAME_SHOW:
						this.silex.config.ANIM_NAME_SHOW;
					case ANIM_NAME_CLOSE:
						this.silex.config.ANIM_NAME_CLOSE;
					case ANIM_NAME_TRANSITION:
						this.silex.config.ANIM_NAME_TRANSITION;									
					case ANIM_NAME_TRANSITION_CLOSE:
						this.silex.config.ANIM_NAME_TRANSITION_CLOSE;										
				};
	}
	
	public function registerChildLayer(mc : MovieClip)
	{
		layout.registerLayoutContainer(mc);
	}
}