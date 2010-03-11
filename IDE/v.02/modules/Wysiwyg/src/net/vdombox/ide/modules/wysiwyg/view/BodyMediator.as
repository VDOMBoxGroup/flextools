package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.main.Body;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.skins.spark.PanelSkin;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Body )
		{
			super( NAME, viewComponent );
		}
		
		public var selectedApplication : ApplicationVO;

		private var created : Boolean = false;
		
		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.PIPES_READY );

			return interests;	
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName())
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					selectedApplication = notification.getBody() as ApplicationVO;
					sendNotification( ApplicationFacade.GET_PAGES, notification.getBody());
					
					break;
				}
					
				case ApplicationFacade.PIPES_READY:
				{
					if( created ) 
						sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}
		
		private function removeHandlers() : void
		{
			body.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function commitProperties() : void
		{

		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			created = true;
			sendNotification( ApplicationFacade.BODY_CREATED, body );
		}
	}
}