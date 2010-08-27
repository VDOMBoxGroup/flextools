package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemTransformedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.needForUpdate;

			var item : ObjectRenderer = notification.getBody().item as ObjectRenderer;
//			var itemVO : ItemVO = item.itemVO;
			var attributes : Array = notification.getBody().attributes;

			var itemMediator : ItemMediator;
//			var itemMediatorName : String = ItemMediator.NAME + ApplicationFacade.DELIMITER + itemVO.id;
			var hasAnotherAttributes : Boolean = false;

			var attributeVO : AttributeVO;
			
			var topAttributeVO : AttributeVO;
			var leftAttributeVO : AttributeVO;
			var widthAttributeVO : AttributeVO;
			var heightAttributeVO : AttributeVO;

//			if ( facade.hasMediator( itemMediatorName ) )
//			{
//				itemMediator = facade.retrieveMediator( itemMediatorName ) as ItemMediator;
//
//				for each ( attributeVO in attributes )
//				{
//					switch ( attributeVO.name )
//					{
//						case "top":
//						{
//							itemMediator.item.y = int( attributeVO.value );
//
//							break;
//						}
//
//						case "left":
//						{
//							itemMediator.item.x = int( attributeVO.value );
//
//							break;
//						}
//
//						case "width":
//						{
//							itemMediator.item.width = int( attributeVO.value );
//							hasAnotherAttributes = true;
//
//							break;
//						}
//
//						case "height":
//						{
//							itemMediator.item.height = int( attributeVO.value );
//							hasAnotherAttributes = true;
//
//							break;
//						}
//
//						default:
//						{
//							hasAnotherAttributes = true;
//						}
//					}
//				}
//
//				if ( hasAnotherAttributes )
//				{
//					itemMediator.lock();
//					needForUpdateObject[ itemVO.id ] = "";
//				}
//			}
//
//			var objectVO : ObjectVO = new ObjectVO( itemVO.pageVO, itemVO.typeVO );
//			objectVO.setID( itemVO.id );
//			
//			var objectAttributesVO : ObjectAttributesVO = new ObjectAttributesVO( objectVO );
//			objectAttributesVO.attributes = attributes;
//
//			sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, objectAttributesVO );
		}
	}
}