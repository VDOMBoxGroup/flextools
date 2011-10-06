package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.view.ApplicationManagerWindowMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenAppInEditorCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			facade.removeMediator( ApplicationManagerWindowMediator.NAME );
			sendNotification( ApplicationFacade.OPEN_MAIN_WINDOW );
		}
	}
}