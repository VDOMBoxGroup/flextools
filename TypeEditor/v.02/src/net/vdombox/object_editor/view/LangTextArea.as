package net.vdombox.object_editor.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.object_editor.model.vo.LanguagesVO;
	
	import spark.components.TextArea;
	
	public class LangTextArea extends TextArea
	{
		[Bindable]
		public var words:Object = new Object();
		[Bindable]
		public var currentLanguage:String;
		
		public function LangTextArea()
		{
			super();
			super.addEventListener( Event.CHANGE, newValue );			
		}
		
		private function newValue( event: Event ):void
		{
			words[currentLanguage] = text;
		}
		
		public function apdateFild( ):void
		{
			super.text = words[currentLanguage];			
		}
		
		public function completeStructure( langsVO:LanguagesVO, fildValue:String):void
		{
			var fildID:String = getRegExpWord(fildValue);
			currentLanguage = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;
			
			for each(var word:Object in wordsVO)
			{		
				if( word["ID"] == fildID)
				{
					words = word;
					super.text = words[currentLanguage];	
					return;
				}
			}
			words = null;
			text  = "";
		}
		
		private function getRegExpWord( code:String ):String
		{	
			var  regResource:RegExp = /#Lang\((\d+)\)/;
			var matchResult:Array = code.match(regResource);			
			if (matchResult)
			{
				return matchResult[1];
			}
			return "";
		}
		
	}
}