package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.GalleryProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.SessionProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.SettingsProxy;
	import net.vdombox.ide.modules.applicationsManagment.model.TypesProxy;
	import net.vdombox.ide.modules.applicationsManagment.view.ApplicationsManagmentJunctionMediator;
	import net.vdombox.ide.modules.applicationsManagment.view.ApplicationsManagmentMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : ApplicationsManagment = note.getBody() as ApplicationsManagment;
			
			facade.registerMediator( new ApplicationsManagmentJunctionMediator() );
			facade.registerMediator( new ApplicationsManagmentMediator( application ) )
				
			facade.registerProxy( new SettingsProxy() );
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new GalleryProxy() );
			facade.registerProxy( new TypesProxy() );
		}
	}
}