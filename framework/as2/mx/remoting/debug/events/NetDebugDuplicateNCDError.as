import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugDuplicateNCDError extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugDuplicateNCDError();
   public var message:String;
   public var source:String;
};
