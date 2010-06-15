package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WorkAreaMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveAttributesRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.needForUpdate;

			var attributesVO : Object = notification.getBody();

			if ( attributesVO is PageAttributesVO )
			{
				var pageAttributesVO : PageAttributesVO = attributesVO as PageAttributesVO;
				var workAreaMediator : WorkAreaMediator = facade.retrieveMediator( WorkAreaMediator.NAME ) as WorkAreaMediator;

//				workAreaMediator.lock();

				needForUpdateObject[ pageAttributesVO.pageVO.id ] = "";

				sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, pageAttributesVO );

				return;
			}

			if ( attributesVO is ObjectAttributesVO )
			{
				var topAttribute : AttributeVO;
				var leftAttribute : AttributeVO;
				var attributeVO : AttributeVO;

				var hasAnotherAttributes : Boolean = false;
				var objectAttributesVO : ObjectAttributesVO = attributesVO as ObjectAttributesVO;

				var itemMediatorName : String = ItemMediator.NAME + ApplicationFacade.DELIMITER + objectAttributesVO.objectVO.id;

				if ( facade.hasMediator( itemMediatorName ) )
				{
					var itemMediator : ItemMediator = facade.retrieveMediator( itemMediatorName ) as ItemMediator;

					var attributes : Array = objectAttributesVO.getChangedAttributes();

					for each ( attributeVO in attributes )
					{
						if ( attributeVO.name == "left" )
							leftAttribute = attributeVO;
						else if ( attributeVO.name == "top" )
							topAttribute = attributeVO;
						else
							hasAnotherAttributes = true;
					}

					if ( hasAnotherAttributes )
					{
						itemMediator.lock();
						needForUpdateObject[ objectAttributesVO.objectVO.id ] = "";
					}

					if ( leftAttribute )
						itemMediator.item.x = int( leftAttribute.value );

					if ( topAttribute )
						itemMediator.item.y = int( topAttribute.value );

					sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, objectAttributesVO );
				}
			}
		}
	}
}