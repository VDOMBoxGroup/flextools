package net.vdombox.ide.modules.tree.view.components
{
	import flash.events.MouseEvent;

	import mx.containers.Canvas;
	import mx.containers.VBox;
	import mx.controls.Image;
	import mx.controls.Label;
	import mx.controls.VRule;
	import mx.events.FlexEvent;

	public class ColorMenu extends VBox
	{

//		[Embed( source='assets/treeEditor/treeEditor.swf', symbol='rMenu' )]
//		[Bindable]
//		public var rMenu : Class;

		[Embed( source='assets/treeEditor/colored_button_all_levels.png' )]
		[Bindable]
		public var openEye : Class;

//		[Embed( source='assets/treeEditor/treeEditor.swf', symbol='closeEye' )]
//		[Bindable]
//		public var closeEye : Class;



		public var masLevels : Array;

		private var levels : Levels = new Levels();

		private var slctLevel : Number;

//		private var eye:Image;	
		private var eyeOpend : Boolean = true;

		private var textLabel : Label;

		public function ColorMenu()
		{
			addEventListener( FlexEvent.SHOW, showHandler );
			addEventListener( FlexEvent.HIDE, hideHandler );

			//TODO: implement function
			super();
			percentWidth = 100;
			setStyle( "verticalGap", "1" );
			setStyle( "backgroundColor", "0x999999" );

			var imgBackGround : Image = new Image();

//			imgBackGround.source = rMenu;
//			addChild(imgBackGround);
			slctLevel = 0;


			textLabel = new Label();
//				textLabel.text = ;
			//textLabel.x = ;
			textLabel.y = 2;
			textLabel.width = 190;
			textLabel.setStyle( "color", "0xFFFFFF" );
			textLabel.setStyle( 'fontWeight', "bold" );
			textLabel.setStyle( 'textAlign', 'center' );
//			addChild(textLabel);
		/*

		 */
		}

		private function showHandler( flEvt : FlexEvent ) : void
		{
			creatLevels();
		}

		private function hideHandler( flEvt : FlexEvent ) : void
		{
			removeLevels();
		}

		private function removeLevels() : void
		{
			for ( var i : int = 0; i < levels.length; i++ )
			{
				removeChild( masLevels[ i ] );
			}
			masLevels = [];
		}

		private function eyeClickHandler( msEvt : MouseEvent ) : void
		{

			eyeOpend = !eyeOpend;
			if ( eyeOpend )
			{
				desabledEye.visible = false;

			}
			else
			{
				desabledEye.visible = true;
			}

			for ( var i : String in masLevels )
			{
				masLevels[ i ].status = eyeOpend;
			}


		}

		private function creatLevels() : void
		{
			creatMainEye();

			masLevels = new Array();
			for ( var i : int = 0; i < levels.length; i++ )
			{
				masLevels[ i ] = new Level( levels.getLevel( i ) );
//				masLevels[i].y = i * 20 + 25;
//				masLevels[i].x = 2;

//				masLevels[ i ].addEventListener( TreeEditorEvent.HIDE_LINES, dispasher );
//				masLevels[ i ].addEventListener( TreeEditorEvent.SHOW_LINES, dispasher );
//				masLevels[ i ].addEventListener( TreeEditorEvent.SELECTED_LEVEL, selectedLevelHandler );
				addChild( masLevels[ i ] );
			}
			masLevels[ slctLevel ].select();
		}

		private var desabledEye : Canvas;

		private function creatMainEye() : void
		{
			var canv : Canvas = new Canvas();
			canv.percentWidth = 100;
			canv.height = 20;
			canv.setStyle( "backgroundColor", "#7c7c7c" );
			addChild( canv );

			var eye : Image = new Image();
			eye.x = 3;
			eye.y = 0;
//			eye.width = 20;
//			eye.height = 10;
			eye.source = openEye;
			eye.addEventListener( MouseEvent.CLICK, eyeClickHandler );
			canv.addChild( eye );

			desabledEye = new Canvas();
			desabledEye.graphics.beginFill( 0xAAAAAA );
			desabledEye.graphics.lineStyle( 1 );
			desabledEye.graphics.drawCircle( 0, 0, 6 );
			desabledEye.graphics.endFill();

			desabledEye.x = 12;
			desabledEye.y = 8;
			desabledEye.visible = false;
			desabledEye.addEventListener( MouseEvent.CLICK, eyeClickHandler );
			canv.addChild( desabledEye );

			var vLine : VRule = new VRule();
			vLine.height = 14;
			vLine.x = 23;
			vLine.y = 0;
			canv.addChild( vLine );

			var label : Label = new Label;
			label.text = "Hide/Show";
			label.x = 30;
			label.y = 0;
//			label.width = 120;
			label.setStyle( 'fontSize', "9" );
			label.setStyle( "color", "#FFFFFF" );
//			label.setStyle('textAlign', 'center');
			canv.addChild( label );

		}

		public function get selectedItem() : Object
		{
			return levels.getLevel( slctLevel );
		}

		public function get openedEyeOfSelectedLevel() : Boolean
		{
			return masLevels[ slctLevel ].status;
		}

		public function showLevel( level : String ) : Boolean
		{
			var intLevel : Number = Number( level );
			return masLevels[ intLevel ].status;
		}

//		private function selectedLevelHandler( trEvt : TreeEditorEvent ) : void
//		{
//			if ( slctLevel.toString() != trEvt.ID )
//			{
//				masLevels[ slctLevel ].unSelect();
//				slctLevel = Number( trEvt.ID );
//			}
//			dispatchEvent( new TreeEditorEvent( TreeEditorEvent.SELECTED_LEVEL, trEvt.ID ) );
//			//	trace('Color menu: ' +  slctLevel);
//		}

//		private function dispasher( treEvt : TreeEditorEvent ) : void
//		{
//			//	trace(treEvt);
//			dispatchEvent( new TreeEditorEvent( treEvt.type, treEvt.ID ) );
//		}

		public function set text( str : String ) : void
		{
			textLabel.text = str;
			creatLevels();
		}
	}
}