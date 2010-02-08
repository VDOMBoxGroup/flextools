package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.CreatePageWindowMediator;
	import net.vdombox.ide.modules.tree.view.components.CreatePageWindow;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenCreatePageWindowRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var createPageWindow : CreatePageWindow = new CreatePageWindow();
			
			facade.registerMediator( new CreatePageWindowMediator( createPageWindow ) );
			
			sendNotification( ApplicationFacade.OPEN_WINDOW, { content: createPageWindow, title: "Create Page", isModal: true } );
		}
	}
}