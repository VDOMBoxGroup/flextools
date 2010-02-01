package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
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

		private var pageAttributes : Array;

		public function get propertiesPanel() : PropertiesPanel
		{
			return viewComponent as PropertiesPanel;
		}

		override public function onRegister() : void
		{
			addEventListeners();
		}

		override public function onRemove() : void
		{
			removeEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectedPageVO = notification.getBody().pageVO as PageVO;
					typeVO = notification.getBody().typeVO as TypeVO;

					propertiesPanel.typeName = typeVO.displayName;

					if ( selectedPageVO )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, selectedPageVO );

					break;
				}

				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{
					pageAttributes = body as Array;

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

		private function addEventListeners() : void
		{

		}

		private function removeEventListeners() : void
		{

		}

		private function getAttributeByName( name : String ) : AttributeVO
		{
			var result : AttributeVO;

			for each ( var attributeVO : AttributeVO in pageAttributes )
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