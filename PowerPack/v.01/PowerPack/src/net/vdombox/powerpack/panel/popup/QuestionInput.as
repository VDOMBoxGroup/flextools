package net.vdombox.powerpack.panel.popup
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	
	import mx.containers.HBox;
	import mx.controls.TextArea;
	import mx.events.FlexEvent;

	public class QuestionInput extends Question
	{
		private var answerTextInput : TextArea;
		
		public function QuestionInput()
		{
			super ();
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			answerTextInput = new TextArea();
			answerTextInput.percentWidth = 100;
			//answerTextInput.percentHeight = 100;
			answerTextInput.setStyle("top", 10);
			answerTextInput.setStyle("bottom", 0);
			answerTextInput.setStyle("cornerRadius", 7);
			answerTextInput.setStyle("fontSize", 14);
			
			answerCanvas.addChild( answerTextInput );
			
			answerTextInput.addEventListener( Event.CHANGE, onTextInput );
			
			btnOk.enabled = false;
		}
		
		private function onTextInput (evt:Event) : void
		{
			btnOk.enabled = evt.target.text ? true : false;
		}
		
		override protected function btnOkClickHandler(evt:MouseEvent) : void
		{
			answerTextInput.addEventListener( Event.CHANGE, onTextInput );
			
			super.btnOkClickHandler(evt);
		}
		
		override protected function closeDialog() : void
		{
			strAnswer = answerTextInput.text;
			
			super.closeDialog();
		}
		
	}
}