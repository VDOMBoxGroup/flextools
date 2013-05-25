package net.vdombox.ide.modules.wysiwyg.model.vo
{
	public class RendererCoordinateAndSizeVO
	{
		private var _x : int;
		private var _y : int ;
		private var _width : int;
		private var _height : int;
		public static var nullValue : int = -10; 
		
		public function RendererCoordinateAndSizeVO()
		{
		}

		public function get x():int
		{
			return _x;
		}

		public function set x(value:int):void
		{
			_x = value;
		}

		public function get y():int
		{
			return _y;
		}

		public function set y(value:int):void
		{
			_y = value;
		}

		public function get width():int
		{
			return _width;
		}

		public function set width(value:int):void
		{
			_width = value;
		}

		public function get height():int
		{
			return _height;
		}

		public function set height(value:int):void
		{
			_height = value;
		}

		public function setData( x : int, y : int, width : int, height : int ) : void
		{
			_x = x;
			_y = y;
			_width = width;
			_height = height;
		}
		
	}
}