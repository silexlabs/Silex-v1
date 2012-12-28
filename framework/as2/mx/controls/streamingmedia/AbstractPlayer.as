//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
 * AbstractPlayer contains common code used by the player classes.
 * It relies on function defined in the IPlayer interface being
 * implemented in concrete subclasses.
 *
 * @author Andrew Guldman
 */
class mx.controls.streamingmedia.AbstractPlayer
{
	private var _playing:Boolean;

	public function AbstractPlayer()
	{
		_playing = false;
	}

	/**
	 * @return True if the media is playing; false if not.
	 */
	public function isPlaying():Boolean
	{
		return _playing;
	}

	public function get playing():Boolean
	{
		return isPlaying();
	}

	public function setPlaying(flag:Boolean):Void
	{
		_playing = flag;
	}

}
