package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.resourceSelector.ResourceSelector;
	import net.vdombox.ide.modules.wysiwyg.view.components.resourceSelector.ResourceSelectorWindow;
	
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
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{
					resourceSelectorWindow.resources = body as Array;
					
					var resourceVO : ResourceVO;
					
					for each( resourceVO in body )
					{
						sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO );
					}
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.addEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
		}

		private function removeHandlers() : void
		{
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.CLOSE, closeHandler );
			resourceSelectorWindow.removeEventListener( ResourceSelectorWindowEvent.APPLY, applyHandler );
		}

		private function applyHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );
			
			facade.removeMediator( mediatorName );
			_resourceSelector.value = resourceSelectorWindow.value;
		}

		private function closeHandler( event : ResourceSelectorWindowEvent ) : void
		{
			PopUpManager.removePopUp( resourceSelectorWindow );
			facade.removeMediator( mediatorName );
		}
	}
}