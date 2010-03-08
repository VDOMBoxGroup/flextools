package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var item : Item = notification.getBody() as Item;
			
			var mediatorName : String = ItemMediator.NAME + ApplicationFacade.DELIMITER + item.itemVO.id;

			if ( facade.hasMediator( mediatorName ) )
				facade.removeMediator( mediatorName );

			facade.registerMediator( new ItemMediator( item ) );
		}
	}
}