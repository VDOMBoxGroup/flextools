package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
//			var item : ObjectRenderer = notification.getBody() as ObjectRenderer;
//			
//			if( item.itemVO )
//				facade.removeMediator( ItemMediator.NAME + ApplicationFacade.DELIMITER + item.itemVO.id );
		}
	}
}