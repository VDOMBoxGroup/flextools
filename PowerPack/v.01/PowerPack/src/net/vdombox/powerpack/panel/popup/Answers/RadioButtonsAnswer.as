package net.vdombox.powerpack.panel.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;

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
			
		}
		
		private function createRadioButtonsGroup():void
		{
			radioBtnGroup = new RadioButtonGroup();
			
			vBox= new VBox();
			vBox.setStyle( "paddingLeft", 10  );
			vBox.maxHeight = 200;
			vBox.percentWidth = 100;

			addChild( vBox );
			
			
			var radBtn : RadioButton;
			
			var variants : Array = dataProvider.slice(2);
			
			if (variants.length == 1)
				variants = String(variants[0]).split(",");
			
			for each (var value:String in variants) 
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