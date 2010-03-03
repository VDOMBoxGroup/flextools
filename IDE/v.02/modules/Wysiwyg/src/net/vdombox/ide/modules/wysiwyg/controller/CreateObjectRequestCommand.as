package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var pageVO : PageVO = sessionProxy.selectedPage;

			if ( !pageVO )
				return;

			if ( body.parentID == pageVO.id )
			{
				sendNotification( ApplicationFacade.CREATE_OBJECT, { pageVO: pageVO, attributes: body.attributes, typeVO: body.typeVO } );
			}

			else
			{
				var objectVO : ObjectVO = new ObjectVO( pageVO, body.typeVO );
				objectVO.setID( body.parentID );
				
				sendNotification( ApplicationFacade.CREATE_OBJECT, { objectVO: objectVO, attributes: body.attributes, typeVO: body.typeVO } );
			}
		}
	}
}
