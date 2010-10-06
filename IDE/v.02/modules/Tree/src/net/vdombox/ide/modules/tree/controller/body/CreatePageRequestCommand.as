package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.model.SessionProxy;
	
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