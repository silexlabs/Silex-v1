import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugRtmpLog extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugRtmpLog(infoobj:Object);
   public var info:Object;
   public var source:String;
   public var trace:String;
};
