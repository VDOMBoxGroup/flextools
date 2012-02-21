package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.Event;
	
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.resourceBrowser.events.ResourcesListItemRendererEvent;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesList;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesListItemRenderer;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.List;
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
		
		public function get resourcesProvider() : List
		{
			return resourcesList.resources as List;
		}
		
		private var statesProxy : StatesProxy;

		private var isActive : Boolean;
		
		private var allResources : ArrayList;

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

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

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.RESOURCES_GETTED );
			interests.push( Notifications.RESOURCE_UPLOADED );
			interests.push( Notifications.RESOURCE_DELETED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			var resourceVO : ResourceVO;
			var resourcesArrayList : ArrayList;

			switch ( notification.getName() )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						sendNotification( Notifications.GET_RESOURCES, statesProxy.selectedApplication );

						isActive = true;

						break;
					}
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case Notifications.RESOURCES_GETTED:
				{
					allResources = new ArrayList( body as Array );

					resourcesProvider.dataProvider = allResources;

					break;
				}

				case Notifications.RESOURCE_UPLOADED:
				{
					resourceVO = body as ResourceVO;
					//resourcesArrayList = resourcesProvider.dataProvider as ArrayList;

					if ( resourceVO && allResources )
						allResources.addItem( resourceVO );

					resourcesProvider.dataProvider = allResources;
					
					findResource( resourcesList.nameFilter.text.toLowerCase() );
					
					break;
				}

				case Notifications.RESOURCE_DELETED:
				{
					resourceVO = body as ResourceVO;
					var currentReourceVO : ResourceVO;

					if ( resourceVO )
					{
						//resourcesArrayList = resourcesProvider.dataProvider as ArrayList;

						for each ( currentReourceVO in allResources.source )
						{
							if ( currentReourceVO.id == resourceVO.id )
							{
								//resourcesArrayList.removeItem( currentReourceVO );
								allResources.removeItem( currentReourceVO );
								break;
							}
						}
						
						resourcesProvider.dataProvider = allResources;
						
						findResource( resourcesList.nameFilter.text.toLowerCase() );
					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			resourcesList.resources.addEventListener( ResourcesListItemRendererEvent.CREATED, itemRenderer_createdHandler, true, 0, true );
			resourcesList.resources.addEventListener( IndexChangeEvent.CHANGE, changeHandler, false, 0, true );
			resourcesList.nameFilter.addEventListener( Event.CHANGE, applyNameFilter );
			resourcesList.resources.addEventListener( FlexEvent.DATA_CHANGE, sendLoadIcon, true );
		}

		private function removeHandlers() : void
		{
			resourcesList.resources.removeEventListener( ResourcesListItemRendererEvent.CREATED, itemRenderer_createdHandler, true );
			resourcesList.resources.removeEventListener( IndexChangeEvent.CHANGE, changeHandler );
			resourcesList.nameFilter.removeEventListener( Event.CHANGE, applyNameFilter );
			resourcesList.resources.removeEventListener( FlexEvent.DATA_CHANGE, sendLoadIcon, true );
		}
		
		private function applyNameFilter( event : Event ) : void
		{
			findResource( resourcesList.nameFilter.text.toLowerCase() );
		}
		
		private function sendLoadIcon( event : FlexEvent ) : void
		{
			var itemRenderer : ResourcesListItemRenderer = event.target as ResourcesListItemRenderer;
			
			if ( itemRenderer.data )
				sendNotification( Notifications.GET_ICON, itemRenderer.data );
		}
		
		private function findResource( nameFilter : String ) : void
		{
			if ( nameFilter == ResourceManager.getInstance().getString( 'ResourceBrowser_General', 'list_filter' ).toLowerCase() )
				return;
			
			var newResourcesList : ArrayList = new ArrayList();
			var resVO : ResourceVO;
			
			for each ( resVO in allResources.source )
			{
				if ( !resVO )
					continue;
				
				if ( resVO.name.toLowerCase().indexOf( nameFilter ) >= 0 || resVO.type.toLowerCase().indexOf( nameFilter ) >= 0)
				{
					newResourcesList.addItem( resVO );
				}
			}
			
			resourcesProvider.dataProvider = newResourcesList;
		}

		private function clearData() : void
		{
			resourcesProvider.dataProvider = null;
		}

		private function changeHandler( event : IndexChangeEvent ) : void
		{
			var selectedResourceVO : ResourceVO = resourcesProvider.selectedItem as ResourceVO;

			if ( selectedResourceVO ) 
				sendNotification( Notifications.LOAD_RESOURCE, selectedResourceVO );
			//sendNotification( Notifications.CHANGE_SELECTED_RESOURCE_REQUEST, selectedResourceVO );
			
		}

		private function itemRenderer_createdHandler( event : ResourcesListItemRendererEvent ) : void
		{
			var itemRenderer : ResourcesListItemRenderer = event.target as ResourcesListItemRenderer;

			/*if ( itemRenderer && itemRenderer.data && itemRenderer.data is ResourceVO )
				sendNotification( Notifications.LOAD_RESOURCE, itemRenderer.data );*/
		}
	}
}