package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.editors.parsers.StructureDB;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SetStructureProxyCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			StructureDB.structure = notification.getBody() as XML;			
		}
	}
}