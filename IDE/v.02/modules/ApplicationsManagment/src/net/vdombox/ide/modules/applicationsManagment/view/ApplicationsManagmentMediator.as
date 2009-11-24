package net.vdombox.ide.modules.applicationsManagment.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationsManagmentMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationsManagmentMediator";

		public function ApplicationsManagmentMediator( viewComponent : ApplicationsManagment )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			applicationsManagment.addEventListener( ApplicationsManagment.TEAR_DOWN, tearDownHandler )
			
		}

		private function get applicationsManagment() : ApplicationsManagment
		{
			return viewComponent as ApplicationsManagment;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
