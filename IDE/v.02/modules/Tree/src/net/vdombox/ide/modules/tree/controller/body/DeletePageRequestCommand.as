package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class DeletePageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var pageVO : PageVO = notification.getBody() as PageVO;

			if ( statesProxy.selectedApplication && pageVO )
			{
				sendNotification( ApplicationFacade.DELETE_PAGE,
					{ applicationVO: statesProxy.selectedApplication, pageVO: pageVO } );
			}
		}
	}
}