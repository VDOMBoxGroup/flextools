package net.vdombox.ide.modules.preview.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.preview.view.ToolsetMediator;
	import net.vdombox.ide.modules.preview.view.components.Toolset;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateToolsetCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var toolset : Toolset;
			var toolsetMediator : ToolsetMediator;

			if ( facade.hasMediator( ToolsetMediator.NAME ) )
			{
				toolsetMediator = facade.retrieveMediator( ToolsetMediator.NAME ) as ToolsetMediator;
				toolset = toolsetMediator.toolset;
			}
			else
			{
				toolset = new Toolset();
				facade.registerMediator( new ToolsetMediator( toolset ) )
			}

			facade.sendNotification( Notifications.EXPORT_TOOLSET, toolset );
		}
	}
}
