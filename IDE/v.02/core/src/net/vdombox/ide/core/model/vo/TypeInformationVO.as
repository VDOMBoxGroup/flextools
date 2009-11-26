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
				propertyName = property.localName().toString();
				propertyValue = property[ 0 ].toString();
				
				propertyObject[ propertyName ] = propertyValue;
				continue;
			}
		}
		
		private var resourceManager : IResourceManager = ResourceManager.getInstance();
		
		private var _typeName : String;
		
		private var propertyObject : Object;
	}
}