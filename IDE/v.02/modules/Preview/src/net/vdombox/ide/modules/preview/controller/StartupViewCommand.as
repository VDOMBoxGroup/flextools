package net.vdombox.ide.modules.preview.controller
{
	
	import net.vdombox.ide.modules.Preview2;
	import net.vdombox.ide.modules.preview.view.ScriptsJunctionMediator;
	import net.vdombox.ide.modules.preview.view.ScriptsMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupViewCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Preview2 = note.getBody() as Preview2;

			facade.registerMediator( new ScriptsJunctionMediator() );
			facade.registerMediator( new ScriptsMediator( application ) )
		}
	}
}