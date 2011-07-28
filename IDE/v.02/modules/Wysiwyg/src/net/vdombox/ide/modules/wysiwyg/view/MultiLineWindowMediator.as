package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.managers.PopUpManager;
	
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.AttributeEvent;
	import net.vdombox.ide.modules.wysiwyg.events.MultilineWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.MultilineWindow;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ResourceSelectorWindow;
	import net.vdombox.ide.modules.wysiwyg.view.skins.MultilineWindowSkin;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	/**
	 * MultiLineWindowMediator is wrapper on WindowMediator.mxml.   
	 * Get Resources and Pages and set it in combobox for chose.
	 * @author Elena Kotlova
	 */
	public class MultiLineWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MultiLineWindowMediator";		

		public function MultiLineWindowMediator( multilineWindow : MultilineWindow ) : void
		{
			this.multilineWindow = multilineWindow;
			viewComponent = multilineWindow;
			super( NAME, viewComponent );
		}

		private var sessionProxy	: SessionProxy;
		private var multilineWindow	: MultilineWindow;

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;			
	
			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
			sendNotification( ApplicationFacade.GET_PAGES,     sessionProxy.selectedApplication );
			
			multilineWindow.addEventListener( MultilineWindowEvent.APPLY, removeYourself, false, 0, true );
			multilineWindow.addEventListener( AttributeEvent.SELECT_RESOURCE, selectResourceHandler );
		}
		
		override public function onRemove() : void
		{
			sessionProxy = null;
			multilineWindow.removeEventListener(AttributeEvent.SELECT_RESOURCE, selectResourceHandler, false);
			multilineWindow = null;
		}
		
		private function removeYourself ( event : MultilineWindowEvent ) : void
		{
			//multilineWindow.removeEventListener( MultilineWindowEvent.APPLY, removeYourself, false );
			facade.removeMediator( NAME );
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.RESOURCES_GETTED );			
			interests.push( ApplicationFacade.PAGES_GETTED );	
			
			return interests;
		}
		
		private function selectResourceHandler( event : AttributeEvent ) : void
		{
			var multilineWindow : MultilineWindow = event.target as MultilineWindow;
			var resourceSelectorWindow : ResourceSelectorWindow = new ResourceSelectorWindow();
			
			var resourceSelectorWindowMediator : ResourceSelectorWindowMediator = new ResourceSelectorWindowMediator( resourceSelectorWindow );			
			facade.registerMediator( resourceSelectorWindowMediator );
			
			resourceSelectorWindow.multilineSelected = true;
			resourceSelectorWindow.addEventListener( Event.CHANGE, applyHandler, false, 0, true);
			
			
			PopUpManager.addPopUp( resourceSelectorWindow, DisplayObject( multilineWindow.parentApplication ), true);
			PopUpManager.centerPopUp( resourceSelectorWindow );
			
			function applyHandler (event: Event):void
			{
				if (multilineWindow.focus)
					multilineWindow.textAreaContainer.insertText((event.target as ResourceSelectorWindow).value);	
				else
					multilineWindow.attributeValue += (event.target as ResourceSelectorWindow).value;
				resourceSelectorWindow.removeEventListener(Event.CHANGE, applyHandler, false);
				PopUpManager.removePopUp( resourceSelectorWindow );
//				facade.removeMediator( mediatorName );
				//resourceSelectorWindow.dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.CLOSE ) );
			}		
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			/*var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.RESOURCES_GETTED:
				{									
					var resources: ArrayCollection = new ArrayCollection();
					
					for each( var resVO: ResourceVO in body )
					{
						resources.addItem({"label":resVO.name, "data":resVO.id});
					}
					
					multilineWindow.resourceList.dataProvider = resources;
					
					if ( multilineWindow.resourceList.dataProvider[0] )
						 multilineWindow.resourceList.selectedIndex = 0;						

					break;
				}
					
				case ApplicationFacade.PAGES_GETTED:
				{
					var pages: ArrayCollection = new ArrayCollection();
					
					for each( var pageVO: PageVO in body )
					{
						pages.addItem({"label":pageVO.name, "data":pages.length});
					}
					
					multilineWindow.pageList.dataProvider = pages;
					
					if ( multilineWindow.pageList.dataProvider[0] )
						 multilineWindow.pageList.selectedIndex = 0;						
					
					break;
				}
			}*/
		}			
	}
}