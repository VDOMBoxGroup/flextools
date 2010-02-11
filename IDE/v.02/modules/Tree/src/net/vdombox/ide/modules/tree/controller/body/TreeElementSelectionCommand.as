package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class TreeElementSelectionCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeElementVO : TreeElementVO = notification.getBody() as TreeElementVO;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var sessionObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			var currentSelectedTreeElement : TreeElementVO = sessionObject[ ApplicationFacade.SELECTED_TREE_ELEMENT ];

			if ( currentSelectedTreeElement == treeElementVO )
				return;

			sendNotification( ApplicationFacade.SET_SELECTED_PAGE, treeElementVO.pageVO );
		}
	}
}