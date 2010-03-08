package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SelectItemRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var itemVO : ItemVO = notification.getBody() as ItemVO;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var isPage : Boolean = itemVO.typeVO.container == 3 ? true : false;
			var objectVO : ObjectVO;
			
			if( !isPage )
			{
				if ( sessionProxy.selectedObject && sessionProxy.selectedObject.id == itemVO.id )
					return;
				
				objectVO = new ObjectVO( sessionProxy.selectedPage, itemVO.typeVO );
				objectVO.setID( itemVO.id );
				objectVO.parentID = itemVO.parent.id;
			}

			sendNotification( ApplicationFacade.SELECT_OBJECT, objectVO );
		}
	}
}