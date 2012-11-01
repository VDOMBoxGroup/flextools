package net.vdombox.ide.common.model
{
	public class ProxyStorage
	{
		private static var _proxies : Array;

		public static function get proxies():Array
		{
			return _proxies;
		}
		
		public static function addProxy( name : String ) : void
		{
			if ( !_proxies )
				_proxies = new Array();
			
			_proxies.push( name );
		}
		
		public static function removeAllProxies() : void
		{
			_proxies = null;
		}

	}
}