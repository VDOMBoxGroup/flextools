package
{
	public class ImageProperties
	{
		private var _width : Number = -1;
		private var _height : Number = -1;
		
		public function ImageProperties()
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

	}
}