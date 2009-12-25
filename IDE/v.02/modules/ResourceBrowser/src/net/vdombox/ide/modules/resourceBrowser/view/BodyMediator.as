package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.Event;

	import mx.collections.ArrayList;
	import mx.events.FlexEvent;

	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.view.components.Body;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.events.IndexChangeEvent;

	public class BodyMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "BodyMediator";

		public function BodyMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		public var selectedResource : ResourceVO;

		public var selectedApplication : ApplicationVO;

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
			interests.push( ApplicationFacade.RESOURCE_LOADED );
			interests.push( ApplicationFacade.RESOURCES_GETTED );
			interests.push( ApplicationFacade.RESOURCE_DELETED );


			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var resourceVO : ResourceVO;

			switch ( notification.getName() )
			{
				case ApplicationFacade.PIPES_READY:
				{
//					sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
					break;
				}

				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					selectedApplication = notification.getBody() as ApplicationVO;

					if ( selectedApplication )
						sendNotification( ApplicationFacade.GET_RESOURCES, selectedApplication );

					break;
				}

				case ApplicationFacade.RESOURCE_SETTED:
				{
					resourceVO = notification.getBody() as ResourceVO;

					if ( body.resourceList.dataProvider.getItemIndex( resourceVO ) == -1 )
						body.resourceList.dataProvider.addItem( resourceVO );

					break;
				}

				case ApplicationFacade.RESOURCES_GETTED:
				{
					body.resourceList.dataProvider = new ArrayList( notification.getBody() as Array );

					break;
				}

				case ApplicationFacade.RESOURCE_LOADED:
				{
					resourceVO = notification.getBody() as ResourceVO;

					try
					{
						body.preview.source = resourceVO.data;
					}
					catch ( error : Error )
					{
						var d : * = "";
					}

					break;
				}

				case ApplicationFacade.RESOURCE_DELETED:
				{
					resourceVO = notification.getBody() as ResourceVO;

					if ( selectedResource == resourceVO )
						selectedResource = null;

					var resources : ArrayList = body.resourceList.dataProvider as ArrayList;
					resources.removeItem( resourceVO );

					break;
				}
			}
		}

		private var selectedResourceChanged : Boolean;

		private function addEventListeners() : void
		{
			body.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function commitProperties() : void
		{
			if ( selectedResourceChanged )
			{
				selectedResourceChanged = false;

				if ( selectedResource )
				{
					var type : String = selectedResource.type;

					if ( type )
						type.toLowerCase();

					if ( type == "jpg" || type == "jpeg" || type == "png" || type == "gif" )
						sendNotification( ApplicationFacade.LOAD_RESOURCE, selectedResource );
					else
						body.preview.source = null;
				}
				else
				{
					body.preview.source = null;
				}
			}
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			facade.registerMediator( new LoadResourcesViewMediator( body.loadResourcesView ) );
			sendNotification( ApplicationFacade.GET_SELECTED_APPLICATION );
			body.resourceList.addEventListener( IndexChangeEvent.CHANGE, resourceList_changeHandler );
			body.addEventListener( "deleteResource", deleteResourceHandler );
		}

		private function deleteResourceHandler( event : Event ) : void
		{
			if ( !selectedResource )
				return;

			sendNotification( ApplicationFacade.DELETE_RESOURCE, { applicationVO: selectedApplication,
								  resourceVO: selectedResource } );
		}

		private function resourceList_changeHandler( event : IndexChangeEvent ) : void
		{
			selectedResource = event.currentTarget.selectedItem;
			selectedResourceChanged = true;

			commitProperties();
		}
	}
}