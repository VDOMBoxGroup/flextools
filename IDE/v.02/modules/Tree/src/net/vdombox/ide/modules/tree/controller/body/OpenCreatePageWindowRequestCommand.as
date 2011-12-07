package net.vdombox.ide.modules.tree.controller.body
{
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.CreatePageWindowMediator;
	import net.vdombox.ide.modules.tree.view.components.CreatePageWindow;
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
			
			//sendNotification( ApplicationFacade.OPEN_WINDOW, { content: createPageWindow, title: "Create Page", isModal: true, resizable : true } );
		}
	}
}