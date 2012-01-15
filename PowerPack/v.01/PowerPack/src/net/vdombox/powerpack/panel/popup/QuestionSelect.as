package net.vdombox.powerpack.panel.popup
{
	import mx.containers.VBox;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.events.FlexEvent;

	public class QuestionSelect extends QuestionBasePopup
	{
		private var radioBtnGroup : RadioButtonGroup;
		public var possibleAnswers : Array;
		
		private var vBox : VBox;
		public function QuestionSelect()
		{
			super();
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			if (!possibleAnswers)
			{
				throw Error("Possible answers are not declared!");
				return;
			}
			
			radioBtnGroup = new RadioButtonGroup();
			
			 vBox= new VBox();
			
			 vBox.maxHeight = 200;
			 vBox.percentWidth = 100;
			
			
			for ( var i : int = 0; i < possibleAnswers.length; i++ )
			{
				var radBtn : RadioButton = new RadioButton();
				radBtn.group = radioBtnGroup;
					
				radBtn.value = radBtn.label = possibleAnswers[i];
				vBox.addChild( radBtn );
				
				if ( i == 0 )
					radBtn.selected = true;
			}
			
			answerCanvas.addChild( vBox );
			
		}
		
		override protected function measure():void
		{
			super.measure();
			
			answerCanvas.height = vBox.height;
		}
		
		override protected function childrenCreated():void
		{
						super.childrenCreated();
		}
		
		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			trace ("ANS H : " + answerCanvas.height);
			
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			
		}
		
		override protected function closeDialog() : void
		{
			if ( radioBtnGroup.numRadioButtons > 0 )
			{
				if ( !radioBtnGroup.selectedValue )
					return;
				strAnswer = radioBtnGroup.selectedValue.toString();
			}
			
			super.closeDialog();
		}
	}
}