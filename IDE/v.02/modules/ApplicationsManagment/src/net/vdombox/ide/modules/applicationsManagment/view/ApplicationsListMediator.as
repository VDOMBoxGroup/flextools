package net.vdombox.ide.modules.applicationsManagment.view
{
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;

	public class ApplicationsListMediator extends Mediator implements IMediator
	{
		public const NAME : String = "ApplicationsListMediator";

		public function ApplicationsListMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			applicationsList.itemRendererFunction = itemRendererFunction;
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			interests.push( ApplicationFacade.APPLICATIONS_LIST_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.APPLICATIONS_LIST_GETTED:
				{
					applicationsList.dataProvider = new ArrayList( notification.getBody() as Array )
					break;
				}
			}
		}
		
		private function get applicationsList() : List
		{
			return viewComponent as List;
		}
		
		private function itemRendererFunction( item : Object ) : void
		{
			
		}
	}
}