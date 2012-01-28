package net.vdombox.powerpack.panel.popup.Answers
{
	import mx.containers.VBox;
	import mx.controls.Text;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	import net.vdombox.powerpack.gen.parse.parseClasses.LexemStruct;
	
	public class Answer extends VBox
	{
		private var _dataProvider : Array;
		private var textLabel : Text;
		private var dataProvaiderString : String;
		
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
				value[i] =  clearString (ListParser.getElm( value , i+1 ));
//				if (value[i] is LexemStruct)
//					value[i] = clearString (LexemStruct(value[i]).value);
//				else
//					value[i] =  ListParser.getElm( dataProvider , 3)
//				var defaulValue : String =  ListParser.getElm( dataProvider , 3);
				
//				else if (value[i] is Object && value[i].hasOwnProperty("value"))
//					value[i] = value[i].value;
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
		
		public function clearString(value : String ): String
		{
			
			var length : int = value.length;
			if (length < 2)
				return value;
			
			var firstChar : String = value.charAt(0);
			var lastChar : String = value.charAt(length - 1);
			
			if (( firstChar  == '"' && lastChar  == '"')
				|| ( firstChar  == "'" && lastChar  == "'"))
				
				return value.substr(1, length - 2);
			
			return value;
		}
		
		
	}
}