package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedPageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var selectedPageVO : PageVO = notification.getBody() as PageVO;
			
			var itemMediatorName : String;
			var instances : Object = ItemMediator.instances;
			
			for ( itemMediatorName in ItemMediator.instances )
			{
				facade.removeMediator( itemMediatorName );
			}
			
			sessionProxy.selectedPage = selectedPageVO;
		}
	}
}