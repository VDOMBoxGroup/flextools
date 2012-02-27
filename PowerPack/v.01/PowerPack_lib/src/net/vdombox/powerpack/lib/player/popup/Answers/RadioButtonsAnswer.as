package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;

	public class RadioButtonsAnswer extends Answer
	{
		
		private var radioBtnGroup : RadioButtonGroup;
		private var vBox : VBox;
		private var textLabel : Text;
		
		public function RadioButtonsAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createRadioButtonsGroup();
			createRadioButtons();
		}
		
		private function createRadioButtons():void
		{
			for each (var variant:AnswerVariant in answerVariants) 
			{
				createRadioButton( variant );
			}
			
			selectFirstRadioButton();
		}
		
		private function createRadioButtonsGroup():void
		{
			radioBtnGroup = new RadioButtonGroup();
			
			vBox= new VBox();
			vBox.setStyle( "paddingLeft", 10  );
			vBox.maxHeight = 200;
			vBox.percentWidth = 100;

			addChild( vBox );
		}
		
		private function selectFirstRadioButton():void
		{
			var radBtn : RadioButton;
			radBtn = vBox.getChildAt(0) as RadioButton;
			
			if(radBtn)
				radBtn.selected = true;
		}
		
		private function createRadioButton( variant : AnswerVariant ):void
		{
			var radBtn : RadioButton;

			if ( ! variant.value )
				variant.value = variant.label;
			
			radBtn  = new RadioButton();
			radBtn.label = variant.label;
			radBtn.value = variant.value;
			radBtn.group = radioBtnGroup;
			radBtn.styleName = "questionAnswerRadioBtn";
			
			vBox.addChild( radBtn );
			
			
			
		}
		override public function get value () : String
		{
			if ( radioBtnGroup.numRadioButtons > 0 && radioBtnGroup.selectedValue)
			{
				return radioBtnGroup.selectedValue.toString();
			}
			
			return "";
		}
		
	}
}