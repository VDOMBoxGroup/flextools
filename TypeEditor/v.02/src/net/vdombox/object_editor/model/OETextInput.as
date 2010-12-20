package net.vdombox.object_editor.model
{
	import mx.states.OverrideBase;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	
	import org.puremvc.as3.patterns.facade.Facade;
	
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
			//var langsProxy:LanguagesProxy = facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
			//temp
			//var word:String = langsProxy.getWord( sOnCarentLocal(objectTypeVO.languages);
			super.text = language.getWord(matchResult[1]);			
		} 
		
		override public function get text():String
		{
			return 	wordCode;
		} 
	}
}