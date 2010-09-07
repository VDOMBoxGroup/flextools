package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RenderVO;
	import net.vdombox.ide.modules.wysiwyg.view.ObjectEditorMediator;
	import net.vdombox.ide.modules.wysiwyg.view.PageEditorMediator;
	
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

			if ( vdomObjectVO is PageVO )
			{
				var pageEditorMediator : PageEditorMediator;

				for ( var pageEditorMediatorName : String in PageEditorMediator.instancesNameList )
				{
					pageEditorMediator = facade.retrieveMediator( pageEditorMediatorName ) as PageEditorMediator;

					if ( pageEditorMediator.pageVO && pageEditorMediator.pageVO.id == vdomObjectVO.id )
					{
						pageEditorMediator.renderVO = renderVO;
						break;
					}
				}
			}
			else if ( vdomObjectVO is ObjectVO )
			{
				var objectEditorMediator : ObjectEditorMediator;

				for ( var objectEditorMediatorName : String in ObjectEditorMediator.instancesNameList )
				{
					objectEditorMediator = facade.retrieveMediator( objectEditorMediatorName ) as ObjectEditorMediator;

					if ( objectEditorMediator.objectVO && objectEditorMediator.objectVO.id == vdomObjectVO.id )
					{
						objectEditorMediator.renderVO = renderVO;
						break;
					}
				}
			}
		}
	}
}