package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.modules.Scripts;
	import net.vdombox.ide.modules.scripts.model.SettingsProxy;
	import net.vdombox.ide.modules.scripts.view.ScriptsJunctionMediator;
	import net.vdombox.ide.modules.scripts.view.ScriptsMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Scripts = note.getBody() as Scripts;

			facade.registerMediator( new ScriptsJunctionMediator() );
			facade.registerMediator( new ScriptsMediator( application ) )

			facade.registerProxy( new SettingsProxy() );
		}
	}
}