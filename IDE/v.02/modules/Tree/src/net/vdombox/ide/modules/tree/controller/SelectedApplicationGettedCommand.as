package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SelectedApplicationGettedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var selectedApplication : ApplicationVO = notification.getBody() as ApplicationVO;
			
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
						
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			statesObject[ ApplicationFacade.SELECTED_APPLICATION ] = selectedApplication;
			
			sendNotification( ApplicationFacade.GET_APPLICATION_STRUCTURE, selectedApplication );
			sendNotification( ApplicationFacade.GET_PAGES, selectedApplication );
		}
	}
}