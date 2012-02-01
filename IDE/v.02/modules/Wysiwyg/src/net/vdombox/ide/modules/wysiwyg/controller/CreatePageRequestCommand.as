package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreatePageRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			var typeVO : TypeVO = notification.getBody() as TypeVO;
			
			if ( statesProxy.selectedApplication )
			{
				sendNotification( ApplicationFacade.CREATE_PAGE,
					{ applicationVO: statesProxy.selectedApplication, typeVO: typeVO } );				
			}				
		}
	}
}