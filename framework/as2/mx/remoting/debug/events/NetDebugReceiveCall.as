import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugReceiveCall extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugReceiveCall(mName:String, args:Array);
   public var methodName:String;
   public var parameters:Array;
};
