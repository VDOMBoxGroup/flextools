package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
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

		private var typeVO : TypeVO;

		private var pageAttributes : PageAttributesVO;

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
					pageAttributes = body as PageAttributesVO;

					var attributeVO : AttributeVO;

					attributeVO = getAttributeByName( "title" );

					if ( attributeVO )
						propertiesPanel.pageTitle = attributeVO.value;
					
					attributeVO = getAttributeByName( "description" );
					
					if ( attributeVO )
						propertiesPanel.pageDescription = attributeVO.value;

					attributeVO = getAttributeByName( "image" );
					
					if ( attributeVO )
						propertiesPanel.pageImage = attributeVO.value;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{

		}

		private function removeHandlers() : void
		{

		}

		private function getAttributeByName( name : String ) : AttributeVO
		{
			var result : AttributeVO;

			for each ( var attributeVO : AttributeVO in pageAttributes.attributes )
			{
				if ( attributeVO.name == name )
				{
					result = attributeVO;

					break;
				}
			}

			return result;
		}
	}
}