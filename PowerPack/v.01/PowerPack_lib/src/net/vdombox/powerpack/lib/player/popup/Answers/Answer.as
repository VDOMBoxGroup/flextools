package net.vdombox.powerpack.lib.player.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Text;
	
	import net.vdombox.powerpack.lib.player.gen.parse.ListParser;
	import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.LexemStruct;
	
	public class Answer extends VBox
	{
		private var _dataProvider : Array;
		private var textLabel : Text;
		private var dataProvaiderString : String;
		
		public static var context : Array;
		
		public function Answer( data : String )
		{
			super();
			
			setStyle("verticalGap", 0);
			
			dataProvider = ListParser.list2Array( data);
			this.data =  data;
			
			validateLabel();
			
			percentWidth = 100;
		}

		public function get dataProvider() : Array
		{
			return _dataProvider;
		}
		
		public function set dataProvider(value : Array):void
		{
			for (var i:uint=0; i<value.length; i++)
			{
				value[i] =  ListParser.getElmValue( ListParser.array2List(value), i+1, context);
			}
			
			_dataProvider = value;
		}
		
		public function get value():String
		{
			return "";
		}
		
		private function validateLabel():void
		{
			if ( !dataProvider[1] )
				return;
			
			label = dataProvider[1];
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
				
			if ( !dataProvider )
			{
				throw Error("Possible answers are not declared!");
				return;
			}
			
			createLabel();
		}
		
		private function createLabel():void
		{
			if (label == "")
				return;
			
			textLabel = new Text();
			textLabel.percentWidth = 100; 
			
			textLabel.styleName = "infoTextStyle";
			textLabel.selectable = false;
			textLabel.text = label;
			
			addChild(textLabel);
		}
		
	}
}