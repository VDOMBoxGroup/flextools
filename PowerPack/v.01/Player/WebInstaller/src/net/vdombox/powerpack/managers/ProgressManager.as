package net.vdombox.powerpack.managers
{

import flash.desktop.NativeApplication;
import flash.display.DisplayObject;
import flash.display.NativeWindowSystemChrome;
import flash.display.NativeWindowType;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.MouseEvent;
import flash.events.OutputProgressEvent;
import flash.events.ProgressEvent;
import flash.filesystem.FileStream;

import mx.containers.Box;
import mx.containers.ControlBar;
import mx.containers.HBox;
import mx.containers.TitleWindow;
import mx.containers.VBox;
import mx.controls.Button;
import mx.controls.Label;
import mx.controls.ProgressBar;
import mx.controls.ProgressBarMode;
import mx.controls.Text;
import mx.controls.TextArea;
import mx.core.Application;
import mx.core.Container;
import mx.core.EdgeMetrics;
import mx.core.Window;
import mx.events.MoveEvent;
import mx.events.ResizeEvent;
import mx.managers.PopUpManager;
import mx.managers.SystemManager;
import mx.skins.halo.ProgressBarSkin;

import net.vdombox.powerpack.customize.core.windowClasses.SuperStatusBar;
import net.vdombox.powerpack.lib.extendedapi.containers.SuperWindow;
import net.vdombox.powerpack.lib.extendedapi.controls.HDivider;
import net.vdombox.powerpack.menu.MenuGeneral;

public class ProgressManager extends EventDispatcher
{

	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------

	public static const STATUS_MODE : String = "status";
	public static const WINDOW_MODE : String = "window";
	public static const PANEL_MODE : String = "panel";
	public static const DIALOG_MODE : String = "dialog";

	private static var defaultCaptions : Object = {
		progress_title : "Processing...",
		progress_details : "Details",
		progress_desc : "Processing...",
		progress_full_desc : "Processing...",
		progress_label : "%3%%",
		progress_full_label : "Current progress %3%%",
		run_in_background : "run in background",
		details : "Details"
	}

	/**
	 *  @private
	 */
	private static var _instance : ProgressManager;

	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public static function getInstance() : ProgressManager
	{
		if ( !_instance )
		{
			_instance = new ProgressManager();
		}

		return _instance;
	}

	/**
	 *  @private
	 */
	public static function get instance() : ProgressManager
	{
		return getInstance();
	}

	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	public function ProgressManager()
	{
		super();

		if ( _instance )
			throw new Error( "Instance already exists." );

		_sm = Application.application.systemManager.topLevelSystemManager;
		_win = Application.application;

		LanguageManager.setSentences( defaultCaptions );
		createChildren();
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------	

	private var _sm : SystemManager;
	private var _win : Object;

	private var _window : TitleWindow;
	private var _dialog : SuperWindow;
	private var _winBox : Box;
	private var _panel : VBox;
	private var _statusBar : HBox;
	private var _bar : ProgressBar;

	private var _isShown : Boolean;
	private var _showProgress : Boolean;
	private var positioned : Boolean;

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  source
	//----------------------------------

	/**
	 *  @default
	 */
	public static function get source() : Object
	{
		return instance._bar.source;
	}

	/**
	 *  @private
	 */
	public static function set source( value : Object ) : void
	{
		if ( instance._bar.source != value )
		{
			var mode : String = ProgressBarMode.MANUAL;

			if ( value is FileStream )
			{
				mode = ProgressBarMode.MANUAL;

				(value as FileStream).addEventListener( ProgressEvent.PROGRESS, onFileStreamProgress );
				(value as FileStream).addEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onFileStreamProgress );

				function onFileStreamProgress( event : Event ) : void
				{
					var stream : FileStream = event.target as FileStream;

					if ( event is OutputProgressEvent )
					{
						instance._bar.setProgress( OutputProgressEvent( event ).bytesTotal, OutputProgressEvent( event ).bytesPending + OutputProgressEvent( event ).bytesTotal );
					}
					else
					{
						instance._bar.setProgress( ProgressEvent( event ).bytesLoaded, ProgressEvent( event ).bytesTotal );
					}

					if ( instance._bar.parent )
						instance._bar.validateNow();
				}

				(value as FileStream).addEventListener( IOErrorEvent.IO_ERROR, onFileStreamClose );
				(value as FileStream).addEventListener( Event.CLOSE, onFileStreamClose );
				(value as FileStream).addEventListener( Event.COMPLETE, onFileStreamClose );

				function onFileStreamClose( event : Event ) : void
				{
					var stream : FileStream = event.target as FileStream;
					stream.removeEventListener( ProgressEvent.PROGRESS, onFileStreamProgress );
					stream.removeEventListener( OutputProgressEvent.OUTPUT_PROGRESS, onFileStreamProgress );
					stream.removeEventListener( IOErrorEvent.IO_ERROR, onFileStreamClose );
					stream.removeEventListener( Event.CLOSE, onFileStreamClose );
					stream.removeEventListener( Event.COMPLETE, onFileStreamClose );

					instance._bar.dispatchEvent( new Event( Event.COMPLETE ) );
				}
			}
			else if ( value is EventDispatcher )
			{
				mode = ProgressBarMode.EVENT;
			}
			else if ( value && source.hasOwnProperty( 'bytesLoaded' ) && source.hasOwnProperty( 'bytesTotal' ) )
			{
				mode = ProgressBarMode.POLLED;
			}

			instance._bar.mode = mode;
			instance._bar.source = value;
		}
	}

	//----------------------------------
	//  viewMode
	//----------------------------------

	/**
	 *  @private
	 */
	private var _viewMode : String;

	/**
	 *  @private
	 */

	/**
	 *  @default
	 */
	public static function get viewMode() : String
	{
		return instance._viewMode;
	}

	/**
	 *  @private
	 */
	public static function set viewMode( value : String ) : void
	{
		show( value, instance._showProgress );
	}

	//----------------------------------
	//  progressBar
	//----------------------------------

	/**
	 *  @default
	 */
	public static function get bar() : ProgressBar
	{
		return instance._bar;
	}

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	public static function start( viewMode : String = null, showProgress : Boolean = true ) : void
	{
		instance._bar.setProgress( 0, 100 );
		show( viewMode, showProgress );
	}

	public static function step( value : uint, total : uint = 0 ) : void
	{
		instance._bar.setProgress( instance._bar.value + value, total > 0 ? total : instance._bar.maximum );
		instance._bar.validateNow();
	}

	public static function show( viewMode : String = null, showProgress : Boolean = true ) : void
	{
		if ( !viewMode )
			viewMode = instance._viewMode;

		if ( viewMode == instance._viewMode && instance._isShown && instance._showProgress == showProgress )
			return;

		if ( instance._isShown )
			hide();

		if ( instance._bar.parent )
			Container( instance._bar.parent ).removeChild( instance._bar );

		switch ( viewMode )
		{
			case PANEL_MODE:
				instance._bar.label = LanguageManager.sentences['progress_full_label'];
				instance._bar.percentWidth = 100;
				instance._bar.direction = "right";
				instance._bar.labelPlacement = "top";
				instance._bar.setStyle( "barSkin", ProgressBarSkin );
				if ( showProgress )
					instance._panel.addChild( instance._bar );
				/* TODO: restore position or set default position */
				instance._panel.validateNow();
				break;

			case STATUS_MODE:
				if ( !instance._win.statusBar || !(instance._win.statusBar is SuperStatusBar) )
					break;
				instance._bar.label = LanguageManager.sentences['progress_label'];
				instance._bar.direction = "right";
				instance._bar.labelPlacement = "center";
				instance._bar.setStyle( "fontSize", 9 );
				instance._bar.width = 50;
				instance._bar.setStyle( "barSkin", ProgressBarSkin );
				if ( showProgress )
					instance._statusBar.addChild( instance._bar );

				SuperStatusBar( instance._win.statusBar ).statusHBox.addChildAt( instance._statusBar, 0 );
				SuperStatusBar( instance._win.statusBar ).validateNow();
				break;

			case WINDOW_MODE:
				MenuGeneral.disable();

				instance._bar.label = LanguageManager.sentences['progress_full_label'];
				instance._bar.percentWidth = 100;
				instance._bar.direction = "right";
				instance._bar.labelPlacement = "top";
				instance._bar.setStyle( "barSkin", ProgressBarSkin );
				if ( showProgress )
					instance._winBox.addChildAt( instance._bar, 1 );

				instance._window.addChild( instance._winBox );

				var activeWin : Object = SuperWindow.getWindow( NativeApplication.nativeApplication.activeWindow );

				if ( !activeWin )
					activeWin = instance._win;

				PopUpManager.addPopUp( instance._window, activeWin as DisplayObject, true );
				PopUpManager.centerPopUp( instance._window );

				instance._window.validateNow();
				break;

			case DIALOG_MODE:
			default:
				instance._bar.label = LanguageManager.sentences['progress_full_label'];
				instance._bar.percentWidth = 100;
				instance._bar.direction = "right";
				instance._bar.labelPlacement = "top";
				instance._bar.setStyle( "barSkin", ProgressBarSkin );
				if ( showProgress )
					instance._winBox.addChildAt( instance._bar, 1 );

				instance._dialog = new SuperWindow( NativeApplication.nativeApplication.activeWindow );
				instance._dialog.type = NativeWindowType.LIGHTWEIGHT;
				instance._dialog.systemChrome = NativeWindowSystemChrome.NONE;
				//instance._dialog.transparent = true;
				instance._dialog.title = LanguageManager.sentences['progress_title'];
				instance._dialog.showTitleBar = false;
				instance._dialog.showStatusBar = false;
				instance._dialog.showGripper = false;
				instance._dialog.resizable = false;
				instance._dialog.setStyle( "borderStyle", "none" );
				instance._dialog.setStyle( 'cornerRadius', 0 );
				instance._dialog.setStyle( 'backgroundAlpha', 0 );
				instance._dialog.minWidth = 0;
				instance._dialog.minHeight = 0;

				instance._dialog.startPosition = SuperWindow.POS_CENTER_SCREEN;
				instance._dialog.modal = true;

				instance._dialog.addChild( instance._winBox );

				instance._dialog.open();

				instance.doResizeDialog();

				var parent : Window = SuperWindow.getWindow( instance._dialog.parentWindow );

				if ( parent )
					parent.validateNow();
				else
					Application.application.validateNow();

				instance._dialog.activate();

				viewMode = DIALOG_MODE;
				break;
		}

		instance._viewMode = viewMode;
		instance._isShown = true;
		instance._showProgress = showProgress;
		instance.dispatchEvent( new Event( "modeChange" ) );
	}

	public static function hide() : void
	{
		if ( !instance._isShown )
			return;

		switch ( instance._viewMode )
		{
			case WINDOW_MODE:
				MenuGeneral.enable();
				var parent : Object = instance._window;

				if ( instance._winBox.parent )
					instance._winBox.parent.removeChild( instance._winBox );

				PopUpManager.removePopUp( instance._window );

				if ( parent )
					parent.validateNow();
				else
					instance._win.validateNow();

				break;

			case DIALOG_MODE:
				if ( instance._dialog && !instance._dialog.closed )
				{
					instance._dialog.visible = false;
					instance._dialog.includeInLayout = false;

					if ( instance._winBox.parent )
						instance._winBox.parent.removeChild( instance._winBox );

					parent = SuperWindow.getWindow( instance._dialog.parentWindow );
					instance._dialog.nativeWindow.close();

					if ( parent )
						parent.validateNow();
					else
						instance._win.validateNow();

					instance._dialog = null;
				}
				break;

			case PANEL_MODE:
				/* TODO: memorize position before close */
				if ( instance._panel.parent )
				{
					instance._panel.parent.removeChild( instance._panel );
					instance._panel.validateNow();
				}
				break;

			case STATUS_MODE:
				if ( instance._statusBar.parent )
				{
					instance._statusBar.parent.removeChild( instance._statusBar )
					instance._statusBar.validateNow();
				}
				break;
		}

		instance._isShown = false;
	}

	public static function complete() : void
	{
		hide();
		source = null;
	}

	protected function createChildren() : void
	{
		if ( !_bar )
		{
			_bar = new ProgressBar();
			_bar.minimum = 0;
			_bar.maximum = 100;
			_bar.mode = ProgressBarMode.MANUAL;
			_bar.addEventListener( Event.COMPLETE, onComplete );

			function onComplete( event : Event ) : void
			{
				_bar.validateNow();
				complete();
			}
		}
		if ( !_window )
		{
			_window = new TitleWindow();
			_window.showCloseButton = false;
			LanguageManager.bindSentence( 'progress_title', _window, 'title' )
			//_window.addEventListener(Event.RENDER, onWindowRender);
			//_winBox.addEventListener(MoveEvent.MOVE, moveHandler);	

			function onWindowRender( event : Event ) : void
			{
				if ( _dialog == null || _dialog.nativeWindow == null || _dialog.parent == null )
					PopUpManager.centerPopUp( _window );
			}
		}
		if ( !_winBox )
		{
			var box : VBox = new VBox();
			_winBox = box;
			_winBox.addEventListener( ResizeEvent.RESIZE, resizeHandler );
			//box.percentHeight = box.percentWidth = 100;
			_winBox.minWidth = 120;
			box.setStyle( "paddingLeft", 10 );
			box.setStyle( "paddingRight", 10 );
			box.setStyle( "paddingTop", 10 );
			box.setStyle( "paddingBottom", 10 );
			box.setStyle( "borderStyle", "1px solid 0x000000" );

			var txt1 : Text = new Text();
			txt1.text = LanguageManager.sentences['progress_full_desc'];

			var details : VBox = new VBox();
			details.setStyle( "paddingTop", 20 );
			details.percentHeight = details.percentWidth = 100;

			var divider : HDivider = new HDivider();
			LanguageManager.bindSentence( 'progress_details', divider )

			var txt : TextArea = new TextArea();
			txt.percentWidth = 100;
			txt.wordWrap = true;
			txt.editable = false;

			details.addChild( divider );
			details.addChild( txt );

			box.addChild( txt1 );
			//box.addChild(details);

			var controlBar : ControlBar = new ControlBar();
			controlBar.setStyle( "horizontalAlign", "right" );

			var btnHide : Button = new Button();
			LanguageManager.bindSentence( 'run_in_background', btnHide )
			btnHide.addEventListener( MouseEvent.CLICK, onBtnHideClick );

			function onBtnHideClick( event : MouseEvent ) : void
			{
				ProgressManager.viewMode = STATUS_MODE;
			}

			var btnCancel : Button = new Button();
			LanguageManager.bindSentence( 'cancel', btnCancel );
			btnCancel.addEventListener( MouseEvent.CLICK, onBtnCancelClick );

			function onBtnCancelClick( event : MouseEvent ) : void
			{
			}

			var btnDetails : Button = new Button();
			btnDetails.label = LanguageManager.sentences['details'];
			btnDetails.addEventListener( MouseEvent.CLICK, onBtnDetailsClick );

			function onBtnDetailsClick( event : MouseEvent ) : void
			{
				details.visible = !details.visible;
				details.includeInLayout = !details.includeInLayout;
			}

			//controlBar.addChild(btnHide);
			//controlBar.addChild(btnCancel);
			//controlBar.addChild(btnDetails);

			//box.addChild(controlBar);
		}
		if ( !_panel )
		{
			_panel = new VBox();
			_panel.percentWidth = _panel.percentHeight = 100;
			LanguageManager.bindSentence( 'progress_title', _panel )

			_panel.setStyle( "horizontalAlign", "center" );
			_panel.setStyle( "verticalAlign", "middle" );

			_panel.setStyle( "paddingLeft", 20 );
			_panel.setStyle( "paddingRight", 20 );

			var txt2 : Text = new Text();
			txt2.text = LanguageManager.sentences['progress_full_desc'];

			_panel.addChild( txt2 );
		}
		if ( !_statusBar )
		{
			_statusBar = new HBox();
			LanguageManager.bindSentence( 'progress_title', _statusBar )
			_statusBar.setStyle( "verticalAlign", "middle" );
			_statusBar.doubleClickEnabled = true;
			_statusBar.addEventListener( MouseEvent.DOUBLE_CLICK, onStatusDoubleClick );

			function onStatusDoubleClick( event : MouseEvent ) : void
			{
				ProgressManager.viewMode = WINDOW_MODE;
			}

			var label : Label = new Label();
			label.text = LanguageManager.sentences['progress_desc'];

			_statusBar.addChild( label );
		}
	}

	private function doResizeDialog() : void
	{
		_winBox.validateProperties();
		_winBox.validateSize();

		var edges : EdgeMetrics = _dialog.viewMetricsAndPadding;
		var size : Object = {	w : _winBox.width + _winBox.maxHorizontalScrollPosition + edges.left + edges.right,
			h : _winBox.height + _winBox.maxVerticalScrollPosition + edges.top + edges.bottom};

		_dialog.width = size.w;
		_dialog.height = size.h;

		positioned = true;

		_dialog.validateProperties();
		_dialog.validateSize();
		_dialog.setPosition();

		if ( _dialog.parent )
		{
			_dialog.validateNow();
		}
	}

	//--------------------------------------------------------------------------
	//
	//  Event Handlers
	//
	//--------------------------------------------------------------------------			

	/**
	 *  @private
	 */
	private function resizeHandler( event : ResizeEvent ) : void
	{
		if ( _dialog == null || _dialog.nativeWindow == null || _dialog.parent == null )
			return;

		if ( _winBox == null || _winBox.parent == null )
			return;

		doResizeDialog();
	}

	/**
	 *  @private
	 */
	private function moveHandler( event : MoveEvent ) : void
	{
		if ( _dialog == null || _dialog.nativeWindow == null || _dialog.parent == null )
			return;

		_dialog.nativeWindow.x += event.target.x - event.oldX
		_dialog.nativeWindow.y += event.target.y - event.oldY

		event.target.x = 3;
		event.target.y = 3;

		if ( !positioned )
		{
			positioned = true;
			_dialog.setPosition();
		}

		_dialog.validateNow();
	}

}
}