package net.vdombox.ide.modules.edition.controller
{
	import net.vdombox.ide.modules.applicationsManagment.view.ApplicationsManagmentJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			facade.registerMediator( new ApplicationsManagmentJunctionMediator() );
		}
	}
}