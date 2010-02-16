package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.PagesPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.PagesPanel;
	
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

		private var selectedApplicationVO : ApplicationVO;

		public function get pagesPanel() : PagesPanel
		{
			return viewComponent as PagesPanel;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_APPLICATION_GETTED );
			interests.push( ApplicationFacade.PAGES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					selectedApplicationVO = body as ApplicationVO;

					sendNotification( ApplicationFacade.GET_PAGES, { applicationVO: selectedApplicationVO } );

					break;
				}

				case ApplicationFacade.PAGES_GETTED:
				{
					var pages : Array = body as Array;

					pages.unshift( { id: "application", name: "-applications scripts-", applicationVO: selectedApplicationVO } );

					pagesPanel.pages = pages;

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
			pagesPanel.addEventListener( PagesPanelEvent.PAGE_CHANGED, pageChangedHandler );
		}

		private function removeHandlers() : void
		{

		}

		private function pageChangedHandler( event : PagesPanelEvent ) : void
		{
			var pageVO : PageVO = pagesPanel.selectedPage as PageVO;
					
			sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, pageVO );
		}
	}
}