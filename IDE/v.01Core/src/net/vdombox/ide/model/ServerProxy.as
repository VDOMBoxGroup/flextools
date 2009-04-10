package net.vdombox.ide.model
{
	import flash.utils.Proxy;
	import org.puremvc.as3.multicore.interfaces.IProxy;

	public class ServerProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ServerProxy";

		public function LoginProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		public function login() : void
		{
			
		}
	}
}