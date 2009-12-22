package net.vdombox.ide.modules.resourceBrowser.view
{
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
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
			
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			
			interests.push( ApplicationFacade.GET_RESOURCES );
			interests.push( ApplicationFacade.RESOURCES_GETTED );

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

				case ApplicationFacade.RESOURCE_SETTED:
				{
					var resourceVO : ResourceVO = notification.getBody() as ResourceVO;
					
					if( body.resourceList.dataProvider.getItemIndex( resourceVO ) == -1 )
						body.resourceList.dataProvider.addItem( resourceVO );
					
					break;
				}
					
				case ApplicationFacade.RESOURCES_GETTED:
				{
					body.resourceList.dataProvider = new ArrayList( notification.getBody() as Array );
					
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