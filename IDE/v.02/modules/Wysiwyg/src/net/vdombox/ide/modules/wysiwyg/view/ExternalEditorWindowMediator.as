package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.interfaces.IExternalManager;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.events.ExternalEditorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.externalEditor.ExternalEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ExternalEditorWindow;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ExternalEditorWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ExternalEditorWindowMediator";

		public function ExternalEditorWindowMediator( externalEditorWindow : ExternalEditorWindow ) : void
		{
			viewComponent = externalEditorWindow;
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var _externalEditor : ExternalEditor;

		public function set externalEditor( value : ExternalEditor ) : void
		{
			_externalEditor = value;
		}

		private function get externalEditorWindow() : ExternalEditorWindow
		{
			return viewComponent as ExternalEditorWindow;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			addHandlers();

			var resourceVO : ResourceVO = new ResourceVO( statesProxy.selectedObject ? statesProxy.selectedObject.typeVO.id : statesProxy.selectedPage.typeVO.id );
			resourceVO.setID( _externalEditor.resourceID );

			externalEditorWindow.applicationID = statesProxy.selectedApplication.id;
			externalEditorWindow.objectID = statesProxy.selectedObject ? statesProxy.selectedObject.id : statesProxy.selectedPage.id;
			externalEditorWindow.value = _externalEditor.value;
			externalEditorWindow.externalManager = facade.retrieveMediator( ExternalManagerMediator.NAME ) as IExternalManager;
			externalEditorWindow.resourceVO = resourceVO;

			sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
		}

		override public function onRemove() : void
		{
			removeHandlers();
			statesProxy = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.RESOURCES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case Notifications.RESOURCES_GETTED:
				{
					//					externalEditorWindow.resourceVO = body as Array;

					//					var resourceVO : ResourceVO;
					//					
					//					for each( resourceVO in body )
					//					{
					//						sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
					//					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			externalEditorWindow.addEventListener( Event.CLOSE, closeHandler );
			externalEditorWindow.addEventListener( ResourceVOEvent.APPLY, applyHandler );
		}

		private function removeHandlers() : void
		{
			externalEditorWindow.removeEventListener( Event.CLOSE, closeHandler );
			externalEditorWindow.removeEventListener( ResourceVOEvent.APPLY, applyHandler );
		}

		private function applyHandler( event : ExternalEditorWindowEvent ) : void
		{
			//			PopUpManager.removePopUp( externalEditorWindow );

			facade.removeMediator( mediatorName );
			_externalEditor.value = externalEditorWindow.value;
		}

		private function closeHandler( event : Event ) : void
		{
			_externalEditor.value = externalEditorWindow.value;


			facade.removeMediator( mediatorName );
		}
	}
}
