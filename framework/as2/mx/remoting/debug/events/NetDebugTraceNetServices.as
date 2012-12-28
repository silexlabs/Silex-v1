import mx.remoting.debug.events.NetDebug;

intrinsic class mx.remoting.debug.events.NetDebugTraceNetServices extends mx.remoting.debug.events.NetDebug
{
   public function NetDebugTraceNetServices(w:String, s:String, n:Number, m:String);
   public var number:Number;
   public var severity:String;
   public var trace:String;
   public var who:String;
};
