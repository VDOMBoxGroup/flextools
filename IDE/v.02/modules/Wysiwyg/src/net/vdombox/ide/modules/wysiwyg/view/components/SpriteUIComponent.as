//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view.components
{
	import flash.display.Sprite;

	import mx.core.UIComponent;


	/**
	 *
	 * @author andreev ap
	 */
	public class SpriteUIComponent extends UIComponent
	{
		/**
		 * To convert Sprite to UIComponent
		 */
		public function SpriteUIComponent( sprite : Sprite )
		{
			//TODO: implement function
			super();

			explicitHeight = sprite.height;

			explicitWidth = sprite.height;

			addChild( sprite );

		}
	}
}
