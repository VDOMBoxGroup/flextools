package net.vdombox.ide.common.model._vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;

	public class VdomObjectXMLPresentationVO
	{
		public function VdomObjectXMLPresentationVO( vdomObjectVO : IVDOMObjectVO )
		{
			_vdomObjectVO = vdomObjectVO;
		}

		public var xmlPresentation : String = "";

		private var _vdomObjectVO : IVDOMObjectVO;

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _vdomObjectVO;
		}
	}
}
