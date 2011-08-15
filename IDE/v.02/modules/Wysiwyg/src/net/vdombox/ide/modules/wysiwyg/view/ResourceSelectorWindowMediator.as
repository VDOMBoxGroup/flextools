package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.SpinnerPopup;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ListItem;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ListItemEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ListItemNotEmptyContent;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ResourcePreviewWindow;
	import net.vdombox.utils.WindowManager;
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 *
	 * @author Elena Kotlova
	 */
	public class ResourceSelectorWindowMediator extends Mediator implements IMediator
	{
		/**
		 *
		 * @default
		 */
		// TODO: сделать свой rotation класс
		// TODO: сделать крутилку на загрузку иконки			- CHANGE swf -> png
		// TODO: сделать крутилку на отправку файла				- CHANGE swf -> png
		// TODO: загружать спиннер на creationComplete listItem
		// prosmotret' slushateli addHndl and remuveHandlers
		
		public static const NAME			: String = "ResourceSelectorWindowMediator";

		private var _filters				: ArrayCollection = new ArrayCollection();

		private var allResourcesList		: ArrayList;

		private var resourceVO 				: ResourceVO = new ResourceVO( ResourceVO.RESOURCE_TEMP );
		private var delResVO				: ResourceVO;
		private var noneIcon				: ResourceVO = new ResourceVO( ResourceVO.RESOURCE_NONE );
		
		private var sessionProxy 			: SessionProxy;

		private var resourcePreviewWindow	: ResourcePreviewWindow;

		public function ResourceSelectorWindowMediator( resourceSelectorWindow : ResourceSelectorWindow ) : void
		{
			viewComponent = resourceSelectorWindow;
			super( NAME, viewComponent );
		}

		private function get resourceSelectorWindow() : ResourceSelectorWindow
		{
			return viewComponent as ResourceSelectorWindow;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();

			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );		
		}
		
		
		public function ioErrorHandler( event : IOErrorEvent ) : void
		{
			trace( "###################### ERROR" + event.text );
		}

		override public function onRemove() : void
		{
			removeHandlers();

			sessionProxy = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.RESOURCES_GETTED );
			
			interests.push( ApplicationFacade.RESOURCE_SETTED );
			
			return interests;
		}

		/**
		 * Add type in filter list
		 * @param type - type of Resource
		 *
		 */
		private function addFilter( type : String ) : void
		{
			if ( type )
			{			
				for each ( var obj : Object in _filters )
				{
					if ( obj[ "data" ] == type )
						return;
				}
	
				_filters.addItem( { label: type.toUpperCase(), data: type } );
			}
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			var resVO : ResourceVO;

			switch ( name )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{
					_filters.removeAll();
					_filters.addItem( { label: 'NONE', data: '*' } );
					
					resourceSelectorWindow.resources = new ArrayList( body as Array );
										
//					allResourcesList = new ArrayList( body as Array );

					for each ( resVO in body )
					{
//						BindingUtils.bindSetter( dataLoaded, resVO, "icon" );
						addFilter(resVO.type);
//						sendNotification( ApplicationFacade.GET_ICON, resVO );
					}
					
					// set empty resource as null in ListItem
					resourceSelectorWindow.resources.addItemAt( null, 0 );
					resourceSelectorWindow.totalResources = resourceSelectorWindow.resources.length-1;

					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
//					sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );		
					addNewResourceInList( body as ResourceVO );
					
					break;
				}	
				
			}
		}
		
		private var spinnerPopup : SpinnerPopup;
		private function createSpinnerPopup():void
		{
			trace ("[ResSelWindMediator] createSpinnerPopup");
			spinnerPopup = new SpinnerPopup();
			spinnerPopup.width	= resourceSelectorWindow.width;
			spinnerPopup.height	= resourceSelectorWindow.height;
			
			PopUpManager.addPopUp(spinnerPopup, DisplayObject(resourceSelectorWindow), true);
		}
		
		private function removeSpinnerPopup():void
		{
			trace ("[ResSelWindMediator] removeSpinnerPopup");
			spinnerPopup.dispatchEvent(new CloseEvent(CloseEvent.CLOSE));
			spinnerPopup = null;
		}
		
		private function addNewResourceInList( resVO : ResourceVO ) : void
		{
			resourceVO = resVO;
			
			addFilter( resourceVO.type);
			
			//FIXME: ???
			//resourceSelectorWindow.totalResources ++;
			resourceSelectorWindow.resources.addItemAt( resourceVO, resourceSelectorWindow.resources.length );
			resourceSelectorWindow.scrollToIndex = resourceSelectorWindow.resources.length-1;
			resourceSelectorWindow.selectedResourceIndex = resourceSelectorWindow.resources.length-1;
			resourceSelectorWindow.invalidateProperties();
			
			removeSpinnerPopup();
		}
		

		private function addHandlers() : void
		{
			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
//			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler );
//			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler, true );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, getResourcesRequestHandler );
			resourceSelectorWindow.addEventListener(ResourceSelectorWindowEvent.PREVIEW_RESOURCE, onResourcePreview);
			
		}
		
		private function initTitle() : void
		{
			resourceSelectorWindow.title = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'resource_selector_window_title' );
		}
		
		private function addHandlersForResourcesList( event : Event ) : void
		{
			initTitle();
			
			resourceSelectorWindow.nameFilter.addEventListener( Event.CHANGE, applyNameFilter );
			resourceSelectorWindow.resourcesList.addEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler, true, 0, true ); 
			resourceSelectorWindow.resourcesList.addEventListener( ResourceSelectorWindowEvent.GET_ICON, getIconRequestHendler, true, 0,true);
		}
		
		
		private function deleteResourceHandler( event : ListItemEvent ) : void
		{
			trace ("[ResSelWindowMediator] deleteResourceHandler");
			var componentName : String = event.resource ? event.resource.name : "";
			
			delResVO = event.resource;
			
			Alert.noLabel = "Cancel";
			Alert.yesLabel = "Delete";
			
			Alert.Show( "Are you sure want to delete\n " + componentName + " ?", 
						AlertButton.OK_No, 
						resourceSelectorWindow, deleteResourceCloseHandler);
			
		}
		
		private function deleteResourceCloseHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				//delete from server
				sendNotification( ApplicationFacade.DELETE_RESOURCE, { resourceVO: delResVO, applicationVO: sessionProxy.selectedApplication } );
				
				//delete from view
				resourceSelectorWindow.deleteResourceID = delResVO.id;
				
				resourceSelectorWindow.invalidateProperties(); //?
				
				allResourcesList = resourceSelectorWindow.resources;

			}
		}


		private function applyNameFilter( event : Event ) : void
		{
			var nameFilter : String = resourceSelectorWindow.nameFilter.text.toLowerCase();
			var newResourcesList : ArrayList = new ArrayList();
			var resVO : ResourceVO;

			if ( nameFilter == '' )
			{
				resourceSelectorWindow.resources = allResourcesList;
				resourceSelectorWindow.filteredResources = resourceSelectorWindow.totalResources;

				return;
			}

			resourceSelectorWindow.filteredResources = 0;

			for each ( resVO in allResourcesList.source )
			{
				if (!resVO) {
					continue;
				}
				if ( resVO.name.toLowerCase().indexOf( nameFilter ) >= 0 )
				{
					resourceSelectorWindow.filteredResources++;
					newResourcesList.addItem( resVO );
				}
			}

			resourceSelectorWindow.resources = newResourcesList;
		}

		private function removeHandlers() : void
		{
			resourceSelectorWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
//			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler ); //коряво очень поменять местами
//			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler, true ); //коряво очень
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, getResourcesRequestHandler );
			
			resourceSelectorWindow.removeEventListener(ResourceSelectorWindowEvent.PREVIEW_RESOURCE, onResourcePreview);
		
			resourceSelectorWindow.resourcesList.removeEventListener( ResourceSelectorWindowEvent.GET_ICON, getIconRequestHendler);
			
		}

		private function getIconRequestHendler( event: ResourceSelectorWindowEvent):void
		{
			var listItem : ListItem = event.target.parent as ListItem;
			
			sendNotification( ApplicationFacade.GET_ICON, listItem.resourceVO );
		}
			
		private function getResourcesRequestHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
		}

		private function onResourcePreview( event : Event ) : void
		{
			var resVO : ResourceVO = event.currentTarget.resourcesList.selectedItem as ResourceVO;
			resourceVO = resVO;
			
			if (resourcePreviewWindow != null) {
				onClosePreview(null);
			}
			
			resourcePreviewWindow = new ResourcePreviewWindow();
			resourcePreviewWindow.addEventListener(Event.CLOSE, onClosePreview);
			resourcePreviewWindow.resourceVO = resourceVO;
			
			PopUpManager.addPopUp( resourcePreviewWindow, DisplayObject( this.resourceSelectorWindow ), true);
			
			
//			resourceSelectorWindow.removeKeyEvents();
			
			//FIXME: need be like this: resourcePreviewWindow.resourceVO = resourceVO;
			
			
			BindingUtils.bindSetter( previewImage, resourceVO, "data" );
			sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			
		}
		
		private function onClosePreview( event : Event ) : void
		{
			resourcePreviewWindow.removeEventListener(Event.CLOSE, onClosePreview);
			
			
			resourcePreviewWindow = null;
			
			resourceSelectorWindow.addHandlers();
		}
		
		

		private function loadFileHandler( event : ResourceSelectorWindowEvent ) : void
		{
			var openFile : File     = new File();
			
			openFile.addEventListener(Event.SELECT, fileSelected);
			
			var allFilesFilter  : FileFilter = new FileFilter( "All Files (*.*)", "*.*" );
			var imagesFilter	: FileFilter = new FileFilter( 'Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png' );
			var docFilter 		: FileFilter = new FileFilter( 'Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt' );
			
			openFile.browseForOpen( "Choose file to upload", [ imagesFilter, docFilter, allFilesFilter ] );
			
			function fileSelected( event:Event ) : void
			{
				createSpinnerPopup();
				
				openFile.removeEventListener(Event.SELECT, fileSelected);
				
				openFile.addEventListener(Event.COMPLETE, fileDownloaded);
				openFile.load();
				
			}
			
			function fileDownloaded(event:Event) : void
			{
				// compress and encode to base64 in Server
				openFile.removeEventListener(Event.COMPLETE, fileDownloaded);
				
				var resourceVO : ResourceVO = new ResourceVO( sessionProxy.selectedApplication.id );
				resourceVO.setID( openFile.name ); //?
				resourceVO.data = openFile.data;
				resourceVO.name = openFile.name;
				resourceVO.type = openFile.type.slice(1); // type has "."
				
				sendNotification( ApplicationFacade.SET_RESOURCE, resourceVO );
			}
		}

	

		private function previewImage( object : Object ) : void
		{
			//for convert to bitmapData and get width and height of resource
			if ( object )
			{
				var loader : Loader = new Loader();
				loader.name = resourceVO.id;
				
				if ( resourceVO.data != null )
				{
					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
					loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loaderComplete );
					loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loaderComplete );
					
					loader.loadBytes( resourceVO.data );
				}
				else
					return;

			}
		}

		/**
		 * convert to bitmapData for get resolution of Resource
		 */
		private function loaderComplete( event : Event ) : void
		{
			if (event.type != Event.COMPLETE) {
				return;
			}
			
			if ( resourceSelectorWindow.resources.length > 0 )
			{
				var loaderInfo				: LoaderInfo;
				var bitmapData				: BitmapData;
				var bitmap					: Bitmap;
				var bmpWidthHeightRatio		: Number;
				var dimentionsScale			: Number
				
				loaderInfo = LoaderInfo( event.target );
				bitmapData = new BitmapData( loaderInfo.width, loaderInfo.height, false, 0xFFFFFF );
				bitmapData.draw( loaderInfo.loader );
				
				bitmap = new Bitmap(bitmapData);
				bitmap.cacheAsBitmap = true;

				bmpWidthHeightRatio = bitmap.width / bitmap.height;
				
				if (resourcePreviewWindow) {
					
					if (resourcePreviewWindow.resourceImage.height < bitmap.height) {
						bitmap.height = resourcePreviewWindow.resourceImage.height;
						bitmap.width = bitmap.height * bmpWidthHeightRatio;
					}
					
					if (resourcePreviewWindow.resourceImage.width < bitmap.width)
					{
						dimentionsScale = resourcePreviewWindow.resourceImage.width / bitmap.width;
						
						bitmap.width *= dimentionsScale;
						bitmap.height *= dimentionsScale;
					}
					
					bitmap.x = (resourcePreviewWindow.resourceImage.width - bitmap.width) / 2;
					bitmap.y = (resourcePreviewWindow.resourceImage.height - bitmap.height) / 2;
					
					resourcePreviewWindow.setDimentions(loaderInfo.width, loaderInfo.height, resourceVO.isViewable);
					resourcePreviewWindow.loadingImage.visible = false;
					resourcePreviewWindow.resourceImage.addChild(bitmap);
					
					return;
				}
				
			}
		}

//		private function applyHandler( event : ResourceSelectorWindowEvent ) : void
//		{
//			resourceSelectorWindow.dispatchEvent( new Event( Event.CHANGE ) );
//			resourceSelectorWindow.dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.CLOSE ) );
//		}

		private function closeHandler( event : ResourceSelectorWindowEvent ) : void
		{
			WindowManager.getInstance().removeWindow(resourceSelectorWindow);
			facade.removeMediator( mediatorName );
		}
	}
}
