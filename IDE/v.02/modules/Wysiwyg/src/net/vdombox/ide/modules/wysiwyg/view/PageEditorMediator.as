package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.StateChangeEvent;
	
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PageEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PageEditorMediator";

		public function PageEditorMediator( pageEditor : PageEditor )
		{
			super( NAME, pageEditor );
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		public function get pageEditor() : PageEditor
		{
			return viewComponent as PageEditor;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			isActive = false;

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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			var pageXML : XML;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			pageEditor.addEventListener( StateChangeEvent.CURRENT_STATE_CHANGING, currentStateChangingHandler, false, 0, true );
			pageEditor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			pageEditor.removeEventListener( StateChangeEvent.CURRENT_STATE_CHANGING, currentStateChangingHandler );
			pageEditor.removeEventListener( SkinPartEvent.PART_ADDED, partAddedHandler );
		}

		private function clearData() : void
		{
		}

		private function currentStateChangingHandler( event : StateChangeEvent ) : void
		{

		}

		private function partAddedHandler( event : SkinPartEvent ) : void
		{

		}
	}
}