package net.vdombox.ide.modules.resourceBrowser.view
{
	import mx.collections.ArrayList;

	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.events.ResourcesListItemRendererEvent;
	import net.vdombox.ide.modules.resourceBrowser.model.SessionProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesList;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesListItemRenderer;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.events.IndexChangeEvent;

	public class ResourcesListMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ResourcesListMediator";

		public function ResourcesListMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get resourcesList() : ResourcesList
		{
			return viewComponent as ResourcesList;
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.RESOURCES_GETTED );
			interests.push( ApplicationFacade.RESOURCE_UPLOADED );
			interests.push( ApplicationFacade.RESOURCE_DELETED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			var resourceVO : ResourceVO;
			var resourcesArrayList : ArrayList;

			switch ( notification.getName() )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );

						isActive = true;

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.RESOURCES_GETTED:
				{
					var resources : Array = body as Array;

					resourcesList.dataProvider = new ArrayList( resources );

					break;
				}

				case ApplicationFacade.RESOURCE_UPLOADED:
				{
					resourceVO = body as ResourceVO;
					resourcesArrayList = resourcesList.dataProvider as ArrayList;

					if ( resourceVO && resourcesArrayList )
						resourcesArrayList.addItem( resourceVO );

					break;
				}

				case ApplicationFacade.RESOURCE_DELETED:
				{
					resourceVO = body as ResourceVO;
					var currentReourceVO : ResourceVO;

					if ( resourceVO )
					{
						resourcesArrayList = resourcesList.dataProvider as ArrayList;

						for each ( currentReourceVO in resourcesArrayList.source )
						{
							if ( currentReourceVO.id == resourceVO.id )
							{
								resourcesArrayList.removeItem( currentReourceVO );
								break;
							}
						}
					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			resourcesList.addEventListener( ResourcesListItemRendererEvent.CREATED, itemRenderer_createdHandler, true, 0, true );
			resourcesList.addEventListener( IndexChangeEvent.CHANGE, changeHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			resourcesList.removeEventListener( ResourcesListItemRendererEvent.CREATED, itemRenderer_createdHandler, true );
			resourcesList.removeEventListener( IndexChangeEvent.CHANGE, changeHandler );
		}

		private function clearData() : void
		{
			resourcesList.dataProvider = null;
		}

		private function changeHandler( event : IndexChangeEvent ) : void
		{
			var selectedResourceVO : ResourceVO = resourcesList.selectedItem as ResourceVO;

			sendNotification( ApplicationFacade.CHANGE_SELECTED_RESOURCE_REQUEST, selectedResourceVO );
		}

		private function itemRenderer_createdHandler( event : ResourcesListItemRendererEvent ) : void
		{
			var itemRenderer : ResourcesListItemRenderer = event.target as ResourcesListItemRenderer;

			if ( itemRenderer && itemRenderer.data && itemRenderer.data is ResourceVO )
				sendNotification( ApplicationFacade.LOAD_RESOURCE, itemRenderer.data );
		}
	}
}