package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.WindowEvent;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.view.components.ResourceSelector;
	import net.vdombox.ide.modules.tree.view.components.ResourceSelectorWindow;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ResourceSelectorWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ResourceSelectorWindowMediator";

		public function ResourceSelectorWindowMediator( resourceSelectorWindow : ResourceSelectorWindow ) : void
		{
			viewComponent = resourceSelectorWindow;

			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var _resourceSelector : ResourceSelector;


		public function set resourceSelector( value : ResourceSelector ) : void
		{
			_resourceSelector = value;
		}

		public function get resourceSelectorWindow() : ResourceSelectorWindow
		{
			return viewComponent as ResourceSelectorWindow;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			addHandlers();

			resourceSelectorWindow.value = _resourceSelector.value;

			sendNotification( Notifications.GET_RESOURCES, statesProxy.selectedApplication );
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
					resourceSelectorWindow.resources = body as Array;

					var resourceVO : ResourceVO;

					for each ( resourceVO in body )
					{
						sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			resourceSelectorWindow.addEventListener( WindowEvent.PERFORM_CANCEL, cancelHandler, false, 0, true );
			resourceSelectorWindow.addEventListener( WindowEvent.PERFORM_APPLY, applyHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			resourceSelectorWindow.removeEventListener( WindowEvent.PERFORM_CANCEL, cancelHandler );
			resourceSelectorWindow.removeEventListener( WindowEvent.PERFORM_APPLY, applyHandler );
		}

		private function applyHandler( event : WindowEvent ) : void
		{
			_resourceSelector.value = resourceSelectorWindow.value;
			facade.removeMediator( mediatorName );

			//sendNotification( Notifications.CLOSE_WINDOW, resourceSelectorWindow );
		}

		private function cancelHandler( event : WindowEvent ) : void
		{
			facade.removeMediator( mediatorName );

			//sendNotification( Notifications.CLOSE_WINDOW, resourceSelectorWindow );
		}
	}
}
