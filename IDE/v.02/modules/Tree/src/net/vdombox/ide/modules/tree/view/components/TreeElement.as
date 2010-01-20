package net.vdombox.ide.modules.tree.view.components
{
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.events.IOErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.system.LoaderContext;
	import flash.utils.Timer;
	import mx.containers.Canvas;
	import mx.controls.Button;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.Text;
	import vdom.events.DataManagerEvent;
	import vdom.events.TreeEditorEvent;
	import vdom.managers.DataManager;
	import vdom.managers.FileManager;
	public class TreeElement extends Canvas
	{
		public function TreeElement( str : String = "" )
		{
			super();

			cnvUpLayer.clipContent = false;

			dataManager = DataManager.getInstance();

			initUpBody();
			initDownBody();
			updateRatio();

			isRedraw = true;

			addEventListener( MouseEvent.CLICK, endFormatinfHandler );
		}

		[Embed( source="assets/treeEditor/test/content_selected.png" )]
		[Bindable]
		public var _selected_content : Class;

		[Embed( source="assets/treeEditor/test/header_selected.png" )]
		[Bindable]
		public var _selected_header : Class;

		[Embed( source="assets/treeEditor/test/content.png" )]
		[Bindable]
		public var backGround : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="bt_start_page" )]
		[Bindable]
		public var bt_start_page : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="delete" )]
		[Bindable]
		public var delet : Class;

		public var drag : Boolean = true;

		[Embed( source="assets/treeEditor/test/header.png" )]
		[Bindable]
		public var header : Class;

		[Embed( source="assets/treeEditor/test/header_home.png" )]
		[Bindable]
		public var header_home : Class;

		[Embed( source="assets/treeEditor/test/header_home_selected.png" )]
		[Bindable]
		public var header_home_selected : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="line" )]
		[Bindable]
		public var line : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="menu" )]
		[Bindable]
		public var menu : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="minus" )]
		[Bindable]
		public var minus : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="plus" )]
		[Bindable]
		public var plus : Class;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="start_page" )]
		[Bindable]
		public var start_page : Class;

		private var _ID : String;

		/*      availabled      */

		private var _availabled : Boolean = true;

		private var _curPage : Boolean

		private var _ratio : Number = 0.8;

		/*      type ID resourse     */

		private var _resID : String;



		private var _resourceID : String = "";

		private var _startPager : Boolean;

		private var _type : Label;

		private var _xTo : Number = -1;

		private var _yTo : Number = -1;

		private var btDelete : Button;

		private var btLessen : Button;
		private var btLine : Button;

		private var cnvDownLayer : Canvas = new Canvas();

		private var cnvUpLayer : Canvas = new Canvas();

		private var dXtoX : Number = 0;

		private var dYtoY : Number = 0;

		private var dataManager : DataManager;

		[Embed( source="assets/treeEditor/treeEditor.swf", symbol="cube" )]
		[Bindable]
		private var defaultPicture : Class;

		private var delayTimer : Timer;

		private var fileManager : FileManager = FileManager.getInstance();

		private var image : Image;

		private var imgBackGround : Image;

		private var imgDelete : Image;

		private var imgLine : Image;

		private var imgMenu : Image;

		private var imgPlus : Image;

		private var imgSelected : Image;

		private var imgStart : Image;

		private var imgType : Image;

		private var imgheader : Image;



		private var isRedraw : Boolean;

		private var loader : Loader;

		private var loaderTypeRes : Loader = new Loader();

		private var min : Boolean = false;

		private var textArea : Text;

		private var txt : Label;

		public function get ID() : String
		{
			return _ID;
		}

		public function set ID( names : String ) : void
		{
			_ID = names;
		}

		public function set availabled( bl : Boolean ) : void
		{
//			trace("availabled"+ bl)
			_availabled = bl;
		}

		public function set current( data : Boolean ) : void
		{
			_curPage = data;

			if ( _curPage )
			{
				if ( _startPager )
					imgheader.source = header_home_selected;
				else
					imgheader.source = _selected_header;
				imgBackGround.source = _selected_content

			}
			else
			{
				if ( _startPager )
					imgheader.source = header_home;
				else
					imgheader.source = header;

				imgBackGround.source = backGround;
			}
		}

		public function get description() : String
		{
			return textArea.text;
		}

		public function set description( names : String ) : void
		{
			if ( names == "" )
				textArea.text = resourceManager.getString( "Tree", "no_description" );
			else
				textArea.text = resourceManager.getString( "Tree", "description" ) + ":\n";

			if ( names.length > 50 )
			{
				textArea.text += names.slice( 0, 50 ) + "...";
				textArea.toolTip = names;
			}
			else
			{
				textArea.text += names;
				textArea.toolTip = "";
			}
		}

		public function play() : void
		{
			var delay : Number = 1000;
			var repeatCount : int = 10;
			delayTimer = new Timer( 0, repeatCount );
			delayTimer.addEventListener( TimerEvent.TIMER, timerHandler );

			dXtoX = ( _xTo - this.x ) / repeatCount;
			dYtoY = ( _yTo - this.y ) / repeatCount;

			delayTimer.start();

		}

		public function set resource( data : Object ) : void
		{
			loader = new Loader();

			loader.contentLoaderInfo.addEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, loadError );

			var loaderContextInfo : LoaderContext = new LoaderContext();
			loaderContextInfo.allowLoadBytesCodeExecution = true;

			loader.loadBytes( data.data, loaderContextInfo );
		}

		public function get resourceID() : String
		{
			return _resourceID;
		}

		public function set resourceID( names : String ) : void
		{
			_resourceID = names;
			if ( _resourceID == "" )
				image.source = defaultPicture;
		}



		/*      select      */

		public function get select() : Boolean
		{
			return false;
		}

		public function set selected( data : Boolean ) : void
		{
			_startPager = data;


			if ( _curPage )
			{
				if ( _startPager )
					imgheader.source = header_home_selected;
				else
					imgheader.source = _selected_header;
			}
			else
			{
				if ( _startPager )
					imgheader.source = header_home;
				else
					imgheader.source = header;
			}
		}

		/*      sourseImg      */

		public function set sourseImg( obj : Bitmap ) : void
		{
			image.source = obj;
		}

		public function get state() : String
		{
			return min.toString();
		}

		public function set state( names : String ) : void
		{
			changeState( names == "true" );
		}

		public function get title() : String
		{
			return txt.text;
		}

		public function set title( names : String ) : void
		{
			txt.text = names;
		}

		public function get type() : String
		{
			return _type.text;
		}

		/*      type      */

		public function set type( names : String ) : void
		{
			_type.text = names;
		}

		public function get typeID() : String
		{
			return _resID;
		}

		public function set typeID( resID : String ) : void
		{
			_resID = resID;
			fileManager.loadResource( dataManager.currentApplicationId, _resID, this, "typeResourse" );
		}

		public function set typeResourse( data : Object ) : void
		{
			loaderTypeRes.contentLoaderInfo.addEventListener( Event.COMPLETE, loaderTypeResComplete );

			loaderTypeRes.loadBytes( data.data );
		}

		public function unSelect() : void
		{
			endFormatinfHandler( new MouseEvent( MouseEvent.CLICK ) );
		}

		public function set xTo( num : Number ) : void
		{
			_xTo = num;

		}

		override public function set y( value : Number ) : void
		{
			if ( super.y == value )
				return;

			super.y = value;

			if ( !isRedraw && value != 0 )
				dispatchEvent( new TreeEditorEvent( TreeEditorEvent.NEED_TO_SAVE ) );
		}

		public function set yTo( num : Number ) : void
		{
			_yTo = num;

		}

		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{

			super.updateDisplayList( unscaledWidth, unscaledHeight );
			if ( isRedraw )
			{

				dispatchEvent( new TreeEditorEvent( TreeEditorEvent.REDRAW_LINES, _ID ) );
				isRedraw = false;
			}
		}

		private function btLessenOut( muEvt : MouseEvent ) : void
		{
			this.drag = true;
		}

		// при нажатии кнопки свернуть
		private function changeState( blHide : Boolean ) : void
		{
			if ( min == blHide )
				return;

			if ( !blHide )
			{
				if ( contains( cnvDownLayer ) )
					removeChild( cnvDownLayer );
				imgPlus.source = plus;
			}
			else
			{
				addChild( cnvDownLayer );
				imgPlus.source = minus;
			}
			min = blHide;
			isRedraw = true;


		}

		private function deleteClickHandler( msEvt : MouseEvent ) : void
		{
			if ( !_availabled )
				return;

			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.DELETE, _ID ) );
		}

		private function initDownBody() : void
		{
			imgBackGround = new Image();
			imgBackGround.maintainAspectRatio = true;
			imgBackGround.scaleContent = true;

			imgBackGround.source = backGround;

			cnvDownLayer.addChild( imgBackGround );
			textArea = new Text();
			textArea.setStyle( "fontWeight", "bold" );

			textArea.focusEnabled = false;
			textArea.selectable = false;

			cnvDownLayer.addChild( textArea );

			image = new Image();
			image.source = defaultPicture;

			image.maintainAspectRatio = true;
			image.scaleContent = true;

			image.doubleClickEnabled = true;

			cnvDownLayer.addChild( image );



			_type = new Label();
			_type.text = "text  ";

			_type.setStyle( "fontWeight", "bold" );
			cnvDownLayer.addChild( _type );
		}

	
		private function initUpBody() : void
		{
			imgheader = new Image();
			imgheader.source = header;

			imgSelected = new Image();
			imgSelected.source = _selected_header;

			txt = new Label();
			txt.setStyle( "color", "#ffffff" );
			txt.setStyle( "fontWeight", "bold" );

			txt.buttonMode = true;
			txt.doubleClickEnabled = true;
			txt.addEventListener( MouseEvent.DOUBLE_CLICK, txtDoubleClickHandler )

			imgMenu = new Image();
			imgMenu.source = menu;

			imgLine = new Image();
			imgLine.source = line;
			imgLine.buttonMode = true;
			imgLine.toolTip = resourceManager.getString( "Tree", "create_line" ); //----

			imgLine.addEventListener( MouseEvent.CLICK, lineClickHandler );

			imgDelete = new Image();
			imgDelete.source = delet;
			imgDelete.buttonMode = true;
			imgDelete.toolTip = resourceManager.getString( "Tree", "delete" ); //---

			imgDelete.addEventListener( MouseEvent.CLICK, deleteClickHandler );

			imgPlus = new Image();
			imgPlus.source = plus;
			imgPlus.buttonMode = true;
			imgPlus.toolTip = resourceManager.getString( "Tree", "min_max" );

			imgPlus.addEventListener( MouseEvent.CLICK, plusClickHandler );

			imgStart = new Image();
			imgStart.source = bt_start_page;
			imgStart.buttonMode = true;
			imgStart.toolTip = resourceManager.getString( "Tree", "set_start_page" );

			imgStart.addEventListener( MouseEvent.CLICK, startPageClickHandler );

			imgType = new Image();
			imgType.maintainAspectRatio = true;
			imgType.scaleContent = true;

			cnvUpLayer.addChild( imgMenu );
			cnvUpLayer.addChild( imgPlus );
			cnvUpLayer.addChild( imgStart );
			cnvUpLayer.addChild( imgLine );
			cnvUpLayer.addChild( imgDelete );
			cnvUpLayer.addChild( imgheader );
			cnvUpLayer.addChild( txt );
			cnvUpLayer.addChild( imgType );

			cnvUpLayer.addEventListener( MouseEvent.MOUSE_DOWN, startDragHandler );
			cnvUpLayer.addEventListener( MouseEvent.MOUSE_UP, stopDragHandler )
			addChild( cnvUpLayer );


		}

		private function lineClickHandler( msEvt : MouseEvent ) : void
		{
			msEvt.stopPropagation();
			if ( !_availabled )
				return;

			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.START_DRAW_LINE, _ID ) );
		}

		private function loadComplete( evt : Event ) : void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loadError );

			image.source = loader.content;
		}


		private function loadError( evt : IOErrorEvent ) : void
		{
			loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, loadComplete );
			loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, loadError );
		}


		private function loaderTypeResComplete( evt : Event ) : void
		{
			loaderTypeRes.contentLoaderInfo.removeEventListener( Event.COMPLETE, loaderTypeResComplete );
			imgType.source = loaderTypeRes.content;
		}




		private function plusClickHandler( msEvt : MouseEvent ) : void
		{
			if ( !_availabled )
				return;

			changeState( !min );
			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.NEED_TO_SAVE ) );
		}



		private function startDragHandler( msEvt : MouseEvent ) : void
		{
			if ( !_availabled )
				return;

			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.START_REDRAW_LINES, _ID ) );
		}

		private function startPageClickHandler( msEvt : MouseEvent ) : void
		{
			if ( !_availabled )
				return;

			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.CHANGE_START_PAGE, _ID ) );
		}

		private function stopDragHandler( msEvt : MouseEvent ) : void
		{
			stopDrag();
			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.STOP_REDRAW_LINES, _ID ) );
		}

		private function textAreaClickHandler( msEvt : MouseEvent ) : void
		{
			msEvt.stopImmediatePropagation();
		}

		private function timerHandler( tmEvt : TimerEvent ) : void
		{
			this.x = this.x + dXtoX;
			this.y = this.y + dYtoY;

		}


		private function txtDoubleClickHandler( msEvt : MouseEvent ) : void
		{
			msEvt.stopImmediatePropagation();
			changeState( !min );
			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.NEED_TO_SAVE ) );
		}

		private function txtInpClickHandler( msEvt : MouseEvent ) : void
		{
			msEvt.stopImmediatePropagation();
		}

		private function txtInpKeyUpHandler( kbEvt : KeyboardEvent ) : void
		{
		}

		private function updateAttributeCompleteHandler( dmEvt : DataManagerEvent ) : void
		{
			dataManager.removeEventListener( DataManagerEvent.UPDATE_ATTRIBUTES_COMPLETE, updateAttributeCompleteHandler );
		}


		private function updateRatio() : void
		{
			imgSelected.width = 243 * _ratio;
			imgSelected.height = 30 * _ratio;

			imgMenu.x = 4;
			imgMenu.y = 5 * _ratio;
			imgMenu.width = 76 * _ratio;
			imgMenu.height = 14 * _ratio;

			txt.x = 30;
			txt.y = 12 * _ratio;
			txt.width = 210 * _ratio;


			imgLine.y = -7 * _ratio;
			imgLine.x = 25 * _ratio;
			imgLine.width = 10 * _ratio;
			imgLine.height = 10 * _ratio;

			//imgDelete 
			imgDelete.y = -7 * _ratio;
			imgDelete.x = 45 * _ratio;
			imgDelete.width = 10 * _ratio;
			imgDelete.height = 10 * _ratio;


			imgPlus.y = -7 * _ratio;
			imgPlus.x = 9 * _ratio;
			imgPlus.width = 10 * _ratio;
			imgPlus.height = 10 * _ratio;


			imgStart.y = -7 * _ratio;
			imgStart.x = 65 * _ratio;
			imgStart.width = 10 * _ratio;
			imgStart.height = 10 * _ratio;

			imgType.x = _ratio * 5;
			imgType.y = _ratio * 5;
			imgType.height = _ratio * 30;
			imgType.width = _ratio * 30;

			//	cnvUpLayer
			//-----------------------------------
			cnvDownLayer.y = 1 * _ratio;


			imgBackGround.y = 32 * _ratio;
			imgBackGround.x = -4;

			image.x = 10 * _ratio;
			image.y = 40 * _ratio;
			image.height = 100 * _ratio;
			image.width = 95 * _ratio;

			textArea.x = 115 * _ratio; // btButton.width;
			textArea.y = 42 * _ratio; //txt.height;
			textArea.width = 135 * _ratio;
			textArea.height = 73 * _ratio;

			_type.y = 115 * _ratio;
			_type.x = 140 * _ratio;
			_type.width = 100 * _ratio;
			_type.setStyle( "fontSize", "8" );
		}
	}
}