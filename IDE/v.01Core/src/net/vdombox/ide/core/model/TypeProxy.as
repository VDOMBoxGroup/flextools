package net.vdombox.ide.core.model
{
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypeProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";
		public static const TYPES_LOADED : String = "Types Loaded";

		public function TypeProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		private var soap : SOAP = SOAP.getInstance();

		private var _types : XML;

		public function get types() : XML
		{
			return _types;
		}

		public function load() : void
		{
			soap.get_all_types();
		}

		private function addEventListeners() : void
		{
			soap.get_all_types.addEventListener( SOAPEvent.RESULT, soap_getAllTypesHandler );
		}

		private function soap_getAllTypesHandler( event : net.vdombox.ide.core.events.SOAPEvent ) : void
		{
			_types = event.result.Types[ 0 ];
			
			sendNotification( TYPES_LOADED, _types );
		}
	}
}