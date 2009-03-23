package net.vdombox.ide.model
{
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ApplicationAttributesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "ApplicationAttributesProxy";

		public function ApplicationAttributesProxy( data : Array = null )
		{
			super( NAME, data );
		}
		
		public function get attributes() : Array
		{
			return data as Array;
		}
	}
}