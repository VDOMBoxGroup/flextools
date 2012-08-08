package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.MultiObjectsManipulationProxy;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var needForUpdateObject : Object = statesProxy.needForUpdate;

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
						sendNotification( Notifications.OBJECT_CREATED, body.objectVO );
						sendNotification( Notifications.GET_WYSIWYG, statesProxy.selectedPage );
						sendNotification( Notifications.GET_PAGE_SRUCTURE, statesProxy.selectedPage );
						sendNotification( StatesProxy.SET_SELECTED_OBJECT, statesProxy.selectedPage );
					}
					else if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.OBJECT_GETTED, body.objectVO );
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( Notifications.OBJECT_DELETED, body.objectVO );
						var rendererBase : RendererBase = renderProxy.getRendererByID( body.objectVO.id );
						if ( rendererBase.renderVO.parent && rendererBase.renderVO.parent.vdomObjectVO is ObjectVO )
						{
							var objectVO : ObjectVO = rendererBase.renderVO.parent.vdomObjectVO as ObjectVO;
							sendNotification( Notifications.GET_WYSIWYG, objectVO );
						}
						else
						{
							sendNotification( Notifications.GET_WYSIWYG, pageVO );
						}
						sendNotification( Notifications.GET_PAGE_SRUCTURE, pageVO );
						sendNotification( StatesProxy.SET_SELECTED_OBJECT, pageVO );

					}
					break;
				}

				case PPMPageTargetNames.WYSIWYG:
				{
					if ( operation != PPMOperationNames.READ )
						break
						
					sendNotification( Notifications.WYSIWYG_GETTED, body );

					for ( renderer in needForUpdateObject )
					{
						if ( IRenderer( renderer ).vdomObjectVO && IRenderer( renderer ).vdomObjectVO.id == pageVO.id )
							delete needForUpdateObject[ renderer ];
					}

					break;
				}
					
				case PPMPageTargetNames.COPY:
				{
					var multiObjectsManipulationProxy : MultiObjectsManipulationProxy = facade.retrieveProxy( MultiObjectsManipulationProxy.NAME ) as MultiObjectsManipulationProxy;
					
					if ( multiObjectsManipulationProxy.hasNextObjectForPaste() )
						multiObjectsManipulationProxy.pasteNextObject();
					
					sendNotification( Notifications.GET_WYSIWYG, body.pageVO );
					sendNotification( Notifications.GET_PAGE_SRUCTURE, body.pageVO );
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, body.objectVO );
					
					
					break;
				}

				case PPMPageTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( Notifications.XML_PRESENTATION_GETTED, body );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						var multiObjectsManipulationProxy : MultiObjectsManipulationProxy = facade.retrieveProxy( MultiObjectsManipulationProxy.NAME ) as MultiObjectsManipulationProxy;
						
						multiObjectsManipulationProxy.saveNextObject();
						
						if ( pageVO )
						{
							sendNotification( Notifications.GET_WYSIWYG, pageVO )
							sendNotification( Notifications.GET_PAGE_ATTRIBUTES, pageVO )
						}

						sendNotification( Notifications.XML_PRESENTATION_SETTED, body );
					}

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( Notifications.PAGE_STRUCTURE_GETTED, body );

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
					var vdomObjectAttributesVO : VdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

					if ( operation == PPMOperationNames.READ )
					{
						sendNotification( Notifications.PAGE_ATTRIBUTES_GETTED, vdomObjectAttributesVO );
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						sendNotification( Notifications.PAGE_ATTRIBUTES_GETTED, vdomObjectAttributesVO );

						for ( renderer in needForUpdateObject )
						{
							if ( IRenderer( renderer ).vdomObjectVO.id == vdomObjectAttributesVO.vdomObjectVO.id )
							{
								sendNotification( Notifications.GET_WYSIWYG, vdomObjectAttributesVO.vdomObjectVO );
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
						sendNotification( Notifications.PAGE_NAME_SETTED, body );
						sendNotification( Notifications.GET_WYSIWYG, body );
					}
					break;
				}
					
			}
		}
	}
}
