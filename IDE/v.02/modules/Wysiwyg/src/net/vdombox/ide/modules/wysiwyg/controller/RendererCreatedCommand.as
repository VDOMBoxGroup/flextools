package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var renderer : IRenderer = notification.getBody() as IRenderer;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			
			renderProxy.addRenderer( renderer );
			
			
			// on start wysiwyg we need to set transform marker for selected object: 
			// (we do it in VdomObjectEditorMediator, handler for ApplicationFacade.SELECTED_OBJECT_CHANGED msg )
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var selectedObject : IVDOMObjectVO = statesProxy.selectedObject as IVDOMObjectVO;
			
			if (selectedObject && renderer && renderer.vdomObjectVO && selectedObject.id == renderer.vdomObjectVO.id)
			{
				sendNotification( StatesProxy.SELECTED_OBJECT_CHANGED, selectedObject );
			}
		}
	}
}