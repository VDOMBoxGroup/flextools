package net.vdombox.ide.modules.resourceBrowser.view
{
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.resourceBrowser.events.WorkAreaEvent;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.PreviewArea;
	import net.vdombox.ide.modules.resourceBrowser.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		private var statesProxy : StatesProxy;

		private var isActive : Boolean;

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

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

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( StatesProxy.SELECTED_RESOURCE_CHANGED );
			
			interests.push( Notifications.RESOURCE_LOADED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( notification.getName() )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case StatesProxy.SELECTED_RESOURCE_CHANGED:
				{
					workArea.resourceVO = body as ResourceVO;

					break;
				}
					
				case Notifications.RESOURCE_LOADED:
				{
					workArea.resourceVO = body as ResourceVO;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( WorkAreaEvent.DELETE_RESOURCE, deleteResourceHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.LOAD_RESOURCE, loadResourceHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.GET_ICON, getIconHandler, true, 0, true );
			workArea.addEventListener( WorkAreaEvent.ERROR, errorHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( WorkAreaEvent.DELETE_RESOURCE, deleteResourceHandler );
			workArea.removeEventListener( WorkAreaEvent.LOAD_RESOURCE, loadResourceHandler );
			workArea.removeEventListener( WorkAreaEvent.GET_ICON, getIconHandler, true );
			workArea.removeEventListener( WorkAreaEvent.ERROR, errorHandler);
		}

		private function clearData() : void
		{
			workArea.isInfoShowed = true;
			workArea.isAddResourcesShowed = false;
			workArea.resourceVO = null;
		}

		private function deleteResourceHandler( event : WorkAreaEvent ) : void
		{
			//sendNotification( Notifications.DELETE_RESOURCE_REQUEST );
			sendNotification( Notifications.DELETE_RESOURCE, { applicationVO: statesProxy.selectedApplication, resourceVO: workArea.resourceVO } );
		}
		
		private function loadResourceHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.LOAD_RESOURCE, workArea.previewArea.resourceVO );
		}
		
		private function getIconHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.GET_ICON, workArea.previewArea.resourceVO );
		}
		
		private function errorHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.WRITE_ERROR, { applicationVO: statesProxy.selectedApplication, content: event.content } );
		}

	}
}