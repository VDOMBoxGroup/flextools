package vdom.connection {

import vdom.connection.soap.Soap;

public class Proxy {
	
	private static var instance:Proxy;
	
	private var soap:Soap;
	
	public function Proxy() 
	{
        if( instance ) throw new Error( "Singleton and can only be accessed through Proxy.anyFunction()" );
        
         soap = Soap.getInstance();
    } 
	 
	 // initialization		
	 public static function getInstance():Proxy 
	 {
         return instance||new Proxy() ;
     }		
     
     public function flush():void
     {
     	trace("I'm a flush(:)");
     }	
     
     public function  setAttributes(appid:String, objid:String, attr:XML):void
     {
     	trace("I'm a setAttributes(:)");
     }
}
}