package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );

			var applicationVO : ApplicationVO = statesObject[ ApplicationFacade.SELECTED_APPLICATION ];
			var structure : Array = structureProxy.getRawSructure();

			facade.sendNotification( ApplicationFacade.SET_APPLICATION_STRUCTURE, { applicationVO: applicationVO, structure: structure } );
		}
	}
}