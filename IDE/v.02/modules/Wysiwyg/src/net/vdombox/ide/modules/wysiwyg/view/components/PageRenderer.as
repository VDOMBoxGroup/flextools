package net.vdombox.ide.modules.wysiwyg.view.components
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.PageRendererSkin;
	
	import spark.components.Group;

	public class PageRenderer extends RendererBase
	{

		[SkinPart( required="true" )]
		public var transformMarker : TransformMarker;

		private var _selectedRenderer : IRenderer;
		private var isSelectedRendererChanged : Boolean;

		public function PageRenderer()
		{
			super();
			addEventListener(FlexEvent.ADD, showHandler, false, 0, false);
		}
		
		override public function stylesInitialized():void {
			trace("stylesInitialized");
			super.stylesInitialized();
			setStyle("skinClass", Class(PageRendererSkin));
		}
		
		override protected function partAdded( partName : String, instance : Object ) : void
		{
			trace("partAdded");
			super.partAdded( partName, instance );

			if ( instance == transformMarker )
				invalidateProperties();
		}

		public function set selectedRenderer( value : IRenderer ) : void
		{
			trace("selectedRenderer");
			if ( _selectedRenderer != value )
			{
				_selectedRenderer = value;
				isSelectedRendererChanged = true;

				invalidateProperties();
			}
		}
//		RESTRICTED AUTO QUERY - start 
//		SESSION - sesso 
		override public function set renderVO( value : RenderVO ) : void
		{
			trace("renderVO");
			if( transformMarker )
				transformMarker.renderer = null;
			
			super.renderVO = value;
		}

		override protected function commitProperties() : void
		{
			trace("commitProperties");
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
			
//			var lines:Group = new Group();
//			lines.width = 200;
//			lines.height = 200;
//			
//			lines.graphics.lineStyle(0);
//			lines.graphics.beginFill(0);
//			lines.graphics.drawCircle(50,50, 40);
//			background.addElement(lines);
		}
		
		override protected function removeHandlers() : void
		{
			trace("\nremoveHandlers:");
			if ( !hasEventListener( FlexEvent.ADD))
				addEventListener(FlexEvent.ADD, showHandler, false, 0, false);
		}
		
		private function showHandler(event : FlexEvent):void
		{
			super.addHandlers();
		}
		
		
	}
}