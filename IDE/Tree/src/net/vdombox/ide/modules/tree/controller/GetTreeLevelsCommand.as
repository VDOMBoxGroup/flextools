package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StructureProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetTreeLevelsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureLevelsProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;

			sendNotification( Notifications.TREE_LEVELS_GETTED, structureLevelsProxy.treeLevels );
		}
	}
}
