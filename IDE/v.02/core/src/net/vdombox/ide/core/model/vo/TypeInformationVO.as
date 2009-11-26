package net.vdombox.ide.core.model.vo
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;

	public class TypeInformationVO
	{
		public function TypeInformationVO( typeName : String, typeInformation : XML )
		{
			var propertyName : String;
			var propertyValue : String;
			
			_typeName = typeName;
			propertyObject = {};
			
			for each ( var property : XML in typeInformation.* )
			{
				propertyName = property.localName().toString().toLowerCase();
				propertyValue = property[ 0 ];
				
				propertyObject[ propertyName ] = propertyValue;
				continue;
			}
		}
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeName : String;
		
		private var propertyObject : Object;
		
		private var propertyRE : RegExp = /#Lang\((\w+)\)/;
		
		public function get id() : String
		{
			return getValue( "ID" );
		}
		
		public function get name() : String
		{
			return getValue( "name" );
		}
		
		public function get displayName() : String
		{
			return getValue( "DisplayName" );
		}
		
		public function get description() : String
		{
			return getValue( "Description" );
		}
		
		public function get className() : String
		{
			return getValue( "ClassName" );
		}
		
		public function get icon() : String
		{
			return getValue( "Icon" );
		}
		
		public function get editorIcon() : String
		{
			return getValue( "EditorIcon" );
		}
		
		public function get structureIcon() : String
		{
			return getValue( "StructureIcon" );
		}
		
		public function get moveable() : String
		{
			return getValue( "Moveable" );
		}
		
		public function get resizable() : String
		{
			return getValue( "Resizable" );
		}
		
		public function get category() : String
		{
			return getValue( "Category" );
		}
		
		public function get dynamic() : String
		{
			return getValue( "Dynamic" );
		}
		
		public function get version() : String
		{
			return getValue( "Version" );
		}
		
		public function get interfaceType() : String
		{
			return getValue( "InterfaceType" );
		}
		
		public function get optimizationPriority() : String
		{
			return getValue( "OptimizationPriority" );
		}
		
		public function get containers() : String
		{
			return getValue( "Containers" );
		}
		
		public function get container() : String
		{
			return getValue( "Container" );
		}
		
		private function getValue( valueName : String ) : String
		{
			var value : String = "";
			valueName = valueName.toLowerCase();
			
			if( !propertyObject.hasOwnProperty( valueName ) )
				return value;
			
			var matchResult : Array = String( propertyObject[ valueName ] ).match( propertyRE );
			
			if( matchResult )
				value = resourceManager.getString( _typeName, matchResult[ 1 ] );
			else
				value = propertyObject[ valueName ];
			
			return value;
		}
	}
}