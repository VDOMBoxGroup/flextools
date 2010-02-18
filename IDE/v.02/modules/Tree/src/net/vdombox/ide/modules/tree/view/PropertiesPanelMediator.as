package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.PropertiesPanelEvent;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.PropertiesPanel;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class PropertiesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PropertiesPanelMediator";

		public function PropertiesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var selectedPageVO : PageVO;

		private var pageAttributesVO : PageAttributesVO;

		public function get propertiesPanel() : PropertiesPanel
		{
			return viewComponent as PropertiesPanel;
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

			interests.push( ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + mediatorName );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_TREE_ELEMENT_CHANGED:
				{
					var treeElementVO : TreeElementVO = notification.getBody() as TreeElementVO;

					selectedPageVO = treeElementVO.pageVO;

					if ( selectedPageVO )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, { pageVO: treeElementVO.pageVO, recipientID: mediatorName } );

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					pageAttributesVO = body as PageAttributesVO;
					propertiesPanel.pageAttributesVO = pageAttributesVO;

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + mediatorName:
				{
					pageAttributesVO = body as PageAttributesVO;
					propertiesPanel.pageAttributesVO = pageAttributesVO;

					break;
				}
			}
		}

		private function addHandlers() : void
		{

			propertiesPanel.addEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler, false, 0, true );
			propertiesPanel.addEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler, false, 0, true );

		}

		private function removeHandlers() : void
		{
			propertiesPanel.removeEventListener( PropertiesPanelEvent.SAVE_PAGE_ATTRIBUTES, savePageAttributesHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.MAKE_START_PAGE, makeStartPageHandler );
			propertiesPanel.removeEventListener( PropertiesPanelEvent.DELETE_PAGE, deletePageHandler );
		}

		private function savePageAttributesHandler( event : PropertiesPanelEvent ) : void
		{
			if ( selectedPageVO && pageAttributesVO )
			{
				sendNotification( ApplicationFacade.SET_PAGE_ATTRIBUTES,
								  { pageVO: selectedPageVO, pageAttributesVO: pageAttributesVO, recipientID: mediatorName } );
			}
		}

		private function makeStartPageHandler( event : PropertiesPanelEvent ) : void
		{

		}

		private function deletePageHandler( event : PropertiesPanelEvent ) : void
		{

		}
	}
}