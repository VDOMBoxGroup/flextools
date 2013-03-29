//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
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
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.common.view.components.VDOMImage;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.components.windows.SpinnerPopup;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ListItem;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ListItemEvent;
	import net.vdombox.ide.common.view.components.windows.resourceBrowserWindow.ResourcePreviewWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
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

		public static const NAME : String               = "ResourceSelectorWindowMediator";

		/**
		 *
		 * @param resourceSelectorWindow
		 */
		public function ResourceSelectorWindowMediator( resourceSelectorWindow : ResourceSelectorWindow ) : void
		{
			viewComponent = resourceSelectorWindow;
			super( NAME, viewComponent );
		}

		private var _filters : ArrayCollection          = new ArrayCollection();

		private var allResourcesList : ArrayList;

		private var delResVO : ResourceVO;

		private var noneIcon : ResourceVO               = new ResourceVO( ResourceVO.RESOURCE_NONE );

		private var resourcePreviewWindow : ResourcePreviewWindow;

		private var resourceVO : ResourceVO             = new ResourceVO( ResourceVO.RESOURCE_TEMP );

		private var showSpinnerOnListCreation : Boolean = true;

		private var spinnerPopup : SpinnerPopup;

		private var statesProxy : StatesProxy;

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case Notifications.RESOURCES_GETTED:
				{
					resourceSelectorWindow.callLater(updateData, [body]);

					break;
				}

				case Notifications.RESOURCE_SETTED:
				{
					var resVO : ResourceVO = body as ResourceVO;
					
					if ( resVO.status == ResourceVO.LOAD_ERROR )
					{
						removeSpinnerPopup();
					}
					else
					{
						addNewResourceInList( resVO );
					}
			
					break;
				}
			}
		}



		/**
		 *
		 * @param event
		 */
		public function ioErrorHandler( event : IOErrorEvent ) : void
		{
			//trace( "###################### ERROR" + event.text );
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.RESOURCES_GETTED );

			interests.push( Notifications.RESOURCE_SETTED );

			return interests;
		}

		override public function onRegister() : void
		{
			//trace("Res: onRegister()");

			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			addHandlers();

			sendNotification( Notifications.GET_RESOURCES, statesProxy.selectedApplication );
		}

		override public function onRemove() : void
		{
			//trace("Res: onRemove()");

			removeHandlers();

			statesProxy = null;

			allResourcesList = null;

			resourceSelectorWindow.resources = null;
			resourceSelectorWindow.resourcesList.dataProvider = null;

			_filters = null;

			delResVO = null;

			noneIcon = null;

			resourceVO = null;

			spinnerPopup = null;
		}

		/**
		 *
		 * @param event
		 */
		public function onResourceWindowCreationComplete(event : Event) : void
		{
			resourceSelectorWindow.removeEventListener( ResourceVOEvent.CREATION_COMPLETE, onResourceWindowCreationComplete );

			if ( !showSpinnerOnListCreation )
			{
				showSpinnerOnListCreation = true;

				return;
			}

			var spinnerTxt : String = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'spinner_create_resources' );

			createSpinnerPopup(spinnerTxt);
		}

		/**
		 *
		 * @param event
		 */
		public function onResourceWindowListItemCreationComplete(event : Event) : void
		{
			resourceSelectorWindow.removeEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true );
			showSpinnerOnListCreation = false;

			removeSpinnerPopup();
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


		private function addHandlers() : void
		{
			//trace("Res: addHandlers()");
			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.addEventListener( Event.CLOSE, closeHandler );
//			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.addEventListener( ResourceVOEvent.LOAD_RESOURCE, loadFileHandler );
//			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler, true );
			resourceSelectorWindow.addEventListener( ResourceVOEvent.GET_RESOURCES, getResourcesRequestHandler );
			resourceSelectorWindow.addEventListener( ResourceVOEvent.PREVIEW_RESOURCE, onResourcePreview );

			resourceSelectorWindow.addEventListener( ResourceVOEvent.CREATION_COMPLETE, onResourceWindowCreationComplete );
			resourceSelectorWindow.addEventListener( ResourceVOEvent.LIST_ITEM_CREATION_COMPLETE, onResourceWindowListItemCreationComplete, true, 0, true );

		}

		private function addHandlersForResourcesList( event : Event ) : void
		{
			initTitle();

			resourceSelectorWindow.nameFilter.addEventListener( Event.CHANGE, applyNameFilter );
			resourceSelectorWindow.resourcesList.addEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler, true, 0, true );
			resourceSelectorWindow.resourcesList.addEventListener( ResourceVOEvent.GET_ICON, getIconRequestHendler, true, 0,true);
		}

		private function addNewResourceInList( resVO : ResourceVO ) : void
		{
			resourceVO = resVO;

			addFilter( resourceVO.type);

			resourceSelectorWindow.addResource(  resourceVO );

			removeSpinnerPopup();
		}


		private function applyNameFilter( event : Event ) : void
		{
			var nameFilter : String          = resourceSelectorWindow.nameFilter.text.toLowerCase();
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
				if ( !resVO )
					continue;

				if ( resVO.name.toLowerCase().indexOf( nameFilter ) >= 0 || resVO.type.toLowerCase().indexOf( nameFilter ) >= 0 )
				{
					resourceSelectorWindow.filteredResources++;
					newResourcesList.addItem( resVO );
				}
			}

			resourceSelectorWindow.resources = newResourcesList;
		}


		private function closeHandler( event : Event ) : void
		{
			allResourcesList = null;

			facade.removeMediator( mediatorName );
		}

		private function createSpinnerPopup(spinnerTxt : String) : void
		{
			if ( spinnerPopup )
				return;

			spinnerPopup = new SpinnerPopup(spinnerTxt);
			spinnerPopup.width = resourceSelectorWindow.width;
			spinnerPopup.height = resourceSelectorWindow.height;

			PopUpManager.addPopUp(spinnerPopup, DisplayObject(resourceSelectorWindow), true);
		}

		private function deleteResourceCloseHandler(event : PopUpWindowEvent) : void
		{
			if ( event.detail == Alert.YES )
			{
				//delete from server
				sendNotification( Notifications.DELETE_RESOURCE, { resourceVO: delResVO, applicationVO: statesProxy.selectedApplication } );

				//delete from view
				resourceSelectorWindow.deleteResourceID = delResVO.id;

				resourceSelectorWindow.invalidateProperties(); //?

				//delete from array
				//allResourcesList = resourceSelectorWindow.resources;
				deleteResourceInArray( delResVO.id );
				resourceSelectorWindow.totalResources--;
			}
		}


		private function deleteResourceHandler( event : ListItemEvent ) : void
		{
			var componentName : String = event.resource ? event.resource.name : "";

			delResVO = event.resource;

			Alert.setPatametrs( "Delete", "Cancel", VDOMImage.Delete );

			Alert.Show( ResourceManager.getInstance().getString( 'Wysiwyg_General', 'delete_Resource' ),
						ResourceManager.getInstance().getString( 'Wysiwyg_General', 'delete_Renderer' ) + "\n" + componentName + " ?", 
						AlertButton.OK_No, 
						resourceSelectorWindow, deleteResourceCloseHandler);
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

		private function getIconRequestHendler( event: ResourceVOEvent) : void
		{
			var listItem : ListItem = event.target.parent as ListItem;

			sendNotification( Notifications.GET_ICON, listItem.resourceVO );
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

		private function getResourcesRequestHandler( event : Event ) : void
		{
			sendNotification( Notifications.GET_RESOURCES, statesProxy.selectedApplication );
		}

		private function initTitle() : void
		{
			resourceSelectorWindow.title = ResourceManager.getInstance().getString( 'Wysiwyg_General', 'resource_selector_window_title' );
		}



		// TODO: put in resourceSelectorWindow
		private function loadFileHandler( event : ResourceVOEvent ) : void
		{
			var openFile : File = new File();

			openFile.addEventListener(Event.SELECT, fileSelected);

			var allFilesFilter : FileFilter = new FileFilter( "All Files (*.*)", "*.*" );
			var imagesFilter : FileFilter   = new FileFilter( 'Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png' );
			var docFilter : FileFilter      = new FileFilter( 'Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt' );

			openFile.browseForOpen( "Choose file to upload", [ allFilesFilter, imagesFilter, docFilter ] );

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
				resourceVO.type = openFile.type ? openFile.type.slice(1) : "";  // type has "."

				sendNotification( Notifications.SET_RESOURCE, resourceVO );
			}
		}

		/**
		 * convert to bitmapData for get resolution of Resource
		 */
		private function loaderComplete( event : Event ) : void
		{
			if ( event.type != Event.COMPLETE )
				return;


			// TODO: do it in resourcePreviewWindow
			if ( resourceSelectorWindow.resources.length > 0 )
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
						|| resourcePreviewWindow.resourceImage.width < bitmap.width )
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

		private function onClosePreview( event : Event ) : void
		{
			resourcePreviewWindow.removeEventListener( Event.CLOSE, onClosePreview );

			WindowManager.getInstance().removeWindow( resourcePreviewWindow );

			resourcePreviewWindow = null;
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

		private function removeHandlers() : void
		{
			//trace("Res: removeHandlers()");
			resourceSelectorWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.removeEventListener( Event.CLOSE, closeHandler );
			resourceSelectorWindow.removeEventListener( ResourceVOEvent.LOAD_RESOURCE, loadFileHandler ); //коряво очень поменять местами
			resourceSelectorWindow.removeEventListener( ResourceVOEvent.GET_RESOURCES, getResourcesRequestHandler );

			resourceSelectorWindow.removeEventListener(ResourceVOEvent.PREVIEW_RESOURCE, onResourcePreview);

			resourceSelectorWindow.nameFilter.removeEventListener( Event.CHANGE, applyNameFilter );
			resourceSelectorWindow.resourcesList.removeEventListener( ListItemEvent.DELETE_RESOURCE, deleteResourceHandler );
			resourceSelectorWindow.resourcesList.removeEventListener( ResourceVOEvent.GET_ICON, getIconRequestHendler );

		}

		private function removeSpinnerPopup() : void
		{
			if ( !spinnerPopup )
				return;

			spinnerPopup.close();

			spinnerPopup = null;
		}

		private function get resourceSelectorWindow() : ResourceSelectorWindow
		{
			return viewComponent as ResourceSelectorWindow;
		}



		private function updateData(resources: Array) : void
		{
			_filters.removeAll();
			_filters.addItem( { label: 'NONE', data: '*' } );

			allResourcesList = new ArrayList( resources );
			resourceSelectorWindow.resources = new ArrayList( resources );

			for each ( var resVO : ResourceVO in resources )
			{
				addFilter(resVO.type);
			}

			// set empty resource as null in ListItem
			resourceSelectorWindow.resources.addItemAt( null, 0 );
			resourceSelectorWindow.totalResources = allResourcesList.source.length - 1;

		}
	}
}
