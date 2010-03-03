package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemTransformedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
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

			sendNotification( ApplicationFacade.UPDATE_ATTRIBUTES, { objectVO: sessionProxy.selectedObject, attributes: attributes } );
		}
	}
}