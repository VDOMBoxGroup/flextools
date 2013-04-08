package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;

	public class LineVO
	{
		private var _x1 : Number;

		private var _y1 : Number;

		private var _x2 : Number;

		private var _y2 : Number;

		private var _type : int;

		private var _orientationH : Boolean;

		private var _eps : Number;

		private var _renderTo : RendererBase;

		public function LineVO( x1 : Number, y1 : Number, x2 : Number, y2 : Number, eps : Number, type : int, orientationH : Boolean, renderTo : RendererBase )
		{
			_x1 = x1;
			_y1 = y1;
			_x2 = x2;
			_y2 = y2;
			_eps = eps;
			_type = type;
			_orientationH = orientationH;
			_renderTo = renderTo;
		}

		public function get y2() : Number
		{
			return _y2;
		}

		public function get x2() : Number
		{
			return _x2;
		}

		public function get y1() : Number
		{
			return _y1;
		}

		public function get x1() : Number
		{
			return _x1;
		}

		public function get type() : int
		{
			return _type;
		}

		public function get eps() : Number
		{
			return _eps;
		}

		public function get orientationH() : Boolean
		{
			return _orientationH;
		}

		public function get renderTo() : RendererBase
		{
			return _renderTo;
		}


	}
}
