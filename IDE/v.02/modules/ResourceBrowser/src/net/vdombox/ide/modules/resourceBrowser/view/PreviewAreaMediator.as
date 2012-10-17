package net.vdombox.ide.modules.resourceBrowser.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.PreviewArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PreviewAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PreviewAreaMediator";

		public function PreviewAreaMediator( viewComponent : PreviewArea )
		{
			super( NAME, viewComponent );
		}

		public function get previewArea() : PreviewArea
		{
			return viewComponent as PreviewArea;
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
			interests.push( Notifications.RESOURCE_DELETED );
			

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
					previewArea.resourceVO = statesProxy.selectedResource;

					break;
				}
					
				case Notifications.RESOURCE_LOADED:
				{
					previewArea.resourceVO = body as ResourceVO;
					
					break;
				}
					
				case Notifications.RESOURCE_DELETED:
				{
					previewArea.resourceVO = null;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
		}

		private function removeHandlers() : void
		{
		}

		private function clearData() : void
		{
			previewArea.resourceVO = null;
		}
	}
}