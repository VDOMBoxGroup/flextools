package net.vdombox.ide.modules.applicationsManagment.view
{
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationsListMediator extends Mediator implements IMediator
	{
		public const NAME : String = "ApplicationsListMediator";
		
		public function ApplicationsListMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
//			interests.push( ApplicationFacade );
			
			return interests;
		}
		
		override public function onRegister() : void
		{
			sendNotification( ApplicationFacade.GET_APPLICATIONS_LIST );
		}
	}
}