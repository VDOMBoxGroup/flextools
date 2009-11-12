package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.modules.ApplicationsManagment;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.view.ToolsetMediator;
	import net.vdombox.ide.modules.applicationsManagment.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateToolsetCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var toolset : Toolset = new Toolset();
			toolset.label = ApplicationsManagment.NAME;
			
			facade.registerMediator( new ToolsetMediator( toolset ) )
			
			facade.sendNotification( ApplicationFacade.EXPORT_TOOLSET, toolset );
		}
	}
}