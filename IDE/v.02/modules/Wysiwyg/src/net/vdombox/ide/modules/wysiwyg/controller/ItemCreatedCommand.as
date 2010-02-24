package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.Item;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ItemCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var item : Item = notification.getBody() as Item;
			
			facade.registerMediator( new ItemMediator( item ) );
		}
	}
}