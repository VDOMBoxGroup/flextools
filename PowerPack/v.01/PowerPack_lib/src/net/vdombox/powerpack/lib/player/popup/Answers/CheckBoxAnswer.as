package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Button;
	import mx.controls.CheckBox;
	import mx.controls.RadioButton;
	import mx.controls.RadioButtonGroup;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.skins.halo.CheckBoxIcon;
	
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;

	public class CheckBoxAnswer extends Answer
	{
		
		private var vBox : VBox;
		
		public function CheckBoxAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createCheckBoxesGroup();
			createCheckBoxes();
		}
		
		private function createCheckBoxes():void
		{
			for each (var variant:AnswerVariant in answerVariants) 
			{
				createCheckBox( variant );
			}
			
		}
		
		private function createCheckBoxesGroup():void
		{
			vBox= new VBox();
			vBox.setStyle( "paddingLeft", 10  );
			vBox.maxHeight = 200;
			vBox.percentWidth = 100;

			addChild( vBox );
		}
		
		private function createCheckBox( variant : AnswerVariant ):void
		{
			var checkBox : CheckBox;

			checkBox  = new CheckBox();
			checkBox.label = variant.label;
			checkBox.selected = variant.value == 'true' ? true : false;
			checkBox.styleName = "questionAnswerCheckBoxStyle";

			vBox.addChild( checkBox );
		}
		
		override public function get value () : String
		{
			var resultArr : Array = [];
			
			for each (var checkBox : CheckBox in vBox.getChildren())
			{
				resultArr.push(checkBox.selected.toString());
			}
			
			return ListParser.array2List(resultArr);
		}
		
	}
}