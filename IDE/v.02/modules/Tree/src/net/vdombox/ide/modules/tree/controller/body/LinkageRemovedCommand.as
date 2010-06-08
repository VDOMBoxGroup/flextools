package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.vo.LinkageVO;
	import net.vdombox.ide.modules.tree.view.LinkageMediator;
	import net.vdombox.ide.modules.tree.view.components.Linkage;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class LinkageRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var linkage : Linkage = notification.getBody() as Linkage;
			
			if( linkage )
				facade.removeMediator( LinkageMediator.NAME + ApplicationFacade.DELIMITER + linkage.uid );
		}
	}
}