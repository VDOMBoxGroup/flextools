package net.vdombox.ide.modules.preview.view
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.events.PagesPanelEvent;
	import net.vdombox.ide.modules.preview.model.SessionProxy;
	import net.vdombox.ide.modules.preview.view.components.PagesPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PagesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PagesPanelMediator";

		public function PagesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;
		
		private var isActive : Boolean;
		
		public function get pagesPanel() : PagesPanel
		{
			return viewComponent as PagesPanel;
		}

		override public function onRegister() : void
		{
			isActive = false;
			
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
			
			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );
			
			interests.push( ApplicationFacade.PAGES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;
			
			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );
						
						break;
					}
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					var pages : Array = body as Array;

					pages.unshift( { id: "application", name: "-applications scripts-", applicationVO: sessionProxy.selectedApplication } );

					pagesPanel.pages = pages;
					
					pagesPanel.selectedPage = sessionProxy.selectedPage;
					
					

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					var selectedPageVO : PageVO = body as PageVO;

					pagesPanel.selectedPage = selectedPageVO;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			pagesPanel.addEventListener( PagesPanelEvent.PAGE_CHANGED, pageChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			pagesPanel.removeEventListener( PagesPanelEvent.PAGE_CHANGED, pageChangedHandler );
		}

		private function clearData() : void
		{
			pagesPanel.pages = null;
		}
		
		private function pageChangedHandler( event : PagesPanelEvent ) : void
		{
			var pageVO : PageVO = pagesPanel.selectedPage as PageVO;
			
			if( pageVO )
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, pageVO );
		}
	}
}