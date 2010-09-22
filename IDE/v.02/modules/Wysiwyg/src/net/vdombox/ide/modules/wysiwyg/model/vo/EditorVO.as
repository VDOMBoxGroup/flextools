package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;

	[Bidable]
	public class EditorVO
	{
		private var _vdomObjectVO : IVDOMObjectVO;
		private var _renderVO : RenderVO;
		private var _vdomObjectXMLPresentationVO : VdomObjectXMLPresentationVO;

		public function get vdomObjectVO() : IVDOMObjectVO
		{
			return _vdomObjectVO;
		}

		public function set vdomObjectVO( value : IVDOMObjectVO ) : void
		{
			if ( _renderVO )
				renderVO = null;

			if ( _vdomObjectXMLPresentationVO )
				vdomObjectXMLPresentationVO = null;
		}

		public function get renderVO() : RenderVO
		{
			return _renderVO;
		}

		public function set renderVO( value : RenderVO ) : void
		{
			if ( _vdomObjectVO && value && value.vdomObjectVO && value.vdomObjectVO.id == _vdomObjectVO.id )
			{
				_renderVO = value;
			}
			else
				_renderVO = null;
		}

		public function get vdomObjectXMLPresentationVO() : VdomObjectXMLPresentationVO
		{
			return _vdomObjectXMLPresentationVO;
		}

		public function set vdomObjectXMLPresentationVO( value : VdomObjectXMLPresentationVO ) : void
		{
			if ( _vdomObjectVO && value && value.vdomObjectVO && value.vdomObjectVO.id == _vdomObjectVO.id )
			{
				_vdomObjectXMLPresentationVO = value;
			}
			else
				_vdomObjectXMLPresentationVO = null;
		}
	}
}