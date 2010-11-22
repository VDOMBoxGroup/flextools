package net.vdombox.ide.modules.sample.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Sample;
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class SampleMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "SampleMediator";

		public function SampleMediator( viewComponent : Sample )
		{
			super( NAME, viewComponent );
		}

//		вызывается при регистрации данного медиатора
		override public function onRegister() : void
		{
			sample.addEventListener( Sample.TEAR_DOWN, tearDownHandler )
		}

		public function get sample() : Sample
		{
			return viewComponent as Sample;
		}
		
//		вызывается при вызове события Sample.TEAR_DOWN, после чего посылается 
//		уведомление ApplicationFacade.TEAR_DOWN
		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
