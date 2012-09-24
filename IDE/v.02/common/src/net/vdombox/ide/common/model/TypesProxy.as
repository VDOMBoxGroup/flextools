package net.vdombox.ide.common.model
{
	import net.vdombox.editors.parsers.base.Field;
	import net.vdombox.editors.parsers.vdomxml.TypeDB;
	import net.vdombox.ide.common.model._vo.AttributeDescriptionVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	
	import org.puremvc.as3.multicore.interfaces.IProxy;
	import org.puremvc.as3.multicore.patterns.proxy.Proxy;

	public class TypesProxy extends Proxy implements IProxy
	{
		public static const NAME : String = "TypesProxy";
		
		//		types
		public static const GET_TYPES : String = "getTypes";
		public static const TYPES_GETTED : String = "typesGetted";
		
		public static const TYPES_CHANGED : String = "typesChanged";
		
		public static const GET_TYPE : String = "getType";
		public static const TYPE_GETTED : String = "typeGetted";
		
		//		pipe messages
		public static const PROCESS_TYPES_PROXY_MESSAGE : String = "processTypesProxyMessage";
		
		public static const GET_TOP_LEVEL_TYPES : String = "getTopLevelTypes";
		public static const TOP_LEVEL_TYPES_GETTED : String = "topLevelTypesGetted";
		
		public function TypesProxy( data : Object = null  )
		{
			super( NAME, data );
		}
		
		private var _types : Array;
		
		public var tableType : TypeVO;
		
		public function get types() : Array
		{
			if( !_types )
				_types = [];
			
			return _types;
		}
		
		public function set types( types : Array ) : void
		{
			_types = types;
			
			TypeDB.removeDB( "vdom" );
			
			TypeDB.setDB( "vdom", typeDB );
			
			sendNotification( TYPES_CHANGED, _types );
		}
		
		public function set dbtypes( types : Array ) : void
		{
			_types = [];
			
			var typeVO : TypeVO;
			for each ( typeVO in types )
			{
				if ( typeVO.id == "753ea72c-475d-4a29-96be-71c522ca2097" )
				{
					_types.push( typeVO );
				}
				else
				{
					var containers : Array = typeVO.containers.split( "," );
					
					var containerName : String;
					for each ( containerName in containers )
					{
						if ( containerName == "dbschema" )
						{
							_types.push( typeVO );
							
							if ( typeVO.name == "dbtable" )
							{
								tableType = typeVO;
							}
							break;
						}
					}
				}
			}
			
			TypeDB.removeDB( "vdom" );
			
			TypeDB.setDB( "vdom", typeDB );
			
			sendNotification( TYPES_CHANGED, _types );
		}
		
		public function get typeDB() : TypeDB
		{
			var result : TypeDB = new TypeDB();
			result.dbName = "vdom";
			
			var typeVO : TypeVO;
			var typeField : Field;
			var attributeDescriptionVO : AttributeDescriptionVO;
			
			for each ( typeVO in _types )
			{
				typeField = new Field( "type", 0, typeVO.name );
				
				typeField.typeVO = typeVO;
				
				/*for each ( attributeDescriptionVO in typeVO.attributeDescriptions )
				{
					typeField.members.setValue( attributeDescriptionVO.name, new Field( "attribute", 0, attributeDescriptionVO.name ) );
				}*/
				
				typeField.members.setValue( "name", new Field( "attribute", 0, "name" ) );
				
				result.addDefinition( typeField );
			}
			
			return result;
		}
		
		private var names : Array = new Array();
		
		public function getTypeVObyID( typeID : String ) : TypeVO
		{
			var result : TypeVO;
			
			for ( var i : int = 0; i < types.length; i++ )
			{
				if ( types[i].id == typeID )
				{
					result = types[i];
					break;
				}
			}
			
			return result;
		}
		
		public function cleanup() : void
		{
			_types = null;
		}
	}
}