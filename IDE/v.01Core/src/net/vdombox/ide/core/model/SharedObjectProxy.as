package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SharedObjectProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SharedObjectProxy";

		public function SharedObjectProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		private var sharedObject : SharedObject = SharedObject.getLocal( "userData" );

		public function get username() : String
		{
			return sharedObject.data.username ? sharedObject.data.username : "";
		}

		public function set username( value : String ) : void
		{
			sharedObject.data.username = value;
		}

		public function get password() : String
		{
			return sharedObject.data.username ? sharedObject.data.password : "";
		}

		public function set password( value : String ) : void
		{
			sharedObject.data.password = value;
		}

		public function get hostname() : String
		{
			return sharedObject.data.username ? sharedObject.data.hostname : "";
		}

		public function set hostname( value : String ) : void
		{
			sharedObject.data.hostname = value;
		}
	}
}