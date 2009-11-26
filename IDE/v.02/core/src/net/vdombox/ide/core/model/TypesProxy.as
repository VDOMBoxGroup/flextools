package net.vdombox.ide.core.model
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.vo.TypeVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";

		public function TypesProxy( data : Object = null )
		{
			super( NAME, data );

			addEventListeners();
		}

		private var soap : SOAP = SOAP.getInstance();

		private var _types : Array = [];

		public function get types() : Array
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
			var typesXML : XML = event.result.Types[ 0 ];
			
			for each( var type : XML in typesXML.* )
			{
				var typeVO : TypeVO = new TypeVO( type );
				_types.push( typeVO );
				
				sendNotification( ApplicationFacade.TYPE_LOADED, typeVO );
			}
			
			sendNotification( ApplicationFacade.TYPES_LOADED );
		}
	}
}