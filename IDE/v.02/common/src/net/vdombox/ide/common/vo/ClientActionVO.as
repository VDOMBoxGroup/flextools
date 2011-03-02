package net.vdombox.ide.common.vo
{
	import mx.utils.UIDUtil;
	/**
	 * The ClientActionVO is Visual Object of VDOM Client Action.
	 * ClientAction is contained in VDOM Type (TypeVO). 
	 */	
	public class ClientActionVO
	{
		[Bindable]
		public var top : int;
		
		[Bindable]
		public var left : int;
		
		[Bindable]
		public var state : Boolean;
		
		private var _id : String;
		
		private var _objectID : String;
		private var _objectName : String;
		
		private var _name : String;
		
		private var _parameters : Array = [];
		
		public function get id() : String
		{
			return _id;
		}
		
		public function get objectID() : String
		{
			return _objectID;
		}
		
		public function get objectName() : String
		{
			return _objectName;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get parameters() : Array
		{
			return _parameters;
		}
		
		public function setID( value : String ) : void
		{
			_id = value;
		}
		
		public function setObjectID( value : String ) : void
		{
			_objectID = value;
		}
		
		public function setObjectName( value : String ) : void
		{
			_objectName = value;
		}
		
		public function setName( value : String ) : void
		{
			_name = value;
		}
		
		public function setParameters( value : Array ) : void
		{
			_parameters = value; 
		}
		//TODO: Разобраться с переименованием!
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;
			
			testValue = propertiesXML.@ID[ 0 ];
			
			if( testValue !== null )
				_id = testValue;
			
			testValue = propertiesXML.@ObjTgtID[ 0 ];
			
			if( testValue !== null )
				_objectID = testValue;
			
			testValue = propertiesXML.@MethodName[ 0 ];
			
			if( testValue !== null )
				_name = testValue;
			
			testValue = propertiesXML.@Top[ 0 ];
			
			if( testValue !== null )
				top = int( testValue );
			
			testValue = propertiesXML.@Left[ 0 ];
			
			if( testValue !== null )
				left = int( testValue );
			
			testValue = propertiesXML.@State[ 0 ];
			
			if( testValue !== null )
				state = testValue == "true" ? true : false;
			
			var parametersXML : XML = propertiesXML.Parameters[ 0 ];
			var parametersXMLList : XMLList
			var parameterXML : XML;
			
			if( parametersXML )
				parametersXMLList = parametersXML.Parameter;
			else
				parametersXMLList = propertiesXML.Parameter
			
			var actionParameterVO : ActionParameterVO;
			
			if ( parametersXMLList )
			{
				for each ( parameterXML in parametersXMLList )
				{
					actionParameterVO = new ActionParameterVO();
					actionParameterVO.setProperties( parameterXML );
					
					_parameters.push( actionParameterVO );
				}
			}
		}
		
		public function copy() : ClientActionVO
		{
			var copy : ClientActionVO = new ClientActionVO();
			
			//TODO: Создавать новый ID или просто копировать старый, если он есть?
			copy.setID( UIDUtil.createUID() );
			copy.setName( _name );
			
			copy.setObjectID( _objectID );
			copy.setObjectName( _objectName );
			
			copy.setParameters( _parameters.slice() );
			
			return copy;
		}
		
		public function toXML() : XML
		{
			var result : XML = <Action />;
			var actionParameterVO : ActionParameterVO;
			
			result.@MethodName = _name;
			result.@ID = _id;
			result.@ObjTgtID = _objectID;
			result.@Top = top;
			result.@Left = left;
			result.@State = state;
			
			for each ( actionParameterVO in _parameters )
			{
				result.appendChild( actionParameterVO.toXML() );
			}
			
			return result;
		}
		
//		private function getValue( value : String ) : String
//		{
//			var result : String = value ? value : "";
//			
//			var matchResult : Array = result.match( LANG_RE );
//			
//			var matchItem : String;
//			var phraseID : String;
//			
//			if ( matchResult && matchResult.length > 0 )
//			{
//				for each ( matchItem in matchResult )
//				{
//					phraseID = matchItem.substring( 6, matchItem.length - 1 );
//					result = value.replace( matchItem, resourceManager.getString( _typeID, phraseID ) );
//				}
//			}
//			
//			return result;
//		}
	}
}