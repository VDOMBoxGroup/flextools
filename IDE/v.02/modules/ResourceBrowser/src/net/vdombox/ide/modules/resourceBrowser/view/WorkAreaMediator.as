package net.vdombox.ide.modules.resourceBrowser.view
{
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.events.WorkAreaEvent;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;
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

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

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

			interests.push( ApplicationFacade.SELECTED_RESOURCE_CHANGED );
			
			interests.push( ApplicationFacade.RESOURCE_LOADED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( notification.getName() )
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

				case ApplicationFacade.SELECTED_RESOURCE_CHANGED:
				{
					workArea.resourceVO = body as ResourceVO;

					break;
				}
					
				case ApplicationFacade.RESOURCE_LOADED:
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
			//sendNotification( ApplicationFacade.DELETE_RESOURCE_REQUEST );
			sendNotification( ApplicationFacade.DELETE_RESOURCE, { applicationVO: sessionProxy.selectedApplication, resourceVO: workArea.resourceVO } );
		}
		
		private function loadResourceHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( ApplicationFacade.LOAD_RESOURCE, workArea.previewArea.resourceVO );
		}
		
		private function getIconHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_ICON, workArea.previewArea.resourceVO );
		}
		
		private function errorHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( ApplicationFacade.WRITE_ERROR, { applicationVO: sessionProxy.selectedApplication, content: event.content } );
		}

	}
}