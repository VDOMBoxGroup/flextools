package net.vdombox.ide.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ApplicationAttributesProxy";

		public function ApplicationProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		private var _attributes : Array;		
		
		public function get attributes() : Array
		{
			return _attributes;
		}
		
		public function set attributes( value : Array ) : void
		{
			_attributes = value;
		}
	}
}