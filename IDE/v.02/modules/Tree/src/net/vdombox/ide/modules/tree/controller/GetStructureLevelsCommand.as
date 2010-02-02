package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetStructureLevelsCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureLevelsProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			
			sendNotification( ApplicationFacade.STRUCTURE_LEVELS_GETTED, structureLevelsProxy.structureLevels );
		}
	}
}