package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.view.ContainersPanelMediator;
	import net.vdombox.ide.modules.scripts.view.GlobalScriptsPanelMediator;
	import net.vdombox.ide.modules.scripts.view.LibrariesPanelMediator;
	import net.vdombox.ide.modules.scripts.view.ScriptEditorMediator;
	import net.vdombox.ide.modules.scripts.view.ServerScriptsPanelMediator;
	import net.vdombox.ide.modules.scripts.view.WorkAreaMediator;
	import net.vdombox.ide.modules.scripts.view.components.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			//facade.registerMediator( new ScriptEditorMediator( body.sriptEditor ) );
			
			facade.registerMediator( new WorkAreaMediator( body.workArea ) );
			
			facade.registerMediator( new GlobalScriptsPanelMediator( body.globalScriptsPanel ) );
			facade.registerMediator( new ContainersPanelMediator( body.containersPanel ) );
			facade.registerMediator( new ServerScriptsPanelMediator( body.serverScriptsPanel ) );
			facade.registerMediator( new LibrariesPanelMediator( body.librariesPanel ) );
		}
	}
}