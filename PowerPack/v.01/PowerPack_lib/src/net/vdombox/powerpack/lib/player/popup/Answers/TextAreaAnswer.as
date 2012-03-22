package net.vdombox.powerpack.lib.player.popup.Answers
{
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.controls.Button;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;

	public class TextAreaAnswer extends Answer
	{
		
		private var textInput : TextArea;
		private var textLabel : Text;
		
		public function TextAreaAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createTextArea();
			
		}
		
		override public function setFocus () : void
		{
			if (textInput)
			{
				textInput.setFocus();
				return;
			}
			
			setFocus();
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
			
			textInput.addEventListener(KeyboardEvent.KEY_DOWN, textAreaKeyDownHandler)
		}
		
		private function textAreaKeyDownHandler (event : KeyboardEvent) : void
		{
			if (event.keyCode != Keyboard.ENTER)
				return;
			
			event.stopPropagation();
		}
		
		override public function get value () : String
		{
			return textInput.text;
		}
		
	}
}