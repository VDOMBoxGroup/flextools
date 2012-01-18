package net.vdombox.powerpack.panel.popup
{
	import mx.containers.VBox;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.events.FlexEvent;

	public class QuestionSelect extends Question
	{
		private var radioBtnGroup : RadioButtonGroup;
		public var possibleAnswers : Array;
		
		private var vBox : VBox;
		
		public function QuestionSelect( value :  Array = null )
		{
			super();
			possibleAnswers = value;
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
			 vBox.setStyle( "paddingLeft", 10  );
			 vBox.maxHeight = 200;
			 vBox.percentWidth = 100;
			 answerCanvas.addChild( vBox );
			 
			
			 var radBtn : RadioButton;
			 
			 for each (var value:String in possibleAnswers) 
			{
				radBtn  = new RadioButton();
				radBtn.value = value;
				radBtn.label = value;
				radBtn.group = radioBtnGroup;
				
				vBox.addChild( radBtn );
			}
			
			// select first radioButton
			radBtn = vBox.getChildAt(0) as RadioButton;
			
			if(radBtn)
				radBtn.selected = true;
		}
		
		override protected function measure():void
		{
			super.measure();
			
			answerCanvas.height = vBox.height;
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