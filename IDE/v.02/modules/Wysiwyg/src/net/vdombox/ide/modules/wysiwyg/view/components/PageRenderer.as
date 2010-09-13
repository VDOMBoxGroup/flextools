package net.vdombox.ide.modules.wysiwyg.view.components
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;

	public class PageRenderer extends ObjectRenderer
	{

		[SkinPart( required="true" )]
		public var transformMarker : TransformMarker;

		private var _selectedRenderer : IRenderer;
		private var isSelectedRendererChanged : Boolean;
		
		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );
			
			if( instance == transformMarker )
				invalidateProperties();
		}
		
		public function set selectedRenderer( value : IRenderer ) : void
		{
			if( _selectedRenderer != value )
			{
				_selectedRenderer = value;
				isSelectedRendererChanged = true;
				
				invalidateProperties();
			}
		}
		
		override protected function commitProperties():void
		{
			if( isSelectedRendererChanged && transformMarker )
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