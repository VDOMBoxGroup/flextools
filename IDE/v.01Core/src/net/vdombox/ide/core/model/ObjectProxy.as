package net.vdombox.ide.model
{
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;
	import net.vdombox.ide.interfaces.IObjectProxy;

	public class ObjectProxy extends Proxy implements IObjectProxy
	{
		public function ObjectProxy( proxyName : String = null, data : Object = null )
		{
			super( proxyName, data );
		}

		public function get id() : String
		{
			return null;
		}

		public function get attributes() : XMLList
		{
			return null;
		}
	}
}