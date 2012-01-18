package net.vdombox.powerpack.panel.popup
{
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

	public class TextAnswer extends Answer
	{
		
		private var textInput : TextInput;
		private var text1 : Text;
		
		public function TextAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			craeteLabel();
			createTextInput();
			
		}
		private function craeteLabel():void
		{
			if (label == "")
				return;
			
			text1 = new Text();
			text1.percentWidth = 100; 
			
			text1.styleName = "infoTextStyle";
			text1.selectable = false;
			text1.text = label;
			addChild(text1);
		}
		
		private function createTextInput():void
		{
			textInput = new TextInput();
			textInput.percentWidth = 100;
			textInput.styleName = "answerInputTextStyle";
			
			addChild(textInput);

			if ( dataArray[2])
			{
				var defaulValue : String =  ListParser.getElm( dataProvider , 3);
				
				if ( defaulValue )
					textInput.text = clearString( defaulValue );
			}
//			textInput.setStyle("top", 10);
//			textInput.setStyle("bottom", 0);
			
		}
		
		override public function get value () : String
		{
			return textInput.text;
		}
	}
}