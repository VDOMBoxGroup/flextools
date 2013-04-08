package net.vdombox.ide.modules.wysiwyg.view.components
{
	import mx.containers.accordionClasses.AccordionHeader;
	import mx.events.DragEvent;

	import net.vdombox.ide.modules.wysiwyg.events.TypeItemRendererEvent;
	import net.vdombox.ide.modules.wysiwyg.model.business.VdomDragManager;
	import net.vdombox.ide.modules.wysiwyg.view.components.itemrenderer.TypeItemRenderer;

	public class TypesAccordionHeader extends AccordionHeader
	{

		public function TypesAccordionHeader()
		{
			super();

			addEventListener( DragEvent.DRAG_ENTER, dragEnterHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_EXIT, dragExitHandler, false, 0, true );
			addEventListener( DragEvent.DRAG_DROP, dragDropHandler, false, 0, true );
		}

		private function dragEnterHandler( event : DragEvent ) : void
		{
			if ( label != resourceManager.getString( 'Wysiwyg_General', 'toolbox_panel_user_category' ) )
				return;

			var vdomDragManager : VdomDragManager = VdomDragManager.getInstance();;
			vdomDragManager.acceptDragDrop( this );

			setStyle( "color", "green" );
		}

		private function dragExitHandler( event : DragEvent ) : void
		{
			if ( label != resourceManager.getString( 'Wysiwyg_General', 'toolbox_panel_user_category' ) )
				return;

			setStyle( "color", "white" );
		}

		private function dragDropHandler( event : DragEvent ) : void
		{
			if ( label != resourceManager.getString( 'Wysiwyg_General', 'toolbox_panel_user_category' ) )
				return;

			var typeItemRenderer : TypeItemRenderer = event.dragInitiator as TypeItemRenderer;

			if ( typeItemRenderer )
				typeItemRenderer.dispatchEvent( new TypeItemRendererEvent( TypeItemRendererEvent.ADD_IN_USER_CATIGORY ) );
		}
	}
}
