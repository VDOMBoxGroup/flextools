package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.VdomObjectEditorMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class WysiwygGettedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var vdomObjectVO : IVDOMObjectVO = body.pageVO ? body.pageVO : body.objectVO;
			
			if ( !vdomObjectVO )
				return;

			var wysiwygXML : XML = body.wysiwyg;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			var renderVO : RenderVO = renderProxy.generateRenderVO( vdomObjectVO, wysiwygXML );

			var renderers : Array = renderProxy.getRenderersByVO( vdomObjectVO );
			var renderer : IRenderer;
			
			if( renderers && renderers.length != 0 )
			{
				for each( renderer in renderers )
				{
					renderer.renderVO = renderVO;
				}
				return;
			}
		
			var mediator : VdomObjectEditorMediator;
			var mediatorName : String;
			
			for ( mediatorName in VdomObjectEditorMediator.instancesNameList )
			{
				mediator = facade.retrieveMediator( mediatorName ) as VdomObjectEditorMediator;

				try
				{
					if( mediator.editorVO.vdomObjectVO.id == vdomObjectVO.id )
						mediator.editorVO.renderVO = renderVO;
				}
				catch( error : Error )
				{}
			}
		}
	}
}