package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.model.vo.ApplicationVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.view.WorkAreaMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class UndoRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			if( sessionProxy.selectedApplication )
			{ 
				facade.sendNotification( ApplicationFacade.GET_PAGES, { applicationVO: sessionProxy.selectedApplication} );
				facade.sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, { applicationVO: sessionProxy.selectedApplication} );
			}
		}
	}
}