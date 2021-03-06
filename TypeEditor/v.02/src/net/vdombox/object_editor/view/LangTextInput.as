package net.vdombox.object_editor.view
{
	import flash.events.Event;

	import mx.collections.ArrayCollection;

	import net.vdombox.object_editor.model.vo.LanguagesVO;

	import spark.components.TextInput;

	public class LangTextInput extends TextInput
	{
		[Bindable]
		public var words:Object = {};
		[Bindable]
		public var currentLanguage:String;

		public function LangTextInput()
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

		public function clearTextArea( ):void
		{
			currentLanguage = null;
			words 			= null;			
			text 			= "";
		}
		
		/**
		 * 
		 * @param langsVO	- current LanguagesVO;
		 * @param fildValue	- value in format: #Lang("ID")
		 * 
		 */
		public function completeStructure( langsVO:LanguagesVO, fildValue:String):void
		{
			var fildID:String = getRegExpWord(fildValue);
			currentLanguage = langsVO.currentLocation;
			var wordsVO:ArrayCollection = langsVO.words;

			for each (var word:Object in wordsVO)
			{		
				if (word["ID"] == fildID)
				{
					words = word;
					super.text = words[currentLanguage];	
					break;
				}
			}
		}		

		/**
		 * 
		 * @param code in formate: #Lang(ID)
		 * @return ID
		 * 
		 */		
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

