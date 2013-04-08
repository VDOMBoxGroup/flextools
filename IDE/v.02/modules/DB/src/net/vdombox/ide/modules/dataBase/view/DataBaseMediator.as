package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.DataBase;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class DataBaseMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "DataBaseMediator";

		public function DataBaseMediator( vObject : DataBase )
		{
			super( NAME, vObject );
		}

		override public function onRegister() : void
		{
			resourceBrowser.addEventListener( DataBase.TEAR_DOWN, tearDownHandler )

		}

		// FIXME: чето я запутался, зачем DataBase нужен resourceBrowser?
		public function get resourceBrowser() : DataBase
		{
			return viewComponent as DataBase;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( Notifications.TEAR_DOWN );
		}
	}
}
