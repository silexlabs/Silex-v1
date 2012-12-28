import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugConnect extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugConnect(args:Array);
   public var connectString:String;
   public var password:String;
   public var userName:String;
};
