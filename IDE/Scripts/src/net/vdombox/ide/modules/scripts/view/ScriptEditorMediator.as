package net.vdombox.ide.modules.scripts.view
{
	import flash.events.KeyboardEvent;

	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;

	import net.vdombox.editors.parsers.base.BaseScriptEditor;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.events.ScriptAreaComponenrEvent;
	import net.vdombox.ide.common.model.PreferencesProxy;
	import net.vdombox.ide.common.model._vo.ColorSchemeVO;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.model.GoToPositionProxy;
	import net.vdombox.ide.modules.scripts.view.components.PreferencesWindow;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptEditorMediator";

		public function ScriptEditorMediator( viewComponent : Object )
		{
			var instanceName : String = NAME + viewComponent.editorID;
			super( instanceName, viewComponent );
			compliteSourceCode();
		}

		private var isActive : Boolean;

		private var goToDefenitionProxy : GoToPositionProxy;

		private var colorSchemeProxy : PreferencesProxy;

		public function get scriptEditor() : ScriptEditor
		{
			return viewComponent as ScriptEditor;
		}

		private function get currentVO() : Object
		{
			return scriptEditor.actionVO;
		}

		private function set currentVO( value : Object ) : void
		{
			scriptEditor.actionVO = value;
		}

		override public function onRegister() : void
		{
			goToDefenitionProxy = facade.retrieveProxy( GoToPositionProxy.NAME ) as GoToPositionProxy;
			colorSchemeProxy = facade.retrieveProxy( PreferencesProxy.NAME ) as PreferencesProxy;

			scriptEditor.setActionVO();

			updateColorScheme( false );
			updateIndentLines( false );
			updateFontSize( false );
			updateAutoShowAutoComplete();
			updateSelectKeyByAutoComplte();

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( PreferencesProxy.SELECTED_COLOR_SCHEME_CHANGE );
			interests.push( PreferencesProxy.SELECTED_FONT_SIZE_CHANGE );
			interests.push( PreferencesProxy.AUTO_SHOW_AUTOCOMPLETE_CHANGE );
			interests.push( PreferencesProxy.SELECT_KEY_BY_AUTOCOMPLETE_CHANGE );
			interests.push( PreferencesProxy.SHOW_INDENT_LINES_CHANGE );
			interests.push( Notifications.RENAME_IN_ACTION );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case PreferencesProxy.SELECTED_COLOR_SCHEME_CHANGE:
				{
					updateColorScheme();

					break;
				}

				case PreferencesProxy.SELECTED_FONT_SIZE_CHANGE:
				{
					updateFontSize();

					break;
				}

				case PreferencesProxy.AUTO_SHOW_AUTOCOMPLETE_CHANGE:
				{
					updateAutoShowAutoComplete();

					break;
				}

				case PreferencesProxy.SELECT_KEY_BY_AUTOCOMPLETE_CHANGE:
				{
					updateSelectKeyByAutoComplte();

					break;
				}

				case PreferencesProxy.SHOW_INDENT_LINES_CHANGE:
				{
					updateIndentLines();

					break;
				}

				case Notifications.RENAME_IN_ACTION:
				{
					if ( scriptEditor.actionVO != body.actionVO )
						return;

					scriptEditor.scriptEditor.scriptAreaComponent.renameByArray( body.words as Array, body.oldName as String, body.newName as String );

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			scriptEditor.addEventListener( ScriptEditorEvent.SAVE, scriptEditor_saveHandler, false, 0, true );
			scriptEditor.addEventListener( ScriptEditorEvent.OPEN_FIND, scriptEditor_openFindHandler, false, 0, true );
			scriptEditor.addEventListener( ScriptEditorEvent.OPEN_FIND_GLOBAL, scriptEditor_openFindGlobalHandler, false, 0, true );
			scriptEditor.addEventListener( ScriptEditorEvent.CLOSE_SCRIPT_EDITOR, scriptEditor_closeScriptEditorHandler, false, 0, true );
			scriptEditor.addEventListener( FlexEvent.CREATION_COMPLETE, compliteSourceCode, false, 0, true );
			scriptEditor.addEventListener( ScriptAreaComponenrEvent.RENAME, renameHandler, true, 0, true );
			scriptEditor.addEventListener( ScriptAreaComponenrEvent.GLOBAL_RENAME, globalRenameHandler, true, 0, true );

			scriptEditor.addEventListener( ScriptAreaComponenrEvent.GO_TO_DEFENITION, goToDefenitionHandler, true, 0, true );
			scriptEditor.addEventListener( ScriptEditorEvent.OPEN_PREFERENCES, openPreferences, false, 0, true );
		}

		private function removeHandlers() : void
		{
			scriptEditor.removeEventListener( ScriptEditorEvent.SAVE, scriptEditor_saveHandler );
			scriptEditor.removeEventListener( ScriptEditorEvent.OPEN_FIND, scriptEditor_openFindHandler );
			scriptEditor.removeEventListener( ScriptEditorEvent.OPEN_FIND_GLOBAL, scriptEditor_openFindGlobalHandler );
			scriptEditor.removeEventListener( ScriptEditorEvent.CLOSE_SCRIPT_EDITOR, scriptEditor_closeScriptEditorHandler );
			scriptEditor.removeEventListener( FlexEvent.CREATION_COMPLETE, compliteSourceCode );
			scriptEditor.removeEventListener( ScriptAreaComponenrEvent.RENAME, renameHandler, true );
			scriptEditor.removeEventListener( ScriptAreaComponenrEvent.GLOBAL_RENAME, globalRenameHandler, true );

			scriptEditor.removeEventListener( ScriptAreaComponenrEvent.GO_TO_DEFENITION, goToDefenitionHandler );
			scriptEditor.removeEventListener( ScriptEditorEvent.OPEN_PREFERENCES, openPreferences );
		}

		private function updateIndentLines( sendUpdate : Boolean = true ) : void
		{
			scriptEditor.scriptEditor.scriptAreaComponent.showIndentLines = colorSchemeProxy.showIndentLines;

			if ( sendUpdate )
				scriptEditor.scriptEditor.scriptAreaComponent.sendUpdate();
		}

		private function updateColorScheme( sendUpdate : Boolean = true ) : void
		{
			scriptEditor.scriptEditor.controller.colorScheme = colorSchemeProxy.selectedColorScheme;
			scriptEditor.scriptEditor.scriptAreaComponent.colorScheme = colorSchemeProxy.selectedColorScheme;

			if ( sendUpdate )
				scriptEditor.scriptEditor.scriptAreaComponent.sendUpdate();
		}

		private function updateFontSize( sendUpdate : Boolean = true ) : void
		{
			scriptEditor.scriptEditor.scriptAreaComponent.fontSize = colorSchemeProxy.selectedFontSize;

			if ( sendUpdate )
				scriptEditor.scriptEditor.scriptAreaComponent.sendUpdate();
		}

		private function updateAutoShowAutoComplete() : void
		{
			scriptEditor.scriptEditor.autoShowAutoComplete = colorSchemeProxy.autoShowAutoComplete;
		}

		private function updateSelectKeyByAutoComplte() : void
		{
			scriptEditor.scriptEditor.selectKeyByAutoComplte = colorSchemeProxy.selectKeyByAutoComplte;
		}

		private function compliteSourceCode( event : FlexEvent = null ) : void
		{
			var pythonScriptEditor : BaseScriptEditor = scriptEditor.scriptEditor;

			if ( !pythonScriptEditor )
				return;

			pythonScriptEditor.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler );
			//pythonScriptEditor.addEventListener( Event.CHANGE, validateObjectTypeVO );
			pythonScriptEditor.addedToStageHadler( null );
			pythonScriptEditor.loadSource( "", "zzz" );
			pythonScriptEditor.scriptAreaComponent.text = scriptEditor.script;

		}



		private function keyDownHandler( event : KeyboardEvent ) : void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
		}

		private function clearData() : void
		{
		}

		private function scriptEditor_saveHandler( event : ScriptEditorEvent ) : void
		{
			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO: currentVO, check: true } );
		}

		private function scriptEditor_openFindHandler( event : ScriptEditorEvent ) : void
		{
			sendNotification( Notifications.OPEN_FIND_SCRIPT, scriptEditor.scriptEditor.scriptAreaComponent.selectionText );
		}

		private function scriptEditor_openFindGlobalHandler( event : ScriptEditorEvent ) : void
		{
			sendNotification( Notifications.OPEN_FIND_GLOBAL_SCRIPT, scriptEditor.scriptEditor.scriptAreaComponent.selectionText );
		}

		private function scriptEditor_closeScriptEditorHandler( event : ScriptEditorEvent ) : void
		{
			sendNotification( Notifications.CLOSE_EDITOR, scriptEditor.actionVO );
		}

		private function renameHandler( event : ScriptAreaComponenrEvent ) : void
		{
			sendNotification( Notifications.OPEN_RENAME_IN_SCRIPT, { oldName: event.detail.oldName, actionVO: scriptEditor.actionVO, controller: event.detail.controller, global: false } );
		}

		private function globalRenameHandler( event : ScriptAreaComponenrEvent ) : void
		{
			sendNotification( Notifications.OPEN_RENAME_IN_SCRIPT, { oldName: event.detail.oldName, actionVO: scriptEditor.actionVO, controller: event.detail.controller, global: true } );
		}

		private function goToDefenitionHandler( event : ScriptAreaComponenrEvent ) : void
		{
			var detail : Object = event.detail;

			if ( !detail )
				return;

			goToDefenitionProxy.add( detail.libraryVO, detail.position, detail.length );

			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO: detail.libraryVO, check: false } );
		}

		private function openPreferences( event : ScriptEditorEvent ) : void
		{
			var preferencesWindow : PreferencesWindow = new PreferencesWindow();

			preferencesWindow.title = "Preferences";
			preferencesWindow.colorShemesList = new ArrayCollection( colorSchemeProxy.colorSchemes );
			preferencesWindow.fontSizeList = new ArrayCollection( colorSchemeProxy.fontSizes );
			preferencesWindow.selectedColorSheme = colorSchemeProxy.selectedColorScheme;
			preferencesWindow.selectedFontSize = colorSchemeProxy.selectedFontSize;
			preferencesWindow.autoShowAutocomplete = !colorSchemeProxy.autoShowAutoComplete;
			preferencesWindow.showIndentLines = colorSchemeProxy.showIndentLines;
			preferencesWindow.selectKeyByAutoComplte = colorSchemeProxy.selectKeyByAutoComplte;
			preferencesWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			preferencesWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );

			WindowManager.getInstance().addWindow( preferencesWindow, scriptEditor, true );

			function applyHandler( event : PopUpWindowEvent ) : void
			{
				colorSchemeProxy.selectedColorScheme = event.detail.colorScheme as ColorSchemeVO;
				colorSchemeProxy.selectedFontSize = event.detail.fontSize as uint;
				colorSchemeProxy.autoShowAutoComplete = !event.detail.autoShowAutoComplete;
				colorSchemeProxy.showIndentLines = event.detail.showIndentLines;
				colorSchemeProxy.selectKeyByAutoComplte = event.detail.selectKeyByAutoComplte;
				WindowManager.getInstance().removeWindow( preferencesWindow );
			}

			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( preferencesWindow );
			}
		}
	}
}