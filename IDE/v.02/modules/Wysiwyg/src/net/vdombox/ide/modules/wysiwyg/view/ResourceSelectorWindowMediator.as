package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.attributeRenderers.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ResourceSelectorWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ResourceSelectorWindowMediator";

		private var _filters			: ArrayCollection = new ArrayCollection();
		private var allResourcesList	: ArrayList;
		private var resourceVO 			: ResourceVO = new ResourceVO( "temp owner" );
		private var _resourceSelector 	: ResourceSelector;
		private var sessionProxy 		: SessionProxy;
		
		
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
		
			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
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
			
			return interests;
		}
		
		/**
		 * Add type in filter list
		 * @param type - type of Resource
		 * 
		 */
		private function set filters ( type : String ) : void
		{
			for each ( var obj: Object in _filters )
			{
				if ( obj["data"] == type )
					return;
			}

			_filters.addItem({label: type.toUpperCase() , data: type});
		}
						
		override public function handleNotification( notification : INotification ) : void
		{
			var name 		: String = notification.getName();
			var body 		: Object = notification.getBody();	
			var resourceVO	: ResourceVO;
			
			switch ( name )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{
					_filters.addItem( { label : 'NONE', data : '*' } );
					
					resourceSelectorWindow.resources = new ArrayList ( body as Array );
					allResourcesList = new ArrayList ( body as Array );
					
					for each ( resourceVO in body )
					{
						BindingUtils.bindSetter( dataLoaded, resourceVO, "icon" );
						filters = resourceVO.type;
						sendNotification( ApplicationFacade.GET_ICON, resourceVO );
					}
					
					resourceSelectorWindow.filter.dataProvider	= _filters;
					resourceSelectorWindow.totalResources		= resourceSelectorWindow.resources.length;
					
					break;
				}
			}
		}
		
		private function dataLoaded( object : Object = null ) : void 
		{
			
		}
		
		private function addHandlers() : void
		{					
			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, 		closeHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, 		applyHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE, 	loadResourceHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, loadResourcesHandler );
//			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );    
		}
		
		private function addHandlersForResourcesList( event : Event ) : void
		{
			resourceSelectorWindow.filter.addEventListener( Event.CHANGE, applyExtensionFilter );
		}
		
		private function applyExtensionFilter( event : Event ) : void
		{
			var typeFilter			: String	= resourceSelectorWindow.filter.selectedItem.data;
			var newResourcesList	: ArrayList = new ArrayList(); 
			var selectedResID		: String
			
			if ( resourceSelectorWindow.resourcesList.selectedItem )
				selectedResID = resourceSelectorWindow.resourcesList.selectedItem.id;
			else
				selectedResID = null;			
			
			if ( typeFilter == "*" || typeFilter == "None" )
			{
				resourceSelectorWindow.filteredResources = resourceSelectorWindow.totalResources;
				
				resourceSelectorWindow.resources = allResourcesList;
			}
			else
			{		
				resourceSelectorWindow.filteredResources = 0;
				
				for each ( var res : ResourceVO in allResourcesList.source )
				{
					if ( res.type == typeFilter )
					{
						resourceSelectorWindow.filteredResources++;
						newResourcesList.addItem( res );
					}
				}
				
				resourceSelectorWindow.resources = newResourcesList;
			}
			
			if ( selectedResID == null )
				return;
			
			resourceSelectorWindow.resourcesList.selectedIndex = 0;
			
			var res2 : ResourceVO;
			
			for ( var i : int = 0; i < resourceSelectorWindow.resources.length; i++ )
			{		
				res2 = resourceSelectorWindow.resources.source[i] as ResourceVO;
				
				if ( res2.id == selectedResID )
				{
					resourceSelectorWindow.resourcesList.selectedIndex = i;
					
					break;
				}
			}
		}
		
		private function removeHandlers() : void
		{
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.CLOSE, 			closeHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.APPLY, 			applyHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, 	loadFileHandler ); //коряво очень поменять местами
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCE, 	loadResourceHandler );//коряво очень
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCES, 	loadResourcesHandler );
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
			
			if ( !resVO.data || resVO.data == null )
			{
				BindingUtils.bindSetter( previewImage, resVO, "data" );
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resVO );
				
				return;
			}
			
			previewImage();
		}
		
		private function displayResourceProperties( ) : void
		{
			resourceSelectorWindow.resourceID.text	 = "ID: " + resourceVO.id;
			resourceSelectorWindow.resourceName.text = resourceVO.name;
			resourceSelectorWindow.resourceType.text = resourceVO.type;
		}
					
		private function loadFileHandler( event : ResourceSelectorWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECT_AND_LOAD_RESOURCE, sessionProxy.selectedApplication );
		}
		
		private function previewImage( object : Object = null ) : void 
		{
			//for convert to bitmapData and get width and height of resource
			var loader : Loader = new Loader();	
			loader.name = resourceVO.id;
			
			if ( resourceVO.icon != null )
			{
				resourceSelectorWindow.imagePreview.source = resourceVO.icon;
				loader.loadBytes(resourceVO.icon);
			}
			else if ( resourceVO.data != null )
			{
				resourceSelectorWindow.imagePreview.source = resourceVO.data;
				loader.loadBytes(resourceVO.data);
			}
			else
				return
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loaderComplete);
		}
			
		//convert to bitmapData 
		private function loaderComplete( event : Event ):void
		{
			var loaderInfo : LoaderInfo;
			var bitmapData : BitmapData;
			
			loaderInfo	= LoaderInfo( event.target );
			bitmapData	= new BitmapData(loaderInfo.width, loaderInfo.height, false, 0xFFFFFF);
			bitmapData.draw(loaderInfo.loader); 
			
			resourceSelectorWindow.resourceResolution.text = bitmapData.width + " x " + bitmapData.height;
		}		
		
		private function applyHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );
			
			facade.removeMediator( mediatorName );
			_resourceSelector.value = "#Res(" + resourceSelectorWindow.value + ")";
		}

		private function closeHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );
			facade.removeMediator( mediatorName );
		}
	}
}