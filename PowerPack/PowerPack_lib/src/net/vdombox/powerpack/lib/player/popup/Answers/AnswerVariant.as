package net.vdombox.powerpack.lib.player.popup.Answers
{
	public class AnswerVariant
	{
		public function AnswerVariant( label:String = "", value : String = "")
		{
			this.label = label;
			this.value = value;
		}
		
		private var _label : String = "";
		private var _value : String = "";
		
		
		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			_label = value;
		}
		
		public function get value():String
		{
			return _value;
		}
		
		public function set value(value:String):void
		{
			_value = value;
			
			if (!_value)
				_value = _label;
		}
		

	}
}