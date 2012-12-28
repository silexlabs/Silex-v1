import mx.remoting.debug.events.NetDebugDuplicateNCDError;

intrinsic class mx.remoting.debug.GlobalLocalConnection extends Object
{
   public function GlobalLocalConnection(isController:Boolean, receiver:Object, domainName:String);
   private var maxConnections:Number;
   public function send(dataobj:Object):Boolean;
   public function sendCommand(commandObj:Object):Boolean;
   private var sendNames:Array;
   private var sendPrefix:String;
   public function sendRaw(functionName:String, obj:Object):Boolean;
   public function setDomainName(domainName:String):Void;
};
