package net.vdombox.powerpack.panel.popup.Answers
{
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

	public class AnswerTextArea extends Answer
	{
		
		private var textInput : TextArea;
		private var textLabel : Text;
		
		public function AnswerTextArea(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createTextArea();
			
		}
		
		private function createTextArea():void
		{
			textInput = new TextArea();
			textInput.percentWidth = 100;
			textInput.styleName = "answerInputTextStyle";
			textInput.setStyle("bottom", 0);
			
			addChild(textInput);

			if ( dataProvider[2] )
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