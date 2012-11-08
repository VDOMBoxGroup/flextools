package net.vdombox.editors.parsers
{
	public class AutoCompleteItemVO
	{
		public var icon : Class;
		public var value : String;
		public var transcription : String;
		public var description : String;
		
		public function AutoCompleteItemVO( icon : Class = null, value : String = "", transcription : String = "", description : String = "" )
		{
			this.icon = icon;
			this.value = value;
			this.transcription = transcription;
			this.description = description;
		}
	}
}