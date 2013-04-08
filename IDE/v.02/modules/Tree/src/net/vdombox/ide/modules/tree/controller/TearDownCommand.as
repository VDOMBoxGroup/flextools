package net.vdombox.ide.modules.tree.controller
{
	import net.vdombox.ide.modules.tree.view.TreeJunctionMediator;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;

	public class TearDownCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var treeJunctionMediator : TreeJunctionMediator = facade.retrieveMediator( TreeJunctionMediator.NAME ) as TreeJunctionMediator;

			treeJunctionMediator.tearDown();

			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}
