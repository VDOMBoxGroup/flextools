package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import mx.collections.ArrayList;
	import mx.events.CollectionEvent;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.resourceBrowser.ApplicationFacade;
	import net.vdombox.ide.modules.resourceBrowser.view.components.LoadResourcesView;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class LoadResourcesViewMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LoadResourcesViewMediator";
		
		public function LoadResourcesViewMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get loadResourcesView() : LoadResourcesView
		{
			return viewComponent as LoadResourcesView;
		}
		
		private var newResources : ArrayList;
		
		override public function onRegister() : void
		{
			newResources = new ArrayList();
			
			addEventListeners();
			loadResourcesView.reslourceList.dataProvider = newResources;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.GET_RESOURCES );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			switch ( notification.getName() )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			loadResourcesView.addEventListener( "addResource", addResourceHandler );
			loadResourcesView.addEventListener( "loadResources", loadResourcesHandler );
			loadResourcesView.addEventListener( "removeResource", removeResourceHandler, true );
			newResources.addEventListener( CollectionEvent.COLLECTION_CHANGE, newResources_collectionChange )
		}
		
		private function loadResource() : void
		{
			if( newResources.length == 0 )
				return;
			
			var resourceVO : ResourceVO = newResources.removeItemAt( 0 ) as ResourceVO;
		}
		
		private function addResourceHandler( event : Event ) : void
		{
			var file : File = new File();
			
			file.addEventListener( Event.SELECT, file_selectHandler );
			file.browseForOpen( "Load Resource" );
		}
		
		private function loadResourcesHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.SET_RESOURCES, newResources.source );
			loadResource();
		}
		
		private function removeResourceHandler( event : Event ) : void
		{
			var newResourceVO : ResourceVO = event.target.data as ResourceVO;
			
			if ( newResourceVO )
				newResources.removeItem( newResourceVO );
		}
		
		private function file_selectHandler( event : Event ) : void
		{
			var file : File = event.currentTarget as File;
			
			if ( !file || !file.exists )
				return;
			
			file.removeEventListener( Event.SELECT, file_selectHandler );
			
			var fileStream : FileStream = new FileStream();
			var byteArray : ByteArray = new ByteArray();
			
			try
			{
				fileStream.open( file, FileMode.READ );
				fileStream.readBytes( byteArray );
			}
			catch ( error : Error )
			{
				return;
			}
			
			var resourceVO : ResourceVO = new ResourceVO();
			
			resourceVO.name = file.name;
			resourceVO.path = file.nativePath;
			resourceVO.size = file.size;
			
			newResources.addItem( resourceVO );
		}
		
		private function newResources_collectionChange( event : CollectionEvent ) : void
		{
			if ( newResources.length > 0 )
				loadResourcesView.loadResourceLabel.visible = true;
			else
				loadResourcesView.loadResourceLabel.visible = false;
		}
	}
}