package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			var structure : Array = structureProxy.getRawSructure();

			if( statesProxy.selectedApplication )
				facade.sendNotification( Notifications.SET_APPLICATION_STRUCTURE, { applicationVO: statesProxy.selectedApplication, structure: structure } );
		}
	}
}