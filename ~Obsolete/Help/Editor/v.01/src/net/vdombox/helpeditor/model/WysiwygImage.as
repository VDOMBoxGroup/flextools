package net.vdombox.helpeditor.model
{
	public class WysiwygImage
	{
		private var _src	: String = "";
		private var _width	: Number;
		private var _height	: Number;
		
		public function WysiwygImage()
		{
		}
		
		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			_height = value;
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			_width = value;
		}

		public function get src():String
		{
			return _src;
		}

		public function set src(value:String):void
		{
			_src = value;
		}

	}
}