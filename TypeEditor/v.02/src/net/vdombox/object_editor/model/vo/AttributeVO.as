package net.vdombox.object_editor.model.vo
{	
	public class AttributeVO
	{	
		[Bindable]
		public var name			:String = "";
		public var displayName	:String = "#Lang(101)";
		public var defaultValue	:String = "";		
		public var visible		:Boolean = false;	
		public var help			:String = "#Lang(301)";
		public var interfaceType:uint = 0;
		public var codeInterface:String = "";		
		public var colorgroup	:uint = 0;	
		public var errorValidationMessage		:String = "#Lang(201)";
		public var regularExpressionValidation	:String = "";

		public function AttributeVO(attributeName:String = "")
		{				
			name = attributeName;
		}
	}
}


