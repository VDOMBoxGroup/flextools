package net.vdombox.ide.core.model
{
	import flash.net.SharedObject;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	/**
	 *  ResourcesProxy is wrapper on SharedObject. 
	 * Used for save <i>hostame, login and password</i>
	 * @see  flash.net.SharedObject
	 * @author Alexey Andreev
	 * 
	 */
	public class SharedObjectProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "SharedObjectProxy";

		public function SharedObjectProxy()
		{
			super( NAME, {} );
		}

		private var shObjData : Object;

		override public function onRegister() : void
		{
			shObjData = SharedObject.getLocal( "userData" );
		}

		public function get username() : String
		{
			return shObjData.data.username ? shObjData.data.username : "";
		}

		public function set username( value : String ) : void
		{
			shObjData.data.username = value;
		}

		public function get password() : String
		{
			return shObjData.data.password ? shObjData.data.password : "";;
		}

		public function set password( value : String ) : void
		{
			shObjData.data.password = value;
		}

		public function get hostname() : String
		{
			return shObjData.data.hostname ? shObjData.data.hostname : "";
		}

		public function set hostname( value : String ) : void
		{
			shObjData.data.hostname = value;
		}

		public function get localeCode() : String
		{
			return shObjData.data.localeCode ? shObjData.data.localeCode : "";
		}

		public function set localeCode( value : String ) : void
		{
			shObjData.data.localeCode = value;
		}
	}
}