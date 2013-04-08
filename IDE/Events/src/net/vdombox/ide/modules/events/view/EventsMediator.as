package net.vdombox.ide.modules.events.view
{
	import flash.events.Event;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.Events;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class EventsMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EventsMediator";

		public function EventsMediator( viewComponent : Events )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			events.addEventListener( Events.TEAR_DOWN, tearDownHandler )
		}

		public function get events() : Events
		{
			return viewComponent as Events;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( Notifications.TEAR_DOWN );
		}
	}
}
