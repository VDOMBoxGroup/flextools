package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.components.CreatePageWindow;
	import net.vdombox.ide.modules.wysiwyg.view.CreatePageWindowMediator;
	import net.vdombox.utils.WindowManager;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenCreatePageWindowRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var createPageWindow : CreatePageWindow = new CreatePageWindow();
			
			if( facade.hasMediator( CreatePageWindowMediator.NAME ) )
				facade.removeMediator( CreatePageWindowMediator.NAME );
			
			facade.registerMediator( new CreatePageWindowMediator( createPageWindow ) );
			
			WindowManager.getInstance().addWindow(createPageWindow, null, true);
		}
	}
}