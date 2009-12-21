package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;

	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public function get body() : Body
		{
			return viewComponent as Body;
		}

		override public function onRegister() : void
		{
			addEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.PIPES_READY );

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.GET_RESOURCES );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.PIPES_READY:
				{
//					sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					var applicationVO : ApplicationVO = notification.getBody() as ApplicationVO;

					if ( applicationVO )
						sendNotification( ApplicationFacade.GET_RESOURCES, applicationVO );

					break;
				}

				case ApplicationFacade.RESOURCES_GETTED:
				{
					var d : * = "";
					
					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new LoadResourcesViewMediator( body.loadResourcesView ) );
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
		}
	}
}