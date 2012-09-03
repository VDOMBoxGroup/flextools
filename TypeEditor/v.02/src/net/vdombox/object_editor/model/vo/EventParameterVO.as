package net.vdombox.object_editor.model.vo
{
	public class EventParameterVO
	{
		public var name				:String = "";
		public var order			:String = "";
		public var vbType			:String = "";
		public var help				:String = "";
		
		public function EventParameterVO( parameterName:String = "" )
		{
			name = parameterName;
		}
	}
}