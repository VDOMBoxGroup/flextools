package net.vdombox.ide.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class LoginProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "LoginProxy";

		public function LoginProxy( data : Object = null )
		{
			super( NAME, data );
		}

	}
}