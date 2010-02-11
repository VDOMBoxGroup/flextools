package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeLevelVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SelectedTreeLevelChangeRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );

			var currenrTreeLevelVO : TreeLevelVO = statesObject[ ApplicationFacade.SELECTED_TREE_LEVEL ] as TreeLevelVO;
			var treeLevelVO : TreeLevelVO = notification.getBody() as TreeLevelVO;
			
			if( currenrTreeLevelVO == treeLevelVO )
				return;
			
			statesObject[ ApplicationFacade.SELECTED_TREE_LEVEL ] = treeLevelVO;
			
			sendNotification( ApplicationFacade.SELECTED_TREE_LEVEL_CHANGED, treeLevelVO );
		}
	}
}