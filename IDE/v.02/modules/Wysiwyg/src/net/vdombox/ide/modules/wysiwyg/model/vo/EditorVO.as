package net.vdombox.ide.modules.wysiwyg.model.vo
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;

	public class EditorVO extends EventDispatcher
	{
		private var _vdomObjectVO : IVDOMObjectVO;
		private var _renderVO : RenderVO;
		private var _vdomObjectXMLPresentationVO : VdomObjectXMLPresentationVO;

		[Bindable( event="vdomObjectVOChanged" )]
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

			_vdomObjectVO = value;
			
			dispatchEvent( new Event( "vdomObjectVOChanged" ) );
		}

		[Bindable( event="renderVOChanged" )]
		public function get renderVO() : RenderVO
		{
			return _renderVO;
		}

		public function set renderVO( value : RenderVO ) : void
		{
			if ( _vdomObjectVO && value && value.vdomObjectVO && value.vdomObjectVO.id == _vdomObjectVO.id )
				_renderVO = value;
			else
				_renderVO = null;

			dispatchEvent( new Event( "renderVOChanged" ) );
		}

		[Bindable( event="vdomObjectXMLPresentationVOChanged" )]
		public function get vdomObjectXMLPresentationVO() : VdomObjectXMLPresentationVO
		{
			return _vdomObjectXMLPresentationVO;
		}

		public function set vdomObjectXMLPresentationVO( value : VdomObjectXMLPresentationVO ) : void
		{
			if ( _vdomObjectVO && value && value.vdomObjectVO && value.vdomObjectVO.id == _vdomObjectVO.id )
				_vdomObjectXMLPresentationVO = value;
			else
				_vdomObjectXMLPresentationVO = null;
			
			dispatchEvent( new Event( "vdomObjectXMLPresentationVOChanged" ) );
		}
	}
}