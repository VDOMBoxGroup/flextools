package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class SharedObjectProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SharedObjectProxy";

		public function SharedObjectProxy()
		{
			super( NAME, {} );
		}

		private var sharedObject : SharedObject;

		override public function onRegister() : void
		{
			sharedObject = SharedObject.getLocal( "userData" );
			
			data.username = sharedObject.data.username ? sharedObject.data.username : "";
			data.password = sharedObject.data.password ? sharedObject.data.password : "";
			data.hostname = sharedObject.data.hostname ? sharedObject.data.hostname : "";
			data.localeCode = sharedObject.data.localeCode ? sharedObject.data.localeCode : "";
		}

		public function get username() : String
		{
			return data.username;
		}

		public function set username( value : String ) : void
		{
			sharedObject.data.username = data.username = value;
		}

		public function get password() : String
		{
			return data.password;
		}

		public function set password( value : String ) : void
		{
			sharedObject.data.password = data.password = value;
		}

		public function get hostname() : String
		{
			return data.hostname;
		}

		public function set hostname( value : String ) : void
		{
			sharedObject.data.hostname = data.hostname = value;
		}

		public function get localeCode() : String
		{
			return data.localeCode;
		}

		public function set localeCode( value : String ) : void
		{
			sharedObject.data.localeCode = data.localeCode = value;
		}
	}
}