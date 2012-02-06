package net.vdombox.powerpack.panel.popup.Answers
{
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

	public class TextAnswer extends Answer
	{
		
		public  var textInput : TextInput = new TextInput();
		
		public function TextAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createTextInput();
			
		}
		
		private function createTextInput():void
		{
			textInput.percentWidth = 100;
			textInput.height = 27;
			textInput.styleName = "answerInputTextStyle";
			
			addChild(textInput);

			if ( dataProvider[2])
			{
				var defaulValue : String =  dataProvider[2];
				
				if ( defaulValue )
					textInput.text = defaulValue;
			}
			
		}
		
		override public function get value () : String
		{
			return textInput.text;
		}
	}
}