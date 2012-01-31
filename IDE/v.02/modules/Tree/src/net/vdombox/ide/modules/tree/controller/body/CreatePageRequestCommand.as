package net.vdombox.ide.modules.tree.controller.body
{
	import mx.core.Application;
	
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	import net.vdombox.ide.modules.tree.model.StructureProxy;
	import net.vdombox.ide.modules.tree.model.vo.TreeElementVO;
	import net.vdombox.ide.modules.tree.view.components.TreeElement;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreatePageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var typeVO : TypeVO = notification.getBody() as TypeVO;

			if ( sessionProxy.selectedApplication )
			{
				sendNotification( ApplicationFacade.CREATE_PAGE,
					{ applicationVO: sessionProxy.selectedApplication, typeVO: typeVO } );				
			}				
		}
	}
}