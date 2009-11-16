package net.vdombox.ide.modules.applicationsSearch.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.ApplicationsSearch;
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ApplicationsSearchMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ApplicationsManagmentMediator";

		public function ApplicationsSearchMediator( viewComponent : ApplicationsSearch )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			applicationsSearch.addEventListener( ApplicationsManagment.TEAR_DOWN, tearDownHandler )
		}

		private function get applicationsSearch() : ApplicationsManagment
		{
			return viewComponent as ApplicationsManagment;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
