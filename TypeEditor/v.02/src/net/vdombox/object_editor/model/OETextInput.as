package net.vdombox.object_editor.model
{
	import mx.states.OverrideBase;
	
	import spark.components.TextInput;
	
	
	
	public class OETextInput extends TextInput
	{
		private var wordCode:String = "";
		
		public function OETextInput()
		{
			super();
		}
		
		override public function set text(value:String):void
		{
			var  regResource:RegExp = /#Lang\((\d+)\)/;
			var matchResult:Array = value.match(regResource);
			matchResult[1];
			
			wordCode = value;
			
			var language:Language = Language.getInstance();
			super.text = language.getWord(matchResult[1]);
			
		} 
		
		override public function get text():String
		{
			return 	wordCode;
		} 
	}
}