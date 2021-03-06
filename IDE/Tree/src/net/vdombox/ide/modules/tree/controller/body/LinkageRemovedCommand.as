package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.view.LinkageMediator;
	import net.vdombox.ide.modules.tree.view.components.Linkage;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LinkageRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var linkage : Linkage = notification.getBody() as Linkage;

			if ( linkage )
				facade.removeMediator( LinkageMediator.NAME + Notifications.DELIMITER + linkage.uid );

			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			structureProxy.deleteLinkage( linkage.linkageVO );
		}
	}
}
