import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugCall extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugCall(args:Array);
   public var methodName:String;
   public var parameters:Array;
};
