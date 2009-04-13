package net.vdombox.ide.model
{
	import net.vdombox.ide.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class ResourcesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";
		
		public function ResourcesProxy( data : Object = null )
		{
			super( NAME, data );
		}
		
		private var soap : SOAP = SOAP.getInstance();
	}
}