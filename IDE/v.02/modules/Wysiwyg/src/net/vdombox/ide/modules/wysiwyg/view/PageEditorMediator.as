package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.StateChangeEvent;
	
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
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
			
			super( instanceName, PageEditor );
			
			instancesNameList[ instanceName ] = null;
		}

		private var sessionProxy : SessionProxy;

		public function get pageEditor() : PageEditor
		{
			return viewComponent as PageEditor;
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
					
				case ApplicationFacade.XML_PRESENTATION_GETTED:
				{
					pageEditor.xml = "zzz";
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			pageEditor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
			pageEditor.addEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler, false, 0, true );
			pageEditor.addEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler, false, 0, true );
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
			if( event.type == EditorEvent.WYSIWYG_OPENED )
				var d : * = "";
			else if( event.type == EditorEvent.XML_EDITOR_OPENED )
				sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO : pageEditor.vdomObjectVO } );
		}
	}
}