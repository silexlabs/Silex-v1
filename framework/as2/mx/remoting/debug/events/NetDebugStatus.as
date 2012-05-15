import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugStatus extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugStatus(statusobj:Object);
   public var status:Object;
};
