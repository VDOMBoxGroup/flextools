package net.vdombox.ide.modules.wysiwyg.view
{
	import mx.core.UIComponent;
	
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	import net.vdombox.ide.modules.wysiwyg.view.components.ToolbarPanel;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.ImageToolbar;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.TextToolbar;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.RichTextToolbar;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.skins.spark.ToggleButtonSkin;
	
	public class ToolbarPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolbarPanelMediator";
		
		public function ToolbarPanelMediator( viewComponent : ToolbarPanel )
		{
			super( NAME, viewComponent );
		}
		
		private var sessionProxy : SessionProxy;
		
		private var currentToolbar : UIComponent;
		
		public function get toolbarPanel() : ToolbarPanel
		{
			return viewComponent as ToolbarPanel;
		}
		
		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();       
			
			interests.push( ApplicationFacade.SELECT_ITEM_REQUEST );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.SELECT_ITEM_REQUEST:
				{
					var itemVO : ItemVO = body.itemVO;
					var typeVO : TypeVO = itemVO.typeVO;

					currentToolbar
					
					toolbarPanel.removeAllElements();
					
					switch( typeVO.interfaceType )
					{
						case "1" :
						{
							break;
						}
							
						case "2" :
						{
							var richTextToolbar : RichTextToolbar = new RichTextToolbar();
							
							toolbarPanel.addElement( richTextToolbar );
							richTextToolbar.init( body as Item );
							
							break;
						}
							
						case "3" :
						{
							var textToolbar : TextToolbar = new TextToolbar();
							toolbarPanel.addElement( textToolbar );
							textToolbar.init( body as Item );
							
							break;
						}
							
						case "4" :
						{
							toolbarPanel.addElement( new ImageToolbar() );
							
							break;
						}
					}
					
					
					ImageToolbar
					TextToolbar
					ToggleButtonSkin
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
		}
		
		private function removeHandlers() : void
		{
		}
	}
}