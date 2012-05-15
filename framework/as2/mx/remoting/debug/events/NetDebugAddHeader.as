import mx.remoting.debug.events.NetDebugNetConnection;

intrinsic class mx.remoting.debug.events.NetDebugAddHeader extends mx.remoting.debug.events.NetDebugNetConnection
{
   public function NetDebugAddHeader(args:Array);
   public var headerName:String;
   public var headerObject:Object;
   public var mustUnderstand:Boolean;
};
