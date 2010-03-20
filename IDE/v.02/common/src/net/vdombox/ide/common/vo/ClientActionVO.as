package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class ClientActionVO
	{
		[Bindable]
		public var top : int;
		
		[Bindable]
		public var left : int;
		
		[Bindable]
		public var state : Boolean;
		
		private var _name : String;
		
		private var _parameters : Array = [];
		
		public function get name() : String
		{
			return _name;
		}
		
		public function get parameters() : Array
		{
			return _parameters;
		}
		
		public function setProperties( propertiesXML : XML ) : void
		{
			var testValue : String;
			
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
			var parameterXML : XML;
			
			var actionParameterVO : ActionParameterVO;
			
			if ( parametersXML )
			{
				for each ( parameterXML in parametersXML.* )
				{
					actionParameterVO = new ActionParameterVO();
					actionParameterVO.setProperties( parameterXML );
					
					_parameters.push( actionParameterVO );
				}
			}
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