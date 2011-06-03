package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.ArrayList;
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

		public function ResourceSelectorWindowMediator( resourceSelectorWindow : ResourceSelectorWindow ) : void
		{
			viewComponent = resourceSelectorWindow;
			super( NAME, viewComponent );
		}

		private var _resourceSelector : ResourceSelector;
		private var sessionProxy : SessionProxy;
		private var _filters	 : ArrayCollection = new ArrayCollection();
		private var resourceVO : ResourceVO = new ResourceVO( "temp owner" );
		
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
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.GET_RESOURCE, loadResourceHandler );
//			resourceSelectorWindow.addEventListener( FlexEvent.CREATION_COMPLETE, addHandlersForResourcesList );    
		}
		
		private function removeHandlers() : void
		{
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.LOAD_RESOURCE, loadFileHandler ); //коряво очень поменять местами
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.GET_RESOURCE, loadResourceHandler );//коряво очень
		}
		
		private function loadResourceHandler( event : Event ) : void
		{
			var resVO : ResourceVO = event.currentTarget.resourcesList.selectedItem as ResourceVO;
			resourceVO = resVO;
			
			if ( !resVO.data || resVO.data == null )
			{
				BindingUtils.bindSetter( previewImage, resVO, "data" );
				sendNotification( ApplicationFacade.LOAD_RESOURCE, resVO );
				
				return;
			}
			
			previewImage();
		}
			
		private function loadFileHandler( event : ResourceSelectorWindowEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECT_AND_LOAD_RESOURCE, sessionProxy.selectedApplication );
		}
		
		private function previewImage( object : Object = null ) : void 
		{
			resourceSelectorWindow.imagePreview.source = resourceVO.data;
			resourceSelectorWindow.resourceResolution = resourceSelectorWindow.imagePreview.im
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