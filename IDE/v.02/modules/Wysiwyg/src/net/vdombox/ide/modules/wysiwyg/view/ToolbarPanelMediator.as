package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;

	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ToolbarEvent;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.ItemVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	import net.vdombox.ide.modules.wysiwyg.view.components.ToolbarPanel;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.ImageToolbar;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.RichTextToolbar;
	import net.vdombox.ide.modules.wysiwyg.view.components.toolbars.TextToolbar;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ToolbarPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolbarPanelMediator";

		public function ToolbarPanelMediator( viewComponent : ToolbarPanel )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var currentToolbar : Object;

		private var item : Item;

		public function get toolbarPanel() : ToolbarPanel
		{
			return viewComponent as ToolbarPanel;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			toolbarPanel.visible = false;
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
			interests.push( ApplicationFacade.MODULE_SELECTED );
			interests.push( ApplicationFacade.MODULE_DESELECTED );

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
					if ( currentToolbar )
					{
						toolbarPanel.removeAllElements();
						toolbarPanel.visible = false;
						toolbarPanel.includeInLayout = false;
						currentToolbar = null;
					}

					break;
				}

				case ApplicationFacade.SELECT_ITEM_REQUEST:
				{
					item = body as Item;

					var itemVO : ItemVO = item.itemVO;
					var typeVO : TypeVO = itemVO.typeVO;

					if ( currentToolbar )
					{
						currentToolbar.close();

						if ( !( currentToolbar is ImageToolbar ) )
						{
							sendNotification( ApplicationFacade.ITEM_TRANSFORMED, { item: currentToolbar.item,
												  attributes: currentToolbar.attributes } )
						}

						toolbarPanel.removeAllElements();
						toolbarPanel.visible = false;
						toolbarPanel.includeInLayout = false;
						
						currentToolbar = null;
					}



					if ( !item.editableComponent )
						return;

					switch ( typeVO.interfaceType )
					{
						case "1":
						{
							break;
						}

						case "2":
						{
							var richTextToolbar : RichTextToolbar = new RichTextToolbar();

							currentToolbar = richTextToolbar;
							toolbarPanel.addElement( richTextToolbar );
							richTextToolbar.init( item );

							break;
						}

						case "3":
						{
							var textToolbar : TextToolbar = new TextToolbar();

							currentToolbar = textToolbar;
							toolbarPanel.addElement( textToolbar );
							textToolbar.init( item );

							break;
						}

						case "4":
						{
							var imageToolbar : ImageToolbar = new ImageToolbar();

							currentToolbar = imageToolbar;
							toolbarPanel.addElement( imageToolbar );
							imageToolbar.init( item );

							break;
						}
					}

					if( currentToolbar )
					{
						toolbarPanel.visible = true
						toolbarPanel.includeInLayout = true;
					}
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			toolbarPanel.addEventListener( ToolbarEvent.IMAGE_CHANGED, imageChangedHandler, true );
		}

		private function removeHandlers() : void
		{
			toolbarPanel.removeEventListener( ToolbarEvent.IMAGE_CHANGED, imageChangedHandler, true );
		}

		private function imageChangedHandler( event : ToolbarEvent ) : void
		{
			var eventBody : Object = event.body;

			var attributeName : String = "value";

			var resourceVO : ResourceVO = new ResourceVO( item.itemVO.id );
			resourceVO.setID( currentToolbar.attributes[ 0 ].value.toString().substr( 5, 36 ) );

			sendNotification( ApplicationFacade.MODIFY_RESOURCE, { applicationVO: sessionProxy.selectedApplication,
								  resourceVO: resourceVO, attributeName: attributeName, operation: eventBody.operation,
								  attributes: eventBody.attributes } );
		}
	}
}