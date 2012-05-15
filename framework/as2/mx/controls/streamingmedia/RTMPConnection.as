//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.streamingmedia.RTMPPlayer;

/**
 * A subclass of NetConnection that is tailored to work with the RTMPPlayer
 * class.
 *
 * @author Stephen Cheng
 */
class mx.controls.streamingmedia.RTMPConnection
extends NetConnection
{
	/** Flag to indicate whether a thread is already in connect(). Only one thread
	 *  at a time should be in this function.
	 */
	static var _connectFlag:Boolean;
	/** Array of queued RTMPPlayers, awaiting their turn to call connect(). */
	static var _connectorQueue:Array = new Array();

	private var _targetURI:String;
	private var _streamName:String;
	private var _player:RTMPPlayer;

	public function RTMPConnection(player:RTMPPlayer)
	{
		_player = player;
	}

	public function onMetaData(info)
	{
		_player.setTotalTime(info.duration);
	}

	/* Only one thread can be in this function at a time.
	 */
	public function connect(targetURI:String, streamName:String):Void
	{
		if (_connectFlag == true)
		{
			pushConnection(targetURI, streamName);
			return;
		}

		_connectFlag = true;

		super.connect(targetURI, streamName);

		popConnection();
	}

	private function pushConnection(targetURI:String, streamName:String):Void
	{
		_targetURI = targetURI;
		_streamName = streamName;

		//queue the connection attempt and retry later
		_connectorQueue.push(this);
	}

	private function popConnection():Void
	{
		_connectFlag = false;
		if ( _connectorQueue.length != 0)
		{
			var poppedConnection:RTMPConnection = RTMPConnection(_connectorQueue.pop());
			poppedConnection.connect(poppedConnection._targetURI, poppedConnection._streamName);
		}
	}
}
