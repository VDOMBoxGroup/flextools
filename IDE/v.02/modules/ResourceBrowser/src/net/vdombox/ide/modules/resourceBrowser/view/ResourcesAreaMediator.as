package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.net.FileFilter;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.components.windows.SpinnerPopup;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ListItem;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ListItemEvent;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ResourcePreviewWindow;
	import net.vdombox.ide.modules.resourceBrowser.model.StatesProxy;
	import net.vdombox.ide.modules.resourceBrowser.view.components.ResourcesArea;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ResourcesAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String               = "ResourcesAreaMediator";
		
		public function ResourcesAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get resourcesArea() : ResourcesArea
		{
			return viewComponent as ResourcesArea;
		}
		
		private var isActive : Boolean;
		
		private var statesProxy : StatesProxy;
		
		private var _filters : ArrayCollection = new ArrayCollection();
		
		private var allResourcesList : ArrayList;
		
		private var resourcePreviewWindow : ResourcePreviewWindow;
		
		private var spinnerPopup : SpinnerPopup;
		private var resourceVO : ResourceVO  = new ResourceVO( ResourceVO.RESOURCE_TEMP );
		
		
		override public function onRegister() : void
		{			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			addHandlers();
			
			sendNotification( Notifications.GET_RESOURCES, statesProxy.selectedApplication );
		}
		
		override public function onRemove() : void
		{			
			removeHandlers();
			
			statesProxy = null;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( Notifications.RESOURCES_GETTED );
			interests.push( Notifications.RESOURCE_UPLOADED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( statesProxy.selectedApplication )
					{
						resourcesArea.addEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true, 0, true );
						
						onResourceWindowCreationComplete();
						
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
					if ( body.length == 0 )
						removeSpinnerPopup();
					
					resourcesArea.callLater(updateData, [body]);
					
					break;
				}
					
				case Notifications.RESOURCE_UPLOADED:
				{
					addNewResourceInList( body as ResourceVO );
					
					break;
				}
			}
		}
		
		
		private function addHandlers() : void
		{
			resourcesArea.nameFilter.addEventListener( Event.CHANGE, applyNameFilter );
			resourcesArea.resourcesList.addEventListener( ResourceVOEvent.GET_ICON, getIconRequestHendler, true, 0,true);
			resourcesArea.resourcesList.addEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler, true, 0, true );
			resourcesArea.addEventListener( ResourceVOEvent.LOAD_RESOURCE, loadFileHandler );
			resourcesArea.addEventListener( ResourceVOEvent.PREVIEW_RESOURCE, onResourcePreview );
			
			resourcesArea.addEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true, 0, true );
		}
		
		private function removeHandlers() : void
		{
			resourcesArea.nameFilter.removeEventListener( Event.CHANGE, applyNameFilter );
			resourcesArea.resourcesList.removeEventListener( ResourceVOEvent.GET_ICON, getIconRequestHendler, true );
			resourcesArea.resourcesList.removeEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler, true );
			resourcesArea.removeEventListener( ResourceVOEvent.LOAD_RESOURCE, loadFileHandler );
			resourcesArea.removeEventListener( ResourceVOEvent.PREVIEW_RESOURCE, onResourcePreview );
			
			//
			resourcesArea.removeEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true );
		}
		
		private function clearData() : void
		{
			removeSpinnerPopup();
			
			allResourcesList = null;
			//resourcesArea.resources = null;
			
			resourcesArea.resourcesList.dataProvider.removeAll();
		}
		
		private function updateData(resources: Array) : void
		{
			_filters.removeAll();
			_filters.addItem( { label: 'NONE', data: '*' } );
			
			for each ( var resVO : ResourceVO in resources )
			{
				resVO.viewType = ResourceVO.BIG_PICTURE_VIEW;
			}
			
			allResourcesList = new ArrayList( resources );
			resourcesArea.resources = new ArrayList( resources );
			
			/*for each ( var resVO : ResourceVO in resources )
			{
			addFilter(resVO.type);
			}*/
			
			//resourcesArea.resources.addItemAt( null, 0 );
			resourcesArea.totalResources = allResourcesList.source.length - 1;
			
		}
		
		private function addNewResourceInList( resVO : ResourceVO ) : void
		{
			
			//addFilter( resVO.type);
			
			resVO.viewType = ResourceVO.BIG_PICTURE_VIEW;
			
			resourcesArea.addResource(  resVO );
			
			removeSpinnerPopup();
		}
		
		private function applyNameFilter( event : Event ) : void
		{
			var nameFilter : String          = resourcesArea.nameFilter.text.toLowerCase();
			var newResourcesList : ArrayList = new ArrayList();
			var resVO : ResourceVO;
			
			if ( nameFilter == '' )
			{
				resourcesArea.resources = allResourcesList;
				resourcesArea.filteredResources = resourcesArea.totalResources;
				
				return;
			}
			
			resourcesArea.filteredResources = 0;
			
			for each ( resVO in allResourcesList.source )
			{
				if ( !resVO )
					continue;
				
				if ( resVO.name.toLowerCase().indexOf( nameFilter ) >= 0 || resVO.type.toLowerCase().indexOf( nameFilter ) >= 0)
				{
					resourcesArea.filteredResources++;
					newResourcesList.addItem( resVO );
				}
			}
			
			resourcesArea.resources = newResourcesList;
		}
		
		private function getIconRequestHendler( event: ResourceVOEvent) : void
		{
			var listItem : ListItem = event.target.parent as ListItem;
			
			sendNotification( Notifications.GET_ICON, listItem.resourceVO );
		}
		
		private function deleteResourceHandler( event : ListItemEvent ) : void
		{
			var componentName : String = event.resource ? event.resource.name : "";
			
			Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );
			
			Alert.Show( ResourceManager.getInstance().getString( 'ResourceBrowser_General', 'delete_Resource' ),
				ResourceManager.getInstance().getString( 'ResourceBrowser_General', 'delete_Renderer' ) + "\n" + componentName + " ?", 
				AlertButton.OK_No, 
				resourcesArea, deleteResourceCloseHandler);
			
			function deleteResourceCloseHandler(event2 : PopUpWindowEvent) : void
			{
				if ( event2.detail == Alert.YES )
				{
					//delete from server
					sendNotification( Notifications.DELETE_RESOURCE, { resourceVO: event.resource, applicationVO: statesProxy.selectedApplication } );
					
					//delete from view
					resourcesArea.deleteResourceID = event.resource.id;
					
					resourcesArea.invalidateProperties(); //?
					
					//delete from array
					
					deleteResourceInArray( event.resource.id );
					resourcesArea.totalResources--;
				}
			}
		}
		
		private function deleteResourceInArray( idRes : String ) : void
		{
			var i : int;
			
			for ( i = 1; i < allResourcesList.source.length; i++ )
			{
				if ( allResourcesList.getItemAt( i ).id == idRes )
				{
					allResourcesList.removeItemAt( i );
					break;
				}
			}
		}
		
		private function loadFileHandler( event : ResourceVOEvent ) : void
		{
			var openFile : File = new File();
			
			openFile.addEventListener(Event.SELECT, fileSelected);
			
			var allFilesFilter : FileFilter = new FileFilter( "All Files (*.*)", "*.*" );
			var imagesFilter : FileFilter   = new FileFilter( 'Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png' );
			var docFilter : FileFilter      = new FileFilter( 'Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt' );
			
			openFile.browseForOpen( "Choose file to upload", [ imagesFilter, docFilter, allFilesFilter ] );
			
			function fileSelected( event:Event ) : void
			{
				var spinnerTxt : String = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'spinner_new_resource' );
				createSpinnerPopup(spinnerTxt);
				
				openFile.removeEventListener(Event.SELECT, fileSelected);
				
				openFile.addEventListener(Event.COMPLETE, fileDownloaded);
				openFile.load();
				
			}
			
			function fileDownloaded(event:Event) : void
			{
				// compress and encode to base64 in Server
				openFile.removeEventListener(Event.COMPLETE, fileDownloaded);
				
				var resourceVO : ResourceVO = new ResourceVO( statesProxy.selectedApplication.id );
				resourceVO.setID( openFile.name ); //?
				resourceVO.setData( openFile.data);
				resourceVO.name = openFile.name;
				resourceVO.type = openFile.type ? openFile.type.slice(1) : ""; // type has "."
				
				sendNotification( Notifications.UPLOAD_RESOURCE, resourceVO );
			}
		}
		
		private function createSpinnerPopup(spinnerTxt : String) : void
		{
			if ( spinnerPopup )
				return;
			
			spinnerPopup = new SpinnerPopup(spinnerTxt);
			spinnerPopup.width = resourcesArea.width;
			spinnerPopup.height = resourcesArea.height;
			
			PopUpManager.addPopUp(spinnerPopup, resourcesArea, true);
		}
		
		private function removeSpinnerPopup() : void
		{
			if ( !spinnerPopup )
				return;
			
			spinnerPopup.close();
			
			spinnerPopup = null;
		}
		
		public function onResourceWindowCreationComplete() : void
		{
			resourcesArea.removeEventListener( ResourceVOEvent.CREATION_COMPLETE, onResourceWindowCreationComplete );
			
			/*if ( !showSpinnerOnListCreation )
			{
			showSpinnerOnListCreation = true;
			
			return;
			}*/
			
			var spinnerTxt : String = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'spinner_create_resources' );
			
			createSpinnerPopup(spinnerTxt);
		}
		
		private function onResourcePreview( event : Event ) : void
		{
			var resVO : ResourceVO = event.currentTarget.resourcesList.selectedItem as ResourceVO;
			resourceVO = resVO;
			
			if ( resourcePreviewWindow != null )
				onClosePreview(null);
			
			resourcePreviewWindow = new ResourcePreviewWindow();
			resourcePreviewWindow.addEventListener( Event.CLOSE, onClosePreview );
			resourcePreviewWindow.resourceVO = resourceVO;
			
			WindowManager.getInstance().addWindow( resourcePreviewWindow, null, true );
			
			BindingUtils.bindSetter( previewImage, resourceVO, "data", false, true  );
			
			sendNotification( Notifications.LOAD_RESOURCE, resourceVO );
		}
		
		private function previewImage( object : Object ) : void
		{
			//for convert to bitmapData and get width and height of resource
			if ( object )
			{
				var loader : Loader = new Loader();
				loader.name = resourceVO.id;
				
				if ( resourceVO.data )
				{
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
					loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loaderComplete );
					loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loaderComplete );
					
					loader.loadBytes( resourceVO.data );
				}
				
			}
		}
		
		private function loaderComplete( event : Event ) : void
		{
			if ( event.type != Event.COMPLETE )
				return;
			
			
			// TODO: do it in resourcePreviewWindow
			if ( resourcesArea.resources.length > 0 )
			{
				var loaderInfo : LoaderInfo;
				var bitmapData : BitmapData;
				var bitmap : Bitmap;
				var bmpWidthHeightRatio : Number;
				var dimentionsScale : Number
				var rectangle : Rectangle;
				
				
				loaderInfo = LoaderInfo( event.target );
				
				rectangle = getImageRectangle( loaderInfo );
				
				bitmapData = new BitmapData( rectangle.width, rectangle.height, false, 0xFFFFFF );
				bitmapData.draw( loaderInfo.loader );
				
				bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO, true);
				bitmap.cacheAsBitmap = true;
				
				
				if ( resourcePreviewWindow )
				{
					// размер height пространства меньше height картинки
					if ( resourcePreviewWindow.resourceImage.height < bitmap.height 
						||	 resourcePreviewWindow.resourceImage.width < bitmap.width )
					{
						resourcePreviewWindow.resourceImage.maintainAspectRatio = true;
						resourcePreviewWindow.resourceImage.scaleContent = true;
						
					}
					
					resourcePreviewWindow.resourceImage.source = bitmap;
					
					resourcePreviewWindow.setDimentions(loaderInfo.width, loaderInfo.height, resourceVO.mastHasPreview);
					resourcePreviewWindow.loadingImage.visible = false;
				}
				
			}
		}
		
		private function getImageRectangle( loaderInfo : LoaderInfo ) : Rectangle
		{
			var maxPisels : Number = 16777215;
			
			var width : Number     = loaderInfo.width;
			var height : Number    = loaderInfo.height;
			
			if ( width * height > maxPisels )
			{
				var proportioWidth : Number  = 1 / height;
				var proportioHeight : Number = 1 / width;
				
				width = maxPisels * proportioWidth;
				height = maxPisels * proportioHeight;
			}
			
			return new Rectangle(0, 0, width, height);
		}
		
		private function onClosePreview( event : Event ) : void
		{
			resourcePreviewWindow.removeEventListener( Event.CLOSE, onClosePreview );
			
			WindowManager.getInstance().removeWindow( resourcePreviewWindow );
			
			resourcePreviewWindow = null;
		}
		
		public function onResourceWindowListItemCreationComplete(event : Event) : void
		{
			resourcesArea.removeEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true );
			//showSpinnerOnListCreation = false;
			
			removeSpinnerPopup();
		}
		
	}
}