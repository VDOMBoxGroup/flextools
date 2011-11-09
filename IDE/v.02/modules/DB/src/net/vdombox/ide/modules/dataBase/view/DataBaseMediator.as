package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.DataBase;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataBaseMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataBaseMediator";

		public function DataBaseMediator( vObject : DataBase )
		{
			trace("DataBaseMediator");
			super( NAME, vObject );
		}

		override public function onRegister() : void
		{
			resourceBrowser.addEventListener( DataBase.TEAR_DOWN, tearDownHandler )
			
		}

		public function get resourceBrowser() : DataBase
		{
			return viewComponent as DataBase;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
