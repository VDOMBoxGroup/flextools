package net.vdombox.ide.modules.preview.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.modules.Preview2;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PreviewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PreviewMediator";
		
		public function PreviewMediator( viewComponent : Preview2 )
		{
			super( NAME, viewComponent );
		}
		
		override public function onRegister() : void
		{
			events.addEventListener( Preview2.TEAR_DOWN, tearDownHandler )
		}
		
		public function get events() : Preview2
		{
			return viewComponent as Preview2;
		}
		
		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( Notifications.TEAR_DOWN );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.PIPES_READY );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{			
			switch ( notification.getName() )
			{
				case Notifications.PIPES_READY:
				{
					sendNotification( StatesProxy.GET_ALL_STATES );
					
					break;
				}
				
			}
		}
	}
	
}