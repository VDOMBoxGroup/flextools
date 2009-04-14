package net.vdombox.ide.model
{
	import net.vdombox.ide.events.SOAPEvent;
	import net.vdombox.ide.model.business.SOAP;

	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";
		public static const TYPES_LOADED : String = "Types Loaded";

		public function TypesProxy( data : Object = null )
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

		private function soap_getAllTypesHandler( event : SOAPEvent ) : void
		{
			_types = event.result.Types[ 0 ];
			
			sendNotification( TYPES_LOADED, _types );
		}
	}
}