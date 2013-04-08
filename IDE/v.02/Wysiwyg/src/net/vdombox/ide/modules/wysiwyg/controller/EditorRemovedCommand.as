package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class EditorRemovedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var editor : IEditor = notification.getBody() as IEditor;
		}
	}
}
