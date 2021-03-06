package net.vdombox.ide.modules.tree.controller.body
{
	import flash.utils.getQualifiedClassName;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.tree.model.StructureProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var structureProxy : StructureProxy = facade.retrieveProxy( StructureProxy.NAME ) as StructureProxy;
			var pageVO : PageVO = notification.getBody().pageVO as PageVO;

			sendNotification( Notifications.SEND_TO_LOG, getQualifiedClassName( this ) );

			structureProxy.createTreeElementByVO( pageVO );


		/*
		   todo
		   for each (var te:TreeElementVO in structureProxy.treeElements)
		   {
		   if (te.pageVO == pageVO)
		   {
		   sendNotification( Notifications.SELECTED_TREE_ELEMENT_CHANGE_REQUEST, te );
		   }
		   }
		 */
		}
	}
}
