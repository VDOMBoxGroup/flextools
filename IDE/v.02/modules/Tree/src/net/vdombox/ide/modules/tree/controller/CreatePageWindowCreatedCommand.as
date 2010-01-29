package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.view.CreatePageWindowMediator;
	import net.vdombox.ide.modules.tree.view.components.CreatePageWindow;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreatePageWindowCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var createPageWindow : CreatePageWindow = notification.getBody() as CreatePageWindow;
			
			facade.registerMediator( new CreatePageWindowMediator( createPageWindow ) );
		}
	}
}