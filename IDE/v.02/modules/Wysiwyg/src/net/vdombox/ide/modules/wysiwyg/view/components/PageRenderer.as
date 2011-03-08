package net.vdombox.ide.modules.wysiwyg.view.components
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;

	public class PageRenderer extends RendererBase
	{

		[SkinPart( required="true" )]
		public var transformMarker : TransformMarker;

		private var _selectedRenderer : IRenderer;
		private var isSelectedRendererChanged : Boolean;

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if ( instance == transformMarker )
				invalidateProperties();
		}

		public function set selectedRenderer( value : IRenderer ) : void
		{
			if ( _selectedRenderer != value )
			{
				_selectedRenderer = value;
				isSelectedRendererChanged = true;

				invalidateProperties();
			}
		}

		override public function set renderVO( value : RenderVO ) : void
		{
			if( transformMarker )
				transformMarker.renderer = null;
			
			super.renderVO = value;
		}

		override protected function commitProperties() : void
		{
			if ( isSelectedRendererChanged && transformMarker )
			{
				isSelectedRendererChanged = false;

				if ( !_selectedRenderer || _selectedRenderer == this )
				{
					transformMarker.renderer = null;
					transformMarker.visible = false;
					transformMarker.includeInLayout = false;
				}
				else
				{
					transformMarker.renderer = _selectedRenderer;
					transformMarker.visible = true;
					transformMarker.includeInLayout = true;
				}
			}
		}
	}
}