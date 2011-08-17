package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.needForUpdate;

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
						sendNotification( ApplicationFacade.GET_WYSIWYG, sessionProxy.selectedPage );
//						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
//						sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, sessionProxy.selectedPage );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, sessionProxy.selectedPage );
//						sendNotification( ApplicationFacade.GET_PAGE_SRUCTURE, sessionProxy.selectedPage );
//						sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, body.objectVO );
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
							if ( IRenderer( renderer ).vdomObjectVO.id == objectVO.id )
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
							sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, objectVO )
							sendNotification( ApplicationFacade.GET_WYSIWYG, objectVO )
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
					}
					break;
				}
			}
		}
	}
}
