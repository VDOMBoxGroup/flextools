package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.collections.ArrayList;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectAttributesPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ObjectAttributesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ObjectAttributesMediator";
		
		public function ObjectAttributesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get objectAttributesPanel() : ObjectAttributesPanel
		{
			return viewComponent as ObjectAttributesPanel;
		}
		
		override public function onRegister() : void
		{
			addEventListeners();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( ApplicationFacade.MODULE_DESELECTED );
			
			interests.push( ApplicationFacade.TYPE_GETTED );
			
			interests.push( ApplicationFacade.PAGE_SELECTED );
			interests.push( ApplicationFacade.OBJECT_SELECTED );
			
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED );
			interests.push( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.MODULE_DESELECTED:
				{
					objectAttributesPanel.attributesList.dataProvider = null;
				}
					
				case ApplicationFacade.TYPE_GETTED:
				{	
					
					
					break;
				}
				
				case ApplicationFacade.PAGE_SELECTED:
				{	
					var pageVO : PageVO = body as PageVO;
					
					sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, pageVO );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_SELECTED:
				{	
					var objectVO : ObjectVO = body as ObjectVO;
					
					sendNotification( ApplicationFacade.GET_OBJECT_ATTRIBUTES, objectVO );
//					sendNotification( ApplicationFacade.GET_TYPE, objectVO.typeVO.id );
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
				{	
					objectAttributesPanel.attributesList.dataProvider = new ArrayList( body as Array );
					
					break;
				}
					
				case ApplicationFacade.OBJECT_ATTRIBUTES_GETTED:
				{	
					objectAttributesPanel.attributesList.dataProvider = new ArrayList( body as Array );
					
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			
		}
	}
}