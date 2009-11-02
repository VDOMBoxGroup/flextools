package net.vdombox.ide.view.controls
{

	import mx.controls.Button;
	import mx.controls.ButtonLabelPlacement;
	import mx.core.IFlexDisplayObject;
	import mx.styles.ISimpleStyleClient;
	import flash.display.DisplayObject;
	import mx.core.mx_internal;

	use namespace mx_internal;

	[Style( name="shadeSkin", type = "Class", inherit = "no" )]

	public class ActionButton extends Button
	{

		[Inspectable( type="Boolean", defaultValue = "true" )]
		public var switched : Boolean = true;

		private var shadeSkin : IFlexDisplayObject;

		public function ActionButton()
		{

			super();

			labelPlacement = "bottom";
		}

		override protected function commitProperties() : void
		{

			super.commitProperties();

			if ( !initialized )
			{

				viewShade();
			}
		}

		private function viewShade() : void
		{

			shadeSkin = IFlexDisplayObject( getChildByName( 'shadeSkin' ) );

			if ( shadeSkin == null )
			{
				//get specific icon style
				var buttonShadeSkinClass : Class = Class( getStyle( 'shadeSkin' ) );
				//default to the more general icon style

				if ( buttonShadeSkinClass != null )
				{
					shadeSkin = IFlexDisplayObject( new buttonShadeSkinClass() );

					// Set its name so that we can find it in the future
					// using getChildByName().
					shadeSkin.name = 'shadeSkin';

					if ( shadeSkin is ISimpleStyleClient )
						ISimpleStyleClient( shadeSkin ).styleName = this;

					addChild( DisplayObject( shadeSkin ) );

						// Keep track of all skin children that have been created.
				}
			}
		}

		override mx_internal function layoutContents( unscaledWidth : Number, unscaledHeight : Number,
													  offset : Boolean ) : void
		{
			super.layoutContents( unscaledWidth, unscaledHeight, offset );

			if ( shadeSkin )
				setChildIndex( DisplayObject( shadeSkin ), numChildren - 1 );
		}

		override protected function updateDisplayList( unscaledWidth : Number, unscaledHeight : Number ) : void
		{

			super.updateDisplayList( unscaledWidth, unscaledHeight );

			if ( labelPlacement == ButtonLabelPlacement.BOTTOM )
			{

				textField.move( ( unscaledWidth - textField.width ) / 2 + 2, unscaledHeight -
								textField.height + 3 );
			}

			if ( shadeSkin )
			{

				shadeSkin.move( 1, 1 );
				shadeSkin.setActualSize( unscaledWidth, unscaledHeight - 15 );
			}
		}

		override public function set label( value : String ) : void
		{

			value = value.toUpperCase();
			super.label = value;
		}
	}
}