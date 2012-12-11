package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.collections.ArrayCollection;
	import mx.controls.Button;
	import mx.controls.ComboBox;
	import mx.controls.Text;
	import mx.controls.TextArea;
	import mx.controls.TextInput;
	import mx.utils.StringUtil;
	
	import net.vdombox.powerpack.lib.player.control.DialogComboBox;
	import net.vdombox.powerpack.lib.player.customize.skins.DropdownArrowButtonSkin;
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;

	public class ComboBoxAnswer extends Answer
	{
		public  var comboBox : DialogComboBox = new DialogComboBox();
		
		public function ComboBoxAnswer(data:String )
		{
			super(data);
			
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
			
			createComboBox();
		}
		
		private function createComboBox():void
		{
			comboBox.percentWidth = 100;
			comboBox.dataProvider = comboData;
			
			addChild(comboBox);
		}
		
		private function get comboData () : ArrayCollection
		{
//			var variants : Array = dataProvider.slice(2);
//			
//			if (variants.length == 1)
//				variants = String(variants[0]).split(",");
			
			return new ArrayCollection(answerVariants);
		}
		
		override public function get value () : String
		{
			if (comboBox.selectedItem )
				return comboBox.selectedItem.value.toString();
			
			return "";
		}
		
		
	}
}