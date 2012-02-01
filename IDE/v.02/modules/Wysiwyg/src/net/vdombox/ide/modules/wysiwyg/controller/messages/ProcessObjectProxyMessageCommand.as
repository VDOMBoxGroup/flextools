package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var needForUpdateObject : Object = statesProxy.needForUpdate;

			var renderProxy : RenderProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			var objectVO : ObjectVO;
			if (body is ObjectVO)
				objectVO = body as ObjectVO;
			else
				objectVO = body.objectVO as ObjectVO;
			
			
			var renderer : *;

			switch ( target )
			{
				case PPMObjectTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
						sendNotification( ApplicationFacade.OBJECT_CREATED, body.newObjectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, body.objectVO );
						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, statesProxy.selectedPage );
						sendNotification( StatesProxy.SET_SELECTED_OBJECT,  body.newObjectVO );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, statesProxy.selectedPage );
						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, statesProxy.selectedPage );
						sendNotification( StatesProxy.SET_SELECTED_OBJECT, statesProxy.selectedPage );
					}

					break;
				}

				case PPMObjectTargetNames.ATTRIBUTES:
				{
					var vdomObjectAttributesVO : VdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, vdomObjectAttributesVO );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, vdomObjectAttributesVO );

						for ( renderer in needForUpdateObject )
						{
							var vdomObjectVO : IVDOMObjectVO = IRenderer( renderer ).vdomObjectVO;

							if ( vdomObjectVO && vdomObjectVO.id == vdomObjectAttributesVO.vdomObjectVO.id )
							{
								sendNotification( ApplicationFacade.GET_WYSIWYG, vdomObjectAttributesVO.vdomObjectVO );
								trace("sendNotification: ApplicationFacade.GET_WYSIWYG");
								break;
							}
						}
					}

					break;
				}

				case PPMObjectTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
					{
						for ( renderer in needForUpdateObject )
						{
							if ( IRenderer( renderer ).vdomObjectVO && IRenderer( renderer ).vdomObjectVO.id == objectVO.id )
							{
								delete needForUpdateObject[ renderer ];
							}
						}

						sendNotification( ApplicationFacade.WYSIWYG_GETTED, body );
					}

					break;
				}

				case PPMObjectTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.XML_PRESENTATION_GETTED, body );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						if ( objectVO )
						{
							sendNotification( ApplicationFacade.GET_WYSIWYG, objectVO )
							sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, objectVO )
						}

						sendNotification( ApplicationFacade.XML_PRESENTATION_SETTED, body );
					}

					break;
				}
					
				case PPMObjectTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( ApplicationFacade.OBJECT_NAME_SETTED, body );
						sendNotification( ApplicationFacade.GET_WYSIWYG, body )
					}
					break;
				}
					
				case PPMObjectTargetNames.COPY:
				{
					sendNotification( ApplicationFacade.GET_WYSIWYG, body );
					sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, body.pageVO );
					
					break;
				}
			}
		}
	}
}
