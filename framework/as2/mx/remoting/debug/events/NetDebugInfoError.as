import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugInfoError extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugInfoError(infoobj:Object, mes:String);
   public var info:Object;
   public var message:String;
   public var source:String;
};
