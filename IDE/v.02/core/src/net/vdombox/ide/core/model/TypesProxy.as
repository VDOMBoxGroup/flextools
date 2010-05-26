package net.vdombox.ide.core.model
{
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";

		public function TypesProxy( data : Object = null )
		{
			super( NAME, data );
		}

		private var soap : SOAP = SOAP.getInstance();

		private var _types : Array;
		private var _topLevelTypes : Array;

		private var isSOAPConnected : Boolean;
		
		override public function onRegister() : void
		{
			if ( soap.ready )
			{
				isSOAPConnected = true;
				addHandlers();
			}
			else
			{
				isSOAPConnected = false;
				soap.addEventListener( SOAPEvent.CONNECTION_OK, soap_connectedHandler, false, 0, true );
			}
			
			soap.addEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectedHandler, false, 0, true );
		}

		override public function onRemove() : void
		{
			unloadTypes();

			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_connectedHandler );
			soap.removeEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectedHandler );
			
			removeHandlers();
		}

		public function get types() : Array
		{
			return _types ? _types.slice() : null;
		}

		public function get topLevelTypes() : Array
		{
			return _topLevelTypes ? _topLevelTypes.slice() : null;
		}
		
		public function get numTypes() : uint
		{
			return _types ? _types.length : 0;
		}

		public function loadTypes() : void
		{
			if( isSOAPConnected )
			{
				sendNotification( ApplicationFacade.TYPES_LOADING );
				soap.get_all_types();
			}
			else
			{
				sendNotification( ApplicationFacade.SEND_TO_LOG, "SOAP is not connected" );
			}
		}

		public function unloadTypes() : void
		{
			_types = null;
			_topLevelTypes = null;
		}
		
		public function getType( typeID : String ) : TypeVO
		{
			if( !typeID || !_types || _types.length == 0 )
				return null;
			
			var typeVO : TypeVO;
			
			for( var i : int = 0; i < _types.length; i++ )
			{
				if( _types[ i ].id != typeID )
					continue;
				
				typeVO = _types[ i ];
			}
			
			return typeVO;
		}

		private function addHandlers() : void
		{
			soap.get_all_types.addEventListener( SOAPEvent.RESULT, soap_getAllTypesHandler );
		}

		private function removeHandlers() : void
		{
			soap.get_all_types.removeEventListener( SOAPEvent.RESULT, soap_getAllTypesHandler );
		}

		private function soap_connectedHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = true;
			addHandlers();
		}
		
		private function soap_disconnectedHandler( event : SOAPEvent ) : void
		{
			isSOAPConnected = false;
		}
		
		private function soap_getAllTypesHandler( event : net.vdombox.ide.core.events.SOAPEvent ) : void
		{
			var typesXML : XML = event.result.Types[ 0 ];
			
			var types : Array = [];
			var topLevelTypes : Array = [];
			
			for each ( var type : XML in typesXML.* )
			{
				var typeVO : TypeVO = new TypeVO( type );
				types.push( typeVO );
				
				if( typeVO.container == 3 )
					topLevelTypes.push( typeVO );
			}
			
			if( types.length > 0 )
				_types = types;
			
			if( topLevelTypes.length > 0 )
				_topLevelTypes = topLevelTypes;

			sendNotification( ApplicationFacade.TYPES_LOADED, types );
		}
	}
}