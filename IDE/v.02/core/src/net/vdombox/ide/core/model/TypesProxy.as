package net.vdombox.ide.core.model
{
	import mx.rpc.events.FaultEvent;
	
	import net.vdombox.ide.common.model.TypesProxy;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	import net.vdombox.ide.core.model.managers.TypesManager;

	/**
	 * ObjectProxy is wrapper on VDOM Object.   
	 * Takes data from the server through the SOAP functions.
	 * 
	 * @see net.vdombox.ide.common.vo.TypeVO
	 * @see net.vdombox.ide.core.model.business.SOAP
	 * @see net.vdombox.ide.core.controller.requests.TypesProxyRequestCommand
	 * 
	 *  @author Alexey Andreev
	 * 
	 * @flowerModelElementId _DE2aoEomEeC-JfVEe_-0Aw
	 */
	public class TypesProxy extends net.vdombox.ide.common.model.TypesProxy
	{
		public static const NAME : String = "TypesProxy";
		
		public static const TYPES_PROXY_REQUEST : String = "typesProxyRequest";
		public static const TYPES_PROXY_RESPONSE : String = "typesProxyResponse";
		
		public static const TYPES_LOADING : String = "typesLoading";
		public static const TYPES_LOADED : String = "typesLoaded";
		public static const GET_TYPES : String = "getTypes";
		
		public function TypesProxy( data : Object = null )
		{
			super( data );
		}

		private var soap : SOAP;

		private var _types : Array;
		private var _topLevelTypes : Array;

		private var isSOAPConnected : Boolean;
		
		private var typesManager : TypesManager;
		
		private var updateTypesCount : int;
		
		public var isTypesLoaded : Boolean;
		
		public var hasTagVersion : Boolean;
		
		private var serverProxy : ServerProxy;
		
		override public function onRegister() : void
		{
			soap = SOAP.getInstance();
			
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
			
			typesManager = TypesManager.getInstance();
			
			soap.addEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectedHandler, false, 0, true );
		}

		override public function onRemove() : void
		{
			unloadTypes();

			soap.removeEventListener( SOAPEvent.CONNECTION_OK, soap_connectedHandler );
			soap.removeEventListener( SOAPEvent.DISCONNECTON_OK, soap_disconnectedHandler );
			
			removeHandlers();
		}

		public override function get types() : Array
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
				sendNotification( TYPES_LOADING );
				isTypesLoaded = false;
				
				soap.list_types();
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
			soap.get_all_types.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.list_types.addEventListener( SOAPEvent.RESULT, soap_getListTypesHandler );
			soap.list_types.addEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_type.addEventListener( SOAPEvent.RESULT, soap_getTypeHandler );
			soap.get_type.addEventListener( FaultEvent.FAULT, soap_faultHandler );
		}

		private function removeHandlers() : void
		{
			soap.get_all_types.removeEventListener( SOAPEvent.RESULT, soap_getAllTypesHandler );
			soap.get_all_types.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.list_types.removeEventListener( SOAPEvent.RESULT, soap_getListTypesHandler );
			soap.list_types.removeEventListener( FaultEvent.FAULT, soap_faultHandler );
			
			soap.get_type.addEventListener( SOAPEvent.RESULT, soap_getTypeHandler );
			soap.get_type.addEventListener( FaultEvent.FAULT, soap_faultHandler );
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
		
		private function soap_getTypeHandler( event : net.vdombox.ide.core.events.SOAPEvent ) : void
		{
			var typeXML : XML = event.result.Type[0];
			
			var typeVO : TypeVO = new TypeVO( typeXML );
			
			_types.push( typeVO );
			
			if( typeVO.container == 3 )
				_topLevelTypes.push( typeVO );
			
			typesManager.setType( serverProxy.authInfo, typeXML );
			
			if ( --updateTypesCount <= 0 )
			{
				isTypesLoaded = true;
				
				sendNotification( TYPES_LOADED, _types );
			}
		}
		
		private function soap_getListTypesHandler( event : net.vdombox.ide.core.events.SOAPEvent ) : void
		{
			
			var typesXML : XML = event.result.Types[ 0 ];
			
			serverProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			hasTagVersion = typesXML.Type[0].@version[0];
			
			if ( !typesManager.hasServer( serverProxy.authInfo ) )
			{
				soap.get_all_types();
			}
			else
			{
				var types : Array = typesManager.getTypes( serverProxy.authInfo, typesXML );
				
				_types = new Array();
				_topLevelTypes = new Array();
				
				var updateTypes : Array = new Array();
				
				var _typesServer : Object = [];
				
				for each ( var type : XML in typesXML.* )
				{
					_typesServer[ type.@id ] = type.@id;
				}
				
				for each ( var typeVO : TypeVO in types )
				{
					var xml : XML = typesXML..Type.( @id == typeVO.id )[ 0 ];
					if ( xml )
					{
						if ( !hasTagVersion || typeVO.version == xml.@version )
						{
							delete _typesServer[ typeVO.id ];
							_types.push( typeVO );
							if( typeVO.container == 3 )
								_topLevelTypes.push( typeVO );
						}
					}						
				}
				
				for each ( var str : String in _typesServer )
					updateTypes.push( str );
				
				if ( updateTypes.length == 0 )
				{
					isTypesLoaded = true;
					sendNotification( TYPES_LOADED, _types );
				}
				else
				{
					updateTypesCount = updateTypes.length;
					for each ( var typeID : String in updateTypes )
					{
						soap.get_type(typeID);
					}
				}
				
			}
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
			
			typesManager.setTypes( serverProxy.authInfo, typesXML );
			
			sendNotification( TYPES_LOADED, _types );

			isTypesLoaded = true;
		}
		
		private function soap_faultHandler( event : FaultEvent ) : void
		{	
			sendNotification( ApplicationFacade.WRITE_ERROR, { text: event.fault.faultString, detail : event.fault.faultDetail } );
		}
	}
}