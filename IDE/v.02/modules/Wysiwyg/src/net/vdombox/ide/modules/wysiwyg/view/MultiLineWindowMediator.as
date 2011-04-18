package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.collections.ArrayCollection;
	import mx.resources.ResourceBundle;
	
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.MultilineWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.MultilineWindow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class MultiLineWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MultiLineWindowMediator";		

		public function MultiLineWindowMediator( multilineWindow : MultilineWindow ) : void
		{
			this.multilineWindow = multilineWindow;
			viewComponent = multilineWindow;
			super( NAME, viewComponent );
		}

		private var sessionProxy		: SessionProxy;
		private var multilineWindow		: MultilineWindow;

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;			
		
			sendNotification( ApplicationFacade.GET_RESOURCES, sessionProxy.selectedApplication );
			sendNotification( ApplicationFacade.GET_PAGES,     sessionProxy.selectedApplication );
		}

		override public function onRemove() : void
		{
			sessionProxy = null;
		}
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.RESOURCES_GETTED );			
			interests.push( ApplicationFacade.PAGES_GETTED );
//			multilineWindow.addEventListener( "setValue", multilineWindow_setValueHandler, false, 0, true );
			multilineWindow.addEventListener( "apply", multilineWindow_setValueHandler, false, 0, true );
						
			return interests;
		}
		
		private function multilineWindow_setValueHandler( event : MultilineWindowEvent ) : void
		{		
//			sendNotification( ApplicationFacade.MODIFY_RESOURCE, event.value ); //string	
//			modifyResource( applicationVO : ApplicationVO, resourceVO : ResourceVO, attributeName : String, operation : String, attributes : XML ) : void
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
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
	//	todo	sendNotification( ApplicationFacade.LOAD_RESOURCE, resourceVO ); if выбрали элемент 

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
			}
		}			
	}
}