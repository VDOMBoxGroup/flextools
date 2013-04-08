package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.view.TreeJunctionMediator;
	import net.vdombox.ide.modules.tree.view.TreeMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupViewCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Tree = note.getBody() as Tree;

			facade.registerMediator( new TreeJunctionMediator() );
			facade.registerMediator( new TreeMediator( application ) )
		}
	}
}
