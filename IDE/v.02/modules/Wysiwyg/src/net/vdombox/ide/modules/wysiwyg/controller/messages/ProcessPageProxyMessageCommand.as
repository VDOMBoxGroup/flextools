package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.needForUpdate;

			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			
			var pageVO : PageVO;
			if (body is PageVO)
				pageVO = body as PageVO;
			else
				pageVO = body.pageVO as PageVO;
			var renderer : *;

			switch ( target )
			{
				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
						sendNotification( ApplicationFacade.OBJECT_CREATED, body.objectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, sessionProxy.selectedPage );
						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
						sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, sessionProxy.selectedPage );
					}
					else if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.OBJECT_GETTED, body.objectVO );
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, pageVO );
						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, pageVO );
						sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, pageVO );

					}
					break;
				}

				case PPMPageTargetNames.WYSIWYG:
				{
					if ( operation != PPMOperationNames.READ )
						break
						
					sendNotification( ApplicationFacade.WYSIWYG_GETTED, body );

					for ( renderer in needForUpdateObject )
					{
						if ( IRenderer( renderer ).vdomObjectVO && IRenderer( renderer ).vdomObjectVO.id == pageVO.id )
							delete needForUpdateObject[ renderer ];
					}

					break;
				}
					
				case PPMPageTargetNames.COPY:
				{
					sendNotification( ApplicationFacade.GET_WYSIWYG, body );
					
					break;
				}

				case PPMPageTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.XML_PRESENTATION_GETTED, body );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						if ( pageVO )
						{
							sendNotification( ApplicationFacade.GET_WYSIWYG, pageVO )
							sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, pageVO )
						}

						sendNotification( ApplicationFacade.XML_PRESENTATION_SETTED, body );
					}

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGE_STRUCTURE_GETTED, body );

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
					var vdomObjectAttributesVO : VdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, vdomObjectAttributesVO );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, vdomObjectAttributesVO );

						for ( renderer in needForUpdateObject )
						{
							if ( IRenderer( renderer ).vdomObjectVO.id == vdomObjectAttributesVO.vdomObjectVO.id )
							{
								sendNotification( ApplicationFacade.GET_WYSIWYG, vdomObjectAttributesVO.vdomObjectVO );
								break;
							}
						}
					}

					break;
				}
					
				case PPMPageTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.PAGE_NAME_SETTED, body );
					}
					break;
				}
					
			}
		}
	}
}
