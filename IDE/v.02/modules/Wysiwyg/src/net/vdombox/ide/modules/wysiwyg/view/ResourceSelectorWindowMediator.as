package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.desktop.Icon;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ListItemEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ResourcePreviewWindow;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	import net.vdombox.utils.WindowManager;
	
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
		public static const NAME : String = "ResourceSelectorWindowMediator";

		private var _filters : ArrayCollection = new ArrayCollection();

		private var allResourcesList : ArrayList;

		private var resourceVO : ResourceVO = new ResourceVO( ResourceVO.RESOURCE_TEMP );

		private var sessionProxy 	: SessionProxy;

		private var noneIcon : ResourceVO = new ResourceVO( ResourceVO.RESOURCE_NONE );

		private var resourcePreviewWindow : ResourcePreviewWindow;

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
			
			setIcon();

			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );		
		}
		
		private function setIcon() : void
		{
			var file : File = new File( File.applicationDirectory.resolvePath( "modules/Wysiwyg/icons/none.png" ).nativePath );

			file.addEventListener( Event.COMPLETE,			fileDounloaded );
			file.addEventListener( IOErrorEvent.DISK_ERROR, ioErrorHandler );
			file.addEventListener( IOErrorEvent.IO_ERROR, 	ioErrorHandler );
			file.load();

			function fileDounloaded( event : Event ) : void
			{
				if ( file )
				{
					try
					{
						noneIcon.name = "Empty";
						noneIcon.icon = file.data;
						noneIcon.data = file.data;
					}
					catch ( error : Error )
					{
						trace( "Failed: was changed path.", error.message );
					}
				}
			}
		}

		public function ioErrorHandler( event : IOErrorEvent ) : void
		{
			trace( "######################ERROR" + event.text );
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
		private function set filters( type : String ) : void
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
										
					allResourcesList = new ArrayList( body as Array );

					for each ( resVO in body )
					{
						BindingUtils.bindSetter( dataLoaded, resVO, "icon" );
						filters = resVO.type;
						sendNotification( ApplicationFacade.GET_ICON, resVO );
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
		
		private function addNewResourceInList( resVO : ResourceVO ) : void
		{
			resourceVO = resVO;
			
			filters = resourceVO.type;
			
			//FIXME: ???
			resourceSelectorWindow.totalResources ++;
			resourceSelectorWindow.resources.addItemAt( resourceVO, resourceSelectorWindow.resources.length );
			resourceSelectorWindow.scrollToIndex = resourceSelectorWindow.resources.length-1;
			resourceSelectorWindow.selectedResourceIndex = resourceSelectorWindow.resources.length-1;
			resourceSelectorWindow.invalidateProperties();
			
			BindingUtils.bindSetter( iconForNewResGetted, resourceVO, "icon" );			
			sendNotification( ApplicationFacade.GET_ICON, resourceVO );
		}
		
		
		private function iconForNewResGetted( object : Object ) : void
		{
			if ( !object )
			{
				var timer:Timer = new Timer(1000, 1);
				timer.addEventListener(TimerEvent.TIMER, requestIcon);
				timer.start();
			}
			
			function requestIcon(event:TimerEvent):void
			{
				sendNotification( ApplicationFacade.GET_ICON, resourceVO );
			}
		}
		
		
		
		private function dataLoaded( object : Object = null ) : void
		{
		}

		private function addHandlers() : void
		{
			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
//			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, loadResourcesHandler );
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
			resourceSelectorWindow.resourcesList.addEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler ); 
		}

		private function deleteResourceHandler( event : ListItemEvent ) : void
		{
			//delete from server
			sendNotification( ApplicationFacade.DELETE_RESOURCE, { resourceVO: event.resource, applicationVO: sessionProxy.selectedApplication } );

			//delete from view
			resourceSelectorWindow.deleteResourceID = event.resource.id;

			resourceSelectorWindow.invalidateProperties(); //?

			allResourcesList = resourceSelectorWindow.resources;
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
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler ); //коряво очень
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, loadResourcesHandler );
			
			resourceSelectorWindow.removeEventListener(ResourceSelectorWindowEvent.PREVIEW_RESOURCE, onResourcePreview);
		}

		private function loadResourcesHandler( event : Event ) : void
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
			
			PopUpManager.addPopUp( resourcePreviewWindow, DisplayObject( this.resourceSelectorWindow ), true);
			PopUpManager.centerPopUp( resourcePreviewWindow );
			
			resourceSelectorWindow.removeKeyEvents();
			
			//FIXME: need be like this: resourcePreviewWindow.resourceVO = resourceVO;
			resourcePreviewWindow.setName(resourceVO.name);
			resourcePreviewWindow.setType(resourceVO.type);
			resourcePreviewWindow.setId(resourceVO.id);
			
			BindingUtils.bindSetter( previewImage, resourceVO, "data" );
			sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
			
		}
		
		private function onClosePreview( event : Event ) : void
		{
			resourcePreviewWindow.removeEventListener(Event.CLOSE, onClosePreview);
			
			PopUpManager.removePopUp(resourcePreviewWindow);
			resourcePreviewWindow = null;
			
			resourceSelectorWindow.addKeyEvents();
		}
		
		private function loadResourceHandler( event : Event ) : void
		{
			var resVO : ResourceVO = event.currentTarget.resourcesList.selectedItem as ResourceVO;
			resourceVO = resVO;

			if ( !resourceVO.data  )
			{
				BindingUtils.bindSetter( previewImage, resourceVO, "data" );
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );

				return;
			}
			
			previewIconImage();
		}

		private function loadFileHandler( event : ResourceSelectorWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECT_AND_LOAD_RESOURCE, sessionProxy.selectedApplication );
//			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
		}

		private function previewIconImage() : void
		{
			var loader : Loader = new Loader();
			loader.name = resourceVO.id;

			loader.loadBytes( resourceVO.icon );

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loaderComplete );
			loader.contentLoaderInfo.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loaderComplete );
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
						bitmap.scaleX = bitmap.scaleY = resourcePreviewWindow.resourceImage.width / bitmap.width;
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
