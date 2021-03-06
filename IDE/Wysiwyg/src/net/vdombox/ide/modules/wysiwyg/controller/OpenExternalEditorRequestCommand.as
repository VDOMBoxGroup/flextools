package net.vdombox.ide.modules.wysiwyg.controller
{
	import mx.core.UIComponent;

	import net.vdombox.ide.modules.wysiwyg.view.ExternalEditorWindowMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.externalEditor.ExternalEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.ExternalEditorWindow;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenExternalEditorRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var externalEditorWindow : ExternalEditorWindow = new ExternalEditorWindow();
			var externalEditor : ExternalEditor = notification.getBody() as ExternalEditor;

			var externalEditorWindowMediator : ExternalEditorWindowMediator = new ExternalEditorWindowMediator( externalEditorWindow );
			externalEditorWindowMediator.externalEditor = externalEditor;


			facade.registerMediator( externalEditorWindowMediator );

			/*
			   PopUpManager.addPopUp( externalEditorWindow, DisplayObject( externalEditor.parentApplication ), true );
			   PopUpManager.centerPopUp( externalEditorWindow );
			 */

			WindowManager.getInstance().addWindow( externalEditorWindow, UIComponent( externalEditor.parentApplication ), true );
		}
	}
}
