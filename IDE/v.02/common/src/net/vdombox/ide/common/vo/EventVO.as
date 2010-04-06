package net.vdombox.ide.common.vo
{
	

	public class EventVO
	{
		[Bindable]
		public var top : int;
		
		[Bindable]
		public var left : int;
		
		[Bindable]
		public var state : Boolean = true;
		
		private var _name : String;
		
		private var _objectID : String;
		private var _objectName : String;
		
		private var _containerID : String;
		
		private var _parameters : Array = [];

		public function get name() : String
		{
			return _name;
		}

		public function get objectID() : String
		{
			return _objectID;
		}
		
		public function get objectName() : String
		{
			return _objectName;
		}
		
		public function get containerID() : String
		{
			return _containerID;
		}
		
		public function get parameters() : Array
		{
			return _parameters;
		}
		
		public function setName( value : String ) : void
		{
			_name = value;
		}
		
		public function setObjectID( value : String ) : void
		{
			_objectID = value;
		}
		
		public function setObjectName( value : String ) : void
		{
			_objectName = value;
		}
		
		public function setContainerID( value : String ) : void
		{
			_containerID = value;
		}
		
		public function setParameters( value : Array ) : void
		{
			_parameters = value;
		}
		
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;
			
			testValue = propertiesXML.@Name[ 0 ];
			
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
			
			testValue = propertiesXML.@ContainerID[ 0 ];
			
			if( testValue !== null )
				_containerID = testValue;
			
			testValue = propertiesXML.@ObjSrcID[ 0 ];
			
			if( testValue !== null )
				_objectID = testValue;
			
			var parametersXML : XML = propertiesXML.Parameters[ 0 ];
			var parameterXML : XML;
			var eventParameterVO : EventParameterVO;
			
			if ( parametersXML )
			{
				for each ( parameterXML in parametersXML.* )
				{
					eventParameterVO = new EventParameterVO();
					eventParameterVO.setProperties( parameterXML );
					_parameters.push( eventParameterVO );
				}
			}
		}
		
		public function copy() : EventVO
		{
			var copy : EventVO = new EventVO();
			
			copy.setName( _name );
			
			copy.setObjectID( _objectID );
			copy.setObjectName( _objectName );
			copy.setContainerID( _containerID );
			
			copy.setParameters( _parameters.slice() );
			
			return copy;
		}
		
		public function toXML() : XML
		{
			var result : XML = <Event />;
			
			result.@Name = _name;
			result.@ObjSrcID = _objectID;
			result.@ContainerID = _containerID;
			result.@Top = top;
			result.@Left = left;
			result.@State = state;
			
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