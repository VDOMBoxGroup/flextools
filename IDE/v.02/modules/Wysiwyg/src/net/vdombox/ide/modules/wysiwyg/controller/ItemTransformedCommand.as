package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemTransformedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.getObject( SessionProxy.NEED_FOR_UPDATE );

			var attributes : Array = [];

			var itemVO : ItemVO = notification.getBody().itemVO as ItemVO;
			var properties : Object = notification.getBody().properties;

			var attributeName : String;
			var attributeVO : AttributeVO;

			for ( attributeName in properties )
			{
				for each ( attributeVO in itemVO.attributes )
				{
					if ( attributeVO.name == attributeName )
					{
						attributeVO.value = properties[ attributeName ];
						attributes.push( attributeVO );

						break;
					}
				}
			}

			var itemMediator : ItemMediator;
			var itemMediatorName : String = ItemMediator.NAME + ApplicationFacade.DELIMITER + itemVO.id;
			var hasAnotherAttributes : Boolean = false;

			var widthAttributeVO : AttributeVO;
			var heightAttributeVO : AttributeVO;

			var topAttributeVO : AttributeVO;
			var leftAttributeVO : AttributeVO;

			if ( facade.hasMediator( itemMediatorName ) )
			{
				itemMediator = facade.retrieveMediator( itemMediatorName ) as ItemMediator;

				for each ( attributeVO in attributes )
				{
					switch ( attributeVO.name )
					{
						case "top":
						{
							itemMediator.item.y = int( attributeVO.value );

							break;
						}

						case "left":
						{
							itemMediator.item.x = int( attributeVO.value );

							break;
						}

						case "width":
						{
							itemMediator.item.width = int( attributeVO.value );
							hasAnotherAttributes = true;

							break;
						}

						case "height":
						{
							itemMediator.item.height = int( attributeVO.value );
							hasAnotherAttributes = true;

							break;
						}

						default:
						{
							hasAnotherAttributes = true;
						}
					}
				}

				if ( hasAnotherAttributes )
				{
					itemMediator.lock();
					needForUpdateObject[ itemVO.id ] = "";
				}
			}

			var objectAttributesVO : ObjectAttributesVO = new ObjectAttributesVO( sessionProxy.selectedObject );
			objectAttributesVO.attributes = attributes;

			sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, objectAttributesVO );
		}
	}
}