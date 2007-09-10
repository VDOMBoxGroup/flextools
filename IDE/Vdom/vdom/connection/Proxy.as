package vdom.connection
{
	import vdom.connection.soap.Soap;
	
	public class Proxy
	{
		private soap:Soap = Soap.getInstance();
		
		public function Proxy() 
		{
            if( instance ) throw new Error( "Singleton and can only be accessed through Proxy.anyFunction()" );
        } 
		 
		 // initialization		
		 public static function getInstance():Soap 
		 {
             return instance||new Proxy() ;
         }		
         
         public function flush():void
         {
         	trace("I'm a flush(:)");
         }	
         
         public function  setAttributes():void
         {
         	trace("I'm a setAttributes(:)")
         }
	}
}