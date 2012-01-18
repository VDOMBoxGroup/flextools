package net.vdombox.powerpack.panel.popup
{
	import mx.containers.VBox;
	
	public class Answer extends VBox
	{
		private var _dataProvider : Array;
		
		private var _value : String;
		
		public function Answer( data : Array)
		{
			super();
			
			_dataProvider = data;
		}

		

		public function get value():String
		{
			return _value;
		}

		public function set dataProvider(value:Array):void
		{
			_dataProvider = value;
		}

	}
}