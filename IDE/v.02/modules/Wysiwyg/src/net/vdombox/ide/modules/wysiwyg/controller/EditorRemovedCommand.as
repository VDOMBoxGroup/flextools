package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.view.ObjectEditorMediator;
	import net.vdombox.ide.modules.wysiwyg.view.PageEditorMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageEditor;
	
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