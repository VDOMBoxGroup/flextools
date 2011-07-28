package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.EditorVO;
	import net.vdombox.ide.modules.wysiwyg.view.VdomObjectEditorMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class XmlPresentationGettedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var vdomObjectVO : IVDOMObjectVO = body.pageVO ? body.pageVO : body.objectVO;

			var vdObjectVO : ObjectVO = null;
			
			if ( !vdomObjectVO )
				return;
			else if (vdomObjectVO is ObjectVO)
				vdObjectVO = vdomObjectVO as ObjectVO;
				

			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
			var vdomObjectXMLPresentationVO : VdomObjectXMLPresentationVO = body.vdomObjectXMLPresentationVO;
			
			var vdomObjectEditorMediator : VdomObjectEditorMediator;
			
			
			var mediator : VdomObjectEditorMediator;
			var mediatorName : String;
			
			for ( mediatorName in VdomObjectEditorMediator.instancesNameList )
			{
				mediator = facade.retrieveMediator( mediatorName ) as VdomObjectEditorMediator;
				
				try
				{
					if (vdObjectVO == null)
					{
						if( mediator.editorVO.vdomObjectVO.id == vdomObjectVO.id )
							mediator.vdomObjectXMLPresentationVO = vdomObjectXMLPresentationVO;
					}
					else
					{
						if( mediator.editorVO.vdomObjectVO.id == vdObjectVO.pageVO.id )
							mediator.vdomObjectXMLPresentationVO = vdomObjectXMLPresentationVO;
					}
				}
				catch( error : Error )
				{}
			}
			
			

//			if ( vdomObjectVO is PageVO )
//			{
//				for ( var pageEditorMediatorName : String in VdomObjectEditorMediator.instancesNameList )
//				{
//					vdomObjectEditorMediator = facade.retrieveMediator( pageEditorMediatorName ) as VdomObjectEditorMediator;
//
//					if ( vdomObjectEditorMediator.editorVO && vdomObjectEditorMediator.editorVO.vdomObjectVO.id== vdomObjectVO.id )
//					{
//						vdomObjectEditorMediator.vdomObjectXMLPresentationVO = vdomObjectXMLPresentationVO;
//						break;
//					}
//				}
//			}
//			else if ( vdomObjectVO is ObjectVO )
//			{
//				for ( var objectEditorMediatorName : String in VdomObjectEditorMediator.instancesNameList )
//				{
//					vdomObjectEditorMediator = facade.retrieveMediator( objectEditorMediatorName ) as VdomObjectEditorMediator;
//
//					if ( vdomObjectEditorMediator.editorVO && vdomObjectEditorMediator.editorVO.vdomObjectVO.id== vdomObjectVO.id )
//					{
//						vdomObjectEditorMediator.vdomObjectXMLPresentationVO = vdomObjectXMLPresentationVO;
//						break;
//					}
//				}
//			}
		}
	}
}