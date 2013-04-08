package net.vdombox.ide.modules.applicationsSearch.controller
{
	import net.vdombox.ide.modules.ApplicationsSearch;
	import net.vdombox.ide.modules.applicationsSearch.view.ApplicationsSearchJunctionMediator;
	import net.vdombox.ide.modules.applicationsSearch.view.ApplicationsSearchMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : ApplicationsSearch = note.getBody() as ApplicationsSearch;
			
			facade.registerMediator( new ApplicationsSearchJunctionMediator() );
			facade.registerMediator( new ApplicationsSearchMediator( application ) )
		}
	}
}