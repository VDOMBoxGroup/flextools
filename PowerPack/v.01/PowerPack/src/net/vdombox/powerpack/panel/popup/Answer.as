package net.vdombox.powerpack.panel.popup
{
	import mx.containers.VBox;
	
	import net.vdombox.powerpack.gen.parse.ListParser;
	
	public class Answer extends VBox
	{
		private var _dataProvider : String;
		
		private var _value : String;
		
		private var _dataArray : Array;
		
		public function Answer( data : String)
		{
			super();
			
			_dataProvider = data;
			_dataArray = ListParser.list2Array( data);
			
			validateLabel();
			
			percentWidth = 100;
		}

		public function get dataArray():Array
		{
			return _dataArray;
		}

		public function set dataArray(value:Array):void
		{
			_dataArray = value;
		}

		public function get dataProvider():String
		{
			return _dataProvider;
		}

		public function get value():String
		{
			return _value;
		}

		public function set dataProvider(value:String):void
		{
			_dataProvider = value;
		}
		
		// TODO: do it on validatPropeties
		private function validateLabel():void
		{
			if ( !dataArray[1] )
				return;
			
			label = clearString( ListParser.getElm( dataProvider , 2));
		}
		
		override protected function createChildren () : void
		{
			super.createChildren();
				
			if ( !_dataProvider )
			{
				throw Error("Possible answers are not declared!");
				return;
			}
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