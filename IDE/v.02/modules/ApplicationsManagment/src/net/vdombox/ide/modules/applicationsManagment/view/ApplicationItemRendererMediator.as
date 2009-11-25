package net.vdombox.ide.modules.applicationsManagment.view
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.components.ApplicationItemRenderer;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationItemRendererMediator extends Mediator implements IMediator
	{
		public function ApplicationItemRendererMediator( viewComponent : Object = null )
		{
			super( getNextID(), viewComponent );
		}

		private static const NAME : String = "ApplicationItemRendererMediator";

		private static var serial : Number = 0;

		private static function getNextID() : String
		{
			return NAME + '/' + serial++;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( mediatorName + "/" + ApplicationFacade.RESOURCE_GETTED );

			return interests;
		}

		override public function onRegister() : void
		{
			var iconID : String = applicationItemRenderer.data.iconID;

			if ( iconID != "" )
				sendNotification( ApplicationFacade.GET_RESOURCE, { resourceID: iconID, recepientName: mediatorName });
		}

		override public function handleNotification( notification : INotification ) : void
		{
			applicationItemRenderer.imageHolder.source = notification.getBody().resourceVO.data;
		}

		private function get applicationItemRenderer() : ApplicationItemRenderer
		{
			return viewComponent as ApplicationItemRenderer;
		}
	}
}