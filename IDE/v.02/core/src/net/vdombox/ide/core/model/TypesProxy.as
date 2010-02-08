package net.vdombox.ide.core.model
{
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.events.SOAPEvent;
	import net.vdombox.ide.core.model.business.SOAP;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	[ResourceBundle( "Types" )]
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

		override public function onRegister() : void
		{
			_types = [];
			_topLevelTypes = [];
			
			addHandlers();
		}

		override public function onRemove() : void
		{
			_types = null;
			_topLevelTypes = null;
			
			removeHandlers();
		}

		public function get types() : Array
		{
			return _types.slice();
		}

		public function get topLevelTypes() : Array
		{
			return _topLevelTypes.slice();
		}
		
		public function get numTypes() : uint
		{
			return _types.length;
		}

		public function loadTypes() : void
		{
			sendNotification( ApplicationFacade.TYPES_LOADING );
			soap.get_all_types();
		}

		public function getType( typeID : String ) : TypeVO
		{
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

		private function soap_getAllTypesHandler( event : net.vdombox.ide.core.events.SOAPEvent ) : void
		{
			var typesXML : XML = event.result.Types[ 0 ];
			
			for each ( var type : XML in typesXML.* )
			{
				var typeVO : TypeVO = new TypeVO( type );
				_types.push( typeVO );
				
				if( typeVO.container == 3 )
					_topLevelTypes.push( typeVO );
			}

			sendNotification( ApplicationFacade.TYPES_LOADED, types );
		}
	}
}