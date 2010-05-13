package net.vdombox.ide.modules.tree.model.vo
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;

	[Bindable]
	public class TreeElementVO
	{
		public function TreeElementVO( pageVO : PageVO )
		{
			_pageVO = pageVO;

			top = 0;
			left = 0;
			
			resourceVO = null;
			
			state = false;
		}

		public var top : int;

		public var left : int;

		public var width : int;

		public var height : int;

		public var state : Boolean;

		public var resourceVO : ResourceVO;

		private var _pageVO : PageVO;

		public function get id() : String
		{
			return _pageVO.id;
		}

		public function get pageVO() : PageVO
		{
			return _pageVO;
		}
	}
}