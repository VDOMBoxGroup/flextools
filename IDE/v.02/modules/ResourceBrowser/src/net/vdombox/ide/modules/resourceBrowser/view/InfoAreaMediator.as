package net.vdombox.ide.modules.resourceBrowser.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.InfoArea;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class InfoAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "InfoAreaMediator";

		public function InfoAreaMediator( viewComponent : InfoArea )
		{
			super( NAME, viewComponent );
		}

		public function get infoArea() : InfoArea
		{
			return viewComponent as InfoArea;
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
					infoArea.resourceVO = statesProxy.selectedResource;

					break;
				}

				case Notifications.RESOURCE_LOADED:
				{
					infoArea.resourceVO = body as ResourceVO;

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
			infoArea.resourceVO = null;
		}
	}
}
