package net.vdombox.ide.common.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	/**
	 * The ActionParameterVO is Visual Object of VDOM Object.
	 * ActionParameterVO is contained in the Object`s Action. 
	 */		 
	public class ActionParameterVO
	{
		private const LANG_RE : RegExp = /#Lang\((\w+)\)/g;
		
		[Bindable]
		public var value : String;
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeID : String;
		
		private var _name : String;
		private var _displayName : String;
		private var _defaultValue : String;
		private var _help : String;
		private var _regularExpressionValidation : String;
		
		public function get typeID() : String
		{
			return _typeID;
		}
		
		public function get name() : String
		{
			return _name;
		}
		
//		public function get displayName() : String
//		{
//			return getValue( _displayName );
//		}
		
		public function get defaultValue() : String
		{
			return _defaultValue;
		}
		
//		public function get help() : String
//		{
//			return getValue( _help );
//		}
		
		public function get regularExpressionValidation() : String
		{
			return _regularExpressionValidation;
		}
		
		public function setProperties( propertiesXML : XML ) : void
		{
			//TODO: Гонимая локализация атрибутов "InterfaceName" и "Help"
			
			var defaultValue : String;
			
			_name = propertiesXML.@ScriptName[ 0 ];
			
			defaultValue = propertiesXML.@DefaultValue[ 0 ];
			
			if( defaultValue === null )
				defaultValue = propertiesXML[ 0 ];
			
			_defaultValue = defaultValue;
			value = defaultValue;
			
			_regularExpressionValidation = propertiesXML.@RegularExpressionValidation[ 0 ];
		}
		
		public function toXML() : XML
		{
			var result : XML;
			var xmlCharRegExp : RegExp = /[<>&"]+/;
			var value : String = this.value;
			
			if( value.search( xmlCharRegExp ) != -1 )
			{	
				value = value.replace(/\]\]>/g, "]]]]"+"><![CDATA[>" );
				value = "<Parameter ScriptName=\""+ _name +"\"><![CDATA[" + value + "]" + "]></Parameter>"
				result = new XML( value );
			}
			else
			{
				result =  <Parameter ScriptName={_name}>{value}</Parameter>;
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