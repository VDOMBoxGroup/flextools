package net.vdombox.ide.modules.preview.controller
{
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	import net.vdombox.ide.modules.preview.view.ContainersPanelMediator;
	import net.vdombox.ide.modules.preview.view.LibrariesPanelMediator;
	import net.vdombox.ide.modules.preview.view.PagesPanelMediator;
	import net.vdombox.ide.modules.preview.view.ScriptEditorMediator;
	import net.vdombox.ide.modules.preview.view.ServerScriptsPanelMediator;
	import net.vdombox.ide.modules.preview.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

//			facade.registerMediator( new ScriptEditorMediator( body.sriptEditor ) );
//			
//			facade.registerMediator( new PagesPanelMediator( body.pagesPanel ) );
//			facade.registerMediator( new ContainersPanelMediator( body.containersPanel ) );
//			facade.registerMediator( new ServerScriptsPanelMediator( body.serverScriptsPanel ) );
//			facade.registerMediator( new LibrariesPanelMediator( body.librariesPanel ) );
		}
	}
}