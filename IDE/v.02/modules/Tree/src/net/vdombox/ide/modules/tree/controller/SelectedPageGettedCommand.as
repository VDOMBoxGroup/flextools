package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class SelectedPageGettedCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			
			statesObject[ ApplicationFacade.SELECTED_PAGE ] = notification.getBody();
		}
	}
}