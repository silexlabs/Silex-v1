import mx.remoting.debug.events.NetDebug;

intrinsic class mx.remoting.debug.events.NetDebugError extends mx.remoting.debug.events.NetDebug
{
   public function NetDebugError(dataobj:Object);
   public var error:Object;
};
