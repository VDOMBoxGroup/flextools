package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.StateChangeEvent;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PageEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ObjectEditorMediator";

		public static var instancesNameList : Object = {};

		public function PageEditorMediator( pageEditor : PageEditor )
		{
			var instanceName : String = NAME + "/" + pageEditor.id;

			super( instanceName, pageEditor );

			instancesNameList[ instanceName ] = null;
		}

		private var sessionProxy : SessionProxy;

		public function get pageEditor() : PageEditor
		{
			return viewComponent as PageEditor;
		}

		public function get pageVO() : PageVO
		{
			return pageEditor.vdomObjectVO as PageVO;
		}
		
		public function get renderVO() : RenderVO
		{
			return pageEditor.renderVO;
		}
		
		public function set renderVO( value : RenderVO ) : void
		{
			pageEditor.renderVO = value;
		}
		
		public function get xmlPresentation() : String
		{
			return pageEditor.xmlPresentation;
		}
		
		public function set xmlPresentation( value : String ) : void
		{
			pageEditor.xmlPresentation = value;
		}
		
		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.XML_PRESENTATION_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;

			switch ( name )
			{
				case ApplicationFacade.BODY_STOP:
				{
					clearData();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			pageEditor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
			pageEditor.addEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler, false, 0, true );
			pageEditor.addEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler, false, 0, true );

			pageEditor.addEventListener( RendererEvent.CREATED, rendererCreatedHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			pageEditor.removeEventListener( SkinPartEvent.PART_ADDED, partAddedHandler );
		}

		private function clearData() : void
		{
		}

		private function partAddedHandler( event : SkinPartEvent ) : void
		{

		}

		private function partOpenedHandler( event : EditorEvent ) : void
		{
			if ( event.type == EditorEvent.WYSIWYG_OPENED && pageEditor.vdomObjectVO )
				sendNotification( ApplicationFacade.GET_WYSIWYG, pageEditor.vdomObjectVO );
			else if ( event.type == EditorEvent.XML_EDITOR_OPENED )
				sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: pageEditor.vdomObjectVO } );
		}

		private function rendererCreatedHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_CREATED, event.target as IRenderer );
		}
	}
}