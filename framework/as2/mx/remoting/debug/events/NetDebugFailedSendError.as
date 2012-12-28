import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugFailedSendError extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugFailedSendError(ev:Object);
   public var message:String;
   public var originalEvent:Object;
   public var source:String;
};
