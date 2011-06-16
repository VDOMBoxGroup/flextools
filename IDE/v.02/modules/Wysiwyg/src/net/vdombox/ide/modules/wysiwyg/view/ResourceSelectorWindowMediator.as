package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.desktop.Icon;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.controls.Alert;
	import mx.core.mx_internal;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.ListItemEvent;
	
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

		private var resourceVO : ResourceVO = new ResourceVO( "temp owner" );

		private var _resourceSelector : ResourceSelector;

		private var sessionProxy 	: SessionProxy;

		private var NoneIcon : ResourceVO = new ResourceVO( "none owner" );


		public function ResourceSelectorWindowMediator( resourceSelectorWindow : ResourceSelectorWindow ) : void
		{
			viewComponent = resourceSelectorWindow;
			super( NAME, viewComponent );
		}

		public function set resourceSelector( value : ResourceSelector ) : void
		{
			_resourceSelector = value;
		}

		private function get resourceSelectorWindow() : ResourceSelectorWindow
		{
			return viewComponent as ResourceSelectorWindow;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			resourceSelectorWindow.value = _resourceSelector.value;

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
//						resourceSelectorWindow.resources.setItemAt( icon, 0 );
						NoneIcon.name = "resource no";
						NoneIcon.icon = file.data;
						NoneIcon.data = file.data;
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
			trace( event.text );
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
					trace("ApplicationFacade.RESOURCES_GETTED:");
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
					
					resourceSelectorWindow.resources.addItemAt( NoneIcon, 0 );
					resourceSelectorWindow.typeFilter.dataProvider = _filters;
					resourceSelectorWindow.totalResources = resourceSelectorWindow.resources.length-1;

					break;
				}
					
				case ApplicationFacade.RESOURCE_SETTED:
				{
//					sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );		
					//resourceVO = body as ResourceVO;
					addNewResourceInList( body as ResourceVO );
					
					break;
				}	
			}
		}
		
		private function addNewResourceInList( resVO : ResourceVO ) : void
		{
			resourceVO = resVO;
			
			BindingUtils.bindSetter( dataLoaded, resVO, "icon" );
			filters = resVO.type;
			sendNotification( ApplicationFacade.GET_ICON, resourceVO );
//			resourceSelectorWindow.resources.addItemAt( resourceVO, resourceSelectorWindow.resources.length );
			
		}
		
		private function dataLoaded( object : Object = null ) : void
		{

		}

		private function addHandlers() : void
		{
			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, loadResourcesHandler );
//			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );    
		}

		private function addHandlersForResourcesList( event : Event ) : void
		{
			resourceSelectorWindow.typeFilter.addEventListener( Event.CHANGE, applyTypeFilter );
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

		private function applyTypeFilter( event : Event ) : void
		{
			var typeFilter : String = resourceSelectorWindow.typeFilter.selectedItem.data;
			var newResourcesList : ArrayList = new ArrayList();
			var resVO : ResourceVO;

			if ( typeFilter == "*" || typeFilter == "None" )
			{
				resourceSelectorWindow.filteredResources = resourceSelectorWindow.totalResources;

				resourceSelectorWindow.resources = allResourcesList;
			}
			else
			{
				resourceSelectorWindow.filteredResources = 0;

				for each ( resVO in allResourcesList.source )
				{
					if ( resVO.type == typeFilter )
					{
						resourceSelectorWindow.filteredResources++;
						newResourcesList.addItem( resVO );
					}
				}

				resourceSelectorWindow.resources = newResourcesList;
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
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler ); //коряво очень поменять местами
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCE,  loadResourceHandler ); //коряво очень
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, loadResourcesHandler );
		}

		private function loadResourcesHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
		}

		private function loadResourceHandler( event : Event ) : void
		{
			var resVO : ResourceVO = event.currentTarget.resourcesList.selectedItem as ResourceVO;
			resourceVO = resVO;

			displayResourceProperties();

			if ( !resourceVO.data || resourceVO.data != null )
			{
				BindingUtils.bindSetter( previewImage, resourceVO, "data" );
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );

				return;
			}

			previewIconImage();
		}

		private function displayResourceProperties() : void
		{
			resourceSelectorWindow.resourceID.text = "ID: " + resourceVO.id;
			resourceSelectorWindow.resourceName.text = resourceVO.name;
			resourceSelectorWindow.resourceType.text = resourceVO.type;
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

			resourceSelectorWindow.imagePreview.source = resourceVO.icon;
			loader.loadBytes( resourceVO.icon );

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
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
					resourceSelectorWindow.imagePreview.source = resourceVO.data;
					loader.loadBytes( resourceVO.data );
				}
				else
					return

					loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderComplete );
			}
		}

		/**
		 * convert to bitmapData for get resolution of Resource
		 */
		private function loaderComplete( event : Event ) : void
		{
			if ( resourceSelectorWindow.resources.length > 0 )
			{
				var loaderInfo : LoaderInfo;
				var bitmapData : BitmapData;

				loaderInfo = LoaderInfo( event.target );
				bitmapData = new BitmapData( loaderInfo.width, loaderInfo.height, false, 0xFFFFFF );
				bitmapData.draw( loaderInfo.loader );

				resourceSelectorWindow.resourceResolution.text = bitmapData.width + " x " + bitmapData.height;
			}
		}

		private function applyHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );

			facade.removeMediator( mediatorName );
			
			if ( resourceSelectorWindow.value )
				_resourceSelector.value = "#Res(" + resourceSelectorWindow.value + ")";
			else
				_resourceSelector.value = "#Res()";			
		}

		private function closeHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );
			facade.removeMediator( mediatorName );
		}
	}
}
