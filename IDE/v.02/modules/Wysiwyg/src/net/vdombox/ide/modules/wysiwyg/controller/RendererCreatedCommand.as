package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class RendererCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var item : ObjectRenderer = notification.getBody() as ObjectRenderer;
			
//			var mediatorName : String = ItemMediator.NAME + ApplicationFacade.DELIMITER + item.itemVO.id;
//
//			if ( facade.hasMediator( mediatorName ) )
//				facade.removeMediator( mediatorName );
//
//			facade.registerMediator( new ItemMediator( item ) );
		}
	}
}