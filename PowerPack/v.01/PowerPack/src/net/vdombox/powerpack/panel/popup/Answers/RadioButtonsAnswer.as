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
	import net.vdombox.powerpack.gen.parse.parseClasses.CodeFragment;
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
			createRadioButtons();
		}
		
		private function createRadioButtons():void
		{
			var variants : Array = dataProvider.slice(2);
			
			if (variants.length == 1)
			{
				var variantsStr : String = variants[0];
				var multyValue : Array = ListParser.list2Array( variantsStr );
				
				// data like  [ ['app1' 'guid1'] ['app2' 'guid2']  ['app3' 'guid3']]
				if ( multyValue[0] is CodeFragment )
				{
					var dataBt : String; 
					var labelBt : String; 
					var valueBt : String;
					
					for (var j:int = 0; j < multyValue.length; j++) 
					{
						dataBt  = ListParser.getElm( variantsStr, j+1 );
						
						labelBt  = ListParser.getElmValue( data, 1, context ).toString();
						valueBt  = ListParser.getElmValue( data, 2, context ).toString();
						
						createRadioButton( labelBt, valueBt );
					}
					
					selectFirstRadioButton();
					
					return;
				}
				else
				{
					variants = variantsStr.split(",");
				}
			}
			
			for each (var value:String in variants) 
			{
				createRadioButton( value );
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
		
		private function createRadioButton( label : String, data : String = null ):void
		{
			var radBtn : RadioButton;

			if ( ! data )
				data = label;
			
			radBtn  = new RadioButton();
			radBtn.label = label;
			radBtn.value = data;
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