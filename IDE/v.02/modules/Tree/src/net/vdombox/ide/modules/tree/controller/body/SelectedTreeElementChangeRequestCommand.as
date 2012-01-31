package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SelectedTreeElementChangeRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var treeElementVO : TreeElementVO = notification.getBody() as TreeElementVO;

			sessionProxy.selectedTreeElement = treeElementVO;

			var pageVO : PageVO = treeElementVO ? treeElementVO.pageVO : null;

			sendNotification( ApplicationFacade.SET_SELECTED_PAGE, pageVO );
		}
	}
}