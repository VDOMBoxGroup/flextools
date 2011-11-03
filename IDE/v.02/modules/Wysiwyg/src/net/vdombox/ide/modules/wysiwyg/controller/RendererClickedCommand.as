package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererClickedCommand extends SimpleCommand
	{
		private var vdomObjectVO : IVDOMObjectVO 
		override public function execute( notification : INotification ) : void
		{
			var body : IRenderer = notification.getBody() as IRenderer;

			var renderVO : RenderVO = body.renderVO as RenderVO;

			if ( !renderVO )
				return;

			vdomObjectVO  = renderVO.vdomObjectVO;
			
			if ( alreadySelected )
				return;

			if ( vdomObjectVO is ObjectVO )
			{
				//sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, vdomObjectVO );
				
				sendNotification( ApplicationFacade.GET_OBJECT, { pageVO: ObjectVO(vdomObjectVO).pageVO, objectID: vdomObjectVO.id } );
			}
			else if ( vdomObjectVO is PageVO  )
				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, vdomObjectVO );
		}
		
		private function get alreadySelected(): Boolean
		{
			return (!sessionProxy.selectedObject && sessionProxy.selectedPage.id == vdomObjectVO.id)
			|| (sessionProxy.selectedObject && sessionProxy.selectedObject.id == vdomObjectVO.id)
			
		}
		private function  get sessionProxy() : SessionProxy
		{
			return facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
		}
	}
}