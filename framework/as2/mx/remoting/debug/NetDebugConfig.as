
intrinsic class mx.remoting.debug.NetDebugConfig extends Object
{
   public function NetDebugConfig();
   public var amf:Boolean;
   public var amfheaders:Boolean;
   public var app_server:mx.remoting.debug.NetDebugConfig;
   static public function attachNetDebugConfigFunctions(ndc:Object):Object;
   public var client:mx.remoting.debug.NetDebugConfig;
   public var coldfusion:Boolean;
   public var error:Boolean;
   static public function getDefaultNetDebugConfig(isController:Boolean):mx.remoting.debug.NetDebugConfig;
   static public function getNetDebugVersion():Number;
   static public function getRealDefaultNetDebugConfig():mx.remoting.debug.NetDebugConfig;
   public var http:Boolean;
   public var httpheaders:Boolean;
   public var m_debug:Boolean;
   public var realtime_server:mx.remoting.debug.NetDebugConfig;
   public var recordset:Boolean;
   public var rtmp:Boolean;
   public var trace:Boolean;
};
