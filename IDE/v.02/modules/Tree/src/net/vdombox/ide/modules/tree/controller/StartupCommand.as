package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.SettingsProxy;
	import net.vdombox.ide.modules.tree.view.TreeJunctionMediator;
	import net.vdombox.ide.modules.tree.view.TreeMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Tree = note.getBody() as Tree;

//			model prepare
			facade.registerProxy( new SessionProxy() );
			facade.registerProxy( new SettingsProxy() );
			
//			view prepare			
			facade.registerMediator( new TreeJunctionMediator() );
			facade.registerMediator( new TreeMediator( application ) )
		}
	}
}