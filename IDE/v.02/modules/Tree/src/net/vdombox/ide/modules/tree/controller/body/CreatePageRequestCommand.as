package net.vdombox.ide.modules.tree.controller.body
{
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
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
			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );
			var pageAttributesVO : PageAttributesVO = new PageAttributesVO( new PageVO( 

			sendNotification( ApplicationFacade.CREATE_PAGE,
							  { applicationVO: statesObject[ ApplicationFacade.SELECTED_APPLICATION ], typeVO: typeVO, pageAttributesVO : pageAttributesVO } );
		}
	}
}