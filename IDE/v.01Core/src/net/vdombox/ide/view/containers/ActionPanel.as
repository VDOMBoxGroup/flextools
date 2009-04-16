package net.vdombox.ide.view.containers
{
	import flash.display.DisplayObject;

	import mx.containers.ControlBar;
	import mx.containers.Panel;
	import mx.controls.Label;
	import mx.core.EdgeMetrics;
	import mx.core.UIComponent;

	public class ActionPanel extends Panel
	{
		private var _panelLabel : Label;
		private var _panelName : String;
		private var _panelNameChanged : Boolean;


		/**
		 *  Constructor.
		 */
		public function ActionPanel()
		{
			super();
			buttonMode = true;
		}

		public function get panelName() : String
		{
			return _panelName;
		}

		public function set panelName( name : String ) : void
		{
			_panelName = name.toUpperCase();
			;
			_panelNameChanged = true;
			invalidateProperties();
		}

		override protected function measure() : void
		{
			super.measure();

			measuredWidth = Math.max( measuredWidth, 100 );
			measuredHeight = 105;
		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			if ( _panelNameChanged )
			{
				_panelNameChanged = false;
				_panelLabel.text = _panelName;
			}
		}

		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{
			super.updateDisplayList( unscaledWidth, unscaledHeight );

			_panelLabel.move( 0, 0 );
		}

		override protected function createChildren() : void
		{
			super.createChildren();

			if ( !controlBar )
			{

				var tempBar : ControlBar = new ControlBar();
				tempBar.height = 13;


				_panelLabel = new Label();
				_panelLabel.percentWidth = 100;
				_panelLabel.styleName = 'actionPanlelLabel';

				controlBar = tempBar;
				_panelLabel.setStyle( 'paddingTop', -3 );

				controlBar.visible = false;

				tempBar.addChild( _panelLabel );
				rawChildren.addChild( DisplayObject( controlBar ) );
			}
		}

	}
}