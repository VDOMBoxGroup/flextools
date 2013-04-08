package net.vdombox.ide.modules.applicationsSearch.controller
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.applicationsSearch.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsSearch.view.ToolsetMediator;
	import net.vdombox.ide.modules.applicationsSearch.view.components.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateToolsetCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var toolset : Toolset = new Toolset();
			
			facade.registerMediator( new ToolsetMediator( toolset ) )
			
			facade.sendNotification( ApplicationFacade.EXPORT_TOOLSET, toolset );
		}
	}
}